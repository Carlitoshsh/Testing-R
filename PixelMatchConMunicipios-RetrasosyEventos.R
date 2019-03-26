#**Manejo de librerías**#
#Instalación de ,ibrerías necesarias, 
#sólo se debe hacer una única vez, se instala para el sistema
install.packages("rasterVis")
install.packages("maptools")
install.packages("maps")

#Cargar las librerías necesarias para correr el progerama
#Se debe hacer siempre que se abra R
library(raster)
library(ncdf4)
library(maptools)

# Se conviere la fecha debido al formato MODIS
convert_to_normal_date <-
  function(dayofyear, year) {
    as.Date(dayofyear, origin = paste(year,"-12-31", sep=""))
  }

#**Extracción de los valores de los pixeles de los archivos nc4 a los poligonos de los municipios - Datos obtenidos por el sensor e indices Acumulados**#
#Nota: estos cálculos pueden tardar varias horas, para el periodo definido 2007 -2016 el procesamiento de este paso duró aproximadamente 16 horas

# ** tif en QGis ** < ** hdf en RStudio** 
# Bogota, ejemplo para el match.


#Definición del periodo en el cual se van a relizar los calculos. Debe existir un archivo .nc4 por cada mes
years <- 2002:2018
months <- c('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')

#Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
munShapePath <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/mapa municipios/Municipios wgs84_Disolv.shp"
#Lectura del archivo .shp
munShape <- readShapePoly(munShapePath)
#Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
munShape.df <- as(munShape, "data.frame")
#Contador de mes. En este caso son 120 meses
month_number <- 1
#Tabla final donde se guardaran todos los valores de cada municipio. Se inicializa con un valor basura que luego sera reemplazado
data_table <- 0

