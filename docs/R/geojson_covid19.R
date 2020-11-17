# AUTOR: Gabriel E García Peña
# ESTE ALGORITMO GENERA LEE LOS POLIGONOS DE LOS MUNICIPIOS E INCORPORA LOS DATOS DE LA BASE mun.rds
# AL FINAL SE PRODUCE UN DOCUMENTO mun.geojson listo para ser leido por el visualizador javascript: https://symbiontit.c3.unam.mx/mapa_covid19.html
#

# CARGAR LIBRERIAS:
library(rgdal)
require(leaflet)
        
  mun0<- readOGR(dsn = "https://gegp01.github.io/clasificador_Bayes/R/municipios/", layer = "municipios_simpleX")
  D<-readRDS("~/COVID19_C3/html/datos/NODOS.rds")
 
  no2<-data.frame(MUN_OFICIA=D$MUN_OFICIA
                        , CVE_ENT=D$CLAVE_ENTIDAD
                        , CVE_MUN=D$CLAVE_MUNICIPIO
                        , ENTIDAD=D$ENTIDAD
                        , MUNICIPIO=D$MUNICIPIO
                        , infectados = D$infectados
                        , negativos = D$negativos
                        , inf15d= D$infectados15d
                        , pobtot = D$pobtot
                        , inf10mil = D$infectados_10milhab
                        , inf15d10mil=D$infectados15d_10milhab
                        , dead=D$deceso_positivo
                        , dead10mil=D$deceso_positivo_10milhab
                        , Rt = D$Rt
                        , wrkhy = D$workplaces_percent_change_from_baseline
                        , homhy = D$residential_percent_change_from_baseline
                        , wrkmnsem = D$z.mean.sorted # movilidad promedio en el trabajao la semana pasada
                        , wrkmxsem = D$z.max.sorted # movilidad maxima en el trabajao la semana pasada
                        , FECHA_DATOS = D$FECHA_ACTUALIZACION
                  
                    )
  
  no2$epsilon<-epsilon[match(no2$MUN_OFICIA, names(epsilon))]
  
  require(leaflet)
  Xpalette <- colorNumeric(palette=c('#FED976', '#BD0026'), domain=no2$Rt, na.color="transparent")
  no2$Rt_col<-Xpalette(no2$Rt)
  
  Xpalette <- colorNumeric(palette=c('#fadbd8', '#e74c3c'), domain=log(no2$inf15d10mil+1), na.color="transparent")
  no2$inf15d10mil_col<-Xpalette(log(no2$inf15d10mil+1))
  
  Xpalette <- colorNumeric(palette=c('#ebdef0', '#553f7c'), domain=log(no2$dead10mil+1), na.color="transparent")
  no2$dead10mil_col<-Xpalette(log(no2$dead10mil+1))
  
  Xpalette <- colorNumeric(palette=c('#ebdef0', '#553f7c'), domain=log(no2$dead+1), na.color="transparent")
  no2$dead_col<-Xpalette(log(no2$dead+1))

  Xpalette <- colorNumeric(palette=c('#FED976', '#BD0026'), domain=no2$epsilon, na.color="transparent")
  no2$epsilon_col<-Xpalette(no2$epsilon)
  
  Xpalette <- colorNumeric(palette=c('#85c1e9', '#db299e'), domain=no2$wrkmxsem, na.color="transparent")
  no2$wrkmxsem_col<-Xpalette(no2$wrkmxsem)
    
    mun@data = data.frame(mun@data, no2[match(mun$MUN_OFICIA, no2$MUN_OFICIA),])
  
  # HAY QUE BORRAR EL ARCHIVO EXISTENTE!!!! O BUSCAR UNA FORMA DE SALTARSE LA SEGURIDAD
  # sudo rm ~/COVID19_C3/html/unam-app/map/leaflet/datos/mun_nodos_2*
    
#  setwd("~/COVID19_C3/html/unam-app/map/leaflet/datos/")
  # setwd("~/COVID19_C3/html/datos/")
  # writeOGR(mun, ".", "mun_nodos", driver="ESRI Shapefile") #also you were missing the driver argument
  
  # setwd("~/COVID19_C3/html/unam-app/map/leaflet/datos/")
  # writeOGR(mun, ".", "mun_nodos_3", driver="ESRI Shapefile") #also you were missing the driver argument
  
  # AUTOMATIZAR. ESTA INSRTUCCION EN EL SERVIDOR DEBE GUARDAR EL ARVHICO DIRECTAMENTE EN /sr/shiny-server/
  setwd("~/COVID19_C3/html/datos/") # setwd("/srv/shyni-server/")     
  require(leafletR)
  toGeoJSON(mun)

  # EDITAR EL ARCHIVO DESDE EL SISTEMA (Linux)
  system("sed -i '1s/^/ var XDATA =  /' mun.geojson")
  system("sed -i '$s/$/ ; /' mun.geojson")
