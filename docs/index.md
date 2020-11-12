<div style "background="green";">
## Compilador de datos para el análisis de COVID-19 en México.
</div>
#### 1. Para cosechar los datos del reporte de diario de la Dirección general de Epidemiología se puede utilizar la siguiente instrucción:

```markdown
source("datos_DGE.R")
```
El código cosecha la información oficial, guarda una copia y la almacena en un directorio local. El documento <i>datos_DGE.R</i> tiene las siguientes instrucciones, que se ejecutan al leer el archivo desde la dirección url.

``` markdown
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

```

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/gegp01/clasificador_Bayes/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
