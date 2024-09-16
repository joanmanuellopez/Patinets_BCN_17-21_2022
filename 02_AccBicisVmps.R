library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)

# Script per a recollir el gruix de les dades d'accidents amb bicicletes i VMPs
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

# Selecció de les columnes d'interès
cols_keep_1718 <- c("Codi_expedient","Descripcio_tipus_vehicle")
cols_keep_1921 <- c("Numero_expedient","Descripcio_tipus_vehicle")

acc_veh_17_DF <- acc_veh_17_DF[,cols_keep_1718]
acc_veh_18_DF <- acc_veh_18_DF[,cols_keep_1718]
acc_veh_19_DF <- acc_veh_19_DF[,cols_keep_1921]
acc_veh_20_DF <- acc_veh_20_DF[,cols_keep_1921]
acc_veh_21_DF <- acc_veh_21_DF[,cols_keep_1921]

# Reanomenació de les columnes
cols_names <- c("ID","Vehicle")
colnames(acc_veh_17_DF) <- cols_names
colnames(acc_veh_18_DF) <- cols_names
colnames(acc_veh_19_DF) <- cols_names
colnames(acc_veh_20_DF) <- cols_names
colnames(acc_veh_21_DF) <- cols_names

# Ajunto les dades dels 5 anys
acc_veh_df <- rbind(acc_veh_17_DF,acc_veh_18_DF,acc_veh_19_DF,
                    acc_veh_20_DF,acc_veh_21_DF)

acc_veh_df$ID <- trimws(acc_veh_df$ID)

# Recategorització de vehicles
catv_vmp <- c("Veh. mobilitat personal amb motor","Veh. mobilitat personal sense motor")

catv_keep <- c("Bicicleta","VMP")

acc_veh_df$Vehicle[acc_veh_df$Vehicle %in% catv_vmp] <- "VMP"
acc_veh_df$Vehicle[!acc_veh_df$Vehicle %in% catv_keep] <- "Altres"

# Vector amb els ID dels expedients d'accidents amb bicicletes i VMPs
ids_acc <- sort(unique(acc_veh_df[acc_veh_df$Vehicle %in% catv_keep,]$ID))

### Lectura dels fitxers CSV amb les dades generals dels accidents
acc_gu_17_DF <- read.csv("Raw Data/Accidents/2017_accidents_gu_bcn.csv",
                         dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)
acc_gu_18_DF <- read.csv("Raw Data/Accidents/2018_accidents_gu_bcn.csv",
                         dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)
acc_gu_19_DF <- read.csv("Raw Data/Accidents/2019_accidents_gu_bcn.csv",
                         dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)
acc_gu_20_DF <- read.csv("Raw Data/Accidents/2020_accidents_gu_bcn.csv",
                         dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)
acc_gu_21_DF <- read.csv("Raw Data/Accidents/2021_accidents_gu_bcn.csv",
                         dec = ".", header=TRUE, sep=",", quote = "\"", strip.white = TRUE)

# Selecció de les columnes d'interès
cols_keep_gu_1720 <- c(1,2,12,13,15,16,19,20,21,26,27)
cols_keep_gu_21 <- c(1,2,10,11,13,14,17,18,19,24,25)

acc_gu_17_DF <- acc_gu_17_DF[,cols_keep_gu_1720]
acc_gu_18_DF <- acc_gu_18_DF[,cols_keep_gu_1720]
acc_gu_19_DF <- acc_gu_19_DF[,cols_keep_gu_1720]
acc_gu_20_DF <- acc_gu_20_DF[,cols_keep_gu_1720]
acc_gu_21_DF <- acc_gu_21_DF[,cols_keep_gu_21]

# Reanomenació de les columnes
cols_names <- c("ID","Districte","Any","Mes","Dia","Hora","Morts","Lleus","Greus","Longitud","Latitud")
colnames(acc_gu_17_DF) <- cols_names
colnames(acc_gu_18_DF) <- cols_names
colnames(acc_gu_19_DF) <- cols_names
colnames(acc_gu_20_DF) <- cols_names
colnames(acc_gu_21_DF) <- cols_names

# Ajunto les dades dels 5 anys
acc_gu_df <- rbind(acc_gu_17_DF,acc_gu_18_DF,acc_gu_19_DF,acc_gu_20_DF,acc_gu_21_DF)

acc_gu_df$ID <- trimws(acc_gu_df$ID)

# Només conservar accidents amb bicicletes i VMPs
acc_gu_df <- acc_gu_df[acc_gu_df$ID %in% ids_acc,]

