class Popup < Chingu::GameObject
	def initialize(options)
		super
		@stuff = []
		@w = options[:w] or 200
		@h = options[:h] or 100
		options[:text].each do |t|
			@stuff << if t[:align] == :right
				Chingu::Text.create(t[:text], :x => t[:x]-@w, :y => t[:y], :zorder => PZ, :color => (t[:col] or 0xffffffff), :max_width => 200, :align => :right)
			else
				Chingu::Text.create(t[:text], :x => t[:x], :y => t[:y], :zorder => PZ, :color => (t[:col] or 0xffffffff))
			end
		end
		@lx, @ly = 0, 0
	end

	def update
		if @x+@w >= 800 then @x -= @w end
		if @y+@h >= 600 then @y -= @h end
		@stuff.each {|s| s.x += @x-@lx; s.y += @y-@ly}
		@lx, @ly = @x, @y
	end

	def draw
		super
		$window.fill_rect [@x, @y, @w, @h], 0xff000000, 2000
		$window.fill_rect [@x+2, @y+2, @w-4, @h-4], 0xff000050, 2000
	end

	def destroy
		super
		@stuff.each {|s| s.destroy}
	end
end
