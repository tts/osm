library(tidyverse)
library(osmdata)
library(leaflet)

# OSM Sophox SPARQL query https://tinyurl.com/yymrk7ol
# which doesn't return e.g. Uusi Sauna.
# See https://github.com/Sophox/sophox/issues/27

saunas <- getbb("Helsinki Finland") %>%
  opq() %>%
  add_osm_feature(key = "leisure", value = "sauna") %>%
  add_osm_feature(key = "access", value = "!private") %>%
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

m <- leaflet() %>% 
  addTiles() %>%
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.85)) %>%
  addPolygons(data = saunas$osm_polygons,
              color = "black",
              fillColor = "red",
              label = ~iconv(saunas$osm_polygons$name, from = "UTF-8", to = "ISO-8859-1"),
              labelOptions = labelOptions(noHide = T, direction = "bottom",
                                          style = boxstyle)) %>% 
  addCircleMarkers(data = saunas_proper_points,
                   radius = 5,
                   color = "black",
                   fillColor = "red",
                   weight = 2,
                   label = ~saunas_proper_points$name,
                   labelOptions = labelOptions(noHide = T, direction = "bottom",
                                               style = boxstyle)) 

mapview::mapshot(m, file = "saunas.png")
