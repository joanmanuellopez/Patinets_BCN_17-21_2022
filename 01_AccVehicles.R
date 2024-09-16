library(dplyr)
library(stringr)
library(tidyr)

# Lectura dels fitxers CSV amb les dades d'origen
acc_veh_17_DF <- read.csv("Raw Data/Accidents/2017_accidents_vehicles_gu_bcn_.csv",
                          dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_veh_18_DF <- read.csv("Raw Data/Accidents/2018_accidents_vehicles_gu_bcn_.csv",
                          dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_veh_19_DF <- read.csv("Raw Data/Accidents/2019_accidents_vehicles_gu_bcn_.csv",
                          dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_veh_20_DF <- read.csv("Raw Data/Accidents/2020_accidents_vehicles_gu_bcn.csv",
                          dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_veh_21_DF <- read.csv("Raw Data/Accidents/2021_accidents_vehicles_gu_bcn.csv",
                          dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)


# Selecció de columnes d'interès per a la visualització
cols_keep_1718 <- c("Codi_expedient","Any","Mes_any","Descripcio_tipus_vehicle")
cols_keep_1921 <- c("Numero_expedient","NK_Any","Mes_any","Descripcio_tipus_vehicle")

acc_veh_17_DF <- acc_veh_17_DF[,cols_keep_1718]
acc_veh_18_DF <- acc_veh_18_DF[,cols_keep_1718]
acc_veh_19_DF <- acc_veh_19_DF[,cols_keep_1921]
acc_veh_20_DF <- acc_veh_20_DF[,cols_keep_1921]
acc_veh_21_DF <- acc_veh_21_DF[,cols_keep_1921]

# Reanomenació de les columnes
cols_names <- c("ID_Expedient","Any","Mes","Vehicle")
colnames(acc_veh_17_DF) <- cols_names
colnames(acc_veh_18_DF) <- cols_names
colnames(acc_veh_19_DF) <- cols_names
colnames(acc_veh_20_DF) <- cols_names
colnames(acc_veh_21_DF) <- cols_names

acc_veh_df <- rbind(acc_veh_17_DF,acc_veh_18_DF,acc_veh_19_DF,
                    acc_veh_20_DF,acc_veh_21_DF)

# Verificació, unificació i simplificació de les categories de vehicle
catv_tur <- c("Turismo")
catv_bus <- c("Autobús","Autobús articulado","Autobús articulat")
catv_cam <- c("Camió rígid <= 3,5 tones", "Camión <= 3,5 Tm",
              "Camión > 3,5 Tm", "Camió rígid > 3,5 tones")
catv_trm <- c("Tranvía o tren", "Tren o tramvia")
catv_mic <- c("Microbus <=17 plazas","Microbus <= 17","Microbús <= 17")
catv_avs <- c("Altres vehicles sense motor","Carro")
catv_avm <- c("Altres vehicles amb motor","Otros vehíc. a motor","Autocaravana",
              "Tractocamión","Todo terreno","Tot terreny","Quadricicle > 75 cc",
              "Cuadriciclo <75cc", "Quadricicle < 75 cc","Tractor camió", 
              "Maquinaria de obras", "Maquinària d'obres i serveis","Pick-up",
              "Ambulància")
catv_vmp <- c("Veh. mobilitat personal amb motor","Veh. mobilitat personal sense motor")
catv_des <- c("","Desconegut")

acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_tur] <- "Turisme"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_bus] <- "Bus"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_cam] <- "Camió"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_trm] <- "Tramvia"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_mic] <- "Microbús"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_avs] <- "Altres vehicles sense motor"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_avm] <- "Altres vehicles amb motor"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_vmp] <- "VMP"
acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_des] <- "Desconegut"

acc_veh_df$ID_Expedient <- trimws(acc_veh_df$ID_Expedient)

### Dades de la primera visualització
viz1_DF <- acc_veh_df %>% group_by(Any,Mes,Vehicle) %>% summarise (Total_mes = n())
viz1_DF <- viz1_DF[viz1_DF$Vehicle != "Desconegut",]

# Reanomenar les categories "Altres", nom més curt
viz1_DF$Vehicle[viz1_DF$Vehicle == "Altres vehicles sense motor"] <- "Altres sense motor"
viz1_DF$Vehicle[viz1_DF$Vehicle == "Altres vehicles amb motor"] <- "Altres amb motor"

# Fusionar les columnes mes i any (Format Gen 2017)
viz1_DF$Any <- as.character(viz1_DF$Any)
viz1_DF$Mes <- str_pad(as.character(viz1_DF$Mes), 2, pad = "0")
viz1_DF$MesAny <- paste(viz1_DF$Mes, viz1_DF$Any, sep = "/")

viz1_b_DF <- viz1_DF[,c(3:5)]
viz1_b_DF <- viz1_b_DF[,c(3,1,2)]

# Generar una columna per tipus de vehicle
viz1_b_DF <- viz1_b_DF %>% pivot_wider(names_from = Vehicle, values_from = Total_mes)

viz1_b_DF[is.na(viz1_b_DF)] <- 0

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz1_b_DF,"Dades/acc_vehicles_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)