#Algoritmo para realizar la extracción de los valores de los pixeles en cada municipio
#Ciclos que nos permiten iterar sobre cada uno de los archivos correspondientes a un mes en el periodo definido
for (year in years) {
  for (month in months) {
    #Ruta donde se encuentran todos los archivos .nc4 correspondientes a los datos obtenidos por el sensor ya convertidos a las unidade deseadas
    dir = "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/output/VI_16Days_005dg_v6/EVI/"
    #Ruta donde se encuentran todos los archivos .nc4 que contienen el Indice Puntual calculado (Alteraciones) previamente en el anterior script
    # dirPI = "D:/jd/clases/UDES/articulo Daniel/datosNasa/DataIndPuntual/"
    full_path = paste0(dir, 'MOD13C1_EVI_', year, '_', month, ".tif")
    # full_pathPI = paste0(dirPI, 'Rainf_f_tavgTair_f_inst', year, month, ".nc4")
    #Se abre el archivo .nc4 como un raster
    #Por cada una de las variables se debe crear un raster diferente
    #Raster de la temperatura obtenida por el sensor
    rasterTemp <- raster(full_path, varname="Tair_f_inst")
    #Raster de la precipitación obtenida por el sensor
    rasterPrec <- raster(full_path, varname="Rainf_f_tavg")
    #Raster del indice puntual de la temperatura
    #rasterTempPI <- raster(full_pathPI, varname="Tair_f_inst")
    #Raster del indice puntual de la precipitación
    #rasterPrecPI <- raster(full_pathPI, varname="Rainf_f_tavg")
    
    #Se hace uso de la función extract con cada uno de los raster y el archivo .shp abierto previamente (munShape) para la extracción de los valores de los pixeles en cada municipio
    #La función extract recibe un raster y un archivo con los poligonos de los municipios (argumentos 1 y 2), los demas argumentos son parametros que no se usan para nuestros calculos a excepción del parametro normalizeWeights y weights
    #Parametro weights: Permite incluir a los calculos, pixeles que no estan contenidos totalmente en los poligonos. Con este parametro activo la funcion retorna una matriz por cada poligono que contiene los pixeles parcialmente incluidos en el poligono, sus valores, y el porcentaje del pixel que se encuentra en dicho poligono
    #Parametro normalizeWeights: Permite saber que porcentaje del poligono es ocupado por cada pixel.  De esta forma podemos calcular un promedio ponderado para obtener el valor final de la variable en cada municipio
    dataTemp <- extract(rasterTemp, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)
    dataPrec <- extract(rasterPrec, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE, factors=TRUE, sp=FALSE)
    #dataTempPI <- extract(rasterTempPI, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)
    #dataPrecPI <- extract(rasterPrecPI, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE, factors=TRUE, sp=FALSE)
    
    #Variable que contiene el total de municipios
    qtyMun <- 1122
    #Matriz auxiliar donde vamos a almacenar los valores finales de todas las variables y los datos del municipio por cada periodo. Más adelante esta matriz se unirá a la matriz principal que contendrá los resultados para todos los periodos
    data = array(0, c(qtyMun,11))
    
    
    #Ciclo para de acuerdo a las matrices obtenidas con la función extract obtener el promedio ponderado de los pixeles en los municipios y así obtener los valores finales de cada variable en el municipio    
    for(i in 1:qtyMun){
      #Variables para el cálculo de la precipitación
      #Vector que contiene los valores de los pixeles encontrados por la función extract en un municipio
      valuesP <- dataPrec[[i]][, 2]
      #Vector que contiene los pesos de los pixeles encontrados por la función extract en un municipio (Porcentaje del poligono que ocupa cada pixel)
      weightsP <- dataPrec[[i]][, 3]
      #Variable donde se almacenará el valor final luego de calcular el promedio ponderado
      precMun <- 0
      
      #Se crean las mismas variables para temperatura, indice puntual temperatura e indice puntual precipitación
      
      valuesT <- dataTemp[[i]][, 2]
      weightsT <- dataTemp[[i]][, 3]
      tempMun <- 0
      
      
      #Algoritmo que calcula el promedio ponderado de acuerdo a los  vectores creado anteriormente
      #Como algunos pixeles del raster no contienen valores, es decir que el valor es "NA", en caso de que otros pixeles en el municipio si tengan algún valor se reemplazan los "NA" por el promedio de los demas valores. De esta forma no se afectan los cálculos
      for(j in 1:length(valuesT)){
        
        if(is.na(valuesT[j])){
          tempMun = tempMun + (mean(valuesT, na.rm=TRUE) *weightsT[j])
          precMun = precMun + (mean(valuesP, na.rm=TRUE) *weightsP[j])
        }else{      
          tempMun = tempMun + (valuesT[j]*weightsT[j])
          precMun = precMun + (valuesP[j]*weightsP[j])
        }
        
      }
      #Vector con los nombres de cada una de las columnas que va a tener el archivo
      columns <- c("ID", "Codigo DANE", "Año", "Mes", "Fecha","Número de mes", "Codigo DANE-mes","Temperatura", "Precipitación", "Alt Temp", "Alt Prec" )
      #Asignación del vector de nombres a la matriz
      colnames(data) <- columns
      #Se obtiene el código dane del municipio con el dataFrame que contiene los atributos del archivo .shp
      DANE_code = munShape.df[i,"Codigo_DAN"]
      #Se obtiene la fecha en el formato deseado
      date <- format(as.Date(paste0(year,month, "01"), "%Y%m%d"), "%Y%m")
      
      #Se guardan en la matriz auxiliar los campos requeridos.
      data[i,1] = i
      data[i,2] = DANE_code
      data[i,3] = year
      data[i,4] = month
      data[i,5] = date
      data[i,6] = month_number
      #Campo CodigoDane - número de mes
      data[i,7] = paste0(DANE_code, "-", month_number )
      data[i,8] = tempMun
      data[i,9] = precMun
      
      
    }
    
    #Como ya se mencionó, data_table contendrá la tabla final de los municipios, incialmente se había creado con un valor basura por lo que en la primera iteración se debe reemplazar este valor basura por los calculos realizados para el primer periodo
    if(month_number == 1){
      data_table = data
      #La tabla con los datos de cada mes que se vaya calculando (data) se une a la tabla principal (data_table) con la función rbind
    }else{
      data_table = rbind(data_table, data)
    }
    
    #Se suma uno al contador de meses debido a que ya finalizó el procesamiento del mes
    month_number = month_number + 1
    
  }
}

#Si se quieren ver los resultados obtenidos hasta el momento se puede usar la siguiente linea para convertir la matriz a un archivo .csv que se peude visualizar en Excel
write.csv(data_table, file = "Datos_Brutos_Alteraciones.csv")



# #Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
# munShapePath <- "D:/jd/clases/UDES/MAPAS PROYECTOS/mapa municipios/Municipios wgs84_Disolv.shp"
# #Lectura del archivo .shp
# munShape <- readShapePoly(munShapePath)
# #Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
# munShape.df <- as(munShape, "data.frame")
# #Tabla final donde se guardaran todos los valores de cada municipio. Se inicializa con un valor basura que luego sera reemplazado
# data_table_prom <- 0

# #Contador de mes
# month_number <- 1

# months <- c('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')

