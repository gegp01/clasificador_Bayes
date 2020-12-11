# Alojar el archivo en shiny-server/R/
system("// hoy=`date '+%d_%m_%Y'`;
	hoy=`date '+%d_%m_%Y_%Hhr%Mm'`;
	wget -c 'https://datos.cdmx.gob.mx/explore/dataset/colonias-de-atencion-prioritaria-covid-kioscos/download/?format=geojson&timezone=America/Mexico_City&lang=es' -O kioscos_cdmx/kioscos_cdmx_$hoy.geojson")
  
  
