###############################
# OBJETIVO DEL ALGORITMO: GENERAR EL DOCUMENTO mun.geojson QUE ALIMENTA MAPA EN mapa_covid19.html, ALOJADO EN UN DIRECTORIO SUPERIOR A ESTE SCRIPT. 
#
# PARA GENERAR ESTE MAPA SE REQUIREN LA BASE DE DATOS mun, Y EL POLIGONO municipios_simpleX.shp
#
# LIBRERIAS NECESARIAS:
require(rgdal)
require(leafletR)

# LEER DATOS
  mun0<- readOGR(dsn = "poligono/", layer = "municipios_simpleX")
  
  D<-mun
 
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
    
  mun0@data = data.frame(mun0@data, no2[match(mun0$MUN_OFICIA, no2$MUN_OFICIA),])
  
  # HAY QUE BORRAR EL ARCHIVO EXISTENTE!!!! O BUSCAR UNA FORMA DE SALTARSE LA SEGURIDAD
  #system("rm ../mun.geojson")
  
  system("rm mun.geojson")
  system("rm ../mun.geojson")


  # AUTOMATIZAR. ESTA INSRTUCCION EN EL SERVIDOR DEBE GUARDAR EL ARVHICO DIRECTAMENTE EN /sr/shiny-server/
  # setwd("~/COVID19_C3/html/datos/") 
  #setwd("../")  

  toGeoJSON(mun0)

  # EDITAR EL ARCHIVO DESDE EL SISTEMA (Linux)
  system("sed -i '1s/^/ var XDATA =  /' mun0.geojson")
  system("sed -i '$s/$/ ; /' mun0.geojson")
  system("cp mun0.geojson ../mun.geoson")