### Dades de la segona visualització
#add cumulative column to the data frame
#product_sales[,"cum_sales"] <- cumsum(product_sales$Sales)
# Font info: https://rveryday.wordpress.com/2016/11/17/create-a-cumulative-sum-column-in-r/

# Lectura dels fitxers CSV amb les dades d'origen per a obtenir accidents amb vianants
acc_vian_17_DF <- read.csv("Raw Data/Accidents/2017_accidents_persones_gu_bcn_.csv",
                           dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_vian_18_DF <- read.csv("Raw Data/Accidents/2018_accidents_persones_gu_bcn_.csv",
                           dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_vian_19_DF <- read.csv("Raw Data/Accidents/2019_accidents_persones_gu_bcn_.csv",
                           dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_vian_20_DF <- read.csv("Raw Data/Accidents/2020_accidents_persones_gu_bcn.csv",
                           dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

acc_vian_21_DF <- read.csv("Raw Data/Accidents/2021_accidents_persones_gu_bcn.csv",
                           dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

# De tota la info disponible, em quedo només amb ID i Tipus persona
cols_keep_1718 <- c("Numero_expedient","Descripcio_tipus_persona")
cols_keep_19 <- c("Numero_Expedient","Descripcio_tipus_persona")
cols_keep_2021 <- c("Numero_Expedient","Descripció_tipus_persona")

acc_vian_17_DF <- acc_vian_17_DF[,cols_keep_1718]
acc_vian_18_DF <- acc_vian_18_DF[,cols_keep_1718]
acc_vian_19_DF <- acc_vian_19_DF[,cols_keep_19]
acc_vian_20_DF <- acc_vian_20_DF[,cols_keep_2021]
acc_vian_21_DF <- acc_vian_21_DF[,cols_keep_2021]

cols_names <- c("ID_Expedient","Persona")
colnames(acc_vian_17_DF) <- cols_names
colnames(acc_vian_18_DF) <- cols_names
colnames(acc_vian_19_DF) <- cols_names
colnames(acc_vian_20_DF) <- cols_names
colnames(acc_vian_21_DF) <- cols_names

acc_vian_17_DF <- acc_vian_17_DF[acc_vian_17_DF$Persona == "Vianant",]
acc_vian_18_DF <- acc_vian_18_DF[acc_vian_18_DF$Persona == "Vianant",]
acc_vian_19_DF <- acc_vian_19_DF[acc_vian_19_DF$Persona == "Vianant",]
acc_vian_20_DF <- acc_vian_20_DF[acc_vian_20_DF$Persona == "Vianant",]
acc_vian_21_DF <- acc_vian_21_DF[acc_vian_21_DF$Persona == "Vianant",]

ids_17 <- unique(trimws(acc_vian_17_DF$ID_Expedient))
ids_18 <- unique(trimws(acc_vian_18_DF$ID_Expedient))
ids_19 <- unique(trimws(acc_vian_19_DF$ID_Expedient))
ids_20 <- unique(trimws(acc_vian_20_DF$ID_Expedient))
ids_21 <- unique(trimws(acc_vian_21_DF$ID_Expedient))

ids_vianants <- c(ids_17,ids_18,ids_19,ids_20,ids_21)

# Seleccionar del DF amb tots els vehicles en accidents, només els d'aquells amb vianants implicats
viz2_DF <- acc_veh_df[acc_veh_df$ID_Expedient %in% ids_vianants,]
viz2_DF <- viz2_DF %>% group_by(Any,Mes,Vehicle) %>% summarise (Total_mes = n())

viz2_DF <- viz2_DF[viz2_DF$Vehicle != "Desconegut",]

# Fusionar les columnes mes i any
viz2_DF$Any <- as.character(viz2_DF$Any)
viz2_DF$Mes <- str_pad(as.character(viz2_DF$Mes), 2, pad = "0")
viz2_DF$AnyMes <- paste(viz2_DF$Any, viz2_DF$Mes, sep = "/")

viz2_DF <- viz2_DF[,c(3:5)]
viz2_DF <- viz2_DF[,c(3,1,2)]

# Generar una columna per tipus de vehicle
viz2_DF <- viz2_DF %>% pivot_wider(names_from = Vehicle, values_from = Total_mes) %>% arrange(AnyMes)

viz2_DF[is.na(viz2_DF)] <- 0

# Sumes acumulatives
viz2_acumul_DF <- viz2_DF

for (vc in c(2:ncol(viz2_acumul_DF))){
  viz2_acumul_DF[,vc] <- cumsum(viz2_acumul_DF[,vc])
}

# Torno al long format per a tenir el format requerit per la visualització
viz2_acumul_DF <- viz2_acumul_DF %>%
  pivot_longer(!AnyMes, names_to = "TipusVeh", values_to = "TotalAcum")

# Format wide amb columnes AnyMes per a tenir el format requerit per la viz
viz2_acumul_DF <- viz2_acumul_DF %>% 
  pivot_wider(names_from = AnyMes, values_from = TotalAcum)

# Escriure el DF resultant en un CSV per a la visualització amb Flourish
write.csv(viz2_acumul_DF,"Dades/acc_vian_veh_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)
