require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credits'
require_relative 'bomb'
require_relative 'debris'
require_relative 'package'
require_relative 'life'
require_relative 'enemybullet'
require_relative 'mothership'
class SectorFive < Gosu::Window
  WIDTH = 1500
  HEIGHT = 1000
  ENEMY_FREQUENCY = 0.01
  BULLET_FREQUENCY = 0.008
  DEBRIS_FREQUENCY = 1
  PACKAGE_FREQUENCY = 0.0002
  LIFE_FREQUENCY = 0.00009
  MOTHER_BULLET_FREQUENCY = 0.1
  MAX_ENEMIES = 50
  MAX_LIVES = 3
  MOVE_MOTHER = 0.5

#initialize
  def initialize
    super(WIDTH, HEIGHT)::fullscreen = true
    self.caption = 'Sector Five'
    @background_image = Gosu::Image.new('images/start_screen.png')
    @background = Gosu::Image.new('images/space.png')
    @scene = :start
  end
#end initialize

#initialize end
  def initialize_end(fate)

    @file = File.open('highscore.txt').each do |line|
      @highscore = line.chomp
      @highscore = @highscore.to_i
    end
    @file = File.open('highscore.txt', 'w')

  	case fate
    when :count_reached
      @score = (@enemies_destroyed * 100) + (@health * 100) + ((@lives - 1) * 100) + (@mothership_destroyed * 1000)
  		@message1 = "You made it! You destroyed #{@enemies_destroyed} ships"
      @message2 = "and #{50 - @enemies_destroyed} reached the base."
      if @score > @highscore
        @highscore = @score
        @message3 = "New High Score: #{@score}"
        @file.write(@score)
      else
        @message3 = "Your score is: #{@score}"
        @file.write(@highscore)
      end
    when :hit_by_enemy
      @score = @enemies_destroyed * (@health + @lives)
  		@message = "You were struck by an enemy ship."
  		@message2 = "Before your ship was destroyed, "
      @message2 += "you took out #{@enemies_destroyed} enemy ships."
      if @score > @highscore
        @highscore = @score
        @message3 = "New High Score: #{@score}"
        @file.write(@score)
      else
        @message3 = "Your score is: #{@score}"
        @file.write(@highscore)
      end
    end
    
  	@bottom_message = "Press P to play again, or Q to quit."
  	@message_font = Gosu::Font.new(28)
  	@credits = []
  	y = 700
  	File.open('credits.txt').each do |line|
  		@credits.push(Credit.new(self, line.chomp,100,y))
  		y += 30
  	end
  	@scene = :end
  end
#end initialize end


