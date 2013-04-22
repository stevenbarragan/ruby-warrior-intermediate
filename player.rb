class Player

  def initialize()
    @directions = [:left, :right , :backward, :forward]
    @enemies = []
    @back_to_rest = false
  end
  
  def play_turn(warrior)
    @warrior = warrior
    continue = true
    @captives = look_for_captives.length if !@captives

    enemies = look_for_enemies_arround
    ticking = look_for_ticking

    if @back_to_rest && warrior.health < 15
      warrior.rest!
      continue = false
    else
      @back_to_rest = false
    end

    if !ticking.empty?  && continue

        all_enemies_arround = look_for_all_enemies_arround

        captives = look_for_captives_arround


        if !captives.empty? && less_tiking_distance(ticking) == 1
          rescue! captives[0]
          continue = false
        else

          direction = get_ticking_good_direction ticking

          direction = get_other_empty_direction if !direction

          if direction && look_for_all_enemies_direction(direction) <= 2
            walk! direction
            continue = false

          elsif enemies.empty? && warrior.health < min_feel_health(enemies) && !near_ticking?(ticking)
            warrior.rest!
            continue = false

          elsif enemies.length == 1
            if near_ticking?(ticking)
              warrior.attack! enemies[0]
              continue = false

            elsif look_for_all_enemies_direction(enemies[0]) > 1
              warrior.detonate! enemies[0]
              continue = false
            end
          end
      end
    end
    
    if continue
      if enemies.empty?
        captives = look_for_captives_arround

        if warrior.health < min_feel_health(enemies) && count_all_enemies > 0
          warrior.rest!

        elsif @enemies.empty?

          if captives.empty?

            captives = look_for_captives

            if captives.empty?

              enemies = look_for_enemies

              if enemies.empty?
                walk! warrior.direction_of_stairs
              
              else
                if warrior.health < min_health(enemies[0].to_s)
                  warrior.rest!

                else
                  walk! warrior.direction_of enemies[0]

                end
              end

            else
              walk! avoid_stars(warrior.direction_of captives[0])

            end

          else
            rescue! captives[0]

          end

        else
          warrior.attack! @enemies.shift

        end

      elsif enemies.length >= 2
        if warrior.health < 10 && @last_direccion
          @back_to_rest = true
          walk! @last_direccion
        else
          warrior.bind! enemies[0]
          @enemies << enemies[0]
        end

      else
        warrior.attack! enemies[0]

      end
    end

  end

  def rescue!(direction)
    if @warrior.feel(direction).to_s == "Captive"
      @warrior.rescue! direction
      @captives -= 1
    else
      @warrior.attack! direction
    end
  end

  def less_tiking_distance(ticking)
    less = 100
    ticking.each{|tick|
      tick_distance = @warrior.distance_of(tick)
      less = tick_distance if tick_distance < less
    }
    less
  end

  def near_ticking?(ticking)
    ticking.each{|tick|
      return true if @warrior.distance_of(tick) < 3
    }
    false
  end

  def walk!( direction )
    case direction
      when :right
        @last_direccion = :left
      when :left
        @last_direccion = :right
      when :forward
        @last_direccion = :backward
      when :backward
        @last_direccion = :forward
    end

    @enemies = []

    @warrior.walk! direction    
  end

  def enemy?(direction)
    @warrior.feel(direction).enemy? || @enemies.include?(direction)
  end

  def get_ticking_good_direction(ticking)
    ticking.each{|tick|
      direction = @warrior.direction_of tick
      return direction unless enemy?(direction)
    }
    false
  end

  def get_other_empty_direction()
    directions = @directions.select{|direction|
      !enemy?(direction) &&
      @warrior.feel(direction).empty? &&
      direction != @last_direccion
    }

    directions.sample
  end

  def look_for_ticking()
    @warrior.listen.select{|feel| feel.ticking?}
  end

  def avoid_stars(direction)
    if @warrior.feel(direction).stairs?
      @directions.each{ |direction|
        return direction if @warrior.feel(direction).empty? && !@warrior.feel(direction).stairs?
      }
    else
      direction
    end
  end

  def min_feel_health(enemies)
    return 13
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
        20
      when "Sludge"
        13
      else
        0
    end
  end

  def look_for_enemies_arround()
    direcctions = []
    directtions_at_end = []
    @directions.each{ |direction|
      if @warrior.feel(direction).enemy?
        if look_for_all_enemies_direction(direction) > 1
          directtions_at_end << direction
        elsif @warrior.feel(direction).to_s == "Thick Sludge"
          direcctions.unshift( direction )
        else
          direcctions << direction
        end
      end
    }
    direcctions + directtions_at_end
  end

  def look_for_all_enemies_arround()
    look_for_enemies_arround + @enemies
  end

  def look_for_captives_arround()
    captives = []

    @directions.each{ |direction|
      captives << direction if @warrior.feel(direction).captive? && !@enemies.include?(direction)
    }
    captives
  end

  def look_for_captives()
    @warrior.listen.select{ |feel| feel.captive? }
  end

  def look_for_enemies()
    @warrior.listen.select{ |feel| feel.enemy?}
  end

  def look_for_all_enemies_direction(direction)
    enemies = []
    @warrior.look(direction).each{ |feel|
      enemies << direction if feel.enemy?
    }
    enemies << direction if @enemies.include?( direction )

    enemies.length  
  end

  def count_all_enemies()
    weird_captives = look_for_captives.length - @captives
    weird_captives = weird_captives > 0 ? weird_captives : 0
    look_for_enemies.length + @enemies.length + weird_captives
  end

end