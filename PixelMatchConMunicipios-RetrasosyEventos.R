#Carga de librerias
library(raster)
library(ncdf4)
library(maptools)

# Funcion que traslada dia del anio, a dia-mes-anio
# Ver: https://stackoverflow.com/questions/24200014/convert-day-of-year-to-date
# El formato de un archivo MODIS esta disponible en la presente carpeta
# Ver: MODIS_Overview.md
convert_to_normal_date <-
  function(dayofyear, year) {
    as.Date(dayofyear - 1, origin = paste(year, "-01-01", sep = ""))
  }

#Ruta donde se encuentra el archivo .shp que contiene los poligonos de los municipios
munShapePath <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/mapa municipios/Municipios wgs84_Disolv.shp"
#Lectura del archivo .shp
munShape <- readShapePoly(munShapePath)
#Data frame donde se almacenan los atributos del archivo shape. En este caso usaremos el atributo Codigo_DAN para obtener el código Dane del municipio
munShape.df <- as(munShape, "data.frame")
#Carpeta donde se encuentran los archivos EVI
directoryEVIFiles <- "D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/output/VI_16Days_005dg_v6/EVI/"
#Variable que almacena el conteo de indices por municipio
data_table <- 0
#Contador de mes. En este caso son 120 meses
month_number <- 1
# Obtiene los archivos.
modisFiles <- list.files(directoryEVIFiles, pattern = '*.tif$')

# Se itera cada archivo.
for (theFile in modisFiles) {

  # Hace split de cada archivo en la carpeta
  aux <- strsplit(theFile, "_")[[1]]
  # El año corresponde a una posicion anterior
  year <- aux[length(aux) - 1]
  # el día del año se convierte a una fecha con formato dia-mes-año
  dayOfYear <- as.numeric(strsplit(aux[length(aux)], ".tif")[[1]])
  # Se extrae el mes
  month <- format(convert_to_normal_date(dayOfYear, year), "%m")

  # Se extrae el raster con el archivo EVI en formato tif
  rasterVariable <- raster(paste0(directoryEVIFiles, theFile), varname = "EVI")

  # Se etrae la informacion desde el raster
  dataInVariable <- extract(rasterVariable, munShape, fun = NULL, na.rm = FALSE, weights = TRUE, normalizeWeights = TRUE, cellnumbers = TRUE, small = FALSE, df = FALSE, factors = TRUE, sp = FALSE)

  #Variable que contiene el total de municipios
  qtyMun <- 1122
  #Matriz auxiliar donde vamos a almacenar los valores finales de todas las variables y los datos del municipio por cada periodo. Más adelante esta matriz se unirá a la matriz principal que contendrá los resultados para todos los periodos
  data = array(0, c(qtyMun, 8))

  #Ciclo para de acuerdo a las matrices obtenidas con la función extract obtener el promedio ponderado de los pixeles en los municipios y así obtener los valores finales de cada variable en el municipio    
  for (i in 1:qtyMun) {
    #Vector que contiene los valores de los pixeles encontrados por la función extract en un municipio
    valuesVariable <- dataInVariable[[i]][, 2]
    #Vector que contiene los pesos de los pixeles encontrados por la función extract en un municipio (Porcentaje del poligono que ocupa cada pixel)
    weightsVariable <- dataInVariable[[i]][, 3]
    #Variable donde se almacenará el valor final luego de calcular el promedio ponderado
    variableMun <- 0

    #Algoritmo que calcula el promedio ponderado de acuerdo a los  vectores creado anteriormente
    #Como algunos pixeles del raster no contienen valores, es decir que el valor es "NA", en caso de que otros pixeles en el municipio si tengan algún valor se reemplazan los "NA" por el promedio de los demas valores. De esta forma no se afectan los cálculos
    for (j in 1:length(valuesVariable)) {
      if (is.na(valuesVariable[j])) {
        variableMun = variableMun + (mean(valuesVariable, na.rm = TRUE) * weightsVariable[j])
        # precMun = precMun + (mean(valuesP, na.rm=TRUE) *weightsP[j])
      } else {
        variableMun = variableMun + (valuesVariable[j] * weightsVariable[j])
        # precMun = precMun + (valuesP[j]*weightsP[j])
      }
    }

    #Vector con los nombres de cada una de las columnas que va a tener el archivo
    columns <- c("ID", "Codigo DANE", "Año", "Mes", "Fecha", "Número de mes", "Codigo DANE-mes", "Temperatura")
    #Asignación del vector de nombres a la matriz
    colnames(data) <- columns
    #Se obtiene el código dane del municipio con el dataFrame que contiene los atributos del archivo .shp
    DANE_code = munShape.df[i, "Codigo_DAN"]
    #Se obtiene la fecha en el formato deseado
    date <- format(as.Date(paste0(year, month, "01"), "%Y%m%d"), "%Y%m")

    #Se guardan en la matriz auxiliar los campos requeridos.
    data[i, 1] = i
    data[i, 2] = DANE_code
    data[i, 3] = year
    data[i, 4] = month
    data[i, 5] = date
    data[i, 6] = month_number
    #Campo CodigoDane - número de mes
    data[i, 7] = paste0(DANE_code, "-", month_number)
    data[i, 8] = variableMun
  }

  #Como ya se mencionó, data_table contendrá la tabla final de los municipios, incialmente se había creado con un valor basura por lo que en la primera iteración se debe reemplazar este valor basura por los calculos realizados para el primer periodo
  if (month_number == 1) {
    data_table = data
    #La tabla con los datos de cada mes que se vaya calculando (data) se une a la tabla principal (data_table) con la función rbind
  } else {
    data_table = rbind(data_table, data)
  }

  #Se suma uno al contador de meses debido a que ya finalizó el procesamiento del mes
  month_number = month_number + 1
}

write.csv(data_table, file = "Datos_Brutos_Alteraciones.csv")