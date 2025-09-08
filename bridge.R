library(tidyverse)
library(osmdata)
library(leaflet)

# Private bridges in Finland, according to OSM (total: 41)

data <- opq("Mainland Finland") %>%
  add_osm_feature(key = "bridge", value = "yes") %>%
  add_osm_feature(key = "motor_vehicle", value = "private") %>%
  osmdata_sf()

saveRDS(data, "priv_bridges_fi.RDS")

# Due to the bbox coords, some are outside Finland proper
discard_these <- c("507251488","973282863","185964806","128921700","392782554",
                   "1199457231","189631751","373635641","504519145","504519139",
                   "1291195121")

discard_these <- as.numeric(discard_these)

data$osm_lines <- data$osm_lines %>%
  filter(!osm_id %in% discard_these)

m <- leaflet() %>% 
  setView(lat = 65, #.96895,
          lng = 26, #82192,
          zoom = 5) %>% 
  addTiles() %>% 
  addProviderTiles(providers$OpenStreetMap.HOT) %>% 
  addPolylines(data = data$osm_lines,
               popup = paste0(
                             "<b>Nimi: </b>",
                             data$osm_lines$name,
                             "<br>",
                             "<b>OSM-linkki: </b>",
                             '<a href="',
                             paste0('https://www.openstreetmap.org/way/',data$osm_lines$osm_id),
                             '" target="_blank">',
                             data$osm_lines$osm_id,
                             "</a>"),
               color = "red")

m



  