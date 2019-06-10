extensions [ gis time rnd ]

globals [ bisc-outline     ; outline of BISC, vector shapefile
          bathymetry       ; BISC bathymetry, raster .asc
          submerged-area   ; submerged habitat
          seagrass         ; spatial extent of seagrass, from shapefile
          projection       ; projection
          patch-area-sqkm  ; area of patches in square km

          stage.data       ; time series data object - one value for entire bay, patch depth determined by subtraction and bathymetry
          salinity.data    ; spatial-time series data object
          temperature.data ;

          t-datetime       ; date-time objects
          t-date
          tick-date
]

; Turtles
breed [ shrimp a-shrimp ]

turtles-own [ mm           ; shrimp length
              energy       ; shrimp health
              sex          ; male/female
              status       ; live/dead
              life-stage   ; slightly duplicative of age
              Bsub1        ; growth rate from t-1
              D1-check
              D2-check
]

patches-own [ ; computed or time series patch variables
              submerged
              depth
              energy-value
              salinity
              temperature
              LP                        ; eq. 4 in Browder et al. 2002
              M1                        ; eq. 3 in Browder et al. 2002
              daily-survival            ; eq. 5 in Browder et al. 2002
]


;------------------------------------------------------------------------------
to setup
;------------------------------------------------------------------------------
  clear-all
  reset-ticks

  set bisc-outline      gis:load-dataset "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/BISC.shp"
  set bathymetry        gis:load-dataset "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/bisc_bath.asc"
  set salinity.data     gis:load-dataset "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/seasons/salinity_2010-dry.asc"
  set temperature.data  gis:load-dataset "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/seasons/temperature_2010-dry.asc"
  set projection        "WGS_84_Geographic"
  gis:set-world-envelope gis:envelope-of bathymetry

  set patch-area-sqkm (10)
  set-default-shape turtles "bug"

  setup-datetime

  ;display-bisc
  load-salinity-temperature
  load-bathy


  init-turtles 1000
end



;------------------------------------------------------------------------------
to go
;------------------------------------------------------------------------------
  if time:get "year" tick-date = 2019 [ stop ]
  if count turtles = 0                [ stop ]
  update-patches   ; update salinities and temperature

  ask turtles [
    shrimp-movement   ; shrimp movement restricted to bay
    shrimp-growth

    mortality
  ]

  ; kill dead turtles
  ask turtles with [status = "dead"] [ die ]

  ;update-globals
  tick
end





;------------------------------------------------------------------------------
to display-bisc
;------------------------------------------------------------------------------
  gis:set-drawing-color white
  gis:draw bisc-outline 1
end



;------------------------------------------------------------------------------
to load-bathy
;------------------------------------------------------------------------------
  ;gis:paint bathymetry 65
  gis:apply-raster bathymetry submerged
  ; set submerged-area patches with [ submerged < 0 ]
   set submerged-area patches with [ submerged < 0 and temperature > 0 ]
 ; ask patches with [ submerged < 0 and temperature > 0 ] set submerged-area 1
end


;------------------------------------------------------------------------------
to load-salinity-temperature
;------------------------------------------------------------------------------
  gis:paint salinity.data 65
  gis:apply-raster salinity.data salinity
  gis:apply-raster temperature.data temperature

  ask patches with [ salinity > -1 ] [
    set LP -4.6019 + (0.7039 * temperature) + (0.2186 * salinity) - (0.0250 * temperature * temperature) - (0.0077 * salinity * salinity) + (0.0115 * salinity * temperature) ; M1 from Browder et al. 2002
    set M1 (-1 * ln (e ^ LP)) * (((e ^ LP + 1) ^ -1) / 28)
    set daily-survival 1 ;e ^ (-1 * M1) ; daily probability of survival?
  ]
end

;------------------------------------------------------------------------------
to setup-datetime
;------------------------------------------------------------------------------
  set t-datetime time:create "2010-01-01 00:00"
  set t-date time:create "2010-01-01"
  ;set tick-date time:anchor-to-ticks t-datetime 6 "hours"
  set tick-date time:anchor-to-ticks t-date 1 "day"
end


;-------------------------------------------------------------------------
to init-turtles [number-of-turtles]
;-------------------------------------------------------------------------
  create-turtles number-of-turtles [
    setxy random-pxcor random-pycor
    set size 10; mm / 10
    set color pink
    ;; move each turtle to a random submerged patch
    move-to one-of submerged-area
  ]

  ask turtles [
    set mm  2  ; 8.74 + random-float 60.5
    set energy 100
    set sex one-of (list "male" "female")
    set status    "live"
    set life-stage "adult"
    set Bsub1 0.034 ; could also use zero
  ]
