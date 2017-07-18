library(dplyr)
library(datapkg)
library(readxl)
library(stringr)


##################################################################
#
# Processing Script for Labor Market Areas
# Created by Jenna Daly
# On 07/18/2017
#
##################################################################


#Setup environment
sub_folders <- list.files()
data_location <- grep("raw", sub_folders, value=T)
path_to_raw_data <- (paste0(getwd(), "/", data_location))
raw_LMA <- dir(path_to_raw_data, recursive=T, pattern = "LMA") 

#Read in raw file
raw_LMA_xl <- (read_excel(paste0(path_to_raw_data, "/", raw_LMA), sheet=2, skip=0)) 

#Remove "LMA" from end of column
raw_LMA_xl$LMA <- gsub(" LMA", "", raw_LMA_xl$LMA)

#Convert LMA to title case
raw_LMA_xl$LMA <- str_to_title(raw_LMA_xl$LMA)

#Insert "LMA" at beginning of column
raw_LMA_xl$LMA <- sub("^", "LMA ", raw_LMA_xl$LMA)

raw_LMA_xl$LMA <- gsub("-", " - ", raw_LMA_xl$LMA)

#Merge in FIPS
town_fips_dp_URL <- 'https://raw.githubusercontent.com/CT-Data-Collaborative/ct-town-list/master/datapackage.json'
town_fips_dp <- datapkg_read(path = town_fips_dp_URL)
fips <- (town_fips_dp$data[[1]])

LMA_fips <- merge(raw_LMA_xl, fips, by = "Town", all=T)

#remove CT
LMA_fips <- LMA_fips[LMA_fips$Town != "Connecticut",]

LMA_fips <- LMA_fips %>% 
  select(Town, FIPS, LMA) %>% 
  rename(`Labor Market Area` = LMA) %>% 
  arrange(Town)

# Write to File
write.table(
  LMA_fips,
  file.path(getwd(), "data", "labor_market_areas_2017.csv"),
  sep = ",",
  row.names = F
)


