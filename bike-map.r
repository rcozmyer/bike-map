#### Overview ####
# This script will take all of the fit file activities in a given folder and 
# then create a heatmap.
# It's roughly based on this page (which in turn is based on something else):
# https://sherif.io/2017/10/09/mapping-bike-rides.html

#### Libraries ####
#library(devtools)
#install_github("grimbough/FITfileR")

library(dplyr)
library(sf)
library(FITfileR)
library(ggmap)

#### Read fit files####
# TODO make this a function
fileslistfit <- list.files("./TTT_2021", pattern = "\\.fit$", full.names = TRUE)
fileslistgpx <- list.files("./TTT_2021", pattern = "\\.gpx$", full.names = TRUE)

first = 0
for (f in fileslistfit){
  # Maybe extract the filename as the ID for use in the feature?
  rideCoords <- records(readFitFile(f)) %>%
    bind_rows() %>% 
    arrange(timestamp) %>%
    select(position_long, position_lat)
  
  # This will remove any rows that are all NA from the dataframe
  rideCoords[rowSums(is.na(rideCoords)) != ncol(rideCoords),]
  # Converts the dataframe to a line object
  TTTLine <- st_as_sf(x=rideCoords[rowSums(is.na(rideCoords)) != ncol(rideCoords),],
                     coords = c("position_long", "position_lat"),
                     crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") %>%
    summarise(do_union = FALSE) %>%
    st_cast("LINESTRING")
  if (first == 0){
    yearlyTTTfit <- TTTLine
    first = 1
  }
  else{
    yearlyTTTfit <- st_union(TTTLine, yearlyTTTfit)
  }
}

#### Read gpx files####
# TODO write a function to read gpx files
first = 0
for (f in fileslistgpx){
  # Maybe extract the filename as the ID for use in the feature?
  st_layers(f)
  TTTLine <- st_read(f, layer = "tracks")

  if (first == 0){
    yearlyTTTgpx <- TTTLine$"geometry"
    first = 1
  }
  else{
    yearlyTTTgpx <- st_union(TTTLine$"geometry", yearlyTTTgpx)
  }
}

#### Combine the gpx and fit rides ####
# TODO combine the gpx and fit ride lines
yearlyTTT <- st_union(yearlyTTTgpx, yearlyTTTfit)

#### Map the Data ####
xmin <- round(st_bbox(yearlyTTT)$"xmin",1)
xmax <- round(st_bbox(yearlyTTT)$"xmax",1)
xmid <- (xmin + xmax)/2
xmin <- min(xmin, xmid-0.2) #make sure that the axis spans at least 0.4 degrees
xmax <- max(xmax, xmid+0.2) #make sure that the axis spans at least 0.4 degrees
ymin <- round(st_bbox(yearlyTTT)$"ymin",1)
ymax <- round(st_bbox(yearlyTTT)$"ymax",1)
ymid <- (ymin + ymax)/2
ymin <- min(ymin, ymid-0.2) #make sure that the axis spans at least 0.4 degrees
ymax <- max(ymax, ymid+0.2) #make sure that the axis spans at least 0.4 degrees
TTT_bb <- c( left = xmin-0.2, bottom = ymin-0.2, right = xmax+0.2, top = ymax+0.2)

# This sf_use_s2 parameter gives some sort of error "only first part of 
# geometrycollection is retained" which I don't like even though it doesn't  
# appear to affect the appear to affect the results.
sf_use_s2(FALSE) 

# Map the data with background for context
ggmap(get_stamenmap(bbox = TTT_bb, maptype='terrain-background'), maprange = FALSE)+
  geom_sf(data = yearlyTTT, inherit.aes = FALSE) +
  coord_sf(xlim = c(xmin, xmax), ylim = c(ymin, ymax)) + 
  scale_x_continuous(breaks = seq(xmin, xmax, by = .1)) + 
  scale_y_continuous(breaks = seq(ymin, ymax, by = .1))

# Map just the line data
yearlyTTT %>% 
  ggplot(aes()) +
  geom_sf() +
  coord_sf(xlim = c(xmin, xmax), ylim = c(ymin, ymax))
