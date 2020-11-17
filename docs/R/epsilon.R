# Análisis de Bayes sobre la prevalencia a ser positivo a COVID-19 (casos positivos / casos observados) en cada municipio. 
# https://symbiontit.c3.unam.mx/epi-species.html
#  
# PARA EJECUTAR EL ALGORITMO SE REQUIERE DE LA BASE DE DATOS covid, Y SE GENERA LA VARIABLE epsilon, CON LA PROBABILIDAD CONDICIONAL DE SER UN PACIENTE POSITIVO A COVID-19 DADO EL MUNICIPIO DE RESIDENCIA. 
#
# SELECCIONAR DATOS EN LOS ÚLTIMOS 20 DÍAS
  D<-covid[covid$FECHA_SINTOMAS>=max(covid$FECHA_SINTOMAS)-20,]
  
# Identificado de casos
  nms<-unique(D$ID_REGISTRO)
  
# El número de sospechosos en ese municipio
  N<-length(nms)
  
# El número de casos con covid en ese municipio
  Ncovid<-table(D$municipio_oficial[D$infectado==1])
  
# El número de casos sospechosos de ese municipio 
  NH<-table(D$municipio_oficial)
 
# Ordenar la variable Ncovid para cruzarla con NH
  Ncovid.sorted<-Ncovid[match(names(NH), names(Ncovid))]
  
  Z<-data.frame(cbind(NH, Ncovid.sorted))

  Z$municipio_oficial<-as.vector(rownames(Z))
  names(Z)<-c("sospechosos", "confirmados", "municipio_oficial")

# Probabilidad de ser positivo a COVID-19 dado el municipio de residencia (H)
# p (Ncovid|H)

  P.covid.mun<-Z$confirmados/Z$sospechosos
  names(P.covid.mun)<-Z$municipio_oficial

# Probabilidad de ser positivo al covid  
  P.covid<-sum(Ncovid)/N

# Epsilon
  numerador<-(Z$sospechosos*(P.covid.mun-P.covid))
  denominador<-(Z$sospechosos*P.covid*(1-P.covid))^0.5
  epsilon<-numerador/denominador

  names(epsilon)<-rownames(Z)  
  epsilon<-na.exclude(epsilon)
