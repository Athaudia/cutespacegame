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
