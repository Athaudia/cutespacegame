class Chingu::Text; def center; @x = (800-@gosu_font.text_width(@text, self.scale))/2; self; end; end
class TI < Gosu::TextInput; def filter(text_in); if self.text.size < 16 then text_in else '' end; end; end;
class HiscoreState < Chingu::GameState
	def initialize
		super
		@ti = TI.new
		$window.text_input = @ti
		@text = Chingu::Text.create("", :x => 300, :y => 520, :scale => 2)
		Chingu::Text.create("Game Over", :y =>30, :scale => 4).center
		Chingu::Text.create("#{$points} Points", :y =>100, :scale => 2).center
		Chingu::Text.create("            Enter name and press enter to send score to server, or esc to skip", :y =>580, :scale => 1).center
		@iw = @text.gosu_font.text_width("WWWWWWWWWWWWWWWW",2)
		@ih = @text.gosu_font.height * 2
		@text.x = (800-@iw)/2

#		hiscores = [{name: 'Athaudia', score: 15100}]*10
		hiscores = Scores::get
		hiscores.each_with_index do |h,i|
			Chingu::Text.create("#{(i+1)}. #{h['name']} - #{h['score']}", :x => 10, :y => 170+i*30, :scale => 2).center
		end
	end

	def update
		@text.text = @ti.text.clone.insert(@ti.caret_pos, '|')
	end

	def draw
		fill_rect [0,0,800,600], 0xff000030, -2
		fill_rect [@text.x-6, @text.y-6, @iw+12, @ih+12], 0xffffffff
		fill_rect [@text.x-4, @text.y-4, @iw+8, @ih+8], 0xff000000
#		fill_rect [@text.x, @text.y, @iw, @ih], 0xff000000
		super
	end

	def stop
		$window.text_input = nil
		pop_game_state
	end
end
