library(tidyverse)
library(osmdata)
library(leaflet)

# available_tags("leisure")

saunas <- getbb("Helsinki Finland") %>%
  opq() %>%
  add_osm_feature(key = "leisure", value = "sauna") %>%
  osmdata_sf()

# Some saunas are defined both with points and with polygons
# https://stackoverflow.com/a/63550875
saunas_points_defining_polygons <- osm_points(saunas, rownames(saunas$osm_polygons))

saunas_proper_points <- dplyr::anti_join(
  saunas$osm_points, 
  sf::st_drop_geometry(saunas_points_defining_polygons), 
  by = "osm_id") %>% 
  mutate(name = iconv(name, from = "UTF-8", to = "ISO-8859-1"))

boxstyle <- list(
  "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
  "font-size" = "6px",
  "border-color" = "rgba(0,0,0,0.5)"
) 

leaflet() %>% 
  addTiles(attribution = "OpenStreetMap contributors") %>% 
  addPolygons(data = saunas$osm_polygons,
              color = "red",
              label = ~iconv(saunas$osm_polygons$name, from = "UTF-8", to = "ISO-8859-1"),
              labelOptions = labelOptions(noHide = T, direction = "bottom",
                                          style = boxstyle)) %>% 
  addCircleMarkers(data = saunas_proper_points,
                   radius = 0.9,
                   color = "red",
                   label = ~saunas_proper_points$name,
                   labelOptions = labelOptions(noHide = T, direction = "bottom",
                                               style = boxstyle)) 
  


