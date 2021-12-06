library(tidyverse)
library(osmdata)
library(leaflet)

# Buildings under construction

buildings <- getbb("Helsinki Finland") %>%
  opq() %>%
  add_osm_feature(key = "building", value = "construction") %>%
  osmdata_sf()

building_points_defining_polygons <- osm_points(buildings, rownames(buildings$osm_polygons))

building_proper_points <- dplyr::anti_join(
  buildings$osm_points, 
  sf::st_drop_geometry(building_points_defining_polygons), 
  by = "osm_id") 

boxstyle <- list(
  "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
  "font-size" = "6px",
  "border-color" = "rgba(0,0,0,0.5)"
) 

m <- leaflet() %>% 
  addTiles() %>%
  addPolygons(data = buildings$osm_polygons,
              color = "tomato",
              fillColor = "yellow",
              label = ~iconv(buildings$osm_polygons$name, from = "UTF-8", to = "ISO-8859-1"),
              labelOptions = labelOptions(noHide = T, direction = "bottom",
                                          style = boxstyle)) %>%
  addCircles(data = building_proper_points,
             radius = 20,
             color = "tomato",
             fillColor = "yellow",
             weight = 2)

mapview::mapshot(m, file = "buildings_construction.png")