end



;------------------------------------------------------------------------------
to update-patches
;------------------------------------------------------------------------------
  ;if time:get "dayofyear" tick-date = 1
  if (time:show tick-date  "MM-dd" = "05-01") or (time:show tick-date  "MM-dd" = "10-01")
  [
    let yr ( word time:get "year" tick-date "-wet" )
    if time:show tick-date  "MM-dd" = "10-01" [ set yr ( word time:get "year" tick-date "-dry" ) ]
    set salinity.data     gis:load-dataset (word "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/seasons/salinity_" yr ".asc" )
    set temperature.data  gis:load-dataset (word "/opt/physical/troy/NetLogo 6.0.2/Projects/BISC_shrimp/BISC_GIS/seasons/temperature_" yr ".asc" )
    load-salinity-temperature
  ]
end








;------------------------------------------------------------------------------
to shrimp-movement  ;; turtle procedure -- chill when off black patches
;------------------------------------------------------------------------------
  look-around
  look-ahead
end


;------------------------------------------------------------------------------
to look-ahead
;------------------------------------------------------------------------------
ifelse [ submerged ] of patch-ahead 1 < 0
  [ fd 1 ]                  ;; its safe to go foward.
  [ lt random-float 360 ]   ;; Otherwise, turn left randomly
end



;------------------------------------------------------------------------------
to look-around
;------------------------------------------------------------------------------
  let total-patches  count patches in-radius 5
  if total-patches = count patches in-radius 5 with [ submerged < 0 ]
  [ rt random 100
    lt random 100
    fd random 2
  ]
end



;------------------------------------------------------------------------------
to get-away  ;; turtle procedure -- escape from black piles
;------------------------------------------------------------------------------
  ;look-ahead
  rt random 360
  fd random 2
end

;------------------------------------------------------------------------------
to wiggle ; turtle procedure
;------------------------------------------------------------------------------
  ;look-ahead
  fd 1
  rt random 30
  lt random 30
end









;------------------------------------------------------------------------------
;------ growth and reproduction
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
to shrimp-growth ; Browder et al. 1999. Temperature-driven growth
;------------------------------------------------------------------------------
  if temperature > 0 or temperature < 0 [
    let temp temperature
    let sal salinity

    let B max ( list (-0.12006 + ( 0.009219 * temp )- ( 0.00013 * temp ^ 2)) 0 ); growth rate
    let D1 ( 8.734 * EXP( B - 1 ) * EXP( Bsub1 ) ) ;
    let D2 ( 177.75 * (1 - EXP(-0.0082383)) + mm * EXP(-0.0082383) - mm ) ; 177.5 = maximum length, 0.0082383 = k

     ; now, calculate new length
     ifelse mm > 80
       [ set mm mm + D2 ]
         [ ifelse (mm <= 80) and (mm > 40)
           [ set mm mm + D1 * ((80 - mm) / 40) + D2 * ((mm - 40) / 40) ]
             [ set mm mm + D1 ]
           ]
     set Bsub1 B
     set D1-check D1
     set D2-check D2
     set size  mm / 10
  ]
end


