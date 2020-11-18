# Conexión API al motor de Epi-PUMA
#

require(httr)
url = 'http://covid19.c3.unam.mx/api/dev/niche/countsTaxonsGroup'
json_body = '{"iterations": 1, "target_taxons":[{"taxon_rank":"species","value":"COVID-19 CONFIRMADO"}],"idtime":[],"apriori":false,"mapa_prob":false,"min_cells":1,"fosil":false,"date":false,"idtabla":"","grid_resolution":"mun","region":1,"get_grid_species":false,"with_data_score_cell":true,"with_data_freq":true,"with_data_freq_cell":true,"with_data_score_decil":true,"excluded_cells":[],"target_name":"targetGroup","covariables":[{"name":"GpoBio1","biotic":true,"merge_vars":[{"rank":"class","value":"Mammalia","type":0,"level":"species"}],"group_item":1}],"decil_selected":[10]}'
resp = POST(url, content_type_json(), body = json_body)

# NOMBRES DE LOS CONTENIDOS
names(content(resp))

# REVISAR EL RESUMEN POR CELDA DEL CONTENIDO 1
content(resp)$cell_summary[1]

# VER LOS ESDISTICOS POR COVARIABLE DEL CONTENIDO 1
content(resp)$data[1]
