$startuptime = Time.now
$config = {:stars => true}
$config = {:stars => :light}
#$config = {:stars => false}
#require 'gosu'
require 'chingu'
require 'texplay'
include Gosu
$points = 0
$money = 0
$tick = 0

class Float
	def to_radian
		self * 2 * Math::PI / 360
	end
end

class Main < Chingu::Window
	def initialize
		super 800, 600, false
		retrofy
		push_game_state Game
	end
	def update
		super
		$window.caption = "Fps: #{$window.fps} Score: #{$points} Money: $#{$money}"
	end
end

class Img < Chingu::GameObject
	def initialize(options)
		super
		@image = Image[options[:img]]
		if options[:scale]
			self.scale = options[:scale]
		else
			self.scale = 2
		end
	end
end

class Explosion < Chingu::GameObject
	def initialize(options)
		super
		@image = Image["exp001.png"]
		self.scale = 1
	end

	def update
		self.alpha -= 5
		self.scale *= 1.1
		if self.alpha <= 0 then destroy end
	end
end

class Ship < Chingu::GameObject
	traits :velocity, :collision_detection, :bounding_circle
	attr_reader :type, :modules
	def initialize(options)
		super
		@type = options[:type]
		@image = Image[@type[:img]]
		self.scale = 2
		@rs = 0.0
		@faccel = 0.1
		@baccel = 0.05
		@rspeed = 1
		@saccel = 0.05
		@modules = [Weapon.new(:type => $weapons[0], :bullet_class => options[:bullet_class], :off => @type[:slots][0][:off])]
		@health = @type[:armor]
		self.angle = 0.0
		cache_bounding_circle
	end

	def upgrade(type)
		w = (self.worth or 0)
		$money += w
		@modules = []
		@type = type
		if @health > @type[:armor] then @health = @type[:armor] end
	end

	def worth
		@modules.map {|m| if m then m.type[:price] else 0 end}.inject {|a,b| a+b}
	end

	def update
		self.angle += @rs
		@rs *= 0.8
		@velocity_x *= 0.99
		@velocity_y *= 0.99
		if @x < 0 or @x > 2999
			@x = @previous_x
			@velocity_x *= -0.8
		end
		if @y < 0 or @y > 2999
			@y = @previous_y
			@velocity_y *= -0.8
		end
		@modules.each {|w| w.update}
	end

	def shoot
		rca = [0,0]
		@type[:slots].each_with_index do |m,i|
			if [:small_wep].include?(m[:type]) and @modules[i]
				rc = @modules[i].shoot(@x, @y, @velocity_x, @velocity_y, self.angle)
				rca[0] += rc[0]
				rca[1] += rc[1]
			end
		end
		@velocity_x += rca[0]
		@velocity_y += rca[1]
	end

	def hit_by(bullet)
		@health -= bullet.dmg
		if @health <= 0
			Explosion.create(:x => @x, :y => @y)
			pause
			destroy
			$points += 100
			$money += 100
		end
	end

	def draw
		super
		r = @health/100.0
		$window.fill_rect [@x-5, @y+8, 11*r, 2], 0xff000000 + (0xff*r).to_i*256 + (0xff*(1-r)).to_i*256*256, 2
	end

	def start_strafe; @strafe = true; end
	def stop_strafe;  @strafe = false; end
	def turn_left;    if @strafe then strafe_left  else @rs -= @rspeed end; end
	def turn_right;   if @strafe then strafe_right else @rs += @rspeed end; end
	def accel;        @velocity_x += Math.sin(self.angle.to_radian)*@faccel;      @velocity_y -= Math.cos(self.angle.to_radian)*@faccel; end
	def decel;        @velocity_x -= Math.sin(self.angle.to_radian)*@baccel;      @velocity_y += Math.cos(self.angle.to_radian)*@baccel; end
	def strafe_left;  @velocity_x += Math.sin((self.angle-90).to_radian)*@saccel; @velocity_y -= Math.cos((self.angle-90).to_radian)*@saccel; end
	def strafe_right; @velocity_x += Math.sin((self.angle+90).to_radian)*@saccel; @velocity_y -= Math.cos((self.angle+90).to_radian)*@saccel; end
