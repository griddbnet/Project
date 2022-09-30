library(nbastatR)
library(RJDBC)

drv <- JDBC("com.toshiba.mwcloud.gs.sql.Driver",
            "/usr/share/java/gridstore-jdbc.jar",
            identifier.quote = "`")

conn <- dbConnect(drv, "jdbc:gs://127.0.0.1:20001/myCluster/public", "admin", "admin")

#Type IDS:

#22,Personal Take Foul
#45,Personal Foul
#43,Loose Ball Foul
#44,Shooting Foul

#584,Substitution

#155,Defensive Rebound
#156,Offensive Rebound

#12,Kicked Ball
#62, bad pass
#63,Lost Ball Turnover
#90,Out of Bounds - Bad Pass Turnover

# Shooting Type Ids

#92,Jump Shot
#131,Pullup Jump Shot
#132,Step Back Jump Shot
#146,Running Pullup Jump Shot

#145,Driving Floating Bank Jump Shot
#144,Driving Floating Jump Shot
#129,Running Finger Roll Layup
#141,Cutting Layup Shot
#128,Driving Finger Roll Layup
#126,Layup Driving Reverse
#110,Driving Layup Shot

queryString <- "select coordinate_x, coordinate_y, score_value from nba_2022 WHERE shooting_play = 'TRUE' AND participants_0_athlete_id = '3945274' AND type_id = '132'"

rs <- dbGetQuery(conn, queryString )

library(stringr)
library(dplyr)
library(ggplot2)
library(lubridate)
library(ggalt)


source("https://raw.githubusercontent.com/toddwschneider/ballr/master/plot_court.R")
source("https://raw.githubusercontent.com/toddwschneider/ballr/master/court_themes.R")
plot_court() # created the court_points object we need
court_points <- court_points %>% mutate_if(is.numeric,~.*10)

rs <- rs  %>%  mutate_if(is.numeric,~.*10)

DBcourt <- 
  ggplot(rs, aes(x=coordinate_x-250, y=coordinate_y+45)) + 
  scale_fill_manual(values = c("#00529b","#cc4b4b"),guide='none')+
  geom_path(data = court_points,
            aes(x = x, y = y, group = desc),
            color = "black")+
  coord_equal()+
  geom_point(aes(fill="TRUE",color=score_value/10),size=1) +
  xlim(-260, 260)+
  labs(title="Shot location",x="",
       y="",
       caption = "with GridDB")

print(DBcourt)