# Load necessary libraries.
library(tidyverse)
library(shiny)
library(bs4Dash)
library(nhlscraper)
library(cranlogs)
library(echarts4r)

# Set assets.
shiny::addResourcePath("assets", "assets/")

# Get necessary data.
all_seasons   <- get_seasons() |> arrange(id)
current_season <- get_season_now()$seasonId

# Get latest Stanley Cup champions.
finals <- get_series_carousel(current_season, round=4)
while (nrow(finals) != 1 || !(finals$winningTeamId %in% 1:100)) {
  first_year <- current_season %/% 10000
  current_season <- (first_year-1)*10000 + first_year
  finals <- get_series_carousel(current_season, round=4)
}

# Setup user interface.
ui <- dashboardPage(
  help=NULL,
  dark=NULL,
  scrollToTop=TRUE,
  
  title='NHL Statistics',
  header=dashboardHeader(
    title=dashboardBrand(
      title='NHL Statistics',
      image='assets/Logo.png'
    )
  ),
  sidebar=dashboardSidebar(
    sidebarMenu(
      id='sidebarMenuid',
      menuItem(
        'Welcome Aboard',
        tabName='home',
        icon=ionicon('home')
      ),
      menuItem(
        'Skater Statistics',
        tabName='skater',
        icon=ionicon('person')
      ),
      menuItem(
        'Goalie Statistics',
        tabName='goalie',
        icon=ionicon('person')
      ),
      menuItem(
        'Team Statistics',
        tabName='team',
        icon=ionicon('people')
      )
    )
  ),
  footer=dashboardFooter(
    left=a(
      href='https://www.linkedin.com/in/rentosaijo',
      '@RentoSaijo'
    ),
    right='2025'
  ),
  body=dashboardBody(
    tabItems(
      tabItem(
        tabName='home',
        jumbotron(
          title='Welcome to NHL Statistics!',
          status='info',
          lead='Your home for viewing NHL statistics available via the nhlscraper R-package.',
          btnName='Learn about nhlscraper',
          href='https://rentosaijo.github.io/nhlscraper/'
        ),
        fluidRow(
          userBox(
            collapsible=FALSE,
            title=userDescription(
              title='Rento Saijo',
              subtitle='Author of nhlscraper',
              image='assets/RentoSaijo.jpeg',
              type=1
            ),
            status='olive',
            'E: rentosaijo0527@gmail.com'
          ),
          userBox(
            collapsible=FALSE,
            title=userDescription(
              title='Lars Skytte',
              subtitle='Contributor of nhlscraper',
              image='assets/HockeySkytte.png',
              type=1
            ),
            status='olive',
            'W: hockey-statistics.com'
          )
        ),
        fluidRow(
          infoBox(
            width=3,
            title='CRAN Downloads',
            value=sum(cran_downloads(
              package='nhlscraper', 
              from='2025-06-11'
            )$count),
            icon=ionicon('download'),
            color='warning'
          ),
          infoBox(
            width=3,
            title='NHL API Status',
            value=if (ping()) 'Online' else 'Offline',
            icon=ionicon('wifi'),
            color='warning'
          ),
          infoBox(
            width=3,
            title='Top Spotlight Player',
            value=head(get_spotlight_players(), 1)$name.default,
            icon=ionicon('star'),
            color='warning'
          ),
          infoBox(
            width=3,
            title='Stanley Cup Champions',
            value=paste(
              if (finals$topSeed.wins==4) finals$topSeed.abbrev else finals$bottomSeed.abbrev,
              '-',
              current_season
            ),
            icon=ionicon('trophy'),
            color='warning'
          )
        )
      ),
      tabItem(
        tabName = "skater",
        
        fluidRow(
          # -----------------------------------------------
          box(                         # FILTERS
            width  = 3,                # 4/12 of the row
            title  = "Filters",
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            selectInput(
              "season", "Season",
              choices  = all_seasons$id,
              selected = current_season
            ),
            selectizeInput(
              "skater", "Skater",
              choices  = NULL,
              selected = "",
              options  = list(
                placeholder      = "Start typing a player name…",
                allowEmptyOption = TRUE,
                onInitialize     = I('function(){ this.setValue(""); }')
              )
            )
          ),
          
          # -----------------------------------------------
          box(                         # CHART
            width  = 9,                # 8/12 of the row
            title  = "Per-game profile",
            status = "info",
            solidHeader = TRUE,
            
            echarts4rOutput("season_chart", height = "500px")
          )
        )
      ),
      tabItem(
        tabName='goalie'
      ),
      tabItem(
        tabName='team'
      )
    )
  )
)

# Setup server.
server <- function(input, output, session) {

  ## ---- 1. populate skater list whenever season changes ----------
  observeEvent(input$season, {
    skaters <- get_skater_statistics(
      season       = input$season,
      report       = "bios",
      is_aggregate = TRUE
    ) |>
      arrange(skaterFullName)
    
    # add a blank choice up front ──────────────────────────────
    ch <- setNames(
      c("", skaters$skaterFullName),     # values
      c("", skaters$skaterFullName)      # labels
    )
    
    updateSelectizeInput(
      session, "skater",
      choices  = ch,
      selected = "",      # keep empty every time season changes
      server   = TRUE,
      options  = list(
        placeholder      = "Start typing a player name…",
        allowEmptyOption = TRUE
      )
    )
  }, ignoreInit = FALSE)

  ## ---- 2. gather data for the selected skater -------------------
  skater_data <- reactive({
    req(input$skater, input$season)          # wait until both chosen

    # 2a. find player ID
    player_id <- get_skater_statistics(season = input$season,
                                       report = "bios",
                                       is_aggregate = TRUE) |>
      filter(skaterFullName == input$skater) |>
      slice_head(n = 1) |>
      pull(playerId)

    # 2b. pull regular-season + playoff game logs
    regular_gl <- get_player_game_log(player_id, input$season, 2)
    playoff_gl <- get_player_game_log(player_id, input$season, 3)

    bind_rows(regular_gl, playoff_gl) |>
      arrange(gameDate) |>
      separate(toi, into = c("min", "sec"), sep = ":", convert = TRUE) |>
      mutate(toi = min + sec / 60,
             stage = if_else(gameId %in% playoff_gl$gameId, "Playoff", "Regular"))
  })

  ## ---- 3. render chart ------------------------------------------
  output$season_chart <- renderEcharts4r({
    df <- skater_data()

    # base chart
    season_id  <- as.numeric(input$season) 
    chart <- df |>
      e_charts(gameDate) |>
      e_line(toi,   name = "Time on Ice (mins)") |>
      e_line(shots, name = "Shots on Goal") |>
      e_bar(plusMinus, name = "Plus/Minus") |>
      e_tooltip(trigger = "axis") |>
      e_toolbox_feature(feature = "saveAsImage") |>
      e_title(
        paste0(
          input$skater, "'s TOI, SOG, and +/- for ",
          season_id %/% 10000, "-", season_id %% 10000,
          " Season"
        ),
        left = "center", top = 'bottom'
      )

    # playoff marker if any playoff games
    if ("Playoff" %in% df$stage) {
      playoff_start <- df |> filter(stage == "Playoff") |> slice_head(n = 1) |> pull(gameDate)
      chart <- chart |>
        e_mark_line(data = list(xAxis = playoff_start), title = "Playoffs Begin")
    }

    chart
  })
}

# Start shiny application.
shinyApp(ui, server)