end

class PlayerShip < Ship
	def initialize(options)
		options[:bullet_class] = PlayerBullet
		super options
		$player = self
#		@health = 1000
	end
end

class AiShip < Ship
	def initialize(options)
		options[:bullet_class] = EnemyBullet
		super options
		cache_bounding_circle
		@ai = :simple
	end

	def update
		a = Math.atan2(@x-$player.x,-@y+$player.y)*180/Math::PI+180
		if a < self.angle then turn_left end
		if a > self.angle then turn_right end
		r = rand
		if r < 0.1
			strafe_left
		elsif r < 0.2
			strafe_right
		elsif r < 0.3
			decel
		elsif r < 0.5
			accel
		elsif r > 0.99
			shoot
		end
		super
	end
end

class Bullet < Chingu::GameObject
	traits :collision_detection, :bounding_circle
	def initialize(options)
		super
		self.angle = options[:rot].to_f
		@type = options[:type]
		self.image = Image[@type[:img]]
		@timer = @type[:timer]
		self.scale = 2
		@velocity_x =  Math.sin(self.angle.to_radian)*@type[:speed]+options[:rsx]
		@velocity_y = -Math.cos(self.angle.to_radian)*@type[:speed]+options[:rsy]
		if options[:offx] or options[:offy]
			@x +=  Math.sin((self.angle+90).to_radian)*(options[:offx] or 0)+ Math.sin((self.angle).to_radian)*(options[:offy] or 0)
			@y += -Math.cos((self.angle+90).to_radian)*(options[:offx] or 0)+-Math.cos((self.angle).to_radian)*(options[:offy] or 0)
		end
	end

	def dmg; @type[:dmg]*self.alpha/255; end

	def hit
		oh = (@type[:onhit] or :explode)
		puts @type.inspect
		case oh
		when :explode
			explode
		end
	end

	def explode
		if @type[:onexplode] then Weapon.new(:type => @type[:onexplode], :bullet_class => self.class).shoot(@x, @y, 0, 0, 0.0) end
		destroy
	end

	def update
		@x += @velocity_x
		@y += @velocity_y
		@timer -= 1
		if @timer < 0
			self.alpha = (@type[:fade] - -@timer) * 255 / @type[:fade]
		end

		if self.alpha <= 0 then explode	end
	end
end

class EnemyBullet < Bullet; end
class PlayerBullet < Bullet; end

class Weapon
	attr_reader :type, :cooldown
	def initialize(options)
		@type = options[:type]
		@bullet_class = options[:bullet_class]
		@off = (options[:off] or [0,0])
		@cooldown = 0
	end

	def shoot(x, y, rsx, rsy, rotation)
		rcx, rcy = 0, 0
		if @cooldown <= 0
			recoil = (@type[:recoil] or 0)
			rot = rotation + $tick*(@type[:rot_speed] or 0)
			if @type[:multi]
				spr = (@type[:multi_spread] or 4)
				case (@type[:spread_mode] or :side)
				when :side
					@type[:multi].times do |i|
						@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot, :type => @type[:bullet], :offx => spr*i-(@type[:multi]-1)*spr/2 + @off[0], :offy => @off[1])
					end
				when :angle
					@type[:multi].times do |i|
						@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot+spr*i-(@type[:multi]-1)*spr/2, :type => @type[:bullet], :offx => @off[0], :offy => @off[1])
					end
				end
			else
				@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot, :type => @type[:bullet], :offx => @off[0], :offy => @off[1])
			end
			rcx += -Math.sin((rot).to_radian)*recoil
			rcy +=  Math.cos((rot).to_radian)*recoil
			@cooldown = @type[:cooldown]
		end
		return rcx, rcy
	end

	def update
		@cooldown -= 1
	end
end

