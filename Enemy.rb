class Enemy
	SPEED = 4
	attr_reader :x, :y, :radius
	def initialize(window)
		@radius = 30
		@x = rand(window.width - 2 * @radius) + @radius
		@y = 0
		@image = Gosu::Image.new('images/starship.png')
		@window = window
	end

	def move
		@y += SPEED
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end

	def onscreen?
        right = @window.width + @radius
        left = -@radius
        top = -@radius
        bottom = @window.height + @radius
        @x > left and @x < right and @y > top and @y < bottom
    end

end