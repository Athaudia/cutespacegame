class Game < Chingu::GameState
	trait :viewport
	attr_reader :viewport
	def initialize
		super
		$game = self
		$points = 0
		$money = 0
		$tick = 0
		@minimap = TexPlay.create_blank_image($window, 100, 100)
		@minimap.each{|c| c[3] = 1}
		if $config[:stars] and $config[:stars] != :cached
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
					sf.each{|s|s.each{|c| c[0] = c[1] = c[2] = rand(0.2)+0.7 unless c[3] == 0}}
					sl += sf
				end
				$starfield << sl
			end


			4.times{|i| 4.times{|j| $starfield[i][j].save("c:\\star0#{i}#{j}.png")}}
		else
			$starfield = []
			4.times{|i| $starfield[i] = []; 4.times{|j| $starfield[i][j] = Image["star0#{i}#{j}.png"]}}
		end
		@stars = Chingu::Parallax.new(:x => 0, :y => 0)
		@stars << {:image => $starfield[0][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left}
		if $config[:stars] != :light
			@stars << {:image => $starfield[1][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 2}
			@stars << {:image => $starfield[2][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 3}
			@stars << {:image => $starfield[3][0], :repeat_x => true, :repeat_y => true, :rotation_center => :top_left, :damping => 5}
		end

		Shop.create(:x => 100,  :y => 100)
		Shop.create(:x => 100,  :y => 2899)
		Shop.create(:x => 2899, :y => 100)
		Shop.create(:x => 2899, :y => 2899)
		@player = PlayerShip.create(:x => 1500, :y => 1500, :type => $ships[0], :mods => [0])
		@player.input = {
			:holding_a => if $config[:control] == :mouse then :strafe_left else :turn_left end,
			:holding_d => if $config[:control] == :mouse then :strafe_right else :turn_right end,
			:holding_w => :accel,
			:holding_s => :decel,
			:holding_q => :strafe_left,
			:holding_e => :strafe_right,
			:holding_h => :shoot1,
			:holding_j => :shoot2,
			:holding_k => :shoot3,
			:holding_l => :shoot4,
			[:lshift,:rshift] => :start_strafe,
			[:released_lshift,:released_rshift] => :stop_strafe
		}
		@enemies = []
#		1000.times {@enemies << AiShip.create(:x => rand(3000), :y => rand(3000))}
		#self.viewport.lag = 0.99
		self.viewport.game_area = [0,0,3000,3000]
		puts "Took #{Time.now-$startuptime}s to start up"
		@wave = 0
		@timer = 100
	end

	def setup
		@star_animspeed = 10
		@star_tick = 0
		@star_cur = 0
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		begin
			@minimap.rect 0,0,99,99, :fill => true, :color => [0,0,0]
			@enemies.each do |e|
				if e.paused?
					@enemies.delete e
				else
					@minimap.pixel (e.x/30).to_i, (e.y/30).to_i, :color => [1,0,0]
				end
			end
			@minimap.pixel $player.x.to_i/30, $player.y.to_i/30, :color => [0,1,0]
		end
		@minimap.draw 800-120, 20, 1000000#, 1,1,Gosu::Color.rgba(255,255,255,128)
		@player.modules.each_with_index do|m, i|
			if m
				alpha = 1
				progress = 1.0-[(m.cooldown.to_f / m.type[:cooldown]),0.0].max
				if m.type[:cooldown] >= 30 and m.cooldown > 0
					alpha = progress
					$window.fill_rect [34, 10+30*i+20*(progress), 2, 20*(1-progress)], 0xffff0000, 1000000
				end
				Image[m.type[:icon]].draw 10, 10+30*i, 1000000, 2, 2, (0xff*alpha).to_i*0x01000000+0x00ffffff
			end
		end
		if $config[:stars] then @stars.draw end
		super
	end

	def update
		super
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

		if @enemies.size == 0
			if @timer <= 0 and $waves[@wave]
				@enemies = $waves[@wave].map{|s| AiShip.create(:x => rand(3000), :y => rand(3000), :type => $ships[s[0]], :mods => s[1,s.size-1])}
				@wave += 1
			else
				@timer -= 1
			end
		end

		PlayerBullet.each_collision(AiShip) do |bullet, enemy|
			enemy.hit_by bullet
			bullet.hit
		end

		EnemyBullet.each_collision($player) do |bullet, player|
			player.hit_by bullet
			bullet.hit
		end

		Shop.each_collision($player) do |shop, player|
			if shop.alpha == 255
				shop.alpha = 0
				push_game_state ShopState.new(player)
			end
		end

		$tick += 1
		if @until_hiscore
			@until_hiscore -= 1
			if @until_hiscore <= 0
				$wave = @wave
				switch_game_state HiscoreState
			end
		else
			if $player.paused? then @until_hiscore = 200 end
		end
	end
end