class StarField < Chingu::GameObject
	def initialize(options)
		super
		self.image = $starfield[0]
		self.scale = 2
		@animspeed = 10
		@atick = 0
		@cur = 0
	end

	def update
		@atick += 1
		if @atick > @animspeed
			@atick = 0
			@cur = (@cur + 1) % $starfield.size
			self.image = $starfield[@cur]
		end
	end
end

class Shop < Chingu::GameObject
	traits :collision_detection, :bounding_circle
	def initialize(options)
		super
		@image = Image["shop001.png"]
		self.scale = 2
		self.zorder = 1
		self.alpha = 0
	end

	def update
		if self.alpha < 255 then self.alpha += 1 end
	end
end

SLOTTYPEMAP = {:small_wep => "[Weapon]"}
SLOTTYPEICON = {:small_wep => "border_weps.png"}
PZ = 2100

class Popup < Chingu::GameObject
	def initialize(options)
		super
		@stuff = []
		@w = options[:w] or 200
		@h = options[:h] or 100
		options[:text].each do |t|
			@stuff << if t[:align] == :right
				Chingu::Text.create(t[:text], :x => t[:x]-@w, :y => t[:y], :zorder => PZ, :color => (t[:col] or 0xffffffff), :max_width => 200, :align => :right)
			else
				Chingu::Text.create(t[:text], :x => t[:x], :y => t[:y], :zorder => PZ, :color => (t[:col] or 0xffffffff))
			end
		end
		@lx, @ly = 0, 0
	end

	def update
		if @x+@w >= 800 then @x -= @w end
		if @y+@h >= 600 then @y -= @h end
		@stuff.each {|s| s.x += @x-@lx; s.y += @y-@ly}
		@lx, @ly = @x, @y
	end

	def draw
		super
		$window.fill_rect [@x, @y, @w, @h], 0xff000000, 2000
		$window.fill_rect [@x+2, @y+2, @w-4, @h-4], 0xff000050, 2000
	end

	def destroy
		super
		@stuff.each {|s| s.destroy}
	end
end

class ShopState < Chingu::GameState
	def initialize(ship)
		super
		@ship = ship
		@tick = 0
		@active_slot = 0
		@shipimg = Img.create(:x => 400, :y => 300, :img => ship.type[:img], :scale => 32, :alpha => 50)
		Chingu::Text.create("Shop", :x => 10, :y => 10, :factor_x => 2, :factor_y => 2)
		@slot_imgs = []
		@slot_txts = []
		@ship.type[:slots].each_with_index do |slot,i|
			name = SLOTTYPEMAP[slot[:type]]
			icon = SLOTTYPEICON[slot[:type]]
			if @ship.modules[i]
				name = @ship.modules[i].type[:name]
				icon = @ship.modules[i].type[:icon]
			end
			@slot_txts << Chingu::Text.create(name, :x => 40, :y => 100+30*i)
			@slot_imgs << Img.create(:x => 20, :y => 108+30*i, :img => icon, :scale => 2)
		end

    $weapons.each_with_index do |wep,i|
      Img.create :x => 300+30*(i%16), :y => 108+30*(i/16), :img => wep[:icon], :scale => 2
    end

    $ships.each_with_index do |ship,i|
      Img.create :x => 300+30*((i+$weapons.size)%16), :y => 108+30*((i+$weapons.size)/16), :img => ship[:img], :scale => 2
    end

		self.input = {:esc => :pop_game_state}
	end

	def update
		@t = nil
		if $window.mouse_x >= 300-16 and $window.mouse_y >= 108-16
			tx = ($window.mouse_x-(300-16)).to_i/30
			ty = ($window.mouse_y-(108-16)).to_i/30
			if tx < 16 then	@t = tx+ty*16 end
			if @t and @t >= $weapons.size + $ships.size then @t = nil end
		elsif $window.mouse_x <= 33 and $window.mouse_y >= 108-16
			@t = ($window.mouse_y-(108-16)).to_i/30	+ 10000
			if @t >= @ship.type[:slots].size + 10000 then @t = nil end
		end

		if @t != @last_t
			@popup and @popup.destroy
			if @t and @t < 1000
        if @t < $weapons.size
          dmg = $weapons[@t][:bullet][:dmg].to_f
          rpm = 3600.0/$weapons[@t][:cooldown]
          dps = dmg*rpm/60*($weapons[@t][:multi] or 1)
          price = $weapons[@t][:price]
          curmodprice = 0
          if @ship.modules[@active_slot] then curmodprice = @ship.modules[@active_slot].type[:price] end
          price_diff = curmodprice - price
          @popup = Popup.create(:w => 200, :h => 140, :text => [
          {:x=>10,:y=>10,:text=>$weapons[@t][:name]},
          {:x=>10,:y=>30,:text=>"Dmg: " + dmg.to_s},
          {:x=>10,:y=>50,:text=>"RPM: " + rpm.to_s},
          {:x=>10,:y=>70,:text=>"Dps: " + dps.to_s},
          {:x=>190,:y=>90,:text=>"$" + price.to_s, :align=>:right},
          if price_diff < 0
            {:x=>190,:y=>110,:text=>"-$" + price_diff.abs.to_s, :align=>:right, :col=>0xffff0000}
          else
            {:x=>190,:y=>110,:text=>"$" + price_diff.to_s, :align=>:right, :col=>0xff00ff00}
          end
          ])
        elsif @t < $weapons.size + $ships.size
          puts @t
          ship = $ships[@t - $weapons.size]
          puts ship
          @popup = Popup.create(:w => 200, :h => 140, :text =>[
          {x:10, y:10, text: ship[:name]}
          ])
        else
          puts @t
        end
			elsif @t and @t >= 10000
				slot = @ship.type[:slots][@t-10000]
				mt = @ship.modules[@t-10000]
				if mt then mt = mt.type end
