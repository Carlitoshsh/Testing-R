#Package available on https://github.com/ropensci/MODIStsp
#install.packages("MODIStsp")
#install.packages("gWidgetsRGtk2")
#library(gWidgetsRGtk2)

#install.packages("rgdal")
library(MODIStsp)

options_file <- "D:/var/options.json"

# --> Launch the processing
MODIStsp(gui = FALSE, options_file = options_file)
