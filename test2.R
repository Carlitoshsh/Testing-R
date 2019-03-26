#install.packages("maptools")

library(raster)
library(gdalUtils)
library(maptools)

#full_path <- "C:/Users/carlo/Desktop/pruebas/output2/MOD13C1.A2018337.006.2018365204359.hdf"
#rasterTemp <- raster(full_path)

#sds <- get_subdatasets(full_path)
# Isolate the name of the first sds
#name <- sds[1]

#output <- "C:/Users/carlo/Desktop/pruebas/output/test/test.tif"
#gdal_translate(sds[1], dst_dataset = output)

output2 <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/output/VI_16Days_005dg_v6/EVI/MOD13C1_EVI_2018_337.tif"
r <- raster(output2, varname="EVI")


#Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
munShapePath <- "C:/Users/carlo/Desktop/hi/MapaShape/Bogota.shp"
#Lectura del archivo .shp
munShape <- readShapePoly(munShapePath)
#Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
munShape.df <- as(munShape, "data.frame")
dataTemp <- extract(r, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)

