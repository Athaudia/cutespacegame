class Ship < Chingu::GameObject
	traits :velocity, :collision_detection, :bounding_circle
	attr_reader :type, :modules
	attr_accessor :rs
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
		mods = (options[:mods] or [])
		@modules = @type[:slots].map.each_with_index do |s,i|
			if mods[i]
				case s[:type]
				when :small_wep
					Weapon.new(:bullet_class => options[:bullet_class], :off => s[:off], :ship => self, :type => $weapons[mods[i]])
				when :util
					Util.new(:ship => self, :type => $utils[mods[i]])
				end
			else
				nil
			end
		end
#		puts @modules.inspect
#		@modules = [Weapon.new(:type => $weapons[0], :bullet_class => options[:bullet_class], :off => @type[:slots][0][:off], :ship => self)]
		@health = @type[:armor]
		self.angle = 0.0
		cache_bounding_circle
	end

	def repair(r)
		@health += r
		@health = [@health, @type[:armor]].min
	end

	def worth
		@modules.map {|m| if m then m.type[:price] else 0 end}.inject(:+)
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
		@modules.each {|w| w.update if w}
	end

	def shoot(key = 0)
		rca = [0,0]
		@type[:slots].each_with_index do |m,i|
			if [:small_wep].include?(m[:type]) and @modules[i] and (key == 0 or @keys[i][key-1])
				rc = @modules[i].shoot(@x, @y, @velocity_x, @velocity_y, self.angle)
				rca[0] += rc[0]
				rca[1] += rc[1]
			end
		end
		@velocity_x += rca[0]
		@velocity_y += rca[1]
	end
	def shoot1; shoot(1); end
	def shoot2; shoot(2); end
	def shoot3; shoot(3); end
	def shoot4; shoot(4); end

	def hit_by(bullet)
		if @health <= 0 then return end
		@health -= bullet.dmg
		if @health <= 0
			Explosion.create(:x => @x, :y => @y)
			if $config[:godmode] and self.class == PlayerShip
				@health = @type[:armor]
			else
				pause
				destroy
				$points += worth
				$money += worth/2
			end
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
