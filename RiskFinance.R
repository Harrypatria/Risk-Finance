library(shiny)
require(mvtnorm)
require(psych)
risk.sim <- function(input) {
  ## Begin enterprise risk simulation
  set.seed(1016)  ## Freezes the random seed to reproduce results exactly
  n.risks <- 3  ## Number of risk factors
  m <- n.risks
  n.sim <- 1000  ## pull slider settings into the sigma correlation matrix
  sigma <- matrix(c(1, input[1], input[2], 
                    input[1], 1, input[3], input[2], 
                    input[3], 1), nrow = m)
  z <- rmvt(n.sim, delta = rep(0, nrow(sigma)), 
            sigma = sigma, df = 6, type = "shifted")
  u <- pt(z, df = 6)
  x1 <- qgamma(u[, 1], shape = 2, scale = 1)
  x2 <- qbeta(u[, 2], 2, 2)
  x3 <- qt(u[, 3], df = 6)
  factors.df <- cbind(x1/10, x2, x3/10)
  colnames(factors.df) <- c("Revenue", 
                            "Variable Cost", "Fixed Cost")
  revenue <- 1000 * (1 + factors.df[, 
                                    1])
  variable.cost <- revenue * factors.df[, 
                                        2]
  fixed.cost <- revenue * factors.df[, 
                                     3]
  total.cost <- variable.cost + fixed.cost
  operating.margin <- revenue - variable.cost - 
    fixed.cost
  analysis.t <- cbind(revenue, total.cost, 
                      operating.margin)
  colnames(analysis.t) <- c("Revenue", 
                            "Cost", "Margin")
  return(analysis.t)
}

# UI server

ui <- fluidPage(titlePanel("Enterprise Risk Analytics"), 
                sidebarLayout(sidebarPanel(sliderInput(inputId = "cor.1", 
                                                       label = "Set the Revenue - Variable Cost Correlation", 
                                                       value = 0.5, min = 0.1, max = 0.9), 
                                           sliderInput(inputId = "cor.2", 
                                                       label = "Set the Revenue - Variable Cost Correlation", 
                                                       value = 0.5, min = 0.1, max = 0.9), 
                                           sliderInput(inputId = "cor.3", 
                                                       label = "Set the Variable - Fixed Cost Correlation", 
                                                       value = 0.5, min = 0.1, max = 0.9)), 
                              mainPanel(plotOutput("pairs.1"))))

# server
server <- function(input, output) {
  output$pairs.1 <- renderPlot({
    analysis.t <- risk.sim(c(input$cor.1, 
                             input$cor.2, input$cor.3))
    pairs.panels(analysis.t)
  })
}


# Run the app
shinyApp(ui = ui, server = server)
