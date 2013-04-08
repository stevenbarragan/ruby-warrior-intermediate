class Player

  def initialize()
    @directions = [:forward, :left,  :backward, :right]
  end
  
  def play_turn(warrior)
    @warrior = warrior

    enemy = look_enemy

    if enemy
      warrior.attack! enemy
    elsif warrior.health < 13
      warrior.rest!
    else
      warrior.walk! warrior.direction_of_stairs
    end

  end

  def look_enemy()
    @directions.each{ |direction|
      return direction if @warrior.feel(direction).enemy?
    }
    false
  end

end