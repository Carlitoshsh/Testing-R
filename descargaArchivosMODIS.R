#Package available on https://github.com/ropensci/MODIStsp
#install.packages("MODIStsp")
#install.packages("gWidgetsRGtk2")
#library(gWidgetsRGtk2)

#install.packages("rgdal")
library(MODIStsp)

# MODIStsp facilita el uso del paquete MODIS de la NASA, usando JSON
# out_folder : guarda los archivos .tif, que son posibles de rasterizar en R.
# Esta carpeta guarda el producto de MODIS, y adentro los indices solicitados (NDVI, EVI)
# out_folder_mod : guarda los archivos .hdf
options_file <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/options.json"

# --> Launch the processing
MODIStsp(gui = FALSE, options_file = options_file)
