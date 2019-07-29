class Bullet
SPEED = 80
attr_reader :x, :y, :length, :width


  def initialize(window, x, y)
    @x = x
    @y = y
    @direction = 0
    @image = Gosu::Image.new('images/laser.png')
    @width = 12
    @length = 155
    @window = window
  end


  def move
    @x += Gosu.offset_x(@direction, SPEED)
    @y += Gosu.offset_y(@direction, SPEED)
  end


  def draw
    @image.draw(@x - @width, @y - @length, 1)
  end


  def onscreen?
    right = @window.width + @width
    left = -@width
    top = -@length
    bottom = @window.height + @length
    @x > left and @x < right and @y > top and @y < bottom
  end


end