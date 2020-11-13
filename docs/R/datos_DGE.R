# CÓDIGO EN R PARA COSECHAR Y COMPILAR LOS DATOS QUE SE UTILIZARÁN EN EL ANÁLISIS.
#
#   DATOS:
#    + Reporte actualizado de la Dirección General de Epidemiología sonre el COVID-19 en México.
#    + Censo de población y vivienda 2010 (INEGI), agregados a nivel de municipio.
#    + Calidad del aire en cada municipio.
#    + Redes de movilidad basados en el censo de poblacion y vivienda 2010 (INEGI).
#
#
##################
# REF: https://hydroecology.net/downloading-extracting-and-reading-files-in-r/
#
# CREAR UN DIRECTORIO TEMPORAL
  td = tempdir()

# create the placeholder file
# GENERAR UN ARCHIVO TEMPORAL
  tf = tempfile(tmpdir=td, fileext=".zip")

# DESCARGAR LOS DATOS DEL URL EN EL ARCHIVO TEMPORAL
  download.file("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip", tf)
  #download.file("http://epidemiologia.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip", tf)
  # download.file("http://187.191.75.115/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip", tf) # cambio la dirección! 31/jul/2020

# LEER EL NOMBRE DEL PRIMER DOCUMENTO EN EL ARCHIVO ZIP.
  fname = unzip(tf, list=TRUE)$Name[1]

# EXTRAER EL DOCUMENTO Y GUARDARLO EN EL DIRECTORIO TEMPORAL
  unzip(tf, files=fname, exdir=td, overwrite=TRUE)

# OBTENER LA RUTA AL DOCUMENTO (fpath)
  fpath = file.path(td, fname)

# LEER LAS PRIMERAS FILAS DEL DOCUMENTO EN fpath PARA SABER SUS DIMENSIONES (filas, coumnas) 
  d = read.csv(fpath, header=TRUE, row.names=NULL, stringsAsFactors=FALSE, nrows=10) 
  q<-ncol(d) # NUMERO DE COLUMNAS EN EL DOCUMENTO

# LEER TODO EL DOCUMENTO, ASIGNANDO LA CLASE CARACTER PARA TODAS LAS COLUMNAS. ESTO PERMITE MANTENER LA INTEGRIDAD DEL CODIGO DE MUNICIPIO (MUCIPIO_OFICIA)
  covid = read.csv(fpath, header=TRUE, row.names=NULL, stringsAsFactors=FALSE, colClasses=c(rep("character",q))) 

  print("LISTO! LOS DATOS ESTÁN EN EL DATAFRAME covid")
