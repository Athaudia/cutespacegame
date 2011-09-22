SLOTTYPEMAP = {:small_wep => "[Weapon]", :util => "[Util]"}
SLOTTYPEICON = {:small_wep => "border_weps.png", :util => "border_util.png"}
PZ = 2100

class ShopState < Chingu::GameState
	def initialize(ship)
		super
		@ship = ship
		@tick = 0
		@active_slot = 0
		@shipimg = Img.create(:x => 400, :y => 300, :img => ship.type[:img], :scale => 32, :alpha => 50)
		Chingu::Text.create("Shop", :x => 10, :y => 10, :factor_x => 2, :factor_y => 2)
		Chingu::Text.create("version: #{VERSION}", :x => 5, :y => 588-5)
		@slot_imgs = []
		@key_imgs = []
		@slot_txts = []
		@ship.type[:slots].each_with_index do |slot,i|
			name = SLOTTYPEMAP[slot[:type]]
			icon = SLOTTYPEICON[slot[:type]]
			if @ship.modules[i]
				mod = @ship.modules[i]
				name = mod.type[:name]
				icon = mod.type[:icon]
			end
			keys = @ship.keys[i].map{|k| {true => 255, false => 25}[k]}
			if @ship.modules[i] == nil or @ship.modules[i].passive then keys = [0,0,0,0] end
			@key_imgs << [Img.create(x: 50-5, y:108-5+30*i, img: "keyh.png", scale: 2, alpha: keys[0]),
										Img.create(x: 50+5, y:108-5+30*i, img: "keyj.png", scale: 2, alpha: keys[1]),
										Img.create(x: 50-5, y:108+5+30*i, img: "keyk.png", scale: 2, alpha: keys[2]),
										Img.create(x: 50+5, y:108+5+30*i, img: "keyl.png", scale: 2, alpha: keys[3])]
			@slot_txts << Chingu::Text.create(name, :x => 40+30, :y => 100+30*i)
			@slot_imgs << Img.create(:x => 20, :y => 108+30*i, :img => icon, :scale => 2)
		end

	$weapons.each_with_index do |wep,i|
	  Img.create :x => 300+30*(i%16), :y => 108+30*(i/16), :img => wep[:icon], :scale => 2
	end

		$utils.each_with_index do |util,i|
			Img.create :x => 300+30*((i+$weapons.size)%16), :y => 108+30*((i+$weapons.size)/16), :img => util[:icon], :scale => 2
		end

		$ships.each_with_index do |ship,i|
			Img.create :x => 300+30*((i+$weapons.size+$utils.size)%16), :y => 108+30*((i+$weapons.size+$utils.size)/16), :img => ship[:img], :scale => 2
		end

		self.input = {:esc => :pop_game_state}
	end

	def update
		@t = nil
		if $window.mouse_x >= 300-16 and $window.mouse_y >= 108-16
			tx = ($window.mouse_x-(300-16)).to_i/30
			ty = ($window.mouse_y-(108-16)).to_i/30
			if tx < 16 then	@t = tx+ty*16 end
			if @t and @t >= $weapons.size + $utils.size + $ships.size then @t = nil end
		elsif $window.mouse_x <= 33 and $window.mouse_y >= 108-16
			@t = ($window.mouse_y-(108-16)).to_i/30	+ 10000
			if @t >= @ship.type[:slots].size + 10000 then @t = nil end
		elsif $window.mouse_x <= 63 and $window.mouse_y >= 108-16
			@t = ($window.mouse_y-(108-16)).to_i/15*2+($window.mouse_x-(33)).to_i/15 + 10100
			if @t >= @ship.type[:slots].size*4 + 10100 then @t = nil end
		end

		if @t != @last_t
			@popup and @popup.destroy
			if @t and @t < 10000
				if @t < $weapons.size
					w = Weapon.new(:type => $weapons[@t])
					price = $weapons[@t][:price]
					curmodprice = 0
					if @ship.modules[@active_slot] then curmodprice = @ship.modules[@active_slot].type[:price] end
					price_diff = curmodprice - price
					@popup = Popup.create(:w => 200, :h => 160, :text => [
					{:x=>10,:y=>10,:text=>$weapons[@t][:name]},
					{:x=>10,:y=>30,:text=>"Dmg: " + w.dmg.to_s},
					{:x=>10,:y=>50,:text=>"RPM: " + w.rpm.to_s},
					{:x=>10,:y=>70,:text=>"Dps: " + w.dps.to_s},
					{:x=>10,:y=>90,:text=>"Range: " + w.range.to_s},
					{:x=>190,:y=>110,:text=>"$" + price.to_s, :align=>:right},
					if price_diff < 0
						{:x=>190,:y=>130,:text=>"-$" + price_diff.abs.to_s, :align=>:right, :col=>0xffff0000}
					else
						{:x=>190,:y=>130,:text=>"$" + price_diff.to_s, :align=>:right, :col=>0xff00ff00}
					end
					])
				elsif @t < $weapons.size + $utils.size
					util = $utils[@t - $weapons.size]
					@popup = Popup.create(:w => 200, :h => 140, :text =>[
					{x:10, y:10, text: util[:name]}
					])
				elsif @t < $weapons.size + $utils.size + $ships.size
					ship = $ships[@t - $weapons.size - $utils.size]
					@popup = Popup.create(:w => 200, :h => 140, :text =>[
					{x:10, y:10, text: ship[:name]}
					])
				end
			elsif @t and @t < 10100
				slot = @ship.type[:slots][@t-10000]
				mod = @ship.modules[@t-10000]
	#				if mt then mt = mt.type end
	#		if mt and mt[:type] != slot[:type] then mt = nil end
				if mod
					case slot[:type]
					when :small_wep
						w = Weapon.new(:type => mod.type)
						price = mod.type[:price]
						@popup = Popup.create(:w => 200, :h => 140, :text => [
						{:x=>10,:y=>10,:text=>mod.type[:name]},
						{:x=>10,:y=>30,:text=>"Dmg: " + w.dmg.to_s},
						{:x=>10,:y=>50,:text=>"RPM: " + w.rpm.to_s},
						{:x=>10,:y=>70,:text=>"Dps: " + w.dps.to_s},
						{:x=>10,:y=>90,:text=>"Range: " + w.range.to_s},
						{:x=>190,:y=>110,:text=>"$" + price.to_s, :align=>:right},
						])
					end
				end
			end
			@last_t = @t
		end


		if @popup
			@popup.x, @popup.y = $window.mouse_x+10, $window.mouse_y+10
			@popup.update
		end

		mb = $window.button_down?(Gosu::MsLeft)
		if mb and @t
			if @t < 10000
				if @t < $weapons.size + $utils.size
					mod = if @t < $weapons.size then type=:small_wep;$weapons[@t] else type=:util;$utils[@t-$weapons.size] end
					price = mod[:price]
					curmodprice = 0
					if @ship.modules[@active_slot] then curmodprice = @ship.modules[@active_slot].type[:price] end
					price_diff = curmodprice - price
					if $money >= -price_diff and type == @ship.type[:slots][@active_slot][:type]
						if @t < $weapons.size
							@ship.modules[@active_slot] = Weapon.new({:type=>$weapons[@t], :bullet_class=>PlayerBullet, :off => @ship.type[:slots][@active_slot][:off], :ship => @ship})
							icon = $weapons[@t][:icon]
							name = $weapons[@t][:name]
						else
							@ship.modules[@active_slot] = Util.new({:type=>$utils[@t-$weapons.size], :ship => @ship})
							icon = $utils[@t-$weapons.size][:icon]
							name = $utils[@t-$weapons.size][:name]
						end
						@slot_imgs[@active_slot].destroy
						@slot_imgs[@active_slot] = Img.create(:x => @slot_imgs[@active_slot].x, :y => @slot_imgs[@active_slot].y, :img => icon, :scale => 2)
						@slot_txts[@active_slot].destroy
						@slot_txts[@active_slot] = Chingu::Text.create(:x => @slot_txts[@active_slot].x, :y => @slot_txts[@active_slot].y, :text => name)
						if @ship.modules[@active_slot] == nil or @ship.modules[@active_slot].passive
							4.times{|i| @key_imgs[@active_slot][i].alpha = 0}
						else
							4.times{|i| @key_imgs[@active_slot][i].alpha = {true => 255, false => 25}[@ship.keys[@active_slot][i]]}
						end
						$money += price_diff
					end
				elsif @t < $weapons.size + $utils.size + $ships.size
					ship = $ships[@t-$weapons.size-$utils.size]
					@ship.upgrade ship
					pop_game_state
					push_game_state ShopState.new(@ship)
				end
			else
				t = @t
				if @t >= 10100
					tt = @t-10100
					if not @lmb then @ship.keys[tt/4][t%4] = !@ship.keys[tt/4][tt%4] end
					@key_imgs[tt/4][t%4].alpha = {true => 255, false => 25}[@ship.keys[tt/4][tt%4]] unless @ship.modules[tt/4] == nil or @ship.modules[tt/4].passive
					t = (@t-10100)/4+10000
				end
				@slot_imgs[@active_slot].alpha = 255
				@active_slot = t - 10000
			end
		end

		@lmb = mb
		@slot_imgs[@active_slot].alpha = (Math.sin(@tick/10.0)+1)*127
		@tick += 1
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		super
		Image["cursor.png"].draw $window.mouse_x-9, $window.mouse_y-9, 99999, 2, 2
	end
end