# for (month in months){
#   print(month)
#   #Ruta donde se encuentran todos los archivos .nc4 promedio multianual
#   dir = "D:/jd/clases/UDES/articulo Daniel/datosNasa/DataPromMultianual/"
#   full_path = paste0(dir, 'PMAMonth', month, ".nc4")
#   #Se abre el archivo .nc4 como un raster
#   #Por cada una de las variables se debe crear un raster diferente
#   #Raster del promedio de  la temperatura
#   rasterTemp <- raster(full_path, varname="Tair_f_inst")
#   #Raster del promedio de  la precipitación
#   rasterPrec <- raster(full_path, varname="Rainf_f_tavg")
  
  
#   #Se hace uso de la función extract con cada uno de los raster y el archivo .shp abierto previamente (munShape) para la extracción de los valores de los pixeles en cada municipio
#   #La función extract recibe un raster y un archivo con los poligonos de los municipios (argumentos 1 y 2), los demas argumentos son parametros que no se usan para nuestros calculos a excepción del parametro normalizeWeights y weights
#   #Parametro weights: Permite incluir a los calculos, pixeles que no estan contenidos totalmente en los poligonos. Con este parametro activo la funcion retorna una matriz por cada poligono que contiene los pixeles parcialmente incluidos en el poligono, sus valores, y el porcentaje del pixel que se encuentra en dicho poligono
#   #Parametro normalizeWeights: Permite saber que porcentaje del poligono es ocupado por cada pixel.  De esta forma podemos calcular un promedio ponderado para obtener el valor final de la variable en cada municipio
#   dataTemp <- extract(rasterTemp, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)
#   dataPrec <- extract(rasterPrec, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE, factors=TRUE, sp=FALSE)
  
  
#   #Variable que contiene el total de municipios
#   qtyMun <- 1122
#   #Matriz auxiliar donde vamos a almacenar los valores finales de todas las variables y los datos del municipio por cada periodo. Más adelante esta matriz se unirá a la matriz principal que contendrá los resultados para todos los periodos
#   data = array(0, c(qtyMun,5))
  
  
#   #Ciclo para de acuerdo a las matrices obtenidas con la función extract obtener el promedio ponderado de los pixeles en los municipios y así obtener los valores finales de cada variable en el municipio    
#   for(i in 1:qtyMun){
#     #Variables para el cálculo de la precipitación
#     #Vector que contiene los valores de los pixeles encontrados por la función extract en un municipio
#     valuesP <- dataPrec[[i]][, 2]
#     #Vector que contiene los pesos de los pixeles encontrados por la función extract en un municipio (Porcentaje del poligono que ocupa cada pixel)
#     weightsP <- dataPrec[[i]][, 3]
#     #Variable donde se almacenará el valor final luego de calcular el promedio ponderado
#     precMun <- 0
    
#     #Se crean las mismas variables para temperatura
    
#     valuesT <- dataTemp[[i]][, 2]
#     weightsT <- dataTemp[[i]][, 3]
#     tempMun <- 0
    
#     #Algoritmo que calcula el promedio ponderado de acuerdo a los  vectores creado anteriormente
#     #Como algunos pixeles del raster no contienen valores, es decir que el valor es "NA", en caso de que otros pixeles en el municipio si tengan algún valor se reemplazan los "NA" por el promedio de los demas valores. De esta forma no se afectan los cálculos
#     for(j in 1:length(valuesT)){
      
#       if(is.na(valuesT[j])){
#         tempMun = tempMun + (mean(valuesT, na.rm=TRUE) *weightsT[j])
#         precMun = precMun + (mean(valuesP, na.rm=TRUE) *weightsP[j])
#       }else{      
#         tempMun = tempMun + (valuesT[j]*weightsT[j])
#         precMun = precMun + (valuesP[j]*weightsP[j])
        
#       }
      
#     }
#     #Vector con los nombres de cada una de las columnas que va a tener el archivo
#     columns <- c("ID", "Codigo DANE", "Mes","Prom_Temperatura", "Prom_Precipitación")
#     #Asignación del vector de nombres a la matriz
#     colnames(data) <- columns
#     #Se obtiene el código dane del municipio con el dataFrame que contiene los atributos del archivo .shp
#     DANE_code = munShape.df[i,"Codigo_DAN"]
    
    
#     #Se guardan en la matriz auxiliar los campos requeridos.
#     data[i,1] = i
#     data[i,2] = DANE_code
#     data[i,3] = month
#     data[i,4] = tempMun
#     data[i,5] = precMun
#       data[i,6] = month_number

#       data[i,7] = paste0(DANE_code, "-", month_number )
    
    
    
#   }
  
#   #Como ya se mencionó, data_table contendrá la tabla final de los municipios, incialmente se había creado con un valor basura por lo que en la primera iteración se debe reemplazar este valor basura por los calculos realizados para el primer periodo
#   if(month_number == 1){
#     data_table_prom = data
#     #La tabla con los datos de cada mes que se vaya calculando (data) se une a la tabla principal (data_table) con la función rbind
#   }else{
#     data_table_prom = rbind(data_table_prom, data)
#   }
#   #Se suma uno al contador de meses debido a que ya finalizó el procesamiento del mes
#   month_number = month_number + 1
  
# }



