library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)

# Creació dels CSV per a les visualitzacions, d'acord amb el tipus de viz a mostrar
viz01_DF <- read.csv("Dades/acc_vehicles_bcn.csv",dec = ".", header=TRUE, 
                     sep=",", quote = "\"", strip.white = TRUE)

viz02_DF <- read.csv("Dades/acc_vian_veh_bcn.csv",dec = ".", header=TRUE, 
                     sep=",", quote = "\"", strip.white = TRUE)

viz03_DF <- read.csv("Dades/acc_bic_vmp_bcn.csv",dec = ".", header=TRUE, 
                     sep=",", quote = "\"", strip.white = TRUE)

viz06_DF <- read.csv("Dades/meteo_bcn.csv",dec = ".", header=TRUE, 
                     sep=",", quote = "\"", strip.white = TRUE)

### VIZ 01 - Canviar les etiquetes mes any al format Gen 2017
viz01_DF$Mes <- "Mes"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '01/',]$Mes <- "Gen"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '02/',]$Mes <- "Feb"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '03/',]$Mes <- "Mar"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '04/',]$Mes <- "Abr"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '05/',]$Mes <- "Mai"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '06/',]$Mes <- "Jun"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '07/',]$Mes <- "Jul"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '08/',]$Mes <- "Ago"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '09/',]$Mes <- "Set"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '10/',]$Mes <- "Oct"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '11/',]$Mes <- "Nov"
viz01_DF[substr(viz01_DF$MesAny,1,3) == '12/',]$Mes <- "Des"

viz01_DF$Mes <- paste(viz01_DF$Mes,substr(viz01_DF$MesAny,4,7),sep = " ")

viz01_DF <- viz01_DF[,c(1,16,2:15)]

# Reordenació de les columnes per motius estètics
viz01_DF <- viz01_DF[,c(1,2,3,11,13,14,5,4,7,9,12,8,16,10,6,15)]

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz01_DF,"Dades Viz/01_acc_veh_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)


### VIZ 02 - Canviar els noms de les columnes per l'etiqueta normalitzada Gen 2017
cols_norm <- c("TipusVeh",
               "Gen 2017", "Feb 2017", "Mar 2017", "Abr 2017",
               "Mai 2017", "Jun 2017", "Jul 2017", "Ago 2017",
               "Set 2017", "Oct 2017", "Nov 2017", "Des 2017",
               "Gen 2018", "Feb 2018", "Mar 2018", "Abr 2018",
               "Mai 2018", "Jun 2018", "Jul 2018", "Ago 2018",
               "Set 2018", "Oct 2018", "Nov 2018", "Des 2018",
               "Gen 2019", "Feb 2019", "Mar 2019", "Abr 2019",
               "Mai 2019", "Jun 2019", "Jul 2019", "Ago 2019",
               "Set 2019", "Oct 2019", "Nov 2019", "Des 2019",
               "Gen 2020", "Feb 2020", "Mar 2020", "Abr 2020",
               "Mai 2020", "Jun 2020", "Jul 2020", "Ago 2020",
               "Set 2020", "Oct 2020", "Nov 2020", "Des 2020",
               "Gen 2021", "Feb 2021", "Mar 2021", "Abr 2021",
               "Mai 2021", "Jun 2021", "Jul 2021", "Ago 2021",
               "Set 2021", "Oct 2021", "Nov 2021", "Des 2021")

colnames(viz02_DF) <- cols_norm

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz02_DF,"Dades Viz/02_acc_vian_veh_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)

### VIZ 03 - Mapa d'accidents
viz03_mapa_DF <- viz03_DF[,c(1:6,9:13)]

summary((viz03_mapa_DF))

# Neteja dels valors de Lat i Long fora de l'àmbit de BCN
viz03_mapa_DF <- viz03_mapa_DF[(viz03_mapa_DF$Longitud > 2 & viz03_mapa_DF$Longitud < 2.5),]
viz03_mapa_DF <- viz03_mapa_DF[(viz03_mapa_DF$Latitud < 42),]

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz03_mapa_DF,"Dades Viz/03_mapa_acc_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)


