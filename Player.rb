class Player
	ACCELERATION = 0.85
	FRICTION = 0.95
	attr_reader :x, :y, :angle, :radius


	def initialize(window)
		@x = 600
		@y = 950
		@angle = 0
		@image = Gosu::Image.new('images/ship.png')
		@velocity_x = 0
		@velocity_y = 0
		@radius = 20
		@window = window
	end


	def turn_right
		@velocity_x += ACCELERATION
	end


	def turn_left
		@velocity_x -= ACCELERATION
	end


	def move
		@x += @velocity_x
		@velocity_x *= FRICTION
		@velocity_y *= FRICTION
		if @x > @window.width - @radius
			@velocity_x = 0
			@x = @window.width - @radius
		end
		if @x < @radius
			@velocity_x = 0
			@x = @radius
		end
	end

	def draw
		@image.draw_rot(@x, @y, 1, @angle)
	end


end