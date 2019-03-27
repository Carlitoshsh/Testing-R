#Cargar las librerías necesarias para correr el progerama
#Se debe hacer siempre que se abra R
library(raster)
library(ncdf4)
library(maptools)

convert_to_normal_date <-
  function(dayofyear, year) {
    as.Date(dayofyear-1, origin = paste(year,"-01-01", sep=""))
  }


#Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
munShapePath <-  "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/mapa municipios/Municipios wgs84_Disolv.shp"
#Lectura del archivo .shp
munShape <- readShapePoly(munShapePath)
#Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
munShape.df <- as(munShape, "data.frame")
directoryEVIFiles <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/output/VI_16Days_005dg_v6/EVI/"
data_table <- 0
#Contador de mes. En este caso son 120 meses
month_number <- 1

modisFiles <- list.files(directoryEVIFiles, pattern = '*.tif$')
#modisFiles <- list.files("C:/Users/carlo/Desktop/pruebas/output/VI_16Days_005dg_v6/EVI/", pattern = '*.tif$')
for(theFile in modisFiles ){
  aux <- strsplit(theFile, "_")[[1]]
  year <- aux[length(aux)-1]
  dayOfYear <- as.numeric(strsplit(aux[length(aux)],".tif")[[1]])
  month <- format(convert_to_normal_date(dayOfYear,year),"%m")

  rasterEVI <- raster(paste0(directoryEVIFiles,theFile), varname="EVI")

  dataTemp <- extract(rasterEVI, munShape, fun=NULL, na.rm=FALSE, weights=TRUE, normalizeWeights=TRUE, cellnumbers=TRUE, small=FALSE, df=FALSE,factors=TRUE, sp=FALSE)

  #Variable que contiene el total de municipios
  qtyMun <- 1122
  #Matriz auxiliar donde vamos a almacenar los valores finales de todas las variables y los datos del municipio por cada periodo. Más adelante esta matriz se unirá a la matriz principal que contendrá los resultados para todos los periodos
  data = array(0, c(qtyMun,8))

   
    
    #Ciclo para de acuerdo a las matrices obtenidas con la función extract obtener el promedio ponderado de los pixeles en los municipios y así obtener los valores finales de cada variable en el municipio    
    for(i in 1:qtyMun){
      #Variables para el cálculo de la precipitación
      #Vector que contiene los valores de los pixeles encontrados por la función extract en un municipio
      # valuesP <- dataPrec[[i]][, 2]
      #Vector que contiene los pesos de los pixeles encontrados por la función extract en un municipio (Porcentaje del poligono que ocupa cada pixel)
      # weightsP <- dataPrec[[i]][, 3]
      #Variable donde se almacenará el valor final luego de calcular el promedio ponderado
      # precMun <- 0
      
      #Se crean las mismas variables para temperatura, indice puntual temperatura e indice puntual precipitación
      
      valuesT <- dataTemp[[i]][, 2]
      weightsT <- dataTemp[[i]][, 3]
      tempMun <- 0
      
      
      #Algoritmo que calcula el promedio ponderado de acuerdo a los  vectores creado anteriormente
      #Como algunos pixeles del raster no contienen valores, es decir que el valor es "NA", en caso de que otros pixeles en el municipio si tengan algún valor se reemplazan los "NA" por el promedio de los demas valores. De esta forma no se afectan los cálculos
      for(j in 1:length(valuesT)){
        
        if(is.na(valuesT[j])){
          tempMun = tempMun + (mean(valuesT, na.rm=TRUE) *weightsT[j])
          # precMun = precMun + (mean(valuesP, na.rm=TRUE) *weightsP[j])
        }else{      
          tempMun = tempMun + (valuesT[j]*weightsT[j])
          # precMun = precMun + (valuesP[j]*weightsP[j])
        }
        
      }
      #Vector con los nombres de cada una de las columnas que va a tener el archivo
      columns <- c("ID", "Codigo DANE", "Año", "Mes", "Fecha","Número de mes", "Codigo DANE-mes","Temperatura")
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
      # data[i,9] = precMun
      
      
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

write.csv(data_table, file = "Datos_Brutos_Alteraciones.csv")