### VIZ 03B - Climate stripes amb la diferència diurn/nocturn
viz03_b_DF <- viz03_DF[,c(1,2,6)]

viz03_b_DF$Data <- as.Date(viz03_b_DF$Data, "%Y-%m-%d")
viz03_b_DF$Any <- year(viz03_b_DF$Data)
viz03_b_DF$Mes <- month(viz03_b_DF$Data)

viz03_b_agg_DF <- viz03_b_DF %>% group_by(Any,Mes,Llum) %>% summarise(Total = n())

viz03_b_agg_DF <- viz03_b_agg_DF %>% 
  pivot_wider(names_from = Llum, values_from = Total, values_fill = 0)

viz03_b_agg_DF$PercDiu <- 
  (viz03_b_agg_DF$Diurna / (viz03_b_agg_DF$Diurna + viz03_b_agg_DF$Nocturna)) - 0.5

viz03_b_agg_DF$NomMes <- "Mes"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 1,]$NomMes <- "Gen"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 2,]$NomMes <- "Feb"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 3,]$NomMes <- "Mar"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 4,]$NomMes <- "Abr"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 5,]$NomMes <- "Mai"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 6,]$NomMes <- "Jun"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 7,]$NomMes <- "Jul"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 8,]$NomMes <- "Ago"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 9,]$NomMes <- "Set"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 10,]$NomMes <- "Oct"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 11,]$NomMes <- "Nov"
viz03_b_agg_DF[viz03_b_agg_DF$Mes == 12,]$NomMes <- "Des"

viz03_b_agg_DF$Any <- as.character(viz03_b_agg_DF$Any)
viz03_b_agg_DF$Data <- paste(viz03_b_agg_DF$NomMes,viz03_b_agg_DF$Any,sep = " ")

viz03_b_agg_DF <- viz03_b_agg_DF[,c(7,3:5)]

colnames(viz03_b_agg_DF) <- c("Data","Diurns","Nocturns","PercDiu")

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz03_b_agg_DF,"Dades Viz/03b_perc_diurns.csv",sep=",",dec=".",na="",row.names = FALSE)


### VIZ 04 - Line chart amb l'estacionalitat de les hores variables
viz03_4_DF <- viz03_DF[viz03_DF$Hora >= 17 & viz03_DF$Hora <= 21,]
viz03_4_DF <- viz03_4_DF[,c(1:3)]

viz03_4_DF$Data <- as.Date(viz03_4_DF$Data, "%Y-%m-%d")
viz03_4_DF$Any <- year(viz03_4_DF$Data)
viz03_4_DF$Mes <- month(viz03_4_DF$Data)

viz03_4_agg_DF <- viz03_4_DF %>% group_by(Any,Mes,Hora) %>% summarise(Total = n())

viz03_4_agg_DF$NomMes <- "Mes"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 1,]$NomMes <- "Gen"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 2,]$NomMes <- "Feb"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 3,]$NomMes <- "Mar"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 4,]$NomMes <- "Abr"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 5,]$NomMes <- "Mai"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 6,]$NomMes <- "Jun"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 7,]$NomMes <- "Jul"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 8,]$NomMes <- "Ago"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 9,]$NomMes <- "Set"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 10,]$NomMes <- "Oct"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 11,]$NomMes <- "Nov"
viz03_4_agg_DF[viz03_4_agg_DF$Mes == 12,]$NomMes <- "Des"

viz03_4_agg_DF$Any <- as.character(viz03_4_agg_DF$Any)
viz03_4_agg_DF$Hora <- paste(as.character(viz03_4_agg_DF$Hora),"h",sep = "")

viz03_4_agg_DF$Data <- paste(viz03_4_agg_DF$NomMes,viz03_4_agg_DF$Any,sep = " ")

viz03_4_agg_DF <- viz03_4_agg_DF[,c(6,3,4)]

