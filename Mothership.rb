class Mothership
	ACCELERATION = 0.45
	FRICTION = 1
	attr_reader :x, :y, :angle, :radius


	def initialize(window)
		@x = 750
		@y = 0
		@angle = 0
		@image = Gosu::Image.new('images/mothership.png')
		@velocity_x = 0
		@velocity_y = 0
		@radius = 153
        @window = window
	end


    def move_right
        @velocity_x += ACCELERATION
	end


	def move_left
		@velocity_x -= ACCELERATION
    end
    
    def move_to_position
        @y += ACCELERATION
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
        # @image.draw(@x - @radius, @y - @radius, 1)
	end


end