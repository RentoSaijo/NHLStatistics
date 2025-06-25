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
        ),
        fluidRow(
          userBox(
            collapsible=FALSE,
            title=userDescription(
              title='Rento Saijo',
              subtitle='Author of nhlscraper',
              image='https://cdn.discordapp.com/attachments/873849017702948927/1387302795295588403/RentoSaijo_Picture.jpeg?ex=685cd9e9&is=685b8869&hm=eb315238ccd29f458a69230e6edb793ac6625019e7848e856372ccc51c02cf81&',
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
              image='https://cdn.discordapp.com/attachments/873849017702948927/1387308828495708271/Logo.png?ex=685cdf87&is=685b8e07&hm=9121b274a2d33fd1fbf1b3f0bf8235666201a7ed7ad866e2d084e701e2b7bff1&',
              type=1
            ),
            status='olive',
            'W: hockey-statistics.com'
          )
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
