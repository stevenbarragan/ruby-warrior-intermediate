class Player

  def initialize()
    @directions = [:forward, :left,  :backward, :right]
  end
  
  def play_turn(warrior)
    @warrior = warrior

    enemies = look_for_enemies

    if enemies.empty?
      captives = look_for_captives

      if warrior.health < 13
        warrior.rest!

      elsif captives.empty?
        warrior.walk! warrior.direction_of_stairs

      else
        warrior.rescue! captives[0]

      end
    elsif enemies.length >= 2
      warrior.bind! enemies[0]

    else
        warrior.attack! enemies[0]

    end

  end

  def look_for_enemies()
    direcctions = []
    @directions.each{ |direction|
      direcctions << direction if @warrior.feel(direction).enemy?
    }
    direcctions
  end

  def look_for_captives()
    captives = []
    @directions.each{ |direction|
      captives << direction if @warrior.feel(direction).captive?
    }
    captives
  end

end