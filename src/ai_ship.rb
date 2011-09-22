class AiShip < Ship
	def initialize(options)
		options[:bullet_class] = EnemyBullet
		super options
		#@modules = [Weapon.new(:type => $weapons[1], :bullet_class => options[:bullet_class], :off => @type[:slots][0][:off], :ship => self)]
		cache_bounding_circle
		@ai = :simple
		@range = @modules.map{|m| if m.class == Weapon then m.range else 0 end}.max
		@optimal = @modules.map{|m| if m.class == Weapon then m.optimal_range else 999999 end}.min
	end

	def update
		a = Math.atan2(-$player.future_x+@x,$player.future_y-@y)*180.to_f/Math::PI+180
		diff = a - self.angle;
		diff += 360 while diff < -180
		diff -= 360 while diff > 180
		if diff < 0 then turn_left end
		if diff > 0 then turn_right end

		xd = @x - $player.future_x
		yd = @y - $player.future_y
		dist = Math.sqrt(xd*xd + yd*yd)
		if dist < @optimal then decel else accel end
		if dist <= @range then shoot end
		super
	end
end
