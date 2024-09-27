library(RPostgres)
library(tidyverse)

conn <- dbConnect(Postgres(), dbname = "drpstatcast", host = "localhost",
                  port = 5432, user = "postgres", password = "drppassword")

stats_query <- "
SELECT *
FROM statcast
WHERE game_date NOT BETWEEN '2021-03-01' AND '2021-03-31'
   AND game_date NOT BETWEEN '2015-03-28' AND '2015-04-04'
   AND game_date NOT BETWEEN '2016-03-28' AND '2016-04-02'
   AND game_date NOT BETWEEN '2017-03-28' AND '2017-04-01'
   AND game_date NOT BETWEEN '2022-03-28' AND '2022-04-06'
   AND game_date NOT BETWEEN '2023-03-28' AND '2023-03-29'
"

stats_df <- dbGetQuery(conn, stats_query)

re_df <- stats_df %>%
    select(game_date, game_pk, game_year, player_name, batter, pitcher, events, 
           home_team, away_team, on_1b, on_2b, on_3b, outs_when_up, inning, 
           inning_topbot, at_bat_number, batting_team, fielding_team) %>%
    filter(events != "") %>%
    mutate(across(c(on_1b, on_2b, on_3b), ~ ifelse(is.na(.), 0, 1)), 
           half_inning = paste0(inning_topbot, "_", inning)) %>%
    select(-inning, -inning_topbot) %>%
    arrange(game_date, game_pk, at_bat_number)
