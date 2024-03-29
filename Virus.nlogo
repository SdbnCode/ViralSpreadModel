turtles-own
  [ covid_positive?          ;; true if the individual currently has covid-19
    wearing_mask?            ;; true if the individual is wearing a mask
    remaining_immunity_weeks ;; weeks of immunity left for the individual
    infection_duration       ;; duration in weeks the individual has been infected
    individual_age ]         ;; age of the individual in weeks

globals
  [ percent_positive         ;; what percent of the population is covid-positive
    percent_immune           ;; what percent of the population is immune
    individual_lifespan      ;; expected lifespan of an individual
    reproduction_odds        ;; odds of an individual reproducing each tick
    environment_capacity     ;; carrying capacity of the environment
    immunity_period ]        ;; how long immunity lasts, in weeks

;; initialize the model
to setup
  clear-all
  define_parameters
  initialize_population
  calculate_statistics
  visualize_population
  reset-ticks
end

;; create a set number of individuals with some initially covid-positive
to initialize_population
  create-turtles population
    [ set shape "person" 
      setxy random-xcor random-ycor
      set individual_age random individual_lifespan
      set infection_duration 0
      set remaining_immunity_weeks 0
      set size 1.5  ;; makes individuals easier to spot
      regain_health
      set wearing_mask? random-float 100 < people-masked]
  ask n-of 10 turtles [ become_infected ]
end

;; procedures to change the state of health of the individuals
to become_infected
  set covid_positive? true
  set remaining_immunity_weeks 0
end

to regain_health
  set covid_positive? false
  set remaining_immunity_weeks 0
  set infection_duration 0
end

to develop_immunity
  set covid_positive? false
  set infection_duration 0
  set remaining_immunity_weeks immunity_period
end

;; set up model constants
to define_parameters
  set individual_lifespan 50 * 52      ;; lifespan in weeks
  set environment_capacity 300
  set reproduction_odds 0.01           ;; 1% reproduction chance
  set immunity_period 52               ;; immunity lasts one year
  set social-distancing 10             ;; intial level of social distancing
end

;; main model loop
to go
  ask turtles [
    age_individual
    random_move
    if covid_positive? [ resolve_infection ]
    ifelse covid_positive? [ transmit_virus ] [ reproduce ]
  ]
  calculate_statistics
  visualize_population
  tick
end

;; update statistics for the population
to calculate_statistics
  if count turtles > 0
    [ set percent_positive (count turtles with [ covid_positive? ] / count turtles) * 100
      set percent_immune (count turtles with [ is_immune? ] / count turtles) * 100 ]
end

;; update visuals based on health status
to visualize_population
  ask turtles
    [ set color ifelse-value covid_positive? [ red ] [ ifelse-value is_immune? [ grey ] [ green ] ] ]
end

;; procedures to manage individual aging and health status
to age_individual
  set individual_age individual_age + 1
  if individual_age > individual_lifespan [ die ]
  if is_immune? [ set remaining_immunity_weeks remaining_immunity_weeks - 1 ]
  if covid_positive? [ set infection_duration infection_duration + 1 ]
end

to random_move ;; makes individuals move randomly
  let move-distance 1
  ifelse any? other turtles in-radius 3
  [
    let distance-factor (100 - social-distancing) / 100
    set move-distance move-distance * distance-factor
  ]
  [
    set move-distance 1
  ]
  rt random 100
  lt random 100
  fd move-distance
end

;; handling virus transmission with mask and season modifiers
to transmit_virus
  let transmission_modifier 1
  if current-season = "Winter" [ set transmission_modifier 1.56 ]
  if current-season = "Summer" [ set transmission_modifier 0.54 ]
  ask turtles [
    if mask-effectiveness < 0.1 [set mask-effectiveness 0.1]]

  ask other turtles-here with [ not covid_positive? and not is_immune? ]
  [ if random-float 100 < (infectiousness * transmission_modifier) / (ifelse-value wearing_mask? [mask-effectiveness] [1])
      [ become_infected ] ]
