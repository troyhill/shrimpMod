# shrimpMod
NetLogo population model for *Farfantepenaeus duorarum*



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
