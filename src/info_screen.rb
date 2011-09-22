class InfoScreen < Chingu::GameState
	def initialize
		super
		Chingu::Text.create("Athaudia's", :x => 10, :y => 10, :factor_x => 2, :factor_y => 2).center
		Chingu::Text.create("Cute Space Game", :x => 10, :y => 50, :factor_x => 2, :factor_y => 2).center
		Chingu::Text.create("version: #{VERSION}", :x => 5, :y => 588-5)
		text = """Keys:

  A, D: strafe
  W, S: accelerate, decelerate
  Mouse: aim
  Left Mouse Button: shoot

Goal:

  Shoot enemies, earn money and points,
  spend money in one of the 4 upgrade shops
  at the corners of the map, shoot more enemies.
"""
		Chingu::Text.create(text, :x => 20, :y => 100)
		Chingu::Text.create('[press mouse button to start]', y: 588-5).center
		t = Chingu::Text.create("Hiscores", :x => 10, :y => 100, :scale => 1)
		t.x = (400-t.gosu_font.text_width(t.text, 1))/2 + 400
		hiscores = Scores::get
		hiscores.each_with_index do |h,i|
			t = Chingu::Text.create("#{(i+1)}. #{h['name']} - #{h['score']}", :x => 10, :y => 130+i*15, :scale => 1)
			t.x = (400-t.gosu_font.text_width(t.text, 1))/2 + 400
		end

		self.input = {:space => :pop_game_state}
	end

	def update
		if $window.button_down?(Gosu::MsLeft) then pop_game_state end
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		draw_rect [410,90,380,200], 0xffffffff, -1
		draw_rect [10,90,380,200], 0xffffffff, -1
		super
	end
end
