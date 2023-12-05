def tick args
  args.state.current_scene ||= :title_scene

  current_scene = args.state.current_scene

  case current_scene
  when :title_scene
    tick_title_scene args
  when :game_scene
    tick_game_scene args
  when :game_over_scene
    tick_game_over_scene args
  end

  if args.state.current_scene != current_scene
    raise "Scene was changed incorrectly. Set args.state.next_scene to change scenes."
  end

  if args.state.next_scene
    args.state.current_scene = args.state.next_scene
    args.state.next_scene = nil
  end
end

def tick_title_scene args
  args.state.player_van_1 ||= {x: 125, y: 300, w: 64, h: 32, path: 'sprites/van1r.png', angle: 270}
  args.state.timer ||= 0
  args.outputs.background_color = [0, 0, 0]
  args.outputs.sprites << [20, 0, 1260, 720, 'sprites/level1.png']
  args.outputs.labels << [360, 705, "20 Second Delivery Run", 20, 255, 0, 0, 0]
  args.outputs.labels << [390, 500, "Press the Enter key to start.", 10, 255, 0, 0, 0]
  args.outputs.labels << [570, 400, "Controls:", 10, 255, 0, 0, 0]
  args.outputs.labels << [300, 265, "w, s or up, down = Accelerate, Brake.", 10, 255, 0, 0, 0]
  args.outputs.labels << [300, 225, "a, d or left, right = Turn left and right.", 10, 255, 0, 0, 0]
  args.outputs.labels << [480, 85, "Space = Throw parcel.", 10, 255, 0, 0, 0]
  args.outputs.primitives << args.state.player_van_1

  if args.inputs.keyboard.enter
    args.state.next_scene = :game_scene
  end
end

