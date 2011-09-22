class Mod
	attr_reader :type, :cooldown, :keys, :passive
	def initialize(options)
		@type = options[:type]
		@ship = options[:ship]
		@passive = (@type[:passive] or false)
		@cooldown = 0
		@timer = (@type[:cooldown] or 1)
		@keys = [true, false, false, false]
	end

	def update
		@cooldown -= 1
	end
end
