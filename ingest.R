options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx25192m"))
gc()

library(RJDBC)
library(hoopR)


drv <- JDBC("com.toshiba.mwcloud.gs.sql.Driver",
            "/usr/share/java/gridstore-jdbc-5.0.0.jar",
            identifier.quote = "`")

conn <- dbConnect(drv, "jdbc:gs://239.0.0.1:41999/defaultCluster/public", "admin", "admin")

loader <- rds_from_url
urls <- paste0("https://raw.githubusercontent.com/sportsdataverse/hoopR-data/main/nba/pbp/rds/play_by_play_2016.rds") 

p <- NULL

out <- lapply(urls, progressively(loader, p))
out <- rbindlist_with_attrs(out)

out$type_abbreviation <- NULL

#createTableString <- "CREATE TABLE IF NOT EXISTS nba_play_by_play ( shooting_play STRING, sequence_number STRING, period_display_value STRING, period_number INTEGER, home_score INTEGER, coordinate_x INTEGER, coordinate_y INTEGER, away_score INTEGER, scoring_play STRING, id DOUBLE, text STRING, clock_display_value STRING, type_id STRING, type_text STRING, score_value INTEGER, team_id STRING, participants_0_athlete_id STRING, participants_1_athlete_id STRING, participants_2_athlete_id STRING, season INTEGER, season_type INTEGER, away_team_id INTEGER, away_team_name STRING, away_team_mascot STRING, away_team_abbrev STRING, away_team_name_alt STRING, home_team_id INTEGER, home_team_name STRING, home_team_mascot STRING, home_team_abbrev STRING, home_team_name_alt STRING, home_team_spread DOUBLE, game_spread DOUBLE, home_favorite STRING, game_spread_available STRING, game_id INTEGER, qtr INTEGER, time STRING, clock_minutes INTEGER, clock_seconds DOUBLE, half STRING, game_half STRING, lag_qtr DOUBLE, lead_qtr DOUBLE, lag_game_half STRING, lead_game_half STRING, start_quarter_seconds_remaining INTEGER, start_half_seconds_remaining INTEGER, start_game_seconds_remaining INTEGER, game_play_number INTEGER, end_quarter_seconds_remaining DOUBLE, end_half_seconds_remaining DOUBLE, end_game_seconds_remaining DOUBLE, period INTEGER)" # nolint

#RJDBC::dbSendUpdate(conn, createTableString)

for (i in 1:nrow(out)) {
  RJDBC::dbWriteTable(conn, "nba_2016", out[i, ], append = TRUE )
}