# #**Extracción de los valores de los pixeles de los archivos nc4 a los poligonos de los municipios - Eventos niño, niña y neutro (Indices acumulados)**#

# #Número del total de eventos
# n_events = 11

# #Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
# munShapePath <- "D:/jd/clases/UDES/MAPAS PROYECTOS/mapa municipios/Municipios wgs84_Disolv.shp"
# #Lectura del archivo .shp
# munShape <- readShapePoly(munShapePath)
# #Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
# munShape.df <- as(munShape, "data.frame")

# #Cantidad de municipios
# qtyMun <- 1122
# #Matriz donde se guardarán los calculos finales
# events_data = array(0, c(qtyMun,23))
# #Vector que contiene el nombre de las columnas de la matriz, la convención en este caso es "E#EventoVariable" donde T es temperatur y P es precipitación
# columns <- c("Codigo DANE", "E1T", "E1P", "E2T", "E2P", "E3T", "E3P","E4T", "E4P", "E5T", "E5P", "E6T", "E6P", "E7T", "E7P","E8T", "E8P", "E9T", "E9P", "E10T", "E10P", "E11T", "E11P")         
# #Asignación del vector de nombres a la matriz
# colnames(events_data) <- columns

# #Algoritmo para realizar la extracción de los valores de los pixeles en cada municipio
# #Ciclo que recorre cada uno de los eventos. Importante recordar que debe exisitir un archivo .nc4 con los cálculos correspondientes por cada evento
# for(event in 1:n_events){
#   #Ruta donde se encuentran todos los archivos .nc4 correspondientes a el indice acumulado calculado por cada evento
#   dir = "D:/jd/clases/UDES/articulo Daniel/datosNasa/DataIndAcumulado/"
#   full_path = paste0(dir, 'evento', event, ".nc4")
  
#   #Se abre el archivo .nc4 como un raster por cada variable
#   rasterTemp <- raster(full_path, varname="Tair_f_inst")
#   rasterPrec <- raster(full_path, varname="Rainf_f_tavg")
  
#   #se realiza la extracción de los valores por cada pixel con la función extract. Ver arriba la extracción del indice puntual y datos del sensor para mas detalle
#   dataTemp = extract(rasterTemp, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)
#   dataPrec = extract(rasterPrec, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)
  
#   #Ver arriba la extracción del indice puntual y datos del sensor para mas detalle
#   ##Ciclo para de acuerdo a las matrices obtenidas con la función extract obtener el promedio ponderado de los pixeles en los municipios y así obtener los valores finales de cada variable en el municipio    
#   for(i in 1:qtyMun){
    
#     #Variables para el cálculo de la precipitación
#     #Vector que contiene los valores de los pixeles encontrados por la función extract en un municipio
#     valuesP <- dataPrec[[i]][, 2]
#     #Vector que contiene los pesos de los pixeles encontrados por la función extract en un municipio (Porcentaje del poligono que ocupa cada pixel)
#     weightsP <- dataPrec[[i]][, 3]
#     #Variable donde se almacenará el valor final luego de calcular el promedio ponderado
#     precMun <- 0
#     #Se crean las mismas variables para temperatura
#     valuesT <- dataTemp[[i]][, 2]
#     weightsT <- dataTemp[[i]][, 3]
#     tempMun <- 0
    
#     #Algoritmo que calcula el promedio ponderado de acuerdo a los  vectores creado anteriormente
#     #Como algunos pixeles del raster no contienen valores, es decir que el valor es "NA", en caso de que otros pixeles en el municipio si tengan algún valor se reemplazan los "NA" por el promedio de los demas valores. De esta forma no se afectan los cálculos
#     for(j in 1:length(valuesT)){
      
#       if(is.na(valuesT[j])){
#         tempMun = tempMun + (mean(valuesT, na.rm=TRUE) *weightsT[j])
#         precMun = precMun + (mean(valuesP, na.rm=TRUE) *weightsP[j])
#       }else{      
#         tempMun = tempMun + (valuesT[j]*weightsT[j])
#         precMun = precMun + (valuesP[j]*weightsP[j])
#       }
      
#     }
    
#     #Se obtiene el código dane del municipio con el dataFrame que contiene los atributos del archivo .shp
#     DANE_code = munShape.df[i,"Codigo_DAN"]
    
#     #Se guardan en la matriz final los campos requeridos en la columna correspondiente (event*2 para temperatura y event*2 +1 para precipitación)
#     events_data[i,1] = DANE_code
#     events_data[i,(event  * 2)] = tempMun
#     events_data[i,(event * 2) + 1] = precMun
    
    
#   }
# }
# #Se guarda la matriz en un objeto .rds para conservar los datos obtenidos en formato R
# saveRDS(data_table, "final_data.rds")

# #Escritura de la matriz final en un archivo .csv
# write.csv(data_table, file = "final_data_table.csv")