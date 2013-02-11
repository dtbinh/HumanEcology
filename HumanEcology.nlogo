globals [food_collection_left food_collection_right food_collection_total predatorx predatory pher_ahead new_distance curr_distance dist pile_radius GAdev GAevap GArecruit GAtrail_drop GAtrail GAsite GAexpand
         rfood_counter1 rfood_counter2 sfood_counter1 sfood_counter2 mfood_counter1 mfood_counter2 lfood_counter1 lfood_counter2 food_totall food_totalr food_total]

breed [humans human]

humans-own [trail_ahead behavior nestx boundary? has_food? foodx foody fidelity recruit]

patches-own [sfood? mfood? lfood? ofood? pheremone? ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;main setup function;;;;;;;;;;main setup function;;;;;;;;;;main setup function;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup_world

__clear-all-and-reset-ticks       
  setup_humans
  ask patches [
  set pcolor 61
  ]  
  go_density_recruit
  do-plotting-left
  if ticks > 100 [
    ask humans [
      set behavior 3
               ]
  ]
  
end

to setup_save  ;function re-generates a perviously saved pile configuration
  
  ask patches [  
    set pheremone? 0  ;resets all pheromone values
    set pcolor green  ;refreshes the world in base green color  
;    if pxcor < 1 and pxcor > -1 [
;      set pcolor black
;    ]  
    if lfood? = 1 [
      set pcolor 61  ;colors 61 dense piles
    ]
;    if mfood? = 1 [
;      set pcolor yellow  ;colors medium density piles
;    ]
;    if sfood? = 1 [
;      set pcolor 7  ;colors random seeds 
;    ]
;    if ofood? = 1 [
;      set pcolor 123  ;colors low density piles
;    ]
  ]
  ask humans [  ;resets all humans by removing existing humans
    die
  ]
  setup_humans  ;re-generates human city
  clear-all-plots  ;resets the graph
  reset-ticks  ;resets the time step

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;creates locations for food piles;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;to create_large_food ;function for dense food pile creation
;  
;  set pile_radius 100 ;creates a circle with an area of exactly 256 pixels
;  
;  ask patches [
;    set pcolor green ;;colors entire world green
;    if pxcor < 1 and pxcor > -1 [
;      set pcolor black
;    ]
;  ] 
;  let xl 1  ;local variable for the x location of large food
;  let yl 1  ;local variable for the y location of large food
;  let pile_true 1  ;defines feasible location for piles
;  let head 1
;  let pile_count 0  ;counter for existing piles
;  while [pile_count < Large_piles] [ ;iterates function until number of food piles is equal to the number in the slider
;    set pile_true 1 
;    set xl (-190 + random 180)   ;if piles are generated ontop of each other, picks a new random pile location
;    set yl (-90 + random 181)
;    ask patch xl yl [
;      repeat 360 [
;        set head (head + 1) ;scans all patches in a circle around pile location
;        ask patch-at-heading-and-distance head 10 [ 
;          if pcolor = 61 [
;            set pile_true 0  ;checks to see if piles are being generated ontop of each other
;          ]
;        ]
;      ]
;    ] 
;    if pile_true = 1 [
;      set pile_count (pile_count + 1) ;increments pile counter
;      ask patches [
;        if (distancexy xl yl) <= pile_radius [ ;;creates a circle of food with area equivalent to 256 seeds
;          set pcolor 61
;          ask patch-at 200 0 [
;            set pcolor 61
;          ]
;        ]
;      ]
;    ]
;  ]
;  set lfood_counter1 count patches with [pcolor = 61 and pxcor < 0]
;  set lfood_counter2 count patches with [pcolor = 61 and pxcor > 0]
;end


;to create_medium_food ;function for medium density food creation
;  
;  set pile_radius 9.027033336764101
;  let xm 1 ;pile x coordinate
;  let ym 1 ;pile y coordinate
;  let pile_true 1 ;checks for pile location validity
;  let head 1
;  let pile_count 0 ;value to determine number of generated piles
;  
;  while [pile_count < Medium_piles] [ ;iterates function until number of food piles is equal to the number in the slider
;    set pile_true 1
;    set xm (-190 + random 180)   ;if piles are generated ontop of each other, picks a new random pile location
;    set ym (-90 + random 181)
;    ask patch xm ym [
;      repeat 360 [
;        set head (head + 1) ;scans all patches in a circle around pile location
;        ask patch-at-heading-and-distance head 10 [ 
;          if pcolor = 61 or pcolor = yellow [ ;checks to see if piles are being generated ontop of each other
;            set pile_true 0
;          ]
;        ]
;      ]
;    ]
;    if pile_true = 1 [
;      set pile_count (pile_count + 1) ;increments pile counter
;      ask patches [
;        if (distancexy xm ym) <= pile_radius [ ;;creates a circle of food with area equivalent to 256 seeds
;          if random 4 < 1 [
;            set pcolor yellow
;            ask patch-at 200 0 [
;              set pcolor yellow
;            ]
;          ] 
;        ]
;      ]
;    ]
;  ]
;  set mfood_counter1 count patches with [pcolor = yellow and pxcor < 0]
;  set mfood_counter2 count patches with [pcolor = yellow and pxcor > 0]
;end
;
;
;
;to create_other_food ;function for medium density food creation
;  
;  set pile_radius 9.027033336764101
;  let xo 1 ;pile x coordinate
;  let yo  1 ;pile y coordinate
;  let pile_true 1 ;checks for pile location validity
;  let head 1
;  let pile_count 0 ;value to determine number of generated piles
;  
;  while [pile_count < Low_density_piles] [ ;iterates function until number of food piles is equal to the number in the slider
;    set pile_true 1
;    set xo (-190 + random 180)   ;if piles are generated ontop of each other, picks a new random pile location
;    set yo (-90 + random 181)
;    ask patch xo yo [
;      repeat 360 [
;        set head (head + 1) ;scans all patches in a circle around pile location
;        ask patch-at-heading-and-distance head 10 [ 
;          if pcolor = 61 or pcolor = yellow or pcolor = 123 [ ;checks to see if piles are being generated ontop of each other
;            set pile_true 0
;          ]
;        ]
;      ]
;    ]
;    if pile_true = 1 [
;      set pile_count (pile_count + 1) ;increments pile counter
;      ask patches [
;        if (distancexy xo yo) <= pile_radius [ ;;creates a circle of food with area equivalent to 256 seeds
;          if random 16 < 1 [
;            set pcolor 123
;            ask patch-at 200 0 [
;              set pcolor 123
;            ]
;          ] 
;        ]
;      ]
;    ]
;  ]
;  set sfood_counter1 count patches with [pcolor = 123 and pxcor < 0]
;  set sfood_counter2 count patches with [pcolor = 123 and pxcor > 0]
;end
;
;
;to create_small_food
;  
;  let num 0
;  while [num < Random_seeds] [  ;;colors individual patches until he total number is 512
;    ask one-of patches [ 
;      if pcolor = green [ ;will only generate on places without pre-existing food
;        if pxcor < -1 and pxcor > -198 [
;          set pcolor 7 
;          ask patch-at 200 0 [
;            set pcolor 7
;          ]
;          set num (num + 1)  ;increments sparse food counter
;        ]
;      ]
;    ]
;  ]
;  set rfood_counter1 count patches with [pcolor = 7 and pxcor < 0]
;  set rfood_counter2 count patches with [pcolor = 7 and pxcor > 0]
;end



to setup_humans
  
  set-default-shape humans "dot" ;human shape
  ask patch 0 0 [
    sprout-humans city_size        
  ]  

  ask humans [
    set color black ;human color
    set ycor (-7 + random 14) ;human location
    set xcor ((xcor - 7) + random 14)
    set heading random 360 ;human heading
    set behavior 0 ;sets the humans to their initial behavior condition
    set size 1
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;main runtime function;;;;;;;;;;;;;;;;;;;;;main runtime function;;;;;;;;;;;;;;;main runtime function;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go_density_recruit ;;function executed by the "run" button
  
  ;P61etermined GA parameters are defined here  
  set GArecruit -.369849
  set GAtrail_drop .00114605
  set GAevap .0250054
  set GAdev .269567
  set GAtrail .92328
  set GAsite 1.0
  set GAexpand 0.9836
  
  
  if  ticks > 5000 [  ;simulation resets after 5000 ticks
    set food_collection_total 0
    set food_collection_right 0
    set food_collection_left 0
    clear-patches
    clear-all-plots
    clear-turtles
    reset-ticks
;    create_large_food
;    create_medium_food
;    create_small_food
;    create_other_food 
    setup_humans
  ]
  
  
  evaporate_trail   ;;;decrements all trails pheremone value (ctrl+F "evaporate trail" for details)
  
  
  
  ask humans [ ;splits the humans behavior into halves based on location.
    ;humans on the left will bring food to the left nest and humans on the right will bring food to the right nest.
      if  nestx != 0
 [
    set nestx 0
 ]
    
    
    
    
    if not can-move? 1 or pcolor = black[ ;if humans are near the world boundary, will turn 180 degrees and move away 1 unit
      rt 180 
     fd 1 
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
    ;;;;;;;;;returning to the nest;;;;;;;;;;;
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
  
  tick ;next time step
  
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;human behavioral fuctions;;;;;;;;;;;;;;;;human behavioral fuctions;;;;;;;;;;;;;;;;human behavioral fuctions;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to return_home  ;function for human behavior when returning to the nest 
  
  let max_pher 0
  let x -1
  let y -1  
  let trail_follow? 0  
  let x1 nestx
  
  ifelse (distancexy nestx 0) > 0 [  ;if human is not at nest, execute movement
    facexy nestx 0
    set curr_distance (distancexy nestx 0) ; registers current distance from nest
    rt random-normal 0 20  ;random wiggle movement
    ask patch-ahead 1 [
      set new_distance (distancexy x1 0)  ;registers future position from nest
    ]
    if new_distance < curr_distance[ ;only moves if future position from nest is closer than current position
      face patch-ahead 1
      forward distance patch-ahead 1 ;moves to the patch 1 unit ahead
      setxy  pxcor pycor ;centers on the patch after moving
    ]
  ]
  
  [ if has_food? = 1 [ ;increments the food collection counters on the respective side of the simulation upon returing food to the nest
    if xcor = 0 [
;      set food_collection_left (food_collection_left + 1) 
;      set food_totall (food_totall + 1)
;    ]

    set food_collection_total (food_collection_total + 1)
      set food_total (food_total + 1)
    
  ]  ] 
  set has_food? 0
  
  while [x < 2] [
    set y -1
    while [y < 2] [ ;while loops used to ask all surrounding patches for pheremone
      if x != nestx or y != 0 [ ;does not look for pheromone on the nest
        ask patch-at x y [
          if pheremone? > max_pher [ ;sets maximum pheremone value to highest surrounding pheremone value
            set max_pher pheremone?
          ]
        ]
      ]
      set y (y + 1)
    ] 
    set x (x + 1) 
  ]
  ifelse recruit = 1 [
    ifelse max_pher > 0 [
      set xcor nestx
      set ycor 0
      while [xcor = nestx and ycor = 0 and behavior != 2] [ ;If human enters trail follow behavior, executes loop until human moves away from the nest
        set heading (random 360)
        scan_ahead   ;scans 1 patch at every random heading
        if pher_ahead >= (random-float max_pher) [  ;random chance based on the maximum pheremone to follow current pheremone trail
          face patch-ahead 1
          fd distance patch-ahead 1 ;moves onto 1 patch ahead
          setxy pxcor pycor ;centers on current patch
          set behavior 2
        ]
      ]
    ]
    [ set heading (random 360) ;if no pheremone is present, human enters search mode
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
  
  if pxcor = 0 
  [ set st_dev turn_while_searching
  ]  
  ;behavior executed during behavior 1
  if ticks mod 4 = 0 [
    rt random-normal 0 (st_dev * 180 / pi)
  ]
  fd .25   ;turns up to 30 degrees off of current heading and moves forward 1/4 of maximum speed
  
end





to evaporate_trail
  
  
  ask patches with [pheremone? > 0] [

    let evapo 0
    
    if pxcor = 0  ;defines trail evaporation consthuman based on GA and user input parameters
     
    
    [ set evapo Evaporation_rate
    ]

    
    set pheremone? (pheremone? * (1 - evapo))  ;pheremone evaporation function
    if pheremone? < .001 [set pheremone? 0]   ;if pheremone becomes almost undetectable, sets value to 0
    if pcolor != 61 and pcolor != yellow and pcolor != 123 and pcolor != 7 [   ;pheremone is only visually represented on pixels without food
      if pheremone? >= 6 [set pcolor 99]  
      if pheremone? >= 5 and pheremone? < 6 [set pcolor 98]   ;color gets darker as pheremone gets weaker
      if pheremone? >= 4 and pheremone? < 5 [set pcolor 97]
      if pheremone? >= 3 and pheremone? < 4 [set pcolor 96]
      if pheremone? >= 2 and pheremone? < 3 [set pcolor 95]
      if pheremone? >= 1 and pheremone? < 2 [set pcolor 94]
      if pheremone? >= .1  and pheremone? < 1 [set pcolor 93] 
      if pheremone? >= .01 and pheremone? < .1 [set pcolor 92]
      if pheremone? = 0 and pcolor = 92 [set pcolor green] 
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
  fd 1
  setxy xcor ycor
  
  
end

to stop_search?
  
  
  if random 10000 = 1 [  ;determines the percentage chance for humans to give up and return to the nest
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
    if pcolor = 61 or pcolor = yellow or pcolor = 7 or pcolor = 123[
      if count turtles-here >= 1  [
        set food? 1
        
        ;decrements food counters and updates real-time graphs for each food source
        
        if pcolor = 61 [ ;dense food
          if pxcor = 0 [
            set lfood_counter1 (lfood_counter1 - 1)
          ]

        ]
        
;        if pcolor = yellow [ ;medium density food
;          ifelse pxcor < 0 [
;            set mfood_counter1 (mfood_counter1 - 1)
;          ]
;          [ set mfood_counter2 (mfood_counter2 - 1)
;          ]
;        ]
;        
;        if pcolor = 7 [ ;low density food
;          ifelse pxcor < 0 [
;            set rfood_counter1 (rfood_counter1 - 1)
;          ]
;          [ set rfood_counter2 (rfood_counter2 - 1)
;          ]
;        ]
;        
;        if pcolor = 123 [ ;random food
;          ifelse pxcor < 0 [
;            set sfood_counter1 (sfood_counter1 - 1)
;          ]
;          [ set sfood_counter2 (sfood_counter2 - 1)
;          ]
;        ]
      ]
    ]
  ]
  
  if behavior = 1 or behavior = 2 and food? = 1[ ;executes once food has been collected
    set has_food? 1
    set seed_count 0
    set pcolor green ;removes visual represenation of food from the patch
    while [x < 2] [ ;uses while loops to scan surrounding eight patches for food
      set y -1
      while [y < 2] [
        if (pxcor + x) > (- world-width / 2 + 1) and (pxcor + x) < (world-width / 2 - 1) [
          if (pycor + y) > (- world-height / 2 + 1) and (pycor + y) < (world-height / 2 - 1) [
            ask patch-at x y [
              if pcolor = 61 or pcolor = yellow or pcolor = 7 or pcolor = 123[
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

to scan_ahead ;humans look for pheromone directly infront of themselves
  
  let nx nestx
  
  if can-move? 1 [ ;checks for the world boundaries
    ask patch-ahead 1 [  
      ifelse pheremone? > 0 [ ;if pheremone ahead, return true
        set pher_ahead pheremone?
        set dist distancexy nx 0
        ask humans [
          set trail_ahead 1
        ]
      ]
      [ set pher_ahead 0
        ask humans [
          set trail_ahead 0
        ]
      ]
    ]
  ]
  
end      

to scan_trail ;function to follow pheromone trails
  
  let max_pher 0
  let x2 xcor
  let y2 ycor
  let nx nestx
  let tdrop 0
  
  if pxcor = 0 

  [ set tdrop abandon_trail
  ]
  
  set curr_distance (distancexy nestx 0) ;will not follow trails that get closer to the nest
  ask neighbors [
    if distancexy nx 0 > curr_distance[
      if pheremone? > 0 [
        if pheremone? > max_pher [
          set max_pher pheremone?
        ]                
      ]
    ]
  ]
  ifelse max_pher > 0 [  
    while [xcor = x2 and ycor = y2] [
      set heading (random 360)
      set color white ;turn white while following a trail for visual effect
      scan_ahead 
      if pher_ahead > random max_pher [
        if dist >= distancexy nestx 0 [
          face patch-ahead 1
          fd distance patch-ahead 1
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


to color_trail
  
  ask patch-here [ 
    if ((pycor != 0) or (pxcor != -100)) and ((pycor != 0) or (pxcor != 100)) [ ;will not lay pheromone ontop of the nest
      ;function to lay down pheremone during behvaior 3
      set pheremone? (pheremone? + 1)  ;increments pheremone by 1 every tick
      if pcolor != 61 and pcolor != yellow and pcolor != 123 and pcolor != 7 [   ;only draws pheremone on pixels without food
        if pheremone? >= 6 [set pcolor 99]     ;gradual progression from dark blue to white based on pheremone strength
        if pheremone? >= 5 and pheremone? < 6 [set pcolor 98]
        if pheremone? >= 4 and pheremone? < 5 [set pcolor 97]
        if pheremone? >= 3 and pheremone? < 4 [set pcolor 96]
        if pheremone? >= 2 and pheremone? < 3 [set pcolor 95]
        if pheremone? >= 1 and pheremone? < 2  [set pcolor 94]
        if pheremone? < 1  and pcolor = green [set pcolor 93]   ;will not draw pheremone over food, only green space
                                                                ; set trail_evaporation  trail_evaporation
      ]
    ]
  ]
  
  
end     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;plotting and data-exporting;;;;;;;;plotting and data-exporting;;;;;;;;;;;;;;;;;plotting and data-exporting;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to do-plotting-left
  set-current-plot "User controlled human city" ;plot name
  if plot? [
    set-current-plot-pen "large piles"
    plot-pen-down
    plotxy ticks lfood_counter1;count patches with [pcolor = 61 and pxcor < 0] ;plot high density food quhumanity in 61
;    set-current-plot-pen "medium piles"
;    plot-pen-down
;    plotxy ticks mfood_counter1;count patches with [pcolor = yellow and pxcor < 0] ;plot medium density food quhumanity in yellow
;    set-current-plot-pen "random food"
;    plot-pen-down
;    plotxy ticks rfood_counter1;count patches with [pcolor =  7 and pxcor < 0] ;plot random food distribution quhumanity in white
;    set-current-plot-pen "sparse piles"
;    plot-pen-down
;    plotxy ticks sfood_counter1;count patches with [pcolor = 123 and pxcor < 0] ;plot low density food quhumanity in brown
  ]
  if not plot? [   
    ;clear-all-plots    ;if plot switch is off, clears all plot lines and stops drawing plot values
    set-current-plot-pen "large piles"
    plot-pen-up 
;    set-current-plot-pen "medium piles"
;    plot-pen-up 
;    set-current-plot-pen "random food"
;    plot-pen-up 
;    set-current-plot-pen "sparse piles"
;    plot-pen-up 
  ]
end

;to do-plotting-right
;  set-current-plot "GA human city" ;plot name
;  if plot_2? [
;    set-current-plot-pen "large piles"
;    plot-pen-down
;;    plotxy ticks lfood_counter2 ;plot high density food quhumanity in 61
;;    set-current-plot-pen "medium piles"
;;    plot-pen-down
;;    plotxy ticks mfood_counter2 ;plot medium density food quhumanity in yellow
;;    set-current-plot-pen "random food"
;;    plot-pen-down
;;    plotxy ticks rfood_counter2 ;plot random food distribution quhumanity in white
;;    set-current-plot-pen "sparse piles"
;;    plot-pen-down
;;    plotxy ticks sfood_counter2 ;plot low density food quhumanity in brown
;  ]
;  if not plot_2? [   ;if plot switch is off stops drawing plot values
;    set-current-plot-pen "large piles"
;    plot-pen-up 
;;    set-current-plot-pen "medium piles"
;;    plot-pen-up 
;;    set-current-plot-pen "random food"
;;    plot-pen-up 
;;    set-current-plot-pen "sparse piles"
;;    plot-pen-up 
;  ]
;end

to save_pile_config
  
  ask patches [
    set lfood? 0 ;resets all different pile configurations to 0
;    set mfood? 0
;    set sfood? 0
;    set ofood? 0    
    if pcolor = 7 [set sfood? 1]  ;defines existing food locations and stores them in variables
    if pcolor = yellow [set mfood? 1]
    if pcolor = 61 [set lfood? 1]
    if pcolor = 123  [set ofood? 1]
  ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
497
23
1309
456
200
100
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
-100
100
1
1
1
ticks
30.0

BUTTON
102
239
277
274
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
194
141
366
174
City_size
City_size
1
1000
211
1
1
humans
HORIZONTAL

BUTTON
289
239
466
275
Run
go_density_recruit\n;do-plotting-right\ndo-plotting-left\n;test
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
100
377
276
410
Evaporation_rate
Evaporation_rate
.0001
.1
0.0998
.0001
1
NIL
HORIZONTAL

PLOT
681
454
1088
579
User controlled human city
time
food 
0.0
600.0
0.0
300.0
true
true
"" ""
PENS
"large piles" 1.0 0 -2674135 true "" ""
"medium piles" 1.0 0 -1184463 true "" ""
"sparse piles" 1.0 0 -5825686 true "" ""
"random food" 1.0 0 -16777216 true "" ""

MONITOR
1216
409
1308
454
food collected
food_collection_total
0
1
11

SLIDER
290
333
466
366
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
100
332
276
365
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
262
30
412
52
Setup
18
0.0
1

BUTTON
102
189
276
222
Save Layout
save_pile_config
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
289
189
466
222
Load Layout
setup_save
NIL
1
T
OBSERVER
NIL
L
NIL
NIL
1

SWITCH
1087
545
1177
578
plot?
plot?
0
1
-1000

SLIDER
100
418
275
451
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
289
377
482
410
Turn_while_searching
Turn_while_searching
0
1
1
.01
1
NIL
HORIZONTAL

SLIDER
101
293
277
326
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
291
293
466
326
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
498
410
571
455
total food
food_total
17
1
11

BUTTON
322
79
385
112
Hole
go_density_recruit\ndo-plotting-left\nif ticks > 100 [\n ask humans [\n  set behavior 3\n            ]\n]
T
1
T
OBSERVER
NIL
H
NIL
NIL
1

BUTTON
141
76
289
109
Remove Pheromones
ask patches [\n set pheremone? 0\n ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This is a model of ant colony foraging behavior, based on the behavior and foraging ecology of harvester ants (genus Pogonomyrmex). This behavior is an example of a system where the simple behaviors of individuals (the ants) result in the emergent behavior of the complex system that is the ant colony. In particular, this model focuses on two strategies for information use and sharing:

- Pheromone recruitment, where ants leave trails from food sources back to the nest, which other ants can follow to find sites where other ants have found food previously.  This allows ants to share information about where food has been found, and where there may be more food.  
- Site fidelity, where individual ants remember the location where they last found food, and return to that location to search for more food without recruiting other ants to the site.  This is a strategy for using individual rather than shared information.

This model demonstrates how ant colony behavior can be more effective as a whole unit than as individual ants. The user is able to control the ants on the left side of the simulation, by adjusting sliders that control aspects of the ants' behavior, and see a real-time comparison to optimized ant behavior on the right side.

## HOW IT WORKS

The ants in the simulation follow four distinct behaviors.

- Initial expansion: At the beginning of the simulation, all ants start at the nest, and move away from the nest to cover ground and distribute themselves around their territory before beginning to search.  (Distance_to_walk slider)
- Random search: Searching ants move at 1/4 their maximum speed (as when traveling away from or returning to the nest, following trails, or returning to known foraging sites) and make random turns while looking for food. (Turn_while_searching slider)
- Returning to the nest: When they find food, ants return to the nest, and may draw pheromone or move towards the nest at full speed. (site_fidelity slider)  
- Leaving the nest: Ants decide to follow pheromone trails from the nest, or to return to the last place the ant found food, or begin a random search for food at the nest. (Density_recruit, Lay_a_trail, and evaporation_rate sliders)

The right side of the simulation is optimized using a genetic algorithm. Genetic algorithms are an optimization scheme inspired by natural selection.  The behavior of the ants in this simulation is controlled by the selection of various parameters (such as a parameter that determines how much ants turn as they search for food, or how fast pheromone trails evaporate from the grid) and the effectiveness of the ant behaviors at collecting food depends on these parameter values.  The genetic algorithm creates a random population of parameter sets, and tests each of these parameter sets for their ability to collect food quickly by running the model with each set of parameters.  It selects successful parameter sets, recombines them with other sets, and introduces occasional random mutation into each parameter.  It repeats this process over many generations until it converges on an optimal parameter set.

In the simulation, the ant colony on the right side of the grid is controlled by the parameters selected by the genetic algorithm.  The colony on the left side is controlled by the user, via sliders that set the values for the parameters that determine the ants' behaviors.  Can you find parameter combinations that beat the genetic algorithm?  One approach may be to continulously tune parameters as the model runs to adjust the ants' behaviors to the food available on the grid over time.  This may allow more efficient food collection because the genetic algorithm cannot change its parameters from moment to moment.  It will be a greater challenge to find a single set of parameters that beat the genetic algorithm in the long term. 

## HOW TO USE IT

The simulation window is split into two halves. The right half is controlled by an optimized parameter set, and the left half is controlled by the user via the sliders. There are 7 sliders that alter behavior and 5 sliders that can change the initial setup. 

The behavior sliders:

- Initial_expansion determines how far ants travel from the nest at the beginning of each simulation.  This parameter determines the probability each tick that a traveling ant will stop traveling and begin to search.  With larger values, ants tend to begin searching closer to the nest; with smaller values, ants tend to begin searching farther away.  
- Turn_while_searching determines how much ants turn during their random search for food. With high values, ants turn more and search more thoroughly in a local area; with low values, ants turn less and cover more distance.  
- Lay_a_trail determines ants' likelihood of laying pheromone trails as they return to the nest after finding food.  With higher values, ants are more likely to leave trails.  A value of 1 means that ants will lay a pheromone trail every time they find food.  With values less than 1, the tendency to leave trails is also influenced by the presence of other food an ant senses nearby - ants more frequently leave trails to places where there is other food for nestmates to find.  
- Site_fidelity determines ants' likelihood of deciding to return to the current location after delivering food to the nest.  This allows individual ants to make use of personal memory to return to places where they have found food previously, and where more food may be found.  As above, with higher values, ants are more likely to decide to return to the current location.  A value of 1 means ants return to the location every time they find food.  With values less than 1, this is also influenced by the presence of other food in the immediate area.  
- Density_Recruit determines ants' likelihood of following pheromone trails, if they are present, from the nest after delivering food.  With increasing values, ants are more likely to follow trails from the nest.  This allows ants to travel to sites where food has been found by other ants.  Note that the decision to follow trails conflicts with the decision to return to the last site where the ant has found food, as an ant can't do both.  Therefore an optimal strategy for making use of both individual and shared information must strike a balance between these two.  Because ants with individual knowledge of sites where more food is present should return to those sites instead of following pheromone trails, an ant's tendency to follow trails from the nest decreases with the amount of other food in the area where it last found food.  
- Abandon_trail determine the probability each tick that an ant following a pheromone trail will leave the trail and begin searching.  Ants in nature sometimes abandon pheromone trails before reaching their end in order to search for other nearby foods that have not been discovered yet.  
- Trail_evaporation determines the rate that pheromone trails evaporate from the grid.  Pheromone trails evaporate so that ants tend to follow trails to places where food has been found more recently.  For high values, pheromone trails evaporate more quickly; for low values, pheromone trails are more permanent.

The setup sliders influence: Colony size (ant_number) and food quantity (large_piles, low_density_piles, medium_piles, random_food)


## THINGS TO NOTICE

The simulation provides real time feedback through the graphs at the bottom of the screen and the boxes at the bottom of the runtime windows. The monitors give real time information about how much food has been collected on each side of the simulation. The graphs show how much of each food type is remaining. These graphs may be turned off to increase runtime speed.


## THINGS TO TRY

Can you beat the ideal colony?  
The goal for the user in this simulation is to find a set of behaviors that can consistently beat the computer controlled counterpart.  Experiment with the sliders described in "How It Works" above.  Try different values for each slider one at a time and observe how it changes the behavior of the ants on the left side of the simulation.  After learning how each of the sliders changes the ant's behavior, can you come up with a different combination of parameter values that collects food faster than the genetic algorithm?  You may be able to beat the genetic algorithm by managing the sliders' values over time to change the ants behaviors according to circumstances within a particular run, such as when an ant discovers the large pile of seeds.  It may be a bigger challenge to find a single set of parameters that beat the genetic algorithm over many runs.

If you can beat the computer with a set of parameters on a standard 50 ant colony, try to scale it up! Experiment with 10- or 100- ant colonies and see if they behave as effectivey if there are more or fewer ants. In addition to adding or subtracting ants, you can see how to optimize the collection behavior if there is more or less food. Is it easier to find new parameters that beat the genetic algorithm for colonies of different sizes or different food distributions?  Why might this be?


## NETLOGO FEATURES

Netlogo has numerous data exportation features and graphing capabilities. These are utilized in this model through the plots at the bottom of the screen. Additionally, the program can be made to export comprehensive data on each run to a word doument which can then be analyzed in Excel or Matlab.



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
