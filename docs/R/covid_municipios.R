# COMPILADOR DE DATOS A NIVEL DE MUNICIPIO
# LOS DATOS SE ENCUENTRAN EN EL DATAFRAME covid
# PARA LEER LOS DATOS NUEVAMENTE Y SIN PASAR POR EL ALGORITMO datos_DGE.R: covid<-readRDS("NOMBRE DEL DOCUMENTO.rds")

      head(covid)

# NOTA: TODOS LOS DATOS SE HAN LEIDO EN FORMATO DE TEXTO PARA MANTENER LA INTEGRIDAD DE LOS CODIGOS DE MUNICIPIO.
# POR ELLO HAY QUE CAMBIARLES LAS CLASE A LAS FECHAS. SE CONSIDERAN NA A LAS FECHAS CON 9999-99-99" 

      covid$FECHA_ACTUALIZACION[covid$FECHA_ACTUALIZACION=="9999-99-99"]<-NA
      covid$FECHA_ACTUALIZACION<-as.Date(covid$FECHA_ACTUALIZACION)

      covid$FECHA_INGRESO[covid$FECHA_INGRESO=="9999-99-99"]<-NA
      covid$FECHA_INGRESO<-as.Date(covid$FECHA_INGRESO)
      covid$ingreso_julianos<-covid$FECHA_INGRESO-as.Date("2019-12-31")

      covid$FECHA_SINTOMAS[covid$FECHA_SINTOMAS=="9999-99-99"]<-NA
      covid$FECHA_SINTOMAS<-as.Date(covid$FECHA_SINTOMAS)
      covid$sintomas_julianos<-covid$FECHA_SINTOMAS-as.Date("2019-12-31")

      covid$FECHA_DEF[covid$FECHA_DEF=="9999-99-99"]<-NA
      covid$FECHA_DEF<-as.Date(covid$FECHA_DEF) 
      covid$defuncion_julianos<-covid$FECHA_DEF-as.Date("2020-01-01")


# 2. INTEGRAR Y COMPILAR DATOS EPIDEMIOLÓGICOS
# A los datos de la dirección general de epidemiología le agregaremos informacion sobre los municipios:
##########################################

# 2.1. DATOS DE MUNICIPIO

      mun<-read.csv("https://gegp01.github.io/clasificador_Bayes/R/datos_censo2010.csv"
                  , colClasses=c(rep("character",8)))

      mun$pobtot<-as.numeric(mun$pobtot)
      
      covid$id<-paste(covid$ENTIDAD_RES, covid$MUNICIPIO_RES, sep="")
      #mun$id<-paste(mun$CVE_ENT, mun$CVE_MUN)
      #covid$municipio_oficial<-mun$MUN_OFICIA[match(covid$id, mun$id)] ####
      
      covid$municipio_oficial<-mun$MUN_OFICIA[match(covid$id, mun$MUN_OFICIA)] 
      
      covid$infectado<-ifelse(covid$RESULTADO_LAB==1, 1, 0)
      I<-aggregate(covid$infectado, list(covid$municipio_oficial), sum)
      
      ## def<-aggregate(covid$infectado, list(covid$municipio_oficial), sum)
      
      covid$ultimos15dias<-
        ifelse(max(covid$sintomas_julianos)-covid$sintomas_julianos<=20, 1, 0) # los ultimos 5 dias tienen un retraso sustancial en la actualización.

      covid$ultimos30dias<-
        ifelse(max(covid$sintomas_julianos)-covid$sintomas_julianos<=30, 1, 0)
      
      
      covid$infectados_15d<-covid$infectado*covid$ultimos15dias
      covid$infectados_30d<-covid$infectado*covid$ultimos30dias
            
      
      I_ultimos15<-aggregate(covid$infectados_15d, list(covid$municipio_oficial), sum)
      I_ultimos30<-aggregate(covid$infectados_30d, list(covid$municipio_oficial), sum)
      
      
      covid$negativo<-ifelse(covid$RESULTADO_LAB==2, 1, 0)
      
      S<-aggregate(covid$negativo, list(covid$municipio_oficial), sum)
  
      covid$negativos_15d<-covid$negativo*covid$ultimos15dias
      covid$negativos_30d<-covid$negativo*covid$ultimos30dias  
      
      S_ultimos15<-aggregate(covid$negativos_15d, list(covid$municipio_oficial), sum)
      S_ultimos30<-aggregate(covid$negativos_30d, list(covid$municipio_oficial), sum)
      
      mun$infectados<-I$x[match(mun$MUN_OFICIA, I$Group.1)]
      mun$infectados[is.na(mun$infectados)]<-0
      
      mun$negativos<-S$x[match(mun$MUN_OFICIA, S$Group.1)]
      mun$negativos[is.na(mun$negativos)]<-0
      
      mun$infectados15d<-I_ultimos15$x[match(mun$MUN_OFICIA, I_ultimos15$Group.1)]
      mun$infectados15d[is.na(mun$infectados15d)]<-0
      
      mun$infectados30d<-I_ultimos30$x[match(mun$MUN_OFICIA, I_ultimos30$Group.1)]
      mun$infectados30d[is.na(mun$infectados30d)]<-0
  
      mun$negativos15d<-S_ultimos15$x[match(mun$MUN_OFICIA, S_ultimos15$Group.1)]
      mun$negativos15d[is.na(mun$negativos15d)]<-0
      
      mun$negativos30d<-S_ultimos30$x[match(mun$MUN_OFICIA, S_ultimos30$Group.1)]
      mun$negativos30d[is.na(mun$negativos30d)]<-0
      
    # Calculamos las estadísticas epidemiológicas para cada estado
    # infectados por cada 10 mil habitantes, hace 20 días o 30 días; y los decesos de personas contagiadas con el coronavirus
    
      mun$infectados_10milhab<-(mun$infectados/mun$pobtot)*10000
      mun$infectados15d_10milhab<-(mun$infectados15d/mun$pobtot)*10000
      mun$infectados30d_10milhab<-(mun$infectados30d/mun$pobtot)*10000
      
      deceso<-ifelse(is.na(covid$defuncion_julianos), 0, 1)
      covid$deceso_positivo<-ifelse(covid$RESULTADO_LAB==1, deceso, 0)
      
      death<-aggregate(covid$deceso_positivo, list(covid$municipio_oficial), sum)
      mun$deceso_positivo<-death$x[match(mun$MUN_OFICIA, death$Group.1)]
      mun$deceso_positivo_10milhab<-(mun$deceso_positivo/mun$pobtot)*10000
              
      mun$ID<-paste(mun$NOM_MUN, mun$NOM_ENT, mun$MUN_OFICIA, sep="-")
      
      mun$FECHA_ACTUALIZACION<-rep(covid$FECHA_ACTUALIZACION[1], nrow(mun))
      
      saveRDS(mun, "mun.rds")
      write.csv(mun, "mun.csv")
      
# SIGUEN:
  #      nodos<-data.frame(mun, gmx.hoy.sorted, z.max.sorted, z.mean.sorted)
  # 3. AGREGAR DATOS DEMOGRÁFICOS DEL CENSO DE POBLACION Y VIVIENDA DEL 2010 (INEGI). source("mun_iter.R")
  
  # 4. CALCULAR EL INCREMENTO DE CONTAGIOS POR MUNICIPIO Y AGREGARLO EN LA BASE DE DATOS mun. source("Rt.R")
  
  # 5. AGREGAR DATOS DE MOVILIDAD DE GOOGLE (A NIVEL DE ESTADO)
  




