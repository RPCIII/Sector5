class EnemyBullet
SPEED = 10
attr_reader :x, :y, :radius


  def initialize(window, x, y)
    @x = x
    @y = y
    @direction = 0
    @image = Gosu::Image.new('images/EnemyBullet.png')
    @radius = 3
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