#update game
  def update_game
    if @players.any? == false
      @players.push Player.new(self)
    end
    @players.each do |player|
      player.turn_left if button_down?(Gosu::KbLeft)
      player.turn_right if button_down?(Gosu::KbRight)
      player.move
    end
    if rand < ENEMY_FREQUENCY && MAX_ENEMIES >= @enemies_appeared
      @enemies.push Enemy.new(self)
      @enemies_appeared += 1
    end
    if rand < DEBRIS_FREQUENCY
      @debris.push Debris.new(self)
    end
    if rand < PACKAGE_FREQUENCY
      @packages.push Package.new(self)
    end
    if rand < LIFE_FREQUENCY
      @newlives.push Life.new(self)
    end
    if rand < BULLET_FREQUENCY
      @enemies.each do |enemy|
        @enemyBullets.push EnemyBullet.new(self, enemy.x, enemy.y)
      end
    end
    if rand < MOTHER_BULLET_FREQUENCY && @mothership.any? == true
      @mothership.each do |mothership|
        @enemyBullets.push EnemyBullet.new(self, mothership.x, mothership.y)
      end
    end
    @enemies.each do |enemy|
      enemy.move
    end
    @debris.each do |debris|
      debris.move
    end
    @bullets.each do |bullet|
      bullet.move
    end
    @enemyBullets.each do |bullet|
      bullet.move
    end
    @bombs.each do |bomb|
      bomb.move
    end
    @packages.each do |package|
      package.move
    end
    @newlives.each do |life|
      life.move
    end
    @mothership.each do |mothership|
      mothership.move_to_position if mothership.y < 300
      if rand < MOVE_MOTHER
        mothership.move_right
      else
        mothership.move_left
      end
      mothership.move
    end
    @mothership.each do |mothership|
      @bullets.dup.each do |bullet|
        distance = Gosu.distance(mothership.x, mothership.y, bullet.x, bullet.y)
        if distance < mothership.radius + bullet.width
          @bullets.delete bullet
          @mothership_health = @mothership_health - 5
        end
      end
    end
    @mothership.each do |mothership|
      @bombs.dup.each do |bomb|
        distance = Gosu.distance(mothership.x, mothership.y, bomb.x, bomb.y)
        if distance < mothership.radius + bomb.radius + 50
          @bombs.delete bomb
          @mothership_health = @mothership_health - 10
        end
      end
    end
    @mothership.each do |mothership|
      if @mothership_health <= 0
        @mothership.delete mothership
        @explosions.push Explosion.new(self, mothership.x, mothership.y)
        @mothership_destroyed += 1
      end
    end
    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.width
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @enemies_destroyed += 1
        end
      end
    end
    @enemyBullets.dup.each do |bullet|
      @bombs.dup.each do |bomb|
        distance = Gosu.distance(bullet.x, bullet.y, bomb.x, bomb.y)
        if distance < bullet.radius + 5 + bomb.radius
          @enemyBullets.delete bullet
          @bombs.delete bomb
          @explosions.push Explosion.new(self, bomb.x, bomb.y)
        end
      end
    end
    @players.each do |player|
      @enemyBullets.dup.each do |bullet|
        distance = Gosu.distance(player.x, player.y, bullet.x, bullet.y)
        if distance < player.radius + bullet.radius
          @enemyBullets.delete bullet
          @health = @health - 20
          if @health <= 0
            @players.delete player
            @explosions.push Explosion.new(self, player.x, player.y)
            @lives = @lives - 1
            @players.push Player.new(self)
            @health = 100
          end
        end
      end
    end
    @enemies.dup.each do |enemy|
      @bombs.dup.each do |bomb|
        distance = Gosu.distance(enemy.x, enemy.y, bomb.x, bomb.y)
        if distance < enemy.radius + bomb.radius + 50
          @enemies.delete enemy
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @explosions.push Explosion.new(self, bomb.x, bomb.y)
          @enemies_destroyed += 1
        end
      end
    end
    @packages.each do |package|
      @players.each do |player|
        distance = Gosu.distance(package.x, package.y, player.x, player.y)
        if distance < player.radius + package.radius
          @bombs_left = 5
          @packages.delete package
        end
      end
    end
    @newlives.each do |life|
      @players.each do |player|
        distance = Gosu.distance(life.x, life.y, player.x, player.y)
        if (distance < player.radius + life.radius) && @lives < MAX_LIVES
          @lives = @lives + 1
          @newlives.delete life
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
    @enemies.dup.each do |enemy|
      @enemies.delete enemy unless enemy.onscreen?
    end
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
    @enemyBullets.dup.each do |bullet|
      @enemyBullets.delete bullet unless bullet.onscreen?
    end
    @debris.dup.each do |debris|
      @debris.delete debris unless debris.onscreen?
    end
    @bombs.dup.each do |bomb|
      @bombs.delete bomb unless bomb.onscreen?
    end
    @packages.dup.each do |package|
      @packages.delete package unless package.onscreen?
    end
    @newlives.dup.each do |life|
      @newlives.delete life unless life.onscreen?
    end  
    mothership_battle if @enemies_appeared > MAX_ENEMIES
    if @mothership_health <= 0
      initialize_end(:count_reached)
    end
    # initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES
    @enemies.each do |enemy|
      @players.each do |player|
        distance = Gosu.distance(enemy.x, enemy.y, player.x, player.y)
        if distance < player.radius + enemy.radius
          @lives = @lives - 1
          @enemies.delete enemy
          @players.delete player
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @explosions.push Explosion.new(self, player.x, player.y)
          @players.push Player.new(self)
        end
        if @lives == 0
          initialize_end(:hit_by_enemy)
        end
      end
    end
  end
