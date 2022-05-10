# bike-map
Takes a folder of bike rides (or any type of activity probably? this can read gpx and fit) and then stacks them all on top of each other. Still needs a little bit of work  to make the plot presentable, but I've got an output!

Requires:
* [grimbough/FITfileR](https://github.com/grimbough/FITfileR) to read the fit files
* dplyr
* sf to handle spatial data
* ggmap to do the plotting (although right now it could probably just use "plot")

Inspired by (and less code stolen from than I originally would've guessed):
https://sherif.io/2017/10/09/mapping-bike-rides.html
https://macwright.com/2016/05/17/a-new-running-map-in-print.html

Here's what it all looks like - behold, all of the TTTs of 2021:

![TTT 2021](https://user-images.githubusercontent.com/51971787/167529676-a86e5e67-3e31-41a1-ae04-1e04a97bca4f.png)
