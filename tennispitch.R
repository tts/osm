library(tidyverse)
library(osmdata)
library(sf)
library(patchwork)

source("polygonangle.R")

get_data <- function(place) {
  tennis <- opq(place) %>%
    add_osm_feature(key = "sport", value = "tennis") %>%
    add_osm_feature(key = "leisure", value = "pitch") %>%
    osmdata_sf()
  
  return(tennis)
}

def_orientation <- function(data) {
  
  d <- data %>% 
    st_geometry() %>% 
    st_as_sf() 
  
  d_box <- pmap_dfr(d, min_box_sf) 
  
  d_box$range <- cut(d_box$angle, breaks=seq(0, 360, 30))
  
  range_count <- data.frame(d_box$range) %>%
    rename(range = d_box.range) %>%
    dplyr::count(., range)
  
  d_box_range <- left_join(d_box, range_count) %>% 
    rename(Range = range) %>% 
    mutate(South = angle + 180)
  
  return(d_box_range)
  
}

make_plot <- function(data, place) {
  p <- ggplot(data, aes(x = angle, fill = factor(n))) + 
    geom_histogram(breaks = seq(0, 360, 30), colour = "grey") + 
    geom_histogram(aes(x = South, fill = factor(n)), breaks = seq(0, 360, 30), colour = "grey") + 
    coord_polar(start = 4.71, direction = -1) + # 0/360 in East as radii, counterclockwise
    theme_minimal() + 
    theme(axis.text.y = element_blank(), 
          axis.ticks = element_blank(),
          axis.title = element_blank()) +
    scale_fill_brewer() + 
    guides(fill = guide_legend("Lkm")) +
    scale_x_continuous("", limits = c(0, 360),
                       breaks = seq(0, 360, 30),
                       labels = c(seq(0, 330, 30), "")) +
    labs(subtitle = place)
  return(p)
}

places <- c("Helsinki Finland", "Oulu Finland", "Suomi Finland", "Illinois US")
d <- map(places, get_data)

saveRDS(d, "tennisdata.RDS")
d <- readRDS("tennisdata.RDS")

geo <- purrr::map_depth(d, 1, function(x) {
  def_orientation(x$osm_polygons)
})

hki_p <- make_plot(geo[[1]], "Helsinki")
oulu_p <- make_plot(geo[[2]], "Oulu")
fi_p <- make_plot(geo[[3]], "Suomi")
il_p <- make_plot(geo[[4]], "Illinois USA")

hki_p + oulu_p + fi_p + il_p + plot_annotation(title = "Ulkotenniskenttien ilmansuunta",
                                      caption = "data OSM | kuva @ttso")

ggsave("tennis.png", width = 30, height = 20, dpi = 72, units = "cm", device = "png")


