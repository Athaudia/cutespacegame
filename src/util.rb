class Util < Mod
	def initialize(options)
		super(options)
		@repair = (@type[:repair] or 0)
	end

	def update
		super
		self.activate if @passive
	end

	def activate
		if @cooldown <= 0
			@ship.repair @repair if @repair > 0
			@cooldown = @timer
		end
	end
end
