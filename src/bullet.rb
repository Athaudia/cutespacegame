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
		case oh
		when :explode
			explode
		end
	end

	def explode
		if @type[:onexplode] then @type[:onexplode].each{|w| Weapon.new(:type => w, :bullet_class => self.class).shoot(@x, @y, 0, 0, 0.0)} end
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
