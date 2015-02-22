## Using RCharts to create an interactive d3 visualization of snow calls
# Created by Daniel Hadley 2/2015

setwd("/Users/dphnrome/Documents/Git/Hack-Across-311-Snow/charts/")

## First install package (if not already installed)
#require(devtools)
#install_github('rCharts', 'ramnathv')

library(rCharts)
library(lubridate)
library(tidyr)
library(dplyr)
library(ggplot2)

#### Load data ####
# Will eventually retrieve data using Soda API 
# But for now just using dowloaded csv

snowData <- read.csv("./data/Commonwealth_Connect_reports_within_Massachusetts_State.csv")

# Mainly adding date data
d <- snowData %>%
  tbl_df()  %>% # Convert to tbl class - easier to examine than dfs
  mutate(dateTime = mdy_hms(ticket_created_date_time, tz='EST')) %>%
  arrange(dateTime) %>%
  mutate(date = as.Date(dateTime),
         hour = hour(dateTime)) %>%
  mutate(monthDay = day(date),
         weekDay = wday(date),
         month = month(date),
         year = year(date)) 


### This will give me a timeseries of every day
days <- d %>%
  group_by(date) %>%
  summarise(Events = n())

allDays <- seq.Date(from=d$date[1], to = d$date[nrow(d)], b='days')
allDays <- allDays  %>%  as.data.frame() 
colnames(allDays)[1] = "date"

# After this we will have a df with every date and how many snow issues
ts = merge(days, allDays, by='date', all=TRUE)
ts[is.na(ts)] <- 0

remove(allDays, days)
ts$id <- seq(1, nrow(ts))


#### Now make the d3 chart using rCharts ####
cumulative <- ts %>%
  mutate(Snow.Issues = cumsum(Events))

d3chart<-nPlot(Snow.Issues~date, data=cumulative, type="lineChart")

d3chart$xAxis(
  tickFormat = "#!function(d) {return d3.time.format('%b %Y')(new Date( d * 86400000 ));}!#"
)

## Save it

d3chart$save('d3chart.html', cdn=TRUE)


#### Now a bar chart of top cities/towns ####

byMuni <- d %>%
  group_by(city) %>%
  summarise(Snow.Issues = n()) %>%
  filter(Snow.Issues > 100)
  

d3chart2 <- nPlot(Snow.Issues ~ city, data = byMuni, type = "multiBarChart")

## Save it
d3chart2$save('d3chart2.html', cdn=TRUE)