def tick_game_scene args
  args.state.player ||= {x: 125, y: 300, dx: 0, dy: 0, w: 64, h: 32, path: 'sprites/van1r.png', angle: 270, cooldown: 0, parcels: 10}
  args.state.player_collision ||= {x: 125, y: 300, dx: 0, dy: 0, w: 64, h: 32}
  args.state.player.angle ||= 0
  args.state.player_speed ||= 0
  args.state.parcel_angle ||= 0
  args.state.parcels_delivered ||= 0
  args.state.parcels ||= []
  args.state.targets ||= []
  args.state.buildings_collision_x ||= []
  args.state.buildings_collision_y ||= []
  args.state.buildings_collide_x ||= true
  args.state.buildings_collide_y ||= true
  args.state.debug_enabled ||= false
  args.state.wait_frame_parcels ||= 0
  args.state.wait_frame_turn ||= 0
  args.state.wait_frame_accel ||= 0
  args.state.wait_frame_deccel ||= 0
  args.state.wait_frame_parcel_delivered ||= 0
  args.state.time_seconds ||= 20
  args.state.time_frame ||= 0
  args.state.end_timer ||= 0
  args.state.current_target ||= 1
  args.state.target_1 ||= 0
  args.state.target_2 ||= 0
  args.state.target_3 ||= 0
  args.state.target_4 ||= 0
  args.state.target_5 ||= 0
  args.state.target_6 ||= 0

  if args.state.buildings_collision_x.empty?
    args.state.buildings_collision_x = make_buildings_collision_x
  end
  if args.state.buildings_collision_y.empty?
    args.state.buildings_collision_y = make_buildings_collision_y
  end
  
  if args.state.time_seconds > 0
    args.state.time_frame += 1
  end

  if args.state.time_frame == 59
    args.state.time_frame = 0
    args.state.time_seconds -= 1
  end

  if args.state.time_seconds == 0
    args.state.next_scene = :game_over_scene
  end

  if args.state.wait_frame_parcels > 0
    args.state.wait_frame_parcels -= 1
  end

  if args.state.wait_frame_deccel < 11
    args.state.wait_frame_deccel += 1
  end
  if args.state.wait_frame_deccel == 11
    args.state.wait_frame_deccel = 0
  end 

  if args.state.current_target == 1
    if args.state.target_1 == 0
      args.state.targets = make_target_1
      args.state.target_1 = 1
      args.state.target_6 = 0
    end
    if args.state.parcels_delivered == 1 || args.state.parcels_delivered == 7
      args.state.current_target = 2
    end
  end
  if args.state.current_target == 2
    if args.state.target_2 == 0
      args.state.targets = make_target_2
      args.state.target_2 = 1
      args.state.target_1 = 0
    end
    if args.state.parcels_delivered == 2 || args.state.parcels_delivered == 8
      args.state.current_target = 3
    end
  end
  if args.state.current_target == 3
    if args.state.target_3 == 0
      args.state.targets = make_target_3
      args.state.target_3 = 1
      args.state.target_2 = 0
    end
    if args.state.parcels_delivered == 3 || args.state.parcels_delivered == 9
      args.state.current_target = 4
    end
  end
  if args.state.current_target == 4
    if args.state.target_4 == 0
      args.state.targets = make_target_4
      args.state.target_4 = 1
      args.state.target_3 = 0
    end
    if args.state.parcels_delivered == 4  || args.state.parcels_delivered == 10
      args.state.current_target = 5
    end
  end
  if args.state.current_target == 5
    if args.state.target_5 == 0
      args.state.targets = make_target_5
      args.state.target_5 = 1
      args.state.target_4 = 0
    end
    if args.state.parcels_delivered == 5  || args.state.parcels_delivered == 11
      args.state.current_target = 6
    end
  end
  if args.state.current_target == 6
    if args.state.target_6 == 0
      args.state.targets = make_target_6
      args.state.target_6 = 1
      args.state.target_5 = 0
    end
    if args.state.parcels_delivered == 6  || args.state.parcels_delivered == 12
      args.state.current_target = 1
    end
  end

  if args.inputs.keyboard.p
    args.state.debug_enabled = true
  end
  if args.inputs.keyboard.o
    args.state.debug_enabled = false
  end

  if args.state.debug_enabled
    debug args
  end

  if args.inputs.keyboard.key_held.w || args.inputs.keyboard.key_held.up
    if args.state.wait_frame_accel == 10 && args.state.player_speed < 6
      args.state.player_speed += 1
      args.state.wait_frame_accel = 0
    end
    args.state.wait_frame_accel += 1
  end
  if args.inputs.keyboard.key_up.w || args.inputs.keyboard.key_up.up
    args.state.wait_frame_accel = 0
  end

  if args.state.wait_frame_deccel == 10 && args.state.player_speed > 0 && args.state.player_speed <= 6 && !args.inputs.up
    args.state.player_speed -= 1
  end

  if args.state.wait_frame_deccel == 10 && args.state.player_speed < 0 && args.state.player_speed >= -2 && !args.inputs.up
    args.state.player_speed += 1
  end

  args.state.player[:dx] = args.state.player.angle.x_vector * args.state.player_speed
  args.state.player[:dy] = args.state.player.angle.y_vector * args.state.player_speed
  args.state.player_collision[:dx] = args.state.player.angle.x_vector * args.state.player_speed
  args.state.player_collision[:dy] = args.state.player.angle.y_vector * args.state.player_speed

  if args.inputs.down
    if args.state.wait_frame_deccel == 10 && args.state.player_speed >= 0
      args.state.player_speed -= 1
    end
    if args.state.wait_frame_deccel == 10 && args.state.player_speed >= -2
      args.state.player_speed -= 1
    end
  end

  args.state.player[:x] += args.state.player[:dx]
  args.state.player[:y] += args.state.player[:dy]

  if args.inputs.keyboard.key_down.a || args.inputs.keyboard.key_held.a || args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_held.left
    args.state.wait_frame_turn += 1
    if args.state.wait_frame_turn < 2
      args.state.player.angle += 3
    end
    if args.state.wait_frame_turn > 2
      args.state.player.angle += 6
    end
  end
  if args.inputs.keyboard.key_up.a || args.inputs.keyboard.key_up.left
    args.state.wait_frame_turn = 0
  end

  if args.inputs.keyboard.key_down.d || args.inputs.keyboard.key_held.d || args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_held.right
    args.state.wait_frame_turn += 1
    if args.state.wait_frame_turn < 2
      args.state.player.angle -= 3
    end
    if args.state.wait_frame_turn > 2
      args.state.player.angle -= 6
    end
  end
  if args.inputs.keyboard.key_up.d || args.inputs.keyboard.key_up.right
    args.state.wait_frame_turn = 0
  end

  args.state.parcels.each do |parcel|
    args.state.targets.each do |target|
      if !parcel[:delivered]
        if parcel.intersect_rect? target
          if parcel[:vel] <= 0
            parcel[:dx] = 0
            parcel[:dy] = 0
            parcel[:delivered] = true
            args.state.parcels_delivered += 1
          else
            parcel[:vel] -= 1
            parcel[:x] += parcel[:dx]
            parcel[:y] += parcel[:dy]
          end
        else
          parcel[:x] += parcel[:dx]
          parcel[:y] += parcel[:dy]
        end
      end
    end
  end

  args.state.parcels.each do |parcel|
    if not parcel[:y].between?(20, 700)
      parcel[:dx] = 0
      parcel[:dy] = 0
    end
    if not parcel[:x].between?(20, 1260)
      parcel[:dx] = 0
      parcel[:dy] = 0
    end
  end

  args.state.parcels = args.state.parcels.reject do |parcel|
    if args.state.player.intersect_rect? parcel
      if !parcel[:delivered]
        if args.state.wait_frame_parcels <= 0
          args.state.player[:parcels] += 1
          true
        end
      end
    else
      false
    end
  end

  if args.state.player[:x] <= 0
    args.state.player[:x] = 0
  end
  if args.state.player[:x] >= 1216
    args.state.player[:x] = 1216
  end
  if args.state.player[:y] <= 0
    args.state.player[:y] = 0
  end
  if args.state.player[:y] >= 674
    args.state.player[:y] = 674
  end

  args.state.buildings_collision_x.each do |building|
    if building.intersect_rect? args.state.player 
      #args.state.buildings_collide_x = true
      if args.state.player[:x] <= building[:x] + building[:w] && args.state.player[:dx] < 0 && args.state.buildings_collide_y == false
        args.state.player[:x] = building[:x] + building[:w]
      end
      if args.state.player[:x] >= building[:x] && args.state.player[:dx] > 0  && args.state.buildings_collide_y == false
        args.state.player[:x] = building[:x]
      end
    end
    #args.state.buildings_collide_x = false
  end
  args.state.buildings_collision_y.each do |building|
    if building.intersect_rect? args.state.player
      #args.state.buildings_collide_y = true
      if args.state.player[:y] <= building[:y] + building[:h] && args.state.player[:dy] < 0  && args.state.buildings_collide_x == false
        args.state.player[:y] = building[:y] + building[:h]
      end
      if args.state.player[:y] >= building[:y] && args.state.player[:dy] > 0  && args.state.buildings_collide_x == false
        args.state.player[:y] = building[:y]
      end
    end
    #args.state.buildings_collide_y = false
  end

  args.state.player[:cooldown] -= 1
  if args.inputs.keyboard.key_held.space && args.state.player[:cooldown] <= 0 && args.state.player[:parcels] > 0
    args.state.parcel_angle = args.state.player.angle + 90
    args.state.parcels << {x: args.state.player[:x], y: args.state.player[:y], w: 16, h: 16, path: 'sprites/parcel1.png', vel: 4, dx: args.state.parcel_angle.x_vector * 4, dy: args.state.parcel_angle.y_vector * 4, delivered: false}.sprite!
    args.state.player[:cooldown] = 50 + 1
    args.state.player[:parcels] -= 1
    args.state.wait_frame_parcels += 20
  end

  args.outputs.background_color = [0, 0, 0]
  args.outputs.sprites << [20, 0, 1260, 720, 'sprites/level1.png']
  args.outputs.primitives << args.state.player
  args.outputs.primitives << args.state.parcels
  args.outputs.primitives << args.state.targets
  #args.outputs.primitives << args.state.buildings_collision_x
  args.outputs.labels << [255, 392, "#{(args.state.player[:parcels])}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [240, 394, "x", 3, 255, 255, 255, 255].label
  args.outputs.sprites << [220, 371, 16, 16, 'sprites/parcel1.png']
  args.outputs.primitives << [135, 435, "Time: #{(args.state.time_seconds)}", 5, 255, 255, 255, 255].label
end

def tick_game_over_scene args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.labels << [560, 500, "Times up!", 10, 255, 255, 255, 255]
  args.outputs.labels << [460, 450, "Parcels delivered: #{(args.state.parcels_delivered)}", 10, 255, 255, 255, 255]
  args.outputs.labels << [320, 400, "Press the Enter key to try again.", 10, 255, 255, 255, 255]
  if args.inputs.keyboard.enter
    args.state.next_scene = :game_scene
    args.state.player[:x] = 125
    args.state.player[:y] = 300
    args.state.player[:dx] = 0
    args.state.player[:dy] = 0
    args.state.player[:angle] = 270
    args.state.player[:parcels] = 10
    args.state.player_collision[:x] = 125
    args.state.player_collision[:y] = 300
    args.state.player.angle = 270
    args.state.player_speed = 0
    args.state.parcel_angle = 0
    args.state.parcels_delivered = 0
    args.state.parcels.clear
    args.state.targets.clear
    args.state.wait_frame_parcels = 0
    args.state.wait_frame_turn = 0
    args.state.wait_frame_accel = 0
    args.state.wait_frame_deccel = 0
    args.state.wait_frame_parcel_delivered = 0
    args.state.time_seconds = 20
    args.state.time_frame = 0
    args.state.end_timer = 0
    args.state.current_target = 1
    args.state.target_1 = 0
    args.state.target_2 = 0
    args.state.target_3 = 0
    args.state.target_4 = 0
    args.state.target_5 = 0
    args.state.target_6 = 0
  end
end

def make_target_1
  targets = []
  targets += 1.times.map { |n| {x: 1115, y: 555, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_target_2
  targets = []
  targets += 1.times.map { |n| {x: 755, y: 285, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_target_3
  targets = []
  targets += 1.times.map { |n| {x: 125, y: 550, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_target_4
  targets = []
  targets += 1.times.map { |n| {x: 215, y: 90, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_target_5
  targets = []
  targets += 1.times.map { |n| {x: 935, y: 90, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_target_6
  targets = []
  targets += 1.times.map { |n| {x: 575, y: 540, w: 64, h: 64, path: 'sprites/target1.png'} }
  targets
end

def make_buildings_collision_x
  buildings_collision_x = []
  buildings_collision_x += 1.times.map { |n| {x: 108, y: 402, w:184, h:86, path: 'sprites/target1.png'} }
  buildings_collision_x
end
def make_buildings_collision_y
  buildings_collision_y = []
  buildings_collision_y += 1.times.map { |n| {x: 112, y: 398, w:176, h:94, path: 'sprites/target1.png'} }
  buildings_collision_y
end

def debug args
  args.outputs.labels << [10, 50, "angle x vector: #{(args.state.player.angle.x_vector)}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 80, "angle y vector: #{(args.state.player.angle.y_vector)}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 110, "player dx: #{(args.state.player[:dx])}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 140, "player dy: #{(args.state.player[:dy])}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 170, "player speed: #{(args.state.player_speed)}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 200, "wait frame accel: #{(args.state.wait_frame_accel)}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 230, "wait frame deccel: #{(args.state.wait_frame_deccel)}", 3, 255, 255, 255, 255].label
  args.outputs.labels << [10, 260, "Parcels delivered: #{(args.state.parcels_delivered)}", 3, 255, 255, 255, 255].label
end