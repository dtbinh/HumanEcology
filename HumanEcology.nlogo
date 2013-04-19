globals [
   road_ahead new_distance curr_distance dist pile_radius GAtrail GAsite GAexpand lfood_counter1
   food_total cal_per_min_kg kg_per_individual kilojoule_conversion sec_per_tick movement_total 
   gigajoules_total time_ticks seconds_per_hour max_food_in_a_patch ticks_to_wait_after_harvesting
   movement_humans movement_horses movement_trucks gigajoules_expended_humans gigajoules_expended_horses gigajoules_expended_trucks
   cal_per_hour_horses cal_per_gallon kilometers_per_gallon size_patch carry_volume_humans carry_volume_horses
   carry_volume_trucks squad_size_humans squad_size_horses squad_size_trucks greatest_distance
   food_humans food_horses food_trucks food_joule_ratio_humans food_joule_ratio_horses food_joule_ratio_trucks
   
   ;;vars after this were added post-completion
   gigajoules_collected_humans gigajoules_collected_horses gigajoules_collected_trucks
   calories_collected_humans calories_collected_horses calories_collected_trucks
   calories_expended_humans calories_expended_horses calories_expended_trucks
   net_calories_humans net_calories_horses net_calories_trucks
   
   delivered_over_transport_cal_humans delivered_over_transport_cal_horses delivered_over_transport_cal_trucks
   ]
;first line are vars kept from original code
;all other lines are vars we added

breed [humans human]
breed [horses horse]
breed [trucks truck]

humans-own [trail_ahead behavior cityx boundary? has_food? speed_humans dist_to_move_humans patches_to_move_humans foodx foody fidelity recruit]
horses-own [trail_ahead behavior cityx boundary? has_food? speed_horses dist_to_move_horses patches_to_move_horses foodx foody fidelity recruit]
trucks-own [trail_ahead behavior cityx boundary? has_food? speed_trucks dist_to_move_trucks patches_to_move_trucks foodx foody fidelity recruit]

patches-own [lfood? trail? ticks_since_harvesting]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main setup function;;;;;;;;;;main setup function;;;;;;;;;;main setup function;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup_world

__clear-all-and-reset-ticks       
  setup_breeds
  setup_vars
  ask patches [
  set pcolor 62
  ]  
  go_density_recruit
