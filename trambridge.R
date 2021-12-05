library(tidyverse)
library(osmdata)
library(leaflet)

# Tram bridge(s) under construction

bridges <- getbb("Helsinki Finland") %>%
  opq() %>%
  add_osm_feature(key = "bridge", value = "yes") %>%
  add_osm_feature(key = "construction", value = "tram") %>%
  osmdata_sf()

m <- leaflet() %>% 
  addTiles() %>%
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.15)) %>%
  addPolylines(data = bridges$osm_lines,
               color = "red")

mapview::mapshot(m, file = "trambridge.png")
