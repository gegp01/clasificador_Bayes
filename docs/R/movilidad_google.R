# ESTE ALGORITMO COSECHA LA INFORMACION PUBLICA DE GOOGLE SOBRE LA MOVILIDAD Y LA INCORPORA A LA BASE DE DATOS (DATA FRAME) mun.rds.
# SE NECESITAN LAS BASES DE DATOS mun y covid QYE SE GENERAN EN LOS PUNTOS 1 y 2 de https://gegp01.github.io/clasificador_Bayes/
#
# Nota: ASEGURAR QUE SE TRABAJA EN EL DIRECTORIO DE TRABAJO EN EL QUE ESTÁ EL DOCUMENTO mun.rds

# ELIMINA DATOS NUEVOS DEL SISTEMA
    system("sudo rm Global_Mobility_Report.csv")

# LEER DATOS DE GOOGLE MAPS  
    
    system("wget https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv")
    google<-read.csv("Global_Mobility_Report.csv")


# SELECCIONAR LOS DATOS REFERENTES A MÉXICO
 
      gmx<-google[grep("Mex", google$country_region),]
      gmx$date<-as.Date(gmx$date)
      gmx$julianday<-gmx$date-as.Date("2019-12-31")
      gmx$entidad<-as.vector(gmx$sub_region_1)
      
      ################# SE STANDARIZAN LOS VALORES DE ACUERDO AL INDICE DE ENTIDADES "ent"
      ent<-read.csv("https://gegp01.github.io/clasificador_Bayes/R/cve_entidad_gmx.csv", sep=",", header=F, colClasses=c(rep("character",3)))
      ent$CVE_ENT<-c("01", "02", "03", "04", "07", "08", "05", "06", "09", ent$V2[10:32])
      
      gmx$CVE_ENT<-ent$CVE_ENT[match(gmx$entidad, ent$V3)]
      gmx.hoy<-gmx[gmx$julianday==max(gmx$julianday),]
   
   
# CALCULAR ESTADISTICOS DE MOVILIDAD (max, mean) DE LA SEMANA ANTERIOR A LA FECHA ACTUAL.
      gmx.semana.anterior<-gmx[gmx$julianday>=(max(gmx$julianday)-7),]
      
      z.mean<-aggregate(gmx.semana.anterior$workplaces_percent_change_from_baseline, list(gmx.semana.anterior$CVE_ENT), mean)
      z.max<-aggregate(gmx.semana.anterior$workplaces_percent_change_from_baseline, list(gmx.semana.anterior$CVE_ENT), max)
      
      gmx.hoy.sorted<-gmx.hoy[match(mun$CLAVE_ENTIDAD, gmx.hoy$CVE_ENT),]
      z.mean.sorted<-z.mean$x[match(mun$CLAVE_ENTIDAD, z.mean$Group.1)] # movilidad promedio en el trabajo la semana pasada
      z.max.sorted<-z.max$x[match(mun$CLAVE_ENTIDAD, z.max$Group.1)] # movilidad maxima en el trabajao la semana pasada
      table(gmx.hoy.sorted$CVE_ENT==mun$CLAVE_ENTIDAD) # checar que los datos en gmx.hoy.sorted estén en el orden de mu

# INCORPORAR DATOS DE MOVILIDAD A LA BASE DE DATOS mun.rds
      mun<-data.frame(mun, gmx.hoy.sorted, z.max.sorted, z.mean.sorted)
      saveRDS(mun, "mun.rds")

