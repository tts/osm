library(tidyverse)
library(osmdata)
library(leaflet)

# ATMs

atms <- getbb("Helsinki Finland") %>%
  opq() %>%
  add_osm_feature(key = "amenity", value = "atm") %>%
  osmdata_sf()

m <- leaflet() %>% 
  addTiles() %>%
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.15)) %>%
  addCircleMarkers(data = atms$osm_points, radius = 3, color = "black")

mapview::mapshot(m, file = "atms.png")