#end update game

def mothership_battle
  if @mothership.any? == false
    @mothership.push Mothership.new(self)
  end
end
  

#button down game
  def button_down_game(id)
    @players.each do |player|
      if id == Gosu::KbUp || id == Gosu::KbSpace
        @bullets.push Bullet.new(self, player.x + 8, player.y)
      end
      if id == Gosu::KbDown && @bombs_left > 0
        @bombs.push Bomb.new(self, player.x, player.y)
        @bombs_left -= 1
      end
    end
  end
#end button down game

#update end
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
#end update end

#update
  def update
  	case @scene
  	when :game
      update_game
  	when :end
  		update_end
  	end
  end
#end update

#initialize game
  def initialize_game
    @players = []
    @lives = 1
    @health = 100
    @enemies = []
    @debris = []
    @bullets = []
    @enemyBullets = []
    @bombs = []
    @packages = []
    @explosions = []
    @newlives = []
    @mothership = []
    @scene = :game
    @bombs_left = 5
  	@enemies_appeared = 0
    @enemies_destroyed = 0
    @mothership_destroyed = 0
    @mothership_health = 1000
    @score = 0
    @font = Gosu::Font.new(30)
  end
#end initalize game

#button down start
  def button_down_start(id)
  	initialize_game
  end
#end button down start

#button down end
  def button_down_end(id)
  	if id == Gosu::KbP
  		initialize_game
  	elsif id == Gosu::KbQ
  		close
  	end
  end
#end button down end

#button down
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
#end button down

#draw start
  def draw_start
  	@background_image.draw(0,0,0)
  end
#end draw start

#draw game
  def draw_game
    @background.draw(0,0,0)
    @players.each do |player|
      player.draw
    end
    @enemies.each do |enemy|
      enemy.draw
    end
    @packages.each do |package|
      package.draw
    end
    @debris.each do |debris|
      debris.draw
    end
    @bullets.each do |bullet|
      bullet.draw
    end
    @enemyBullets.each do |bullet|
      bullet.draw
    end
    @bombs.each do |bomb|
      bomb.draw
    end
    @explosions.each do |explosion|
      explosion.draw
    end
    @newlives.each do |life|
      life.draw
    end
    @mothership.each do |mothership|
      mothership.draw
    end
    if @lives == 1
      @lives_icon = Gosu::Image.new('images/one_life.jpg')
    elsif @lives == 2
      @lives_icon = Gosu::Image.new('images/two_lives.jpg')
    elsif @lives == 3
      @lives_icon = Gosu::Image.new('images/three_lives.jpg')
    end
    @lives_icon.draw(20, 20, 2)
    #TODO: Replace font with image based health
    @font.draw(@health, 20, 120, 2)
    @font.draw(@enemies_destroyed, 1400, 20, 2)
  end
#end draw game

#draw end start
  def draw_end
  	clip_to(50,140,700,360) do
  		@credits.each do |credit|
  			credit.draw
  		end
  	end
  	draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
  	@message_font.draw(@message,40,40,1,1,1,Gosu::Color::RED)
    @message_font.draw(@message2,40,75,1,1,1,Gosu::Color::RED)
    @message_font.draw(@message3,40,110,1,1,1,Gosu::Color::RED)
  	draw_line(0,500,Gosu::Color::RED,WIDTH,500,Gosu::Color::RED)
  	@message_font.draw(@bottom_message,180,540,1,1,1,Gosu::Color::RED)
  end
#end draw end

#draw
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
#end draw

end
#end class

window = SectorFive.new
window.show