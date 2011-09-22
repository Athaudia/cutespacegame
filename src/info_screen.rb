class InfoScreen < Chingu::GameState
	def initialize
		super
		Chingu::Text.create("Athaudia's\nCute Space Game", :x => 10, :y => 10, :factor_x => 2, :factor_y => 2)
		Chingu::Text.create("version: #{VERSION}", :x => 5, :y => 588-5)
		text = """Keys:

  A, D: turn
  W, S: accelerate, decelerate
  shift-A, shift-D, Q, E: strafe
  H,J,K,L: fire weapons

Goal:

  Shoot enemies, earn money and points,
  spend money in one of the 4 upgrade shops
  at the corners of the map, shoot more enemies.

[space to start]"""
		Chingu::Text.create(text, :x => 10, :y => 100)
		self.input = {:space => :pop_game_state}
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		super
	end
end
