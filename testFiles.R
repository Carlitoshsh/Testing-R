convert_to_normal_date <-
  function(dayofyear, year) {
    as.Date(dayofyear-1, origin = paste(year,"-01-01", sep=""))
  }

print(convert_to_normal_date(337, "2018"))
format(convert_to_normal_date(337, "2018"),"%m")

modisFiles <- list.files("D:/OneDrive - Olimpia Management/Escritorio/pruebas/pruebas/output/VI_16Days_005dg_v6/EVI/", pattern = '*.tif$')
#modisFiles <- list.files("C:/Users/carlo/Desktop/pruebas/output/VI_16Days_005dg_v6/EVI/", pattern = '*.tif$')
for(theFile in modisFiles ){
  aux <- strsplit(theFile, "_")[[1]]
  year <- aux[length(aux)-1]
  dayOfYear <- as.numeric(strsplit(aux[length(aux)],".tif")[[1]])
  print(convert_to_normal_date(dayOfYear,year))
}
