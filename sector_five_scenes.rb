require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'
class SectorFive < Gosu::Window
  #set constants
  WIDTH = 1200
  HEIGHT = 1000
  ENEMY_FREQUENCY = 0.05
  MAX_ENEMIES = 100
  #opens the game window and starts the game
  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Sector Five'
    @background_image = Gosu::Image.new('images/start_screen.png')
    @scene = :start
  end
  #defines specific endings
  def initialize_end(fate)
  	case fate
  	when :count_reached
  		@message = "You made it! You destroyed #{@enemies_destroyed} ships"
  		@message2 = "and #{100 - @enemies_destroyed} reached the base."
  	when :hit_by_enemy
  		@message = "You were struck by an enemy ship."
  		@message2 = "Before your ship was destroyed, "
  		@message2 += "you took out #{@enemies_destroyed} enemy ships."
  	when :off_top
  		@message = "You got too close to the enemy mother ship."
  		@message2 = "Before your ship was destroyed, "
  		@message2 += "you took out #{@enemies_destroyed} enemy ships."
  	end
  	@bottom_message = "Press P to play again, or Q to quit."
  	@message_font = Gosu::Font.new(28)
  	@credits = []
  	y = 700
  	File.open('credits.txt').each do |line|
  		@credits.push(Credit.new(self,line.chomp,100,y))
  		y += 30
  	end
  	@scene = :end
  end
  #the commands necessary to move your ship and shoot, as well as
  #enemy destruction and removal
  def update_game
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
    if rand < ENEMY_FREQUENCY
      @enemies.push Enemy.new(self)
      @enemies_appeared += 1
    end
    @enemies.each do |enemy|
      enemy.move
    end
    @bullets.each do |bullet|
      bullet.move
    end
    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @enemies_destroyed += 1
        end
      end
    end 
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.finished
    end
    @enemies.dup.each do |enemy|
      if enemy.y > HEIGHT + enemy.radius
        @enemies.delete enemy 
      end
    end
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
    initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES
    @enemies.each do |enemy|
    	distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
    	initialize_end(:hit_by_enemy) if distance < @player.radius + enemy.radius
    end
    initialize_end(:off_top) if @player.y < -@player.radius
  end
  #command necessary to shoot in game
  def button_down_game(id)
      if id == Gosu::KbSpace
        @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
      end
  end
  #command to roll credits once the game is over, displaying player information
  def update_end
  	@credits.each do |credit|
  		credit.move
  	end
  	if @credits.last.y < 150
  		@credits.each do |credit|
  			credit.reset
  		end
  	end
  end
  #controls which 'scene' in the game we are in
  def update
  	case @scene
  	when :game
  		update_game
  	when :end
  		update_end
  	end
  end
  #scene to start the game after title screen
  def initialize_game
  	@player = Player.new(self)
  	@enemies = []
  	@bullets = []
  	@explosions = []
  	@scene = :game
  	@enemies_appeared = 0
  	@enemies_destroyed = 0
  end
  #prompt to start game from title screen
  def button_down_start(id)
  	initialize_game
  end
  #prompt to close the game
  def button_down_end(id)
  	if id == Gosu::KbP
  		initialize_game
  	elsif id == Gosu::KbQ
  		close
  	end
  end
  #controls which 'scene' in the game we are in
  def button_down(id)
  	case @scene
  	when :start
  		button_down_start(id)
  	when :game
  		button_down_game(id)
  	when :end
  		button_down_end(id)
  	end
  end
  #creates graphics for start
  def draw_start
  	@background_image.draw(0,0,0)
  end
  #displays graphics used in game
  def draw_game
  	@player.draw
    @enemies.each do |enemy|
      enemy.draw
    end
    @bullets.each do |bullet|
      bullet.draw
    end
    @explosions.each do |explosion|
      explosion.draw
    end
  end
  #displays the ending
  def draw_end
  	clip_to(50,140,700,360) do
  		@credits.each do |credit|
  			credit.draw
  		end
  	end
  	draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
  	@message_font.draw(@message,40,40,1,1,1,Gosu::Color::FUCHSIA)
  	@message_font.draw(@message2,40,75,1,1,1,Gosu::Color::FUCHSIA)
  	draw_line(0,500,Gosu::Color::RED,WIDTH,500,Gosu::Color::RED)
  	@message_font.draw(@bottom_message,180,540,1,1,1,Gosu::Color::AQUA)
  end
  #defining draw used in other sections
  def draw
  	case @scene
  	when :start
  		draw_start
  	when :game
  		draw_game
  	when :end
  		draw_end
  	end
  end
end

#launches the game
window = SectorFive.new
window.show