end

;; resolution of infection, individuals recover or perish
to resolve_infection
  if infection_duration > duration
    [ ifelse random-float 100 < recovery-rate
      [ develop_immunity ]
      [ die ] ]
end

;; reproduction logic based on environment capacity
to reproduce
  if count turtles < environment_capacity and random-float 100 < reproduction_odds
    [ hatch 1
      [ set individual_age 1
        lt 45 fd 1
        regain_health ] ]
end

;; report immunity status
to-report is_immune?
  report remaining_immunity_weeks > 0
end

;; ensure parameters are defined for the user interface elements
to startup
  define_parameters ;; sets up constants used in the interface
end

@#$#@#$#@
GRAPHICS-WINDOW
270
0
600
331
-1
-1
9.2
1
10
1
1
1
0
1
1
1
-17
17
-17
17
1
1
1
ticks
30

SLIDER
40
155
240
188
duration
duration
0.0
99.0
20
1.0
1
weeks
HORIZONTAL

SLIDER
40
121
240
154
recovery-rate
recovery-rate
0.0
99.0
75
1.0
1
%
HORIZONTAL

SLIDER
40
87
240
120
infectiousness
infectiousness
0.0
99.0
75
1.0
1
%
HORIZONTAL

BUTTON
62
48
132
83
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
138
48
209
84
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
270
391
600
641
Populations
weeks
people
0
52
0
200
true
true
"" ""
PENS
"covid-19" 1 0 -2674135 true "" "plot count turtles with [covid_positive?]"
"immune" 1 0 -7500403 true "" "plot count turtles with [remaining_immunity_weeks > 0]"
"healthy" 1 0 -10899396 true "" "plot count turtles with [not covid_positive?]"
"total" 1 0 -13345367 true "" "plot count turtles\n"

SLIDER
40
10
234
43
population
population
10
environment_capacity
100
1
1
NIL
HORIZONTAL

MONITOR
275
335
375
380
NIL
percent_positive
1
1
11

MONITOR
395
335
495
380
NIL
percent_immune
1
1
11

MONITOR
505
335
605
380
years
ticks / 52
1
1
11

SLIDER
40
190
240
223
people-masked
people-masked
0
300
50
1
1
People
HORIZONTAL

SLIDER
40
230
240
263
mask-effectiveness
mask-effectiveness
0
100
50
1
1
%
HORIZONTAL

CHOOSER
40
305
240
350
current-season
current-season
"Winter" "Spring" "Summer" "Fall"
2

SLIDER
40
265
240
298
social-distancing
social-distancing
0
100
50
1
1
NIL
HORIZONTAL
@#$#@#$#@
## WHAT IS IT?

This simulation offers a glimpse into the dynamics of a COVID-19-like virus spreading within a population. It models the ebb and flow of infection, the protective effects of mask-wearing, and the process of gaining immunity post-infection.

## HOW IT WORKS

The agents in this environment represent people with varying health statuses. Initially, a subset is infected with the virus. These agents can transmit the virus based on proximity, mask usage, and the current season. The outcome of an infection may lead to either immunity or, in rarer cases, death.

## HOW TO USE IT

Click setup to populate the environment and introduce the initial infections. The go button starts the simulation, where agents interact based on the rules defined. Adjust the parameters with sliders to see how they affect the spread of the virus. Keep an eye on the monitors to track the percentage of the population that's infected or has developed immunity.

## THINGS TO NOTICE

Watch how mask usage and seasonal changes influence transmission rates. Observe the balance between the spread of infection and the development of immunity, which will affect the long-term outcome of the simulated epidemic.

## EXTENDING THE MODEL

The model could be expanded to include vaccination strategies, varying levels of social interaction, or more nuanced behaviors related to mask efficacy.

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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
