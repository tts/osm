library(tidyverse)
library(osmdata)
library(sf)
library(tmap)

# Colonies in Denmark / Tanskan siirtolapuutarhat

data <- opq("Denmark") %>%
  add_osm_feature(key = "landuse", value = "allotments") %>%
  osmdata_sf()

saveRDS(data, "allotments_dk.RDS")

data <- readRDS("allotments_dk.RDS")

tmap_mode("view")

puutarhat_polygonit <- data$osm_polygons %>% 
  st_make_valid()

puutarhat_multipolygonit <- data$osm_multipolygons %>% 
  st_make_valid()

m <- tm_shape(puutarhat_polygonit) +
  tm_polygons(fill = "orange", col = "red",
              popup.vars = c("Nimi:" = "name")) +
  tm_shape(puutarhat_multipolygonit) +
  tm_polygons(fill = 'orange', col = "red",
              popup.vars = c("Nimi:" = "name")) +
  tm_basemap("OpenStreetMap.HOT") +
  tm_title("Tanskan siirtolapuutarhat, zoom: Kööpenhamina") +
  tm_credits("OSM | @ttso")

m + tm_view(set_view = c(12.3294, 55.6869, 10)) 

tmap_save(m, filename = "allotments_denmark.html", selfcontained = FALSE)
