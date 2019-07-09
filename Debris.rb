class Debris
	SPEED = 6
	attr_reader :x, :y
	def initialize(window)
		@x = rand(window.width - 2)
        @y = 0
        @radius = 1
        @image = Gosu::Image.new('images/debris.png')
        @window = window
	end

	def move
		@y += SPEED
	end

	def draw
		@image.draw(@x, @y, 1)
    end
    
    def onscreen?
        right = @window.width + @radius
        left = -@radius
        top = -@radius
        bottom = @window.height + @radius
        @x > left and @x < right and @y > top and @y < bottom
    end

end