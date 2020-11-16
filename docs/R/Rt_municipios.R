# COÓDIGO DE R PARA ESTIMAR EL INREMENTO EN CONTAGIOS (Rt) DE ACUERDO CON EL PROTOCOLO DE LA ORGANIZACION MUNDIAL PARA LA SALUD (PHAO). Rt SE CALCULA CON EL ALGORITMO EpiEstim() PARA CADA MUNICIPIO, EXCEPTO AQUELLOS MUNICIPIOS EN LOS QUE SE SE TIENEN POCAS PRUEBAS ().
# autor: Gabriel E. García Peña
# Centro de Ciencias de la Complejidad, Universidad NAcional Autónoma de México
#
# ANTES DE INICIAR, SE REQUIREN LOS ARCHIVO mun.rds, que se genera con la instrucciónes: (1) y (2) en https://gegp01.github.io/clasificador_Bayes/ 
#
# LIBRERIAS DE R
require(EpiEstim)

# CALCULAR TASA DE CRECIMIENTO (INFECTADOS HOY/INFECTADOS AYER)
      
      x4<-table(covid$municipio_oficial[covid$infectado==1], covid$FECHA_SINTOMAS[covid$infectado==1])
      

# CALCULA Rt PARA TODO EL PAIS
#  
#  t_start<-seq(2, length(colSums(x4))-10)
#  t_end<-t_start + 10
#  
#  y<-estimate_R(colSums(x4), method="parametric_si"
#                , config = make_config(list(
#                  mean_si = 4.8
#                  , std_si = 2.3
#                  , t_start = t_start
#                  , t_end = t_end))
#  )
#
# FUNCIÓN PARA CALCULAR Rt en CADA MUNICIPIO.
  f1<-function(x) {
    y<-estimate_R(data.frame(x4[x,]), method="parametric_si"
                  , config = make_config(list(
                    mean_si = 4.8
                    , std_si = 2.3
                    , t_start = t_start
                    , t_end = t_end
                    ))
                  )

    mean(y[['R']][["Median(R)"]])
  }

# EJECUTAR LA FUNCION f1, CON LOS VALORES DE INCIO Y FIN DE LA VENTANA DE TIEMPO QUE SE ANÁLIZA (= 10 DIAS)
  t_start<-seq(2, length(colSums(x4))-10)
  t_end<-t_start + 10

  x<-c(1:nrow(x4))
  Rt<-sapply(x, f1)
  
  names(Rt)<-rownames(x4)
  
  
# INTEGRAR LOS DATOS AL ARCHIVO mun.rds,
  
      mun$Rt<-Rt[match(mun$MUN_OFICIA, names(Rt))]
  
      mun$Rt2<-ifelse(mun$infectados+mun$negativos >= 20, mun$Rt, NA) # eliminamos los estimados de Rt con pocos casos
  
      mun$ID<-paste(mun$NOM_MUN, mun$NOM_ENT, mun$MUN_OFICIA, sep="-")
      
      mun$FECHA_ACTUALIZACION<-rep(covid$FECHA_ACTUALIZACION[1], nrow(mun))

      saveRDS(mun.rds)
      


