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


#### Visualize ####

my.theme <- 
  theme(#plot.background = element_rect(fill="white"), # Remove background
    panel.grid.major = element_blank(), # Remove gridlines
    # panel.grid.minor = element_blank(), # Remove more gridlines
    # panel.border = element_blank(), # Remove border
    # panel.background = element_blank(), # Remove more background
    axis.ticks = element_blank(), # Remove axis ticks
    axis.text=element_text(size=6), # Enlarge axis text font
    axis.title=element_text(size=8), # Enlarge axis title font
    plot.title=element_text(size=12) # Enlarge, left-align title
    ,axis.text.x = element_text(angle=60, hjust = 1) # Uncomment if X-axis unreadable 
  )


### This will give me a timeseries of every day
days <- d %>%
  group_by(date) %>%
  summarise(Events = n())

allDays <- seq.Date(from=d$date[1], to = d$date[nrow(d)], b='days')
allDays <- allDays  %>%  as.data.frame() 
colnames(allDays)[1] = "date"

# After this we will have a df with every date and how many BnEs
ts = merge(days, allDays, by='date', all=TRUE)
ts[is.na(ts)] <- 0

remove(allDays, days)
ts$id <- seq(1, nrow(ts))

ggplot(ts, aes(x=date, y=Events, group = 1)) + 
  geom_line(colour='red', size = 1) + 
  my.theme + ggtitle("Daily Snow Issues") + xlab("Year") +
  ylab("311 Snow Issues") + 
  scale_y_continuous(labels = comma) +
  scale_x_date(labels=date_format("%Y"))


cumulative <- ts %>%
  mutate(cumulativeIssues = cumsum(Events))


ggplot(cumulativeIssues, aes(x=date, y=cumulative, group = 1)) + 
  geom_line(colour='red', size = 1) 

## Now make the d3 chart using rCharts

d3chart<-nPlot(cumulativeIssues~date, data=cumulative, type="lineChart")

d3chart$xAxis(
  tickFormat = "#!function(d) {return d3.time.format('%b %Y')(new Date( d * 86400000 ));}!#"
)



