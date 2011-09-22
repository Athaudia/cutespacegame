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
