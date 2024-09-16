library(lubridate)

# Script per a la neteja i adequació de les hores de llum diurna
dailight_raw_DF <- read.csv("Raw Data/Geo_Meteo/sunrise_sunset_bcn.csv",
                            header=TRUE, sep=";")

# Eliminar el dia de la setmana de la columna Day
dailight_raw_DF$Day <- substr(dailight_raw_DF$Day,6,nchar(dailight_raw_DF$Day))

# Concatenar Day i Year i convertir-lo a Date
dailight_raw_DF$DayYear <- paste(dailight_raw_DF$Day, dailight_raw_DF$Year, sep=" ")

# Subtituir el nom del mes (abreviatura anglesa que dona problemes) pels dígits

dailight_raw_DF$DayYear <- gsub("Jan", "01", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Feb", "02", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Mar", "03", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Apr", "04", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("May", "05", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Jun", "06", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Jul", "07", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Aug", "08", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Sep", "09", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Oct", "10", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Nov", "11", dailight_raw_DF$DayYear)
dailight_raw_DF$DayYear <- gsub("Dec", "12", dailight_raw_DF$DayYear)

dailight_raw_DF$DayYear <- as.Date(dailight_raw_DF$DayYear, "%m %d %Y")

dailight_raw_DF$Twilight.start <- toupper(dailight_raw_DF$Twilight.start)
dailight_raw_DF$Sunrise <- toupper(dailight_raw_DF$Sunrise)
dailight_raw_DF$Sunset <- toupper(dailight_raw_DF$Sunset)
dailight_raw_DF$Twilight.end <- toupper(dailight_raw_DF$Twilight.end)

dailight_raw_DF$Twilight.start <- parse_date_time2(dailight_raw_DF$Twilight.start,
                                                   orders = "%I:%M:%S %p")
dailight_raw_DF$Sunrise <- parse_date_time2(dailight_raw_DF$Sunrise,
                                            orders = "%I:%M:%S %p")
dailight_raw_DF$Sunset <- parse_date_time2(dailight_raw_DF$Sunset,
                                           orders = "%I:%M:%S %p")
dailight_raw_DF$Twilight.end <- parse_date_time2(dailight_raw_DF$Twilight.end,
                                                 orders = "%I:%M:%S %p")

dailight_raw_DF$DiffSunset <- dailight_raw_DF$Sunrise - dailight_raw_DF$Twilight.start

dailight_raw_DF$HoraSunrise <- hour(dailight_raw_DF$Sunrise)
dailight_raw_DF$MinSunrise <- minute(dailight_raw_DF$Sunrise) - 15
dailight_raw_DF$HoraSunset <- hour(dailight_raw_DF$Sunset)
dailight_raw_DF$MinSunset <- minute(dailight_raw_DF$Sunset) + 15

dailight_raw_DF$factorSunrise <- 0
dailight_raw_DF$factorSunset <- 0

dailight_raw_DF$factorSunrise[dailight_raw_DF$MinSunrise >= 30] <- 1
dailight_raw_DF$factorSunset[dailight_raw_DF$MinSunset < 30] <- 1

dailight_raw_DF$FirstDaylight <- dailight_raw_DF$HoraSunrise + dailight_raw_DF$factorSunrise
dailight_raw_DF$LastDaylight <- dailight_raw_DF$HoraSunset - dailight_raw_DF$factorSunset

# Em quedo amb les columnes d'interès i escric el CSV amb les dades
daylight_DF <- dailight_raw_DF[,c(7,13,14)]

write.csv(daylight_DF,"Dades/daylight_bcn.csv",sep=",",row.names = FALSE)
