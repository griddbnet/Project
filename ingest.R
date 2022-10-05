options(java.parameters = c("-XX:+UseConcMarkSweepGC", "-Xmx25192m"))
gc()

library(RJDBC)
library(hoopR)

# Connect to GridDB via JDBC
drv <- JDBC("com.toshiba.mwcloud.gs.sql.Driver",
            "/usr/share/java/gridstore-jdbc.jar",
            identifier.quote = "`")

conn <- dbConnect(drv, "jdbc:gs://127.0.0.1:20001/myCluster/public", "admin", "admin")
print("Succesfully connected to GridDB")


library(nflreadr)
loader <- rds_from_url
urls <- paste0("https://raw.githubusercontent.com/sportsdataverse/hoopR-data/main/nba/pbp/rds/play_by_play_2022.rds") 

p <- NULL

# Read in .rds file of all play by play data
out <- lapply(urls, progressively(loader, p))
out <- rbindlist_with_attrs(out)

#remove type_abbreviation column as it is useless
out$type_abbreviation <- NULL

print("Beginning ingest. Please hang tight as this process may take a few hours+")

#Ingest line by line
for (i in 1:nrow(out)) {
  RJDBC::dbWriteTable(conn, "nba_pbp_2022", out[i, ], append = TRUE )
}

print("Thank you for your patience. The ingest has completed.")
