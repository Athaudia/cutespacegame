class Weapon < Mod
	attr_reader :type, :cooldown, :keys
	def initialize(options)
		super(options)
		@bullet_class = options[:bullet_class]
		@off = (options[:off] or [0,0])
	end

	def shoot(x, y, rsx, rsy, rotation)
		rcx, rcy = 0, 0
		if @cooldown <= 0
			recoil = (@type[:recoil] or 0)
			rot = rotation + $tick*(@type[:rot_speed] or 0)
			if @type[:multi]
				spr = (@type[:multi_spread] or 4)
				case (@type[:spread_mode] or :side)
				when :side
					@type[:multi].times do |i|
						@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot, :type => @type[:bullet], :offx => spr*i-(@type[:multi]-1)*spr/2 + @off[0], :offy => @off[1])
					end
				when :angle
					@type[:multi].times do |i|
						@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot+spr*i-(@type[:multi]-1)*spr/2, :type => @type[:bullet], :offx => @off[0], :offy => @off[1])
					end
				end
			else
				@bullet_class.create(:x => x, :y => y, :rsx => rsx, :rsy => rsy, :rot => rot, :type => @type[:bullet], :offx => @off[0], :offy => @off[1])
			end
			rcx += -Math.sin((rot).to_radian)*recoil
			rcy +=  Math.cos((rot).to_radian)*recoil
			@cooldown = @timer
		end
		return rcx, rcy
	end

	def range
		@type[:bullet][:speed] *(@type[:bullet][:timer]+@type[:bullet][:fade]) + (((@type[:bullet][:onexplode] or []).map{|w| Weapon.new(:type=>w).range}.max) or 0)
	end

	def optimal_range
		@type[:bullet][:speed] *(@type[:bullet][:timer])
	end

	def rpm
		3600.0/@type[:cooldown]
	end

	def dmg
		@type[:bullet][:dmg].to_f*(@type[:multi] or 1) + (((@type[:bullet][:onexplode] or []).map{|w| Weapon.new(:type=>w).dmg}.inject(:+)) or 0)
	end

	def dps
		self.dmg*rpm/60
	end
end