;------------------------------------------------------------------------------
to shrimp-reproduction ; USGS life history report
;------------------------------------------------------------------------------
  ; females and males reach sexual maturity at 85 and 74 mm TL (Eldred et al. 1961
  ; maybe requires depths >= 4 meters


end


;------------------------------------------------------------------------------
;------ mortality functions (Browder et al. 2002)
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
to mortality ; Browder et al. 2002.
;------------------------------------------------------------------------------
  ;; get odds of physiological survival
  let temp temperature
  let sal salinity

  ;set daily-survival physio-survival temp sal ; modify patch variable
  ;; enforce mortality

  set status apply-survival-prob temp sal mm; modify turtle

end

;------------------------------------------------------------------------------
to-report physio-survival [ temp sal ]
;------------------------------------------------------------------------------
; temperature and salinity are numeric. reports daily **survival** probability
  ifelse temp > -50 and sal > -50
 [
  let LP1 -4.6019 + (0.7039 * temp) + (0.2186 * sal) + ; switchint original value, "0.2186", for "0.02186" in this formula results in more swift mortality
    (-0.0250 * temp ^ 2) + (-0.0077 * sal ^ 2) +
    (0.0115 * temp * sal)                   ; equation 4, using survival rate coefficients from Table 1
  let M1_int -1 * ln(exp(LP1)) * ((exp(LP1) + 1) ^ -1 ) / 28 ; equation 3
  let final-value exp(-1 * M1_int)                     ; equation 5
  report min (list final-value 1)
  ] [ report 1 ] ; if temperature or salinity are NAs, disregard mortality calculation for this time step (survival probability = 1
end


;------------------------------------------------------------------------------
to-report predation-survival [ total-length ] ; M2 in Browder et al. 1999
;------------------------------------------------------------------------------
; temperature and salinity are numeric. reports daily survival probability
 let A2   0.0274 ; predation mortality at 0 mm
 let M290 0.00274 ; predation mortality at 90 mm
 let B2 (ln(M290) - ln(A2)) / 90
 let M2 A2 * exp(B2 * total-length)
 report M2
end


;------------------------------------------------------------------------------
to-report apply-survival-prob  [ temp sal total-length]
;------------------------------------------------------------------------------
  ; set daily-survival physio-survival temperature salinity
  let stress-survival physio-survival temp sal
  let stress-death (1 - stress-survival)
  let fishing-mortality 0.003853
  if total-length < 78.4 [ set fishing-mortality 0 ]


  let predation predation-survival total-length
  let death-prob    stress-death + predation + fishing-mortality
  let survival-prob 1 - death-prob

  ;let probabilities (list probs 0.2 )

  ;let pairs [ (list "live" surv )  (list "dead" (1 - surv) ) ]
  ;report first rnd:weighted-one-of-list pairs [ [p] -> last p ]
  let probabilities  (list survival-prob death-prob ) ; [ daily-survival (1 - daily-survival)]
  let some_list ["live" "dead"]
  report first rnd:weighted-one-of-list (map list some_list probabilities) last
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1340
1621
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-280
280
-400
400
1
1
1
ticks
30.0

BUTTON
37
10
110
43
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
123
10
187
44
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
37
54
146
99
date
time:show tick-date \"yyyy-MM-dd\"
17
1
11

MONITOR
41
150
128
195
day of year
time:show tick-date  \"MM-dd\"
17
1
11

PLOT
7
262
207
412
shrimp length 
NIL
NIL
0.0
100.0
0.0
200.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "plot-pen-reset \nforeach sort turtles [ [t] -> ask t [ plot mm ] ]"

@#$#@#$#@
## WHAT IS IT?

A model of shrimp population dynamics in Biscayne Bay, in response to seasonal changes in salinity and temperature


## HOW IT WORKS

Shrimp behavior is modeled based on effects of salinity and/or temperature on growth and mortality. Shrimp (turtles) navigate the bay in a random walk pattern, exposing themselves to salinities and temperatures (patches) that vary on a wet/dry season basis (where wet season is May 01 - September 30). 

Salinity and temperature data are sourced from Miami-Dade Department of Environmental Resources Management and DataForEver. Data for each station are averaged over each wet/dry season and then spatially interpolated across the bay using a nearest-neighbor approach based on Voronoi tesselation. Nearest-neighbor was used because of convergence problems observed during inverse distance weighted interpolation. These interpolated rasters are not provided with the GitHub package because of size constraints.

Growth is modeled as a size- and temperature-dependent process following eq. 1-4 in Browder et al. 1999.

Physiological mortality is modeled as a function of salinity and temperature following eq. 3-5 in Browder et al. 2002. 

Predation mortality is modeled as a size-dependent process following eq. 6 in Browder et al. 2002. 

Fishing mortality is size-dependent and assumed to be a constant 0.003853 daily rate after shrimp reach 78.4 mm total length (Browder et al. 2002).

The sum of mortality from physiological, predation, and fishing pressures are applied to determine the probability of each shrimp's survival at each time step.


## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

Notice that variations in salinity and temperature are not adequate to lead to 
(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

Growth is temperature dependent but should be based on salinity and temperature. I was unable to recreate the analysis in Browder et al. 2002 so am using their earlier work which is limited to temperature, but which I could reproduce.

There is no reproduction in the model. 

Shrimp movement does not vary with life stage. 


## CREDITS AND REFERENCES

https://github.com/troyhill/shrimpMod
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
