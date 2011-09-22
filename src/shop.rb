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
