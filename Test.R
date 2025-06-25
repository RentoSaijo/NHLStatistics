# Obtain list of all seasons and their ID's
all_seasons <- get_seasons() %>% 
  arrange(id)

# Get user input on season (possible options are all_seasons$id)
season <- 20242025

# Obtain list of all skaters and their player ID's
skaters <- get_skater_statistics(
  season=season, 
  report='bios', 
  is_aggregate=TRUE
)

# Get user input on skater (possible options are skaters$skaterFullName)
skater <- 'Cale Makar'

# Find player ID for skater
skater_row <- skaters %>% 
  filter(skaterFullName==skater) %>% 
  slice_head(n=1)
player_id <- skater_row$playerId

# Create area chart on toi, shots, and plusMinus by game
library(echarts4r)
regular_gl <- get_player_game_log(player_id, season, 2)
playoff_gl <- get_player_game_log(player_id, season, 3)
skater_gl <- bind_rows(regular_gl, playoff_gl) %>% 
  arrange(gameDate) %>% 
  separate(toi, into=c('min', 'sec'), sep=':', convert=TRUE) %>%
  mutate(toi=min+sec/60)
season_chart <- skater_gl |>
  e_charts(gameDate) |>
  e_line(toi, name='Time on Ice (mins)') |>
  e_line(shots, name='Shots on Goal') |>
  e_bar(plusMinus, name='Plus/Minus') |>
  e_tooltip(trigger = 'axis') |> 
  e_toolbox_feature(feature = 'saveAsImage') |>
  e_title(paste0(
    skater, 
    '\'s TOI, SOG, and +/- for ', 
    season%/%10000,
    '-',
    season%%10000,
    ' Season'
  ), left='center', top=20)
if (nrow(playoff_gl) >= 1) {
  season_chart <- season_chart |>
    e_mark_line(data=list(xAxis=tail(playoff_gl, 1)$gameDate), title='Playoffs Begin')
}
season_chart

