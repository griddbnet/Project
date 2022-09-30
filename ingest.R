options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx25192m"))
gc()

library(RJDBC)
library(hoopR)


drv <- JDBC("com.toshiba.mwcloud.gs.sql.Driver",
            "/usr/share/java/gridstore-jdbc.jar",
            identifier.quote = "`")

conn <- dbConnect(drv, "jdbc:gs://127.0.0.1:20001/myCluster/public", "admin", "admin")

library(nflreadr)
loader <- rds_from_url
urls <- paste0("https://raw.githubusercontent.com/sportsdataverse/hoopR-data/main/nba/pbp/rds/play_by_play_2022.rds") 

p <- NULL

out <- lapply(urls, progressively(loader, p))
out <- rbindlist_with_attrs(out)

out$type_abbreviation <- NULL

for (i in 1:nrow(out)) {
  RJDBC::dbWriteTable(conn, "nba_2022", out[i, ], append = TRUE )
}