;  do-plotting-left
  if ticks > 100 [
    ask humans [
      set behavior 3
               ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;creates locations for food piles;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup_breeds
  
  set-default-shape humans "person" ;human shape
  ask patch 0 0 [
    sprout-humans pop_humans        
  ]  

  ask humans [
    set color black ;human color
    set ycor (-7 + random 14) ;human location
    set xcor ((xcor - 7) + random 14)
    set heading random 360 ;human heading
    set behavior 0 ;sets the humans to their initial behavior condition
    set size 1
  ]
  
  set-default-shape horses "cow" ;horse shape
  ask patch 0 0 [
    sprout-horses pop_horses        
  ]  

  ask horses [
    set color brown ;horse color
    set ycor (-7 + random 14) ;horse location
    set xcor ((xcor - 7) + random 14)
    set heading random 360 ;horse heading
    set behavior 0 ;sets the horses to their initial behavior condition
    set size 1
  ]
  
   set-default-shape trucks "car" ;truck shape
  ask patch 0 0 [
   sprout-trucks pop_trucks        
  ]  

  ask trucks [
    set color red ;truck color
    set ycor (-7 + random 14) ;truck location
    set xcor ((xcor - 7) + random 14)
    set heading random 360 ;truck heading
    set behavior 0 ;sets the trucks to their initial behavior condition
    set size 1
  ]
end

to setup_vars ;;executed by setup
  
  ;;used for general calculation
  set size_patch 1000; in meters per side. 
  set max_food_in_a_patch 76602;expected yield of 1 sq km of land
  set kilojoule_conversion 4.184  ;4.184 kilojoules per Calorie.
  set sec_per_tick 60; based on program measurements
  set seconds_per_hour 3600
  set greatest_distance 0
  set food_humans 1
  set food_horses 1
  set food_trucks 1
  
  
  ;;for calculating kjoules for human movement
  set cal_per_min_kg 0.06 ;in units of Cal * 1/(sec*kg)
  set kg_per_individual 62 ;average human body mass
  set carry_volume_humans 2.2 ;in cubic m
  set squad_size_humans (max_food_in_a_patch / carry_volume_humans)
  
  
  ;;for calculating kjoules for horse movement
  set cal_per_hour_horses 2500 ;From National Academy's NRH's 2007 study
  set carry_volume_horses 10 ;in cubic m
  set squad_size_horses (ceiling(max_food_in_a_patch / carry_volume_horses))
  
  ;;for calculating kjoules for truck movement
  set cal_per_gallon 35000 ;kcal in a gallon of diesel
  set kilometers_per_gallon 6; avg fuel efficiency of a highly effecient loaded semi
  set carry_volume_trucks 200 ;in cubic m
  set squad_size_trucks (ceiling(max_food_in_a_patch / carry_volume_trucks))

  ask trucks [
      set speed_trucks 64.37; in km/h, originally 40 mph
      set dist_to_move_trucks  (speed_trucks * (sec_per_tick / seconds_per_hour)) ; km/h * (1h/3600sec * 60 sec/tick)
      set patches_to_move_trucks (dist_to_move_trucks / (size_patch / 1000))
  ]
  
  ask horses [
      set speed_horses 13; in km/h, from Sean's data for a trot speed
      ;lowered this speed b/c data was unavailale for calories burned by a canter, but is available for a trot
      set dist_to_move_horses (speed_horses * (sec_per_tick / seconds_per_hour))
      set patches_to_move_horses (dist_to_move_horses / (size_patch / 1000))
  ]
  
  ask humans [
      set speed_humans 4; 
      set dist_to_move_humans (speed_humans * (sec_per_tick / seconds_per_hour))
      set patches_to_move_humans (dist_to_move_humans / (size_patch / 1000)); 
  ]
  
  ;; NOTE:
  ;; dist to move and patches to move are currently the same because the patch size is a kilometer
  ;; this will change when/if the size is changed

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;main runtime function;;;;;;;;;;;;;;;;;;;;;main runtime function;;;;;;;;;;;;;;;main runtime function;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go_density_recruit ;;function executed by the "run" button
  
  set GAtrail .92328
  set GAsite 1.0
  set GAexpand 0.9836
  
  
  evaporate_trail   ;;;decrements all trails trail value (ctrl+F "evaporate trail" for details)
  
  
  
  ask humans [ ;splits the humans behavior into halves based on location.
    ;humans on the left will bring food to the left city and humans on the right will bring food to the right city.
      if  cityx != 0
 [
    set cityx 0
 ]
    
    
    
    
    if not can-move? 1 or pcolor = black[ ;if humans are near the world boundary, will turn 180 degrees and move away 1 unit
      rt 180 
     fd patches_to_move_humans
     set movement_humans (movement_humans + 1) 
   ]
    
    ;;At each tick, humans decide on an individual basis to execute one of six behviors. 
    ;;Different stimuli such as the presence of trails or food will cause humans to change their behaviors 
    ;;on an individual bases. 
    
    
    stop_search? ;function determining random chance of giving up (ctrl+F "stop_search?" for details)
    
    
    if behavior = 0 [ ;function for initial expansion of the humans (ctrl+F "move_away" for details)
      move_away
    ]
    
    if behavior = 1 [  ;function for random walking and food searching behavior (crtl+F "random_walk" or "check_food" for details)
      random_walk
      check_food
    ]
    
    if behavior = 2 [  ;function for trail following behavior (ctrl+F "scan_trail" for details)
      scan_trail
    ]   
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;returning to the city;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if behavior = 3 [  ;function for when the humans choose to return home without marking a trail (ctrl+F "return_home" for details)
      return_home
    ]
    
    if behavior = 4 [ ;function when humans choose to return home while marking a trail or incrementing existing trail (ctrl+F "color_trail" for details)
      color_trail
      return_home  
      
    ]
    if behavior = 6 [ ;function where humans use site fidelity to return to the last known food location (ctrl+F "find_food" for details)
      find_food
    ]
  ]
  
  
  
    ask horses [ ;splits the humans behavior into halves based on location.
    ;humans on the left will bring food to the left city and humans on the right will bring food to the right city.
      if  cityx != 0
 [
    set cityx 0
 ]
    
    
    
    
    if not can-move? 1 or pcolor = black[ ;if humans are near the world boundary, will turn 180 degrees and move away 1 unit
      rt 180 
     fd patches_to_move_horses
     set movement_horses (movement_horses + 1) 
   ]
    
    ;;At each tick, humans decide on an individual basis to execute one of six behviors. 
    ;;Different stimuli such as the presence of trails or food will cause humans to change their behaviors 
    ;;on an individual bases. 
    
    
    stop_search? ;function determining random chance of giving up (ctrl+F "stop_search?" for details)
    
    
    if behavior = 0 [ ;function for initial expansion of the humans (ctrl+F "move_away" for details)
      move_away
    ]
    
    if behavior = 1 [  ;function for random walking and food searching behavior (crtl+F "random_walk" or "check_food" for details)
      random_walk_horses
      check_food
    ]
    
    if behavior = 2 [  ;function for trail following behavior (ctrl+F "scan_trail" for details)
      scan_trail_horses
    ]   
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;returning to the city;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if behavior = 3 [  ;function for when the humans choose to return home without marking a trail (ctrl+F "return_home" for details)
      return_home_horses
    ]
    
    if behavior = 4 [ ;function when humans choose to return home while marking a trail or incrementing existing trail (ctrl+F "color_trail" for details)
      color_trail
      return_home_horses  
      
    ]
    if behavior = 6 [ ;function where humans use site fidelity to return to the last known food location (ctrl+F "find_food" for details)
      find_food_horses
    ]
  ]
    
      ask trucks [ ;splits the humans behavior into halves based on location.
    ;humans on the left will bring food to the left city and humans on the right will bring food to the right city.
      if  cityx != 0
 [
    set cityx 0
 ]
    
    
    
    
    if not can-move? 1 or pcolor = black[ ;if humans are near the world boundary, will turn 180 degrees and move away 1 unit
      rt 180 
     fd patches_to_move_trucks
     set movement_trucks (movement_trucks + 1) 
   ]
    
    ;;At each tick, humans decide on an individual basis to execute one of six behviors. 
    ;;Different stimuli such as the presence of trails or food will cause humans to change their behaviors 
    ;;on an individual bases. 
    
    
    stop_search? ;function determining random chance of giving up (ctrl+F "stop_search?" for details)
    
    
    if behavior = 0 [ ;function for initial expansion of the humans (ctrl+F "move_away" for details)
      move_away
    ]
    
    if behavior = 1 [  ;function for random walking and food searching behavior (crtl+F "random_walk" or "check_food" for details)
      random_walk_trucks
      check_food
    ]
    
    if behavior = 2 [  ;function for trail following behavior (ctrl+F "scan_trail" for details)
      scan_trail_trucks
    ]   
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;returning to the city;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if behavior = 3 [  ;function for when the humans choose to return home without marking a trail (ctrl+F "return_home" for details)
      return_home_trucks
    ]
    
    if behavior = 4 [ ;function when humans choose to return home while marking a trail or incrementing existing trail (ctrl+F "color_trail" for details)
      color_trail
      return_home_trucks  
      
    ]
    if behavior = 6 [ ;function where humans use site fidelity to return to the last known food location (ctrl+F "find_food" for details)
      find_food_trucks
    ]
  ]
  
  ;regrow_patches
  
  set time_ticks (time_ticks + 1)
  
  set calories_expended_humans (cal_per_min_kg * kg_per_individual / 60 * sec_per_tick * pop_humans * squad_size_humans * time_ticks / 1000 / 1000)
  set calories_expended_horses (cal_per_hour_horses / 60 * pop_horses * squad_size_horses * time_ticks / 1000 / 1000)
  set calories_expended_trucks (cal_per_gallon / kilometers_per_gallon * squad_size_trucks * movement_trucks / 1000 / 1000)
  
  set calories_collected_humans (food_humans * 2000)
  set calories_collected_horses (food_horses * 2000)
  set calories_collected_trucks (food_trucks * 2000)
  
  set net_calories_humans (calories_collected_humans - calories_expended_humans)
  set net_calories_horses (calories_collected_horses - calories_expended_horses)
  set net_calories_trucks (calories_collected_trucks - calories_expended_trucks)
  
  set delivered_over_transport_cal_humans (calories_collected_humans / calories_expended_humans)
  set delivered_over_transport_cal_horses (calories_collected_horses / calories_expended_horses)
  set delivered_over_transport_cal_trucks (calories_collected_trucks / calories_expended_trucks)
  
  set gigajoules_expended_humans (cal_per_min_kg * kg_per_individual * kilojoule_conversion / 60 * sec_per_tick * pop_humans * squad_size_humans * time_ticks / 1000 / 1000)
  set gigajoules_expended_horses (cal_per_hour_horses / 60 * kilojoule_conversion * pop_horses * squad_size_horses * time_ticks / 1000 / 1000)
  set gigajoules_expended_trucks (cal_per_gallon / kilometers_per_gallon * kilojoule_conversion * squad_size_trucks * movement_trucks / 1000 / 1000)
  
  set gigajoules_collected_humans (food_humans * 2000 * kilojoule_conversion) ;km harvested * Gcalories per km * cal-to-kilojoule conversion, units are Gjoule
  set gigajoules_collected_horses (food_horses * 2000 * kilojoule_conversion)
  set gigajoules_collected_trucks (food_trucks * 2000 * kilojoule_conversion)
  
  set food_joule_ratio_humans (gigajoules_expended_humans / food_humans)
  set food_joule_ratio_horses ( gigajoules_expended_horses / food_horses)
  set food_joule_ratio_trucks (gigajoules_expended_trucks / food_trucks)
  
  set gigajoules_total (gigajoules_expended_humans + gigajoules_expended_horses + gigajoules_expended_trucks) 
  set food_total (food_humans + food_horses + food_trucks)
  set movement_total (movement_humans + movement_horses + movement_trucks)
  
  
  
  tick ;next time step
  
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;human behavioral fuctions;;;;;;;;;;;;;;;;human behavioral fuctions;;;;;;;;;;;;;;;;human behavioral fuctions;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to return_home  ;function for human behavior when returning to the city 
  
  let max_road 0
  let x -1
  let y -1  
  let trail_follow? 0  
  let x1 cityx
  
  ifelse (distancexy cityx 0) > 0 [  ;if human is not at city, execute movement
    facexy cityx 0
    set curr_distance (distancexy cityx 0) ; registers current distance from city
    
    if curr_distance > greatest_distance [
     set greatest_distance curr_distance 
    ]
    
    
    rt random-normal 0 20  ;random wiggle movement
    ask patch-ahead 1 [
      set new_distance (distancexy x1 0)  ;registers future position from city
    ]
    if new_distance < curr_distance[ ;only moves if future position from city is closer than current position
      face patch-ahead 1
      forward distance patch-ahead .51 ;moves to the patch 1 unit ahead
      set movement_humans (movement_humans + 1)
      setxy  pxcor pycor ;centers on the patch after moving
    ]
  ]
  
  [ if has_food? = 1 [ ;increments the food collection counters on the respective side of the simulation upon returing food to the city
      set food_humans (food_humans + 1)
    
      ] 
  set has_food? 0
  
  while [x < 2] [
    set y -1
    while [y < 2] [ ;while loops used to ask all surrounding patches for trail
      if x != cityx or y != 0 [ ;does not look for trail on the city
        ask patch-at x y [
          if trail? > max_road [ ;sets maximum trail value to highest surrounding trail value
            set max_road trail?
          ]
        ]
      ]
      set y (y + 1)
    ] 
    set x (x + 1) 
  ]
  ifelse recruit = 1 [
    ifelse max_road > 0 [
      set xcor cityx
      set ycor 0
      while [xcor = cityx and ycor = 0 and behavior != 2] [ ;If human enters trail follow behavior, executes loop until human moves away from the city
        set heading (random 360)
        scan_ahead   ;scans 1 patch at every random heading
        if road_ahead >= (random-float max_road) [  ;random chance based on the maximum trail to follow current trail trail
          face patch-ahead 1
          fd distance patch-ahead .51 ;moves onto 1 patch ahead
          set movement_humans ((movement_humans + 1) )
          setxy pxcor pycor ;centers on current patch
          set behavior 2
        ]
      ]
    ]
    [ set heading (random 360) ;if no trail is present, human enters search mode
      set behavior 1
    ]
  ]
  [
    ifelse fidelity = 1 [      
      facexy foodx foody
      set behavior 6
    ]
    [ set heading (random 360)
      set behavior 1
    ]
  ]
  
  ]
  
end

to return_home_horses  ;function for human behavior when returning to the city 
  
  let max_road 0
  let x -1
  let y -1  
  let trail_follow? 0  
  let x1 cityx
  
  ifelse (distancexy cityx 0) > 0 [  ;if human is not at city, execute movement
    facexy cityx 0
    set curr_distance (distancexy cityx 0) ; registers current distance from city
    
    if curr_distance > greatest_distance [
      set greatest_distance curr_distance 
    ]
        
    rt random-normal 0 20  ;random wiggle movement
    ask patch-ahead 1 [
      set new_distance (distancexy x1 0)  ;registers future position from city
    ]
    
    if new_distance < curr_distance[ ;only moves if future position from city is closer than current position
      face patch-ahead 1
      forward distance patch-ahead .8 ;moves to the patch 1 unit ahead
      setxy  pxcor pycor ;centers on the patch after moving
    ]
  ]
  
  [ if has_food? = 1 [ ;increments the food collection counters on the respective side of the simulation upon returing food to the city
      set food_horses (food_horses + 1)
    
      ] 
  set has_food? 0
  
  while [x < 2] [
    set y -1
    while [y < 2] [ ;while loops used to ask all surrounding patches for trail
      if x != cityx or y != 0 [ ;does not look for trail on the city
        ask patch-at x y [
          if trail? > max_road [ ;sets maximum trail value to highest surrounding trail value
            set max_road trail?
          ]
        ]
      ]
      set y (y + 1)
    ] 
    set x (x + 1) 
  ]
  ifelse recruit = 1 [
    ifelse max_road > 0 [
      set xcor cityx
      set ycor 0
      while [xcor = cityx and ycor = 0 and behavior != 2] [ ;If human enters trail follow behavior, executes loop until human moves away from the city
        set heading (random 360)
        scan_ahead_horses   ;scans 1 patch at every random heading
        if road_ahead >= (random-float max_road) [  ;random chance based on the maximum trail to follow current trail trail
          face patch-ahead 1
          fd distance patch-ahead .8 ;moves onto 1 patch ahead
          set movement_horses (movement_horses + 1)
          setxy pxcor pycor ;centers on current patch
          set behavior 2
        ]
      ]
    ]
    [ set heading (random 360) ;if no trail is present, human enters search mode
      set behavior 1
    ]
  ]
  [
    ifelse fidelity = 1 [      
      facexy foodx foody
      set behavior 6
    ]
    [ set heading (random 360)
      set behavior 1
    ]
  ]
  
  ]
  
end

to return_home_trucks  ;function for human behavior when returning to the city 
  
  let max_road 0
  let x -1
  let y -1  
  let trail_follow? 0  
  let x1 cityx
  
  ifelse (distancexy cityx 0) > 0 [  ;if human is not at city, execute movement
    facexy cityx 0
    set curr_distance (distancexy cityx 0) ; registers current distance from city
    
    if curr_distance > greatest_distance [
      set greatest_distance curr_distance 
    ]
        
    rt random-normal 0 20  ;random wiggle movement
    ask patch-ahead 1 [
      set new_distance (distancexy x1 0)  ;registers future position from city
    ]
    if new_distance < curr_distance[ ;only moves if future position from city is closer than current position
      face patch-ahead 1
      forward distance patch-ahead patches_to_move_trucks ;moves to the patch 1 unit ahead
      setxy  pxcor pycor ;centers on the patch after moving
    ]
  ]
  
  [ if has_food? = 1 [ ;increments the food collection counters on the respective side of the simulation upon returing food to the city
      set food_trucks (food_trucks + 1)
    
      ] 
  set has_food? 0
  
  while [x < 2] [
    set y -1
    while [y < 2] [ ;while loops used to ask all surrounding patches for trail
      if x != cityx or y != 0 [ ;does not look for trail on the city
        ask patch-at x y [
          if trail? > max_road [ ;sets maximum trail value to highest surrounding trail value
            set max_road trail?
          ]
        ]
      ]
      set y (y + 1)
    ] 
    set x (x + 1) 
  ]
  ifelse recruit = 1 [
    ifelse max_road > 0 [
      set xcor cityx
      set ycor 0
      while [xcor = cityx and ycor = 0 and behavior != 2] [ ;If human enters trail follow behavior, executes loop until human moves away from the city
        set heading (random 360)
        scan_ahead_trucks   ;scans 1 patch at every random heading
        if road_ahead >= (random-float max_road) [  ;random chance based on the maximum trail to follow current trail trail
          face patch-ahead 1
          fd distance patch-ahead patches_to_move_trucks ;moves onto 1 patch ahead
          set movement_trucks (movement_trucks + 1)
          setxy pxcor pycor ;centers on current patch
          set behavior 2
        ]
      ]
    ]
    [ set heading (random 360) ;if no trail is present, human enters search mode
      set behavior 1
    ]
  ]
  [
    ifelse fidelity = 1 [      
      facexy foodx foody
      set behavior 6
    ]
    [ set heading (random 360)
      set behavior 1
    ]
  ]
  
  ]
  
end


to random_walk
  set color black
  let st_dev 0
  
  ;behavior executed during behavior 1
  if ticks mod 4 = 0 [
    rt random-normal 0 (st_dev * 180 / pi)
  ]
  fd .25   ;turns up to 30 degrees off of current heading and moves forward 1/4 of maximum speed
  set movement_humans (movement_humans + .25) 

  
end

to random_walk_horses
  set color brown
  let st_dev 0
  
  ;behavior executed during behavior 1
  if ticks mod 4 = 0 [
    rt random-normal 0 (st_dev * 180 / pi)
  ]
  fd .25   ;turns up to 30 degrees off of current heading and moves forward 1/4 of maximum speed
  set movement_horses (movement_horses + 1) 
  
end

to random_walk_trucks
  set color red
  let st_dev 0
  
  ;behavior executed during behavior 1
  if ticks mod 4 = 0 [
    rt random-normal 0 (st_dev * 180 / pi)
  ]
  fd .25   ;turns up to 30 degrees off of current heading and moves forward 1/4 of maximum speed
  set movement_trucks (movement_trucks + 1) 
  
end



to evaporate_trail
  
  
  ask patches with [trail? > 0] [

    let evapo 0
    
   set evapo Evaporation_rate
    
    set trail? (trail? * (1 - evapo))  ;trail evaporation function
    if trail? < .001 [set trail? 0]   ;if trail becomes almost undetectable, sets value to 0
    if pcolor != 62 [   ;trail is only visually represented on pixels without food
      if trail? >= 6 [set pcolor 99]  
      if trail? >= 5 and trail? < 6 [set pcolor 98]   ;color gets darker as trail gets weaker
      if trail? >= 4 and trail? < 5 [set pcolor 97]
      if trail? >= 3 and trail? < 4 [set pcolor 96]
      if trail? >= 2 and trail? < 3 [set pcolor 95]
      if trail? >= 1 and trail? < 2 [set pcolor 94]
      if trail? >= .1  and trail? < 1 [set pcolor 93] 
      if trail? >= .01 and trail? < .1 [set pcolor 92]
      if trail? = 0 and pcolor = 92 [set pcolor grey] 
    ]
  ]
  
end

to find_food
  
  set color blue ;humans turn blue while executing site fidelity
  
  if (abs xcor) < ( abs foodx + 2) and (abs xcor) > ( abs foodx - 2) [ ;if the human is within 2 pixels of last known food location, exits site fidelity behavior
    if (abs ycor) < ( abs foody + 2) and (abs ycor) > ( abs foody - 2) [
      set behavior 1
    ]
  ]
  facexy foodx foody ;moves towards last known food location
  rt (-20 + random 40)
  fd patches_to_move_humans
  set movement_humans (movement_humans + 1) 
  setxy xcor ycor
  
  
end

to find_food_horses
  
  set color blue ;humans turn blue while executing site fidelity
  
  if (abs xcor) < ( abs foodx + 2) and (abs xcor) > ( abs foodx - 2) [ ;if the human is within 2 pixels of last known food location, exits site fidelity behavior
    if (abs ycor) < ( abs foody + 2) and (abs ycor) > ( abs foody - 2) [
      set behavior 1
    ]
  ]
  facexy foodx foody ;moves towards last known food location
  rt (-20 + random 40)
  fd patches_to_move_horses
  set movement_horses (movement_horses + 1) 
  setxy xcor ycor
  
  
end

to find_food_trucks
  
  set color blue ;humans turn blue while executing site fidelity
  
  if (abs xcor) < ( abs foodx + 2) and (abs xcor) > ( abs foodx - 2) [ ;if the human is within 2 pixels of last known food location, exits site fidelity behavior
    if (abs ycor) < ( abs foody + 2) and (abs ycor) > ( abs foody - 2) [
      set behavior 1
    ]
  ]
  facexy foodx foody ;moves towards last known food location
  rt (-20 + random 40)
  fd patches_to_move_trucks
  set movement_trucks (movement_trucks + 1) 
  setxy xcor ycor
  
  
end

to stop_search?
  
  
  if random 10000 = 1 [  ;determines the percentage chance for humans to give up and return to the city
    set behavior 3
  ]
  
end


to move_away 
  
  ifelse not can-move? 1 
  [ set behavior 1 ]
  [ ifelse (xcor < 0) 
    [ ;probability to begin search is determined by GA and user parameters
      ifelse (random 10000 / 10000 < 1 - initial_expansion) 
      [ set behavior 1 ]
      [ set behavior 1 ] ;if search mode is not engaged, moves outward at full speed
    ]
    [  ifelse (random 10000 / 10000 < 1 - GAexpand)
      [ set behavior 1 ]
      [ set behavior 1 ];if search mode is not engaged, moves outward at full speed
    ]
  ]
    
end


to check_food 
  
  let x -1
  let y -1
  let seed_count 0
  let food? 0
  let p 0
  let rec_factor 0
  
  set recruit 0
  set fidelity 0
  
  if xcor = 0 [  ;defines trail creation probabiity based on Ga and user inputs
    set rec_factor lay_a_trail
  ]

  
  ask patch-here [ ;collects food on a patch
    if pcolor = 62[
      if count turtles-here >= 1  [
        set food? 1
        set ticks_since_harvesting 0
      ]
    ]
  ]
  
  if behavior = 1 or behavior = 2 and food? = 1[ ;executes once food has been collected
    set has_food? 1
    set seed_count 0
    set pcolor grey ;removes visual represenation of food from the patch
    while [x < 2] [ ;uses while loops to scan surrounding eight patches for food
      set y -1
      while [y < 2] [
        if (pxcor + x) > (- world-width / 2 + 1) and (pxcor + x) < (world-width / 2 - 1) [
          if (pycor + y) > (- world-height / 2 + 1) and (pycor + y) < (world-height / 2 - 1) [
            ask patch-at x y [
              if pcolor = 62 [
                set seed_count (seed_count + 1) ;number of uncollected food nearby
              ]
            ]
          ]
        ]
        set y (y + 1)
      ] 
      set x (x + 1) 
    ]
    set foodx xcor
    set foody ycor   
    set p (random 100 / 100)
    ifelse p <=  seed_count + rec_factor [ ;function to determine wether to lay a trail
      set behavior 4
    ]
    [set behavior 3
    ]
  ]
  ifelse xcor = 0 [ ;probability to use site fidelity or density recruitment upon finding a seed is determined by GA and user parameters
    if random-float 1 < ((Site_fidelity / 100) + seed_count) [
      set fidelity 1
    ]
    if random-float 1 < ((Density_recruit / 100) - seed_count) [
      set recruit 1
    ]
  ]
  [  if random-float 1 < (GAsite + seed_count) [
    set fidelity 1
  ]
  if random-float 1 < (GAtrail - seed_count) [
    set recruit 1
  ]
  ]

end

to scan_ahead ;humans look for trail directly infront of themselves
  
  let nx cityx
  
  if can-move? 1 [ ;checks for the world boundaries
    ask patch-ahead 1 [  
      ifelse trail? > 0 [ ;if trail ahead, return true
        set road_ahead trail?
        set dist distancexy nx 0
        ask humans [
          set trail_ahead 1
        ]
      ]
      [ set road_ahead 0
        ask humans [
          set trail_ahead 0
        ]
      ]
    ]
  ]
  
end

to scan_ahead_horses ;humans look for trail directly infront of themselves
  
  let nx cityx
  
  if can-move? 1 [ ;checks for the world boundaries
    ask patch-ahead 1 [  
      ifelse trail? > 0 [ ;if trail ahead, return true
        set road_ahead trail?
        set dist distancexy nx 0
        ask horses [
          set trail_ahead 1
        ]
      ]
      [ set road_ahead 0
        ask horses [
          set trail_ahead 0
        ]
      ]
    ]
  ]
  
end   

to scan_ahead_trucks ;humans look for trail directly infront of themselves
  
  let nx cityx
  
  if can-move? 1 [ ;checks for the world boundaries
    ask patch-ahead 1 [  
      ifelse trail? > 0 [ ;if trail ahead, return true
        set road_ahead trail?
        set dist distancexy nx 0
        ask trucks [
          set trail_ahead 1
        ]
      ]
      [ set road_ahead 0
        ask trucks [
          set trail_ahead 0
        ]
      ]
    ]
  ]
  
end    

to scan_trail ;function to follow trail trails
  
  let max_road 0
  let x2 xcor
  let y2 ycor
  let nx cityx
  let tdrop 0
  
  set curr_distance (distancexy cityx 0) ;will not follow trails that get closer to the city
  ask neighbors [
    if distancexy nx 0 > curr_distance[
      if trail? > 0 [
        if trail? > max_road [
          set max_road trail?
        ]                
      ]
    ]
  ]
  ifelse max_road > 0 [  
    while [xcor = x2 and ycor = y2] [
      set heading (random 360)
      set color white ;turn white while following a trail for visual effect
      scan_ahead 
      if road_ahead > random max_road [
        if dist >= distancexy cityx 0 [
          face patch-ahead 1
          fd distance patch-ahead 1
          set movement_humans (movement_humans + 1) 
          setxy pxcor pycor
        ]          
      ]
    ]
    
    if (random 10000) / 10000 < tdrop [ ;small chance to abandon a trail and begin searching
      set behavior 1
      set color black
      set heading random 360
    ]
  ]
  [
    set behavior 1 ;when the trail is gone, humans revert to search behavior
    set color black
    set heading random 360
  ]
  
end  

to scan_trail_horses ;function to follow trail trails
  
  let max_road 0
  let x2 xcor
  let y2 ycor
  let nx cityx
  let tdrop 0
  
  set curr_distance (distancexy cityx 0) ;will not follow trails that get closer to the city
  ask neighbors [
    if distancexy nx 0 > curr_distance[
      if trail? > 0 [
        if trail? > max_road [
          set max_road trail?
        ]                
      ]
    ]
  ]
  ifelse max_road > 0 [  
    while [xcor = x2 and ycor = y2] [
      set heading (random 360)
      set color white ;turn white while following a trail for visual effect
      scan_ahead_horses 
      if road_ahead > random max_road [
        if dist >= distancexy cityx 0 [
          face patch-ahead 1
          fd distance patch-ahead 1
          set movement_horses (movement_horses + 1) 
          setxy pxcor pycor
        ]          
      ]
    ]
    
    if (random 10000) / 10000 < tdrop [ ;small chance to abandon a trail and begin searching
      set behavior 1
      set color brown
      set heading random 360
    ]
  ]
  [
    set behavior 1 ;when the trail is gone, humans revert to search behavior
    set color brown
    set heading random 360
  ]
  
end  

to scan_trail_trucks ;function to follow trail trails
  
  let max_road 0
  let x2 xcor
  let y2 ycor
  let nx cityx
  let tdrop 0
  
  set curr_distance (distancexy cityx 0) ;will not follow trails that get closer to the city
  ask neighbors [
    if distancexy nx 0 > curr_distance[
      if trail? > 0 [
        if trail? > max_road [
          set max_road trail?
        ]                
      ]
    ]
  ]
  ifelse max_road > 0 [  
    while [xcor = x2 and ycor = y2] [
      set heading (random 360)
      set color white ;turn white while following a trail for visual effect
      scan_ahead_trucks
      if road_ahead > random max_road [
        if dist >= distancexy cityx 0 [
          face patch-ahead 1
          fd distance patch-ahead 1
          set movement_trucks (movement_trucks + 1) 
          setxy pxcor pycor
        ]          
      ]
    ]
    
    if (random 10000) / 10000 < tdrop [ ;small chance to abandon a trail and begin searching
      set behavior 1
      set color red
      set heading random 360
    ]
  ]
  [
    set behavior 1 ;when the trail is gone, humans revert to search behavior
    set color red
    set heading random 360
  ]
  
end  

to color_trail
  
  ask patch-here [ 
    if ((pycor != 0) or (pxcor != -100)) and ((pycor != 0) or (pxcor != 100)) [ ;will not lay trail ontop of the city
      ;function to lay down trail during behvaior 3
      set trail? (trail? + 1)  ;increments trail by 1 every tick
      if pcolor != 62 [   ;only draws trail on pixels without food
        if trail? >= 6 [set pcolor 99]     ;gradual progression from dark blue to white based on trail strength
        if trail? >= 5 and trail? < 6 [set pcolor 98]
        if trail? >= 4 and trail? < 5 [set pcolor 97]
        if trail? >= 3 and trail? < 4 [set pcolor 96]
        if trail? >= 2 and trail? < 3 [set pcolor 95]
        if trail? >= 1 and trail? < 2 [set pcolor 94]
        if trail? < 1  and pcolor = grey [set pcolor 93]   ;will not draw trail over food, only grey space
                                                                ; set trail_evaporation  trail_evaporation
      ]
    ]
  ]
  
  
end     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;plotting and data-exporting;;;;;;;;plotting and data-exporting;;;;;;;;;;;;;;;;;plotting and data-exporting;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to plot_joules_vs_time
  
    set-current-plot "Gigajoules expended v. Time" ;plot name
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy ticks gigajoules_expended_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy ticks gigajoules_expended_horses
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy ticks gigajoules_expended_trucks
    
end

to plot_joules_vs_distance
  
    set-current-plot "Gigajoules expended v. Greatest length of food network" ;plot name
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy greatest_distance gigajoules_expended_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy greatest_distance gigajoules_expended_horses
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy greatest_distance gigajoules_expended_trucks
    
end

to plot_joules_per_food_vs_distance
  
    set-current-plot "Gigajoules expended to harvest 1 km v. Greatest length of food network" ;plot name
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy greatest_distance food_joule_ratio_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy greatest_distance food_joule_ratio_horses 
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy greatest_distance food_joule_ratio_trucks 
    
end

to plot_delivered_vs_transport
    set-current-plot "Delivered GCalories v. Expended GCalories" ;plot name. 
    
    ;Keep in mind this is Giga-foodcalories.
    ;I know exactly how bad of a person this name makes me.
    
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy calories_expended_humans calories_collected_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy calories_expended_horses calories_collected_horses
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy calories_expended_trucks calories_collected_trucks
    
end

to plot_net_cal_vs_transport_cal
    set-current-plot "Net GCalories v. Expended GCalories"
    ;Sorry again for the GCal units~
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy calories_expended_humans net_calories_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy calories_expended_horses net_calories_horses
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy calories_expended_trucks net_calories_trucks
    
end

to plot_ratio_vs_time
      set-current-plot "Delivered/Transport GCal v. Time"
    ;one last use of GCal. sorry~
    set-current-plot-pen "humans"
    plot-pen-down
    plotxy time_ticks delivered_over_transport_cal_humans
    set-current-plot-pen "horses"
    plot-pen-down
    plotxy time_ticks delivered_over_transport_cal_horses
    set-current-plot-pen "trucks"
    plot-pen-down
    plotxy time_ticks delivered_over_transport_cal_trucks
end
@#$#@#$#@
GRAPHICS-WINDOW
670
52
1482
529
200
111
2.0
1
10
1
1
1
0
0
0
1
-200
200
-111
111
1
1
1
ticks
30.0

BUTTON
59
205
232
238
New Setup
setup_world\nif ticks > 4 [\nfile-delete \"netlogo food log.txt\"\n]\n
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

SLIDER
59
62
232
95
pop_humans
pop_humans
0
1000
150
10
1
humans
HORIZONTAL

BUTTON
424
206
600
239
Run
;main loop\ngo_density_recruit\n\n;plotting\nplot_joules_vs_time\nplot_joules_vs_distance\nplot_joules_per_food_vs_distance\nplot_delivered_vs_transport\nplot_net_cal_vs_transport_cal\nplot_ratio_vs_time
T
1
T
OBSERVER
NIL
R
NIL
NIL
1

SLIDER
240
159
416
192
Evaporation_rate
Evaporation_rate
.0001
.1
1.0E-4
.0001
1
NIL
HORIZONTAL

MONITOR
670
10
799
55
Kilometers harvested
food_total
0
1
11

SLIDER
423
110
598
143
Initial_expansion
Initial_expansion
0.9
1.0
0.9
.0001
1
NIL
HORIZONTAL

SLIDER
240
110
416
143
Lay_a_trail
Lay_a_trail
-9
1
-9
.01
1
NIL
HORIZONTAL

TEXTBOX
301
18
370
47
Setup
24
0.0
1

SLIDER
241
205
416
238
Abandon_trail
Abandon_trail
0
1
0.0016
.0001
1
NIL
HORIZONTAL

SLIDER
423
159
599
192
Turn_while_searching
Turn_while_searching
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
239
62
415
95
Density_Recruit
Density_Recruit
-100
100
100
.1
1
%
HORIZONTAL

SLIDER
423
62
598
95
Site_fidelity
Site_fidelity
-100
100
100
.1
1
%
HORIZONTAL

MONITOR
799
10
964
55
Total Gigajoules expended
gigajoules_total
0
1
11

SLIDER
60
110
232
143
pop_horses
pop_horses
0
1000
150
10
1
horses
HORIZONTAL

SLIDER
60
159
232
192
pop_trucks
pop_trucks
0
1000
150
10
1
trucks
HORIZONTAL

MONITOR
1020
10
1174
55
Gigajoules used by trucks
gigajoules_expended_trucks
0
1
11

MONITOR
1168
10
1325
55
Gigajoules used by horses
gigajoules_expended_horses
0
1
11

MONITOR
1319
10
1482
55
Gigajoules used by humans
Gigajoules_expended_humans
0
1
11

PLOT
8
346
402
538
Gigajoules expended v. Time
time
Gigajoules expended
0.0
2000.0
0.0
1000000.0
true
false
"" ""
PENS
"Humans" 1.0 0 -16777216 true "" ""
"Horses" 1.0 0 -10402772 true "" ""
"Trucks" 1.0 0 -2674135 true "" ""

PLOT
5
562
404
761
Gigajoules expended v. Greatest length of food network
Greatest Distance From City Traveled
Gigajoules Expended
0.0
200.0
0.0
1000000.0
true
false
"" ""
PENS
"Humans" 1.0 0 -16777216 true "" ""
"Horses" 1.0 0 -10402772 true "" ""
"Trucks" 1.0 0 -2674135 true "" ""

PLOT
541
558
1098
814
Gigajoules expended to harvest 1 km v. Greatest length of food network
Greatest Length of Food Network
Gigajoules Expended to Harvest 1 km
25.0
150.0
30.0
1000.0
false
false
"" ""
PENS
"humans" 1.0 0 -16777216 true "" ""
"trucks" 1.0 0 -2674135 true "" ""
"horses" 1.0 0 -10402772 true "" ""

TEXTBOX
294
310
373
339
Results
24
0.0
1

PLOT
1492
206
1839
423
Delivered GCalories v. Expended GCalories
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"humans" 1.0 0 -16777216 true "" ""
"horses" 1.0 0 -10402772 true "" ""
"trucks" 1.0 0 -2674135 true "" ""

PLOT
1491
10
1839
201
Net GCalories v. Expended GCalories
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"humans" 1.0 0 -16777216 true "" ""
"horses" 1.0 0 -10402772 true "" ""
"trucks" 1.0 0 -2674135 true "" ""

PLOT
1492
429
1841
626
Delivered/Transport GCal v. Time
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"humans" 1.0 0 -16777216 true "" ""
"horses" 1.0 0 -10402772 true "" ""
"trucks" 1.0 0 -2674135 true "" ""

MONITOR
528
418
656
463
NIL
squad_size_trucks
17
1
11

@#$#@#$#@
##Problem Definition
In two analyses of human ecology in cities, titled "Invention in the city: Increasing returns to patenting as a scaling function on metropolitan size" (2006) and "Growth, innovation, scaling, and the pace of life in cities," (2007) the author, Luis M.A. Bettencourt, discusses the effect of a city's size on its ecology. Bettencourt first found that larger cities are much more likely to house innovators and inventors, and showed a super-linear relationship between city size and the amount of inventors. Bettencourt then relates patterns of wealth, behavior, and infrastructure to city growth in the same superlinear manner, and postulates that this may promote "urbanism as a way of life." In essence, Bettencourt shows that larger cities have disproportionately more invention and wealth.

In these papers, however, the scaling relationship of food needs in city ecology is not mentioned. Given that other population-related qualities of the city follow a relationship of increasing returns, our team was curious about whether the food ecology of a city would be affected by the city's size in the same manner. This is especially important when discussing food production, gathering, and import into a metropolitan area. The goal of this project is to create a model that can accurately describe the scaling relationship between the two.

##Problem Solution
The simulation will make clear the relationship between a city's size and the impact on its food ecology. We plan on creating the city with initial populations of increasing magnitude. Agents emerging from the city will seek out snd return with food from the land surrounding the city. The energetic cost of collecting and importing the goods will be measured against how many kilocalories the agent has returned with, and charted on real-time graphs. By examining how the city expands its food collection efforts, we should be able to examine the relationship between food ecology and city size.

##Progress to Date
We have partnered with a team of ecologists and computer scientists at UNM. They are assisting us in developing the program, which is being written in NetLogo. Using their previous ecological models as guidelines and reference points, we are working on creating agents who follow an optimized search algorithm before returning to the city.

##Expected Results
After development is finished, the agents should be able to wander a distance from the city, and return after finding food. The area where they gathered the food from should degrade, and eventually replenish. The population within the city should suffer if their caloric intake is regularly not being met. The agents should have differing means of transport, and these means' ecology, specifically measured in energy spent per units of distances traveled per kilogram, should be analyzed.

##Team Members
Roderick Van Why
Nico Ponder
Israel Montoya
Walid Hasan
RJ Rosa



## CREDITS AND REFERENCES
This model was created by Daniel Washington and Dr. Kenneth Letendre
in the lab of Dr. Melanie Moses, Departments of Computer Science and
Biology, at the University of New Mexico. Funding was from the
National Science Foundation's program in Advancing Theory in Biology
(grant #EF 1038682).

More information about the model and the ants upon which the model is
based can be found in:

T.P. Flanagan, K. Letendre, W.R. Burnside, G.M. Fricke and M.E. Moses.
(2011). “How Ants Turn Information into Food.” Proceedings of the 2011
IEEE Conference on Artificial Life:178-185.

and

T.P. Flanagan, K. Letendre, W.R. Burnside, G.M. Fricke and M.E. Moses.
(2012). “The Effect of Colony Size and Food Distribution on Harvester
Ant Foraging.” PLoS ONE (in press).

Original simulation URL: https://sites.google.com/site/unmantbot/?pli=1
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