#        if mt and mt[:type] != slot[:type] then mt = nil end
				if mt
					dmg = mt[:bullet][:dmg].to_f
					rpm = 3600.0/mt[:cooldown]
					dps = dmg*rpm/60*(mt[:multi] or 1)
					price = mt[:price]
					@popup = Popup.create(:w => 200, :h => 120, :text => [
					{:x=>10,:y=>10,:text=>mt[:name]},
					{:x=>10,:y=>30,:text=>"Dmg: " + dmg.to_s},
					{:x=>10,:y=>50,:text=>"RPM: " + rpm.to_s},
					{:x=>10,:y=>70,:text=>"Dps: " + dps.to_s},
					{:x=>190,:y=>90,:text=>"$" + price.to_s, :align=>:right},
					])
				end
			end
			@last_t = @t
		end


		if @popup
			@popup.x, @popup.y = $window.mouse_x+10, $window.mouse_y+10
			@popup.update
		end

		if $window.button_down?(Gosu::MsLeft) and @t
			if @t < 10000
        if @t < $weapons.size
          price = $weapons[@t][:price]
          curmodprice = 0
          if @ship.modules[@active_slot] then curmodprice = @ship.modules[@active_slot].type[:price] end
          price_diff = curmodprice - price
          if $money > price_diff
            @ship.modules[@active_slot] = Weapon.new({:type=>$weapons[@t], :bullet_class=>PlayerBullet, :off => @ship.type[:slots][@active_slot][:off]})
            @slot_imgs[@active_slot].destroy
            @slot_imgs[@active_slot] = Img.create(:x => @slot_imgs[@active_slot].x, :y => @slot_imgs[@active_slot].y, :img => $weapons[@t][:icon], :scale => 2)
            @slot_txts[@active_slot].destroy
            @slot_txts[@active_slot] = Chingu::Text.create(:x => @slot_txts[@active_slot].x, :y => @slot_txts[@active_slot].y, :text => $weapons[@t][:name])
            $money += price_diff
          end
        elsif @t < $weapons.size + $ships.size
          ship = $ships[@t-$weapons.size]
          @ship.upgrade ship
          pop_game_state
          push_game_state ShopState.new(@ship)
        end
			else
				@slot_imgs[@active_slot].alpha = 255
				@active_slot = @t - 10000
			end
		end

		@slot_imgs[@active_slot].alpha = (Math.sin(@tick/10.0)+1)*127
		@tick += 1
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		super
		Image["cursor.png"].draw $window.mouse_x-9, $window.mouse_y-9, 99999, 2, 2
	end
end

class Game < Chingu::GameState
	trait :viewport
	def initialize
		super
		if $config[:stars]
			$starfield = []
			(if $config[:stars] == :light then 1 else 4 end).times do
				sl = []
				sl << TexPlay.create_blank_image($window, 512, 512)
				sl[0].each do |c|
					if rand > 0.9998
						c[0] = c[1] = c[2] = rand(0.4)+0.5
						c[3] = 1
					end
				end
				if $config[:stars] != :light
					sf = []
					3.times {sf << sl[0].dup}
					sf.each{|s|s.each{|c| c[0] = c[1] = c[2] = rand(0.2)+0.7}}
					sl += sf
				end
				$starfield << sl
			end

			@star_animspeed = 10
			@star_tick = 0
			@star_cur = 0

			@stars = Chingu::Parallax.new(:x => 0, :y => 0)
			@stars << {:image => $starfield[0][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left}
			if $config[:stars] != :light
				@stars << {:image => $starfield[1][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 2}
				@stars << {:image => $starfield[2][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 3}
				@stars << {:image => $starfield[3][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 5}
			end
		end
		Shop.create(:x => 100,  :y => 100)
		Shop.create(:x => 100,  :y => 2899)
		Shop.create(:x => 2899, :y => 100)
		Shop.create(:x => 2899, :y => 2899)
		@player = PlayerShip.create(:x => 100, :y => 100, :type => $ships[0])
		@player.input = {
			:holding_h => :turn_left,
			:holding_k => :turn_right,
			:holding_u => :accel,
			:holding_j => :decel,
			:holding_y => :strafe_left,
			:holding_i => :strafe_right,
			:holding_f => :shoot,
			:lshift => :start_strafe,
			:released_lshift => :stop_strafe
		}
		@player.input = {
			:holding_a => :turn_left,
			:holding_d => :turn_right,
			:holding_w => :accel,
			:holding_s => :decel,
			:holding_q => :strafe_left,
			:holding_e => :strafe_right,
			:holding_h => :shoot,
			[:lshift,:rshift] => :start_strafe,
			[:released_lshift,:released_rshift] => :stop_strafe
		}
		@enemies = []
#		1000.times {@enemies << AiShip.create(:x => rand(3000), :y => rand(3000))}
		@minimap = TexPlay.create_blank_image($window, 100, 100)
		@minimap.each{|c| c[3] = 1}
		#self.viewport.lag = 0.99
		self.viewport.game_area = [0,0,3000,3000]
		puts "Took #{Time.now-$startuptime}s to start up"
		@spawntimer = 800
		@spawntime = 0
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		@minimap.paint do
			rect 0,0,99,99, :fill => true, :color => [0,0,0]
			@enemies.each do |e|
				if e.paused?
					@enemies.delete e
				else
					pixel (e.x/30).to_i, (e.y/30).to_i, :color => [1,0,0]
				end
			end
			pixel $player.x.to_i/30, $player.y.to_i/30, :color => [0,1,0]
		end
		@minimap.draw 800-120, 20, 1000000#, 1,1,Gosu::Color.rgba(255,255,255,128)
		@player.modules.each_with_index do|m, i|
			alpha = 1
			progress = 1.0-[(m.cooldown.to_f / m.type[:cooldown]),0.0].max
			if m.type[:cooldown] >= 30 and m.cooldown > 0
				alpha = progress
				$window.fill_rect [34, 10+30*i+20*(progress), 2, 20*(1-progress)], 0xffff0000, 1000000
			end
			Image[m.type[:icon]].draw 10, 10+30*i, 1000000, 2, 2, (0xff*alpha).to_i*0x01000000+0x00ffffff
		end
		if $config[:stars] then @stars.draw end
		super
	end

	def update
		super
#		push_game_state ShopState.new(@player)

		self.viewport.center_around @player

		if $config[:stars]
			@stars.camera_x, @stars.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
			@stars.update

			if $config[:stars] != :light
				@star_tick += 1
				if @star_tick > @star_animspeed
					@star_tick = 0
					@star_cur = (@star_cur + 1) % $starfield[0].size
					4.times{|i| @stars.layers[i].image = $starfield[i][@star_cur]}
				end
			end
		end

		@spawntime -= 1
		if @spawntime < 0
			@enemies << AiShip.create(:x => rand(3000), :y => rand(3000), :type => $ships[0])
			@spawntime = @spawntimer
			@spawntimer *= 0.95
		end

		PlayerBullet.each_collision(AiShip) do |bullet, enemy|
			enemy.hit_by bullet
			bullet.hit
		end

		EnemyBullet.each_collision(PlayerShip) do |bullet, player|
			player.hit_by bullet
			bullet.hit
		end

		Shop.each_collision(PlayerShip) do |shop, player|
			if shop.alpha == 255
				shop.alpha = 0
				push_game_state ShopState.new(player)
			end
		end

		$tick += 1
	end
end

puts "Preparing game, please wait..."
$ships = []
$ships << {img: "ship001.png", armor: 100, name: "Amy",   slots: [{type: :small_wep, off: [0,5]}]}
$ships << {img: "ship002.png", armor: 100, name: "Allie", slots: [{type: :small_wep, off: [-6,0]},{type: :small_wep, off: [6,0]}]}
$bullets = []
$bullets << {timer: 40, fade: 10, speed: 5.0,  dmg: 10,  img: "bullet001.png"}
$bullets << {timer: 20, fade: 10, speed: 5.0,  dmg: 2,   img: "bullet001.png"}
$bullets << {timer: 40, fade: 10, speed: 10.0, dmg: 200, img: "bullet002.png"}
$bullets << {timer: 15, fade: 1,  speed: 10.0,  dmg: 0,   img: "bullet003.png", onhit: :nothing, onexplode:
	{bullet: $bullets[0], multi: 128, spread_mode: :angle, multi_spread: 360/128.0}}
$weapons = []
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon001.png", name: "Pink Pellet",        price: 100}
$weapons << {bullet: $bullets[0], cooldown: 5,   icon: "icon002.png", name: "P.P. Turbo",         price: 500}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon003.png", name: "P.P. Duo",           price: 500,   multi: 2}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon003.png", name: "P.P. Duo Spread",    price: 500,   multi: 2, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon004.png", name: "P.P. Triple",        price: 1000,  multi: 3}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon004.png", name: "P.P. Triple Spread", price: 1000,  multi: 3, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon005.png", name: "P.P. Quad",          price: 2000,  multi: 4}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon005.png", name: "P.P. Quad Spread",   price: 2000,  multi: 4, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[1], cooldown: 2,   icon: "icon005.png", name: "P.P. Star",          price: 4000,  multi: 8, spread_mode: :angle, multi_spread: 360/8, :rot_speed => 3}
$weapons << {bullet: $bullets[1], cooldown: 2,   icon: "icon005.png", name: "P.P. Star CCW",      price: 4000,  multi: 8, spread_mode: :angle, multi_spread: 360/8, :rot_speed => -3}
$weapons << {bullet: $bullets[2], cooldown: 60,  icon: "icon006.png", name: "Pink Bolt",          price: 10000, recoil: 2}
$weapons << {bullet: $bullets[2], cooldown: 60,  icon: "icon006.png", name: "P.B. Extreme",       price: 10000, multi: 3, spread_mode: :angle, multi_spread: 8, recoil: 4}
$weapons << {bullet: $bullets[3], cooldown: 600, icon: "icon006.png", name: "Red Bomb",           price: 10000, recoil: 2}
$money = 1000000
Dir.chdir File.dirname($0)
Main.new.show
