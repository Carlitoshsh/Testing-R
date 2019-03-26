#Package available on https://github.com/ropensci/MODIStsp

#install.packages("gWidgetsRGtk2")
#library(gWidgetsRGtk2)

#install.packages("MODIStsp")
library(MODIStsp)

options_file <- "C:/Users/carlo/Desktop/pruebas/options.json"

# --> Launch the processing
MODIStsp(gui = FALSE, options_file = options_file, verbose = TRUE)