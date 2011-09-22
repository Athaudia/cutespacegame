class MainWindow < Chingu::Window
	def initialize
		super 800, 600, false
		retrofy
		push_game_state Game
		push_game_state InfoScreen
	end
	def update
		super
		$window.caption = "Fps: #{$window.fps} Score: #{$points} Money: $#{$money}"
	end
end
