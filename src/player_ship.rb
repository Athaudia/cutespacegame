class PlayerShip < Ship
	attr_reader :keys, :future_x, :future_y, :crosshair
	def initialize(options)
		options[:bullet_class] = PlayerBullet
		super options
		$player = self unless options[:ghost]
		@keys = @type[:slots].map{[true,false,false,false]} unless options[:ghost]
		@crosshair = Chingu::GameObject.create(:image => "crosshair.png", :scale => 2, :zorder => 9000) unless options[:ghost]
		@ghost = PlayerShip.new(ghost: true, type: @type) unless options[:ghost]
		@rsstack = []
	end

	def upgrade(type)
		w = (self.worth or 0)
		$money += w
		@modules = []
		@type = type
		if @health > @type[:armor] then @health = @type[:armor] end
		@keys = @type[:slots].map{[true,false,false,false]}
	end

	def update
		if self != $player
#			puts 123
			self.update_trait
		end
		super
		$game.viewport.center_around self if self == $player
		if $config[:control] == :mouse and self == $player
			@crosshair.x = $window.mouse_x + $game.viewport.x if self == $player
			@crosshair.y = $window.mouse_y + $game.viewport.y if self == $player
			a = Math.atan2(-$player.crosshair.x+@x,$player.crosshair.y-@y)*180.to_f/Math::PI+180 if self == $player
			diff = a - self.angle;
			diff += 360 while diff < -180
			diff -= 360 while diff > 180
			if diff < 0 then turn_left end
			if diff > 0 then turn_right end
			if $window.button_down?(Gosu::MsLeft) and self == $player then shoot1 end
		else
			@crosshair.x = @x + Math.sin(self.angle.to_radian) * 50 if self == $player
			@crosshair.y = @y - Math.cos(self.angle.to_radian) * 50 if self == $player
		end
		if self == $player
			nrs = 0
			nrs = @rsstack.inject(:+)/@rsstack.size if @rsstack.size > 0
			@ghost.x, @ghost.y, @ghost.angle, @ghost.rs = @x, @y, @angle, nrs
			@ghost.velocity_x, @ghost.velocity_y = @velocity_x, @velocity_y
			40.times{@ghost.update; @ghost.rs = nrs}
 			@future_x = @ghost.x
			@future_y = @ghost.y
			@crosshair.angle = @angle
			if @rsstack.size > 100 then @rsstack.shift end
			@rsstack << @rs
		end
	end

	def draw
		super
#		$window.fill_rect [@future_x-2, @future_y-2, 4, 4], 0xffffffff, 10000000 if @future_x
	end
end
