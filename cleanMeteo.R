# Script per a obtenir les dades de Meteocat en un únic CSV
library(tidyr)
library(dplyr)

# Càrrega de les dades dels csv
colsMeteo <- c("character", "character", "float", "float", "float",
                    "integer", "float", "float", "float", "float",
                    "integer", "float", "integer")

raval_1719_meteo_DF <- read.csv("Raw Data/Geo_Meteo/2019_x4_barcelona_el_raval.csv",
                                dec = ".", header=TRUE, sep=",")

zonun_1719_meteo_DF <- read.csv("Raw Data/Geo_Meteo/2019_x8_barcelona_zona_universitaria.csv",
                                header=TRUE, sep=",")

# Convertir columna DATA_LECTURA a data (datetime)
raval_1719_meteo_DF$DATA_LECTURA <- as.POSIXct( raval_1719_meteo_DF$DATA_LECTURA, format="%d/%m/%Y" )
zonun_1719_meteo_DF$DATA_LECTURA <- as.POSIXct( zonun_1719_meteo_DF$DATA_LECTURA, format="%d/%m/%Y" )

raval_1719_meteo_DF <- raval_1719_meteo_DF[raval_1719_meteo_DF$DATA_LECTURA >= "2017-01-01",]
zonun_1719_meteo_DF <- zonun_1719_meteo_DF[zonun_1719_meteo_DF$DATA_LECTURA >= "2017-01-01",]

cols_keep_1719 <- c("CODI_ESTACIO","DATA_LECTURA","TX","PPT24H")
raval_1719_meteo_DF <- raval_1719_meteo_DF[,cols_keep_1719]
zonun_1719_meteo_DF <- zonun_1719_meteo_DF[,cols_keep_1719]

# El format dels fitxers del 2020 i 2021 és diferent a la dels altres anys
bcn_20_meteo_df <- read.csv("Raw Data/Geo_Meteo/2020_MeteoCat_Detall_Estacions.csv",
                            header=TRUE, sep = ",", na.strings = "NA")

bcn_21_meteo_df <- read.csv("Raw Data/Geo_Meteo/2021_MeteoCat_Detall_Estacions.csv",
                            header=TRUE, sep = ",", na.strings = "NA")

colsMeteo <- c("DATA_LECTURA","DATA_EXTREM","CODI_ESTACIO","ACRONIM","VALOR")
colnames(bcn_20_meteo_df) <-colsMeteo
colnames(bcn_21_meteo_df) <-colsMeteo

cols_keep <- c("DATA_LECTURA","CODI_ESTACIO","ACRONIM","VALOR")
bcn_20_meteo_df <- bcn_20_meteo_df[,cols_keep]
bcn_21_meteo_df <- bcn_21_meteo_df[,cols_keep]

# Només dades del Raval (X4) i Zona Universitària (X8) per a temperatura mitja i precipitació en 24h
bcn_20_meteo_df <- bcn_20_meteo_df[bcn_20_meteo_df$CODI_ESTACIO %in% c("X4","X8"),]
bcn_20_meteo_df <- bcn_20_meteo_df[bcn_20_meteo_df$ACRONIM %in% c("TX","PPT"),]

bcn_21_meteo_df <- bcn_21_meteo_df[bcn_21_meteo_df$CODI_ESTACIO %in% c("X4","X8"),]
bcn_21_meteo_df <- bcn_21_meteo_df[bcn_21_meteo_df$ACRONIM %in% c("TX","PPT"),]

# canviar format long a wide els dos DF
bcn_20_meteo_df <- spread(bcn_20_meteo_df,ACRONIM,VALOR)
bcn_21_meteo_df <- spread(bcn_21_meteo_df,ACRONIM,VALOR)

# UN COP TRACTATS, AJUNTAR ELS DATAFRAMES EN UN DE SOL, ORDENATS PER DATA ASCENEDENT
bcn_meteo_1719_DF <- rbind(raval_1719_meteo_DF,zonun_1719_meteo_DF)
bcn_meteo_1719_DF <- arrange(bcn_meteo_1719_DF,DATA_LECTURA,CODI_ESTACIO)

col_order_1719 <- c("DATA_LECTURA","CODI_ESTACIO","TX","PPT24H")
bcn_meteo_1719_DF <- bcn_meteo_1719_DF[,col_order_1719]

col_names_meteo <- c("DIA","CODI_ESTACIO","TEMP_MITJA","PLUJA_24H")
colnames(bcn_meteo_1719_DF) <- col_names_meteo

bcn_meteo_2021_DF <- rbind(bcn_20_meteo_df,bcn_21_meteo_df)

col_order_2021 <- c("DATA_LECTURA","CODI_ESTACIO","TX","PPT")
bcn_meteo_2021_DF <- bcn_meteo_2021_DF[,col_order_2021]
colnames(bcn_meteo_2021_DF) <- col_names_meteo

bcn_meteo_DF <- rbind(bcn_meteo_1719_DF,bcn_meteo_2021_DF)

# Escriptura del CSV amb les dades meteorològiques al període 2017-2021
write.csv(bcn_meteo_DF,"Dades/meteo_bcn.csv",sep=",",dec=".",na="",row.names = FALSE)