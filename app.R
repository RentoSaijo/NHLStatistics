# Load necessary libraries.
library(tidyverse)
library(shiny)
library(bs4Dash)
library(nhlscraper)

# Setup user interface.
ui <- dashboardPage(
  help=NULL,
  dark=NULL,
  scrollToTop=TRUE,
  
  title='NHL Statistics',
  header=dashboardHeader(
    title=dashboardBrand(
      title='NHL Statistics',
      image='https://cdn.discordapp.com/attachments/873849017702948927/1387296286625234944/NHLStatistics.png?ex=685cd3d9&is=685b8259&hm=67725d29c80f96b56efc16773774e9668564d37a1fe8b14bef0626ed57859e8d&'
    )
  ),
  sidebar=dashboardSidebar(
    sidebarMenu(
      id='sidebarMenuid',
      menuItem(
        'Home',
        tabName='home',
        icon=ionicon('home')
      ),
      menuItem(
        'Player',
        tabName='player',
        icon=ionicon('person')
      ),
      menuItem(
        'Team',
        tabName='team',
        icon=ionicon('people')
      )
    )
  ),
  controlbar=dashboardControlbar(),
  footer=dashboardFooter(),
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
        )
      ),
      tabItem(
        tabName='player'
      ),
      tabItem(
        tabName='people'
      )
    )
  )
)

# Setup server.
server <- function(input, output) {
}

# Start shiny application.
shinyApp(ui, server)
