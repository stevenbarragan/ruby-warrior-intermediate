class Player

  def initialize()
    @directions = [:forward, :left, :right , :backward]
    @enemies = []
  end
  
  def play_turn(warrior)
    @warrior = warrior

    enemies = look_for_enemies_arround

    puts enemies

    if enemies.empty?
      captives = look_for_captives_arround

      if warrior.health < min_fell_health(enemies)
        warrior.rest!

      elsif @enemies.empty?

        if captives.empty?

          captives = look_for_captives

          if captives.empty?

            enemies = look_for_enemies

            if enemies.empty?
              puts "walk #{warrior.direction_of_stairs}"
              warrior.walk! warrior.direction_of_stairs
            
            else

              puts "enemies #{enemies[0]}"
              puts "min_health #{min_health(enemies[0])}"

              if warrior.health < min_health(enemies[0].to_s)
                warrior.rest!

              else
                warrior.walk! warrior.direction_of enemies[0]

              end

            end

          else
            warrior.walk! warrior.direction_of captives[0]
          end

        else
          puts "rescue! #{captives[0]}"
          warrior.rescue! captives[0]

        end

      else
        puts "attack! #{@enemies[0]}"
        warrior.attack! @enemies.shift

      end

    elsif enemies.length >= 2
      warrior.bind! enemies[0]
      @enemies << enemies[0]

    else
      puts "attack! #{enemies[0]}"
      warrior.attack! enemies[0]

    end

  end

  def min_fell_health(enemies)
    enemies = enemies || @enemies

    if enemies.empty?
      if @enemies.empty?
        return 0
      else
        enemies = @enemies
      end
    end

    min_health @warrior.feel(enemies[0]).to_s
  end

  def min_health(enemy)
    case enemy
      when "Thick Sludge"
        puts "here 1"
        16
      when "Sludge"
        9
      else
        puts "here 2"
        0
    end
  end

  def look_for_enemies_arround()
    direcctions = []
    @directions.each{ |direction|
      if @warrior.feel(direction).enemy?
        if @warrior.feel(direction).to_s == "Thick Sludge"
          direcctions.unshift( direction )
        else
          direcctions << direction
        end
      end
    }
    direcctions
  end

  def look_for_captives_arround()
    captives = []

    @directions.each{ |direction|
      captives << direction if @warrior.feel(direction).captive?
    }
    captives
  end

  def look_for_captives()
    @warrior.listen.select{ |feel| feel.captive? }
  end

  def look_for_enemies()
    @warrior.listen.select{ |feel| feel.enemy? }
  end

end