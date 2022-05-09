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
fileslist <- list.files("./testdata", pattern = "\\.fit$", full.names = TRUE)

first = 0
for (f in fileslist){
  fname <- basename(f)
  rideCoords <- records(readFitFile(f)) %>%
    bind_rows() %>% 
    arrange(timestamp) %>%
    select(position_long, position_lat)
  
  # This will remove any rows that are all NA from the dataframe
  rideCoords[rowSums(is.na(rideCoords)) != ncol(rideCoords),]
  #Converts the dataframe to a line object
  TTTLine <- st_as_sf(x=rideCoords[rowSums(is.na(rideCoords)) != ncol(rideCoords),],
                     coords = c("position_long", "position_lat"),
                     crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") %>%
    summarise(do_union = FALSE) %>%
    st_cast("LINESTRING")
  if (first == 0){
    yearlyTTT <- TTTLine
    first = 1
  }
  else{
    yearlyTTTfit <- st_union(TTTLine, yearlyTTTfir)
  }
}

plot(yearlyTTTfit)

#### Read gpx files####
# TODO write a function to read gpx files


#### Combine the gpx and fit rides ####
# TODO combine the gpx and fit ride lines
#yearlyTTT <- st_union(yearlyTTTgpx, yearlyTTTfit)
yearlyTTT <- yearlyTTTfit

#### Map the Data ####
ggplot() +
  geom_sf(data = yearlyTTT) +
  scale_colour_gradient(low = "white", high = "black") +
  theme_void()