# Convertir codo districte a string i assignar-li estació meteorològica
acc_gu_df$Districte <- str_pad(as.character(acc_gu_df$Districte), 2, pad = "0")
acc_gu_df$EstMeteo <- "X4"

dte_zu <- str_pad(as.character(4:8),2,pad="0")
acc_gu_df[acc_gu_df$Districte %in% dte_zu,]$EstMeteo <- "X8"

# Fusionar dia-mes-any per a obtenir la data
acc_gu_df$Data <- paste(acc_gu_df$Any,acc_gu_df$Mes,acc_gu_df$Dia, sep = "-")
acc_gu_df$Data <- as.Date(acc_gu_df$Data, "%Y-%m-%d")

# Reordenació i selecció de camps
cols_keep_gu <- c(1,13,6,2,12,7:11)
acc_gu_df <- acc_gu_df[,cols_keep_gu]

### Afegir informació agregada de bicicletes, VMPs i Altres
acc_veh_bv_DF <- acc_veh_df[acc_veh_df$ID %in% ids_acc,]

acc_veh_bv_DF <- acc_veh_bv_DF %>% group_by(ID,Vehicle) %>% summarise(Total = n())

acc_veh_bv_DF <- acc_veh_bv_DF %>% 
  pivot_wider(names_from = Vehicle, values_from = Total, values_fill = 0)

# Juntar la informació al dataframe general
acc_gu_df <- acc_gu_df %>% inner_join( acc_veh_bv_DF, by=c('ID'))


### Recollir informació dels vianants implicats agregada
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

cols_names <- c("ID","Persona")
colnames(acc_vian_17_DF) <- cols_names
colnames(acc_vian_18_DF) <- cols_names
colnames(acc_vian_19_DF) <- cols_names
colnames(acc_vian_20_DF) <- cols_names
colnames(acc_vian_21_DF) <- cols_names

acc_vian_DF <- rbind(acc_vian_17_DF,acc_vian_18_DF,acc_vian_19_DF,
                     acc_vian_20_DF,acc_vian_21_DF)

acc_vian_DF$ID <- trimws(acc_vian_DF$ID)

acc_vian_bv_DF <- acc_vian_DF[(acc_vian_DF$Persona == "Vianant") & 
                                   (acc_vian_DF$ID %in% ids_acc),]

acc_vian_bv_DF <- acc_vian_bv_DF %>% group_by(ID,Persona) %>% summarise(Total = n())

acc_vian_bv_DF <- acc_vian_bv_DF %>% 
  pivot_wider(names_from = Persona, values_from = Total)

acc_gu_2_df <- acc_gu_df %>% left_join( acc_vian_bv_DF, by=c('ID'))
acc_gu_2_df[is.na(acc_gu_2_df$Vianant),]$Vianant <- 0

### Recollir dades de méteo i juntar-les al df general
meteo_DF <- read.csv("Dades/meteo_bcn.csv", dec = ".",
                     header=TRUE, sep=",", quote = "\"")

meteo_DF$DIA <- as.Date(meteo_DF$DIA, "%Y-%m-%d")

acc_gu_2_df <- acc_gu_2_df %>% inner_join( meteo_DF,
                                           by=c('Data'='DIA',
                                                'EstMeteo'='CODI_ESTACIO'))

talls <- c(0,0.1,5,20,50,100,1000)
labels <- c("No pluja","Minsa","Poc abundant","Abundant","Molt abundant","Extrema")

acc_gu_2_df$Pluja <- cut(acc_gu_2_df$PLUJA_24H,talls,labels,right=FALSE)

### Recollir dades de llum diurna i juntar-les al df general
daylight_DF <- read.csv("Dades/daylight_bcn.csv", dec = ".", header=TRUE, sep=",", quote = "\"")

daylight_DF$DayYear <- as.Date(daylight_DF$DayYear, "%Y-%m-%d")

acc_gu_2_df <- acc_gu_2_df %>% inner_join( daylight_DF, by=c('Data'='DayYear'))
acc_gu_2_df$Llum <- "Nocturna"

acc_gu_2_df[acc_gu_2_df$Hora >= acc_gu_2_df$FirstDaylight & acc_gu_2_df$Hora <= acc_gu_2_df$LastDaylight,]$Llum <- "Diurna"


### Recopilació i reordenació de la informació necessària
acc_gu_2_df <- acc_gu_2_df[,c(1,2,3,9,10,20,4,5,17,11,13,14,12,7,8,6)]
acc_gu_2_df <- acc_gu_2_df %>% arrange(ID)


### Escriure el DF resultant a un CSV per a la visualització amb Flourish
write.csv(acc_gu_2_df,"Dades/acc_bic_vmp_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)