viz03_4_wide_DF <- viz03_4_agg_DF %>% 
  pivot_wider(names_from = Hora, values_from = Total, values_fill = 0)

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz03_4_wide_DF,"Dades Viz/04_acc_estac_hora.csv",sep=",",dec=".",na="",row.names = FALSE)

# Replantejament de la visualització per a tenir en compte les proporcions per franja
viz03_4_2_DF <- viz03_4_wide_DF
viz03_4_2_DF <- viz03_4_2_DF %>% inner_join(viz03_b_agg_DF, by=c('Data'))

viz03_4_2_DF$`17h` <- (viz03_4_2_DF$`17h`*100)/(viz03_4_2_DF$Diurns + viz03_4_2_DF$Nocturns)
viz03_4_2_DF$`18h` <- (viz03_4_2_DF$`18h`*100)/(viz03_4_2_DF$Diurns + viz03_4_2_DF$Nocturns)
viz03_4_2_DF$`19h` <- (viz03_4_2_DF$`19h`*100)/(viz03_4_2_DF$Diurns + viz03_4_2_DF$Nocturns)
viz03_4_2_DF$`20h` <- (viz03_4_2_DF$`20h`*100)/(viz03_4_2_DF$Diurns + viz03_4_2_DF$Nocturns)
viz03_4_2_DF$`21h` <- (viz03_4_2_DF$`21h`*100)/(viz03_4_2_DF$Diurns + viz03_4_2_DF$Nocturns)

viz03_4_2_DF <- viz03_4_2_DF[,c(1:6)]

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz03_4_2_DF,"Dades Viz/04_acc_proporcio_hora.csv",sep=",",dec=".",na="",row.names = FALSE)

### VIZ 05 - Heatmap amb la gravetat en funció de la llum i la pluja
viz03_5_DF <- viz03_DF[,c(6,9,14:16)]
viz03_5_DF$Gravetat <- "No Victs"
viz03_5_DF[viz03_5_DF$Morts > 0 | viz03_5_DF$Greus > 0,]$Gravetat <- "Greu"
viz03_5_DF[viz03_5_DF$Lleus & viz03_5_DF$Gravetat == "No Victs",]$Gravetat <- "Lleu"

viz03_5_agg_DF <- viz03_5_DF %>% group_by(Llum,Pluja,Gravetat) %>% summarise(Total = n())
viz03_5_agg_DF <- viz03_5_agg_DF %>% 
  pivot_wider(names_from = Gravetat, values_from = Total, values_fill = 0)

viz03_5_agg_DF$Total <- viz03_5_agg_DF$`No Victs`+viz03_5_agg_DF$Lleu+viz03_5_agg_DF$Greu

viz03_5_agg_DF$PercGreus <- 
  viz03_5_agg_DF$Greu*100/viz03_5_agg_DF$Total

viz03_5_agg_DF <- viz03_5_agg_DF[,c(1,2,5,4,3,7,6)]
viz03_5_agg_DF <- viz03_5_agg_DF[c(4,2,5,1,3,9,7,10,6,8),]

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz03_5_agg_DF,"Dades Viz/05_acc_gravetat.csv",sep=",",dec=".",na="",row.names = FALSE)


### VIZ 06 - Doble donut chat per a contextualitzar les dades de VIZ05 en funció de la pluja
talls <- c(0,0.1,5,20,50,100,1000)
labels <- c("No pluja","Minsa","Poc abundant","Abundant","Molt abundant","Extrema")

viz06_DF$PLUJA <- cut(viz06_DF$PLUJA_24H,talls,labels,right=FALSE)

viz06_agg_DF <- viz06_DF %>% group_by(CODI_ESTACIO,PLUJA) %>% summarise(Total = n()) %>%
  pivot_wider(names_from = CODI_ESTACIO, values_from = Total, values_fill = 0)

colnames(viz06_agg_DF) <- c("PlujaAc24h","X4 - El Raval","X8 - Zona Universitària")

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz06_agg_DF,"Dades Viz/06_dies_pluja.csv",sep=",",dec=".",na="",row.names = FALSE)
