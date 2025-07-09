# DataViz Pro - Excel Analytics Dashboard with Live Stock Data
# Enhanced R Shiny application for Excel data visualization and live stock market data

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)
library(VIM)
library(shinycssloaders)
library(shinyWidgets)
library(httr)
library(jsonlite)
library(lubridate)
library(reactable)

# Helper function to calculate mode
get_mode <- function(x) {
  ux <- unique(x[!is.na(x)])
  if(length(ux) == 0) return(NA)
  ux[which.max(tabulate(match(x, ux)))]
}

# Helper function to detect data types and suggest visualizations
suggest_visualizations <- function(data) {
  suggestions <- list()
  numeric_cols <- sapply(data, is.numeric)
  categorical_cols <- sapply(data, function(x) is.factor(x) || is.character(x))
  
  if(sum(numeric_cols) >= 2) {
    suggestions$scatter <- "Scatter plots recommended for exploring relationships between numeric variables"
    suggestions$correlation <- "Correlation analysis available for numeric variables"
  }
  
  if(sum(numeric_cols) >= 1) {
    suggestions$histogram <- "Histograms recommended for understanding distribution of numeric data"
    suggestions$line <- "Line charts suitable for time series or sequential data"
  }
  
  if(sum(categorical_cols) >= 1) {
    suggestions$bar <- "Bar charts recommended for categorical data analysis"
    if(sum(categorical_cols) == 1 && sum(numeric_cols) >= 1) {
      suggestions$grouped_bar <- "Grouped bar charts available for categorical vs numeric analysis"
    }
  }
  
  return(suggestions)
}

# Function to fetch live stock data (using Alpha Vantage API - free tier)
# Note: You'll need to get a free API key from https://www.alphavantage.co/support/#api-key
fetch_stock_data <- function(symbol = "AAPL", api_key = "demo") {
  tryCatch({
    url <- paste0("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=", 
                  symbol, "&apikey=", api_key)
    
    response <- GET(url)
    
    if(status_code(response) == 200) {
      data <- fromJSON(content(response, "text"))
      
      if("Time Series (Daily)" %in% names(data)) {
        time_series <- data$`Time Series (Daily)`
        
        # Convert to data frame
        stock_df <- data.frame(
          Date = as.Date(names(time_series)),
          Open = as.numeric(sapply(time_series, function(x) x$`1. open`)),
          High = as.numeric(sapply(time_series, function(x) x$`2. high`)),
          Low = as.numeric(sapply(time_series, function(x) x$`3. low`)),
          Close = as.numeric(sapply(time_series, function(x) x$`4. close`)),
          Volume = as.numeric(sapply(time_series, function(x) x$`5. volume`)),
          stringsAsFactors = FALSE
        )
        
        # Add calculated columns
        stock_df <- stock_df %>%
          arrange(Date) %>%
          mutate(
            Daily_Change = Close - lag(Close),
            Daily_Change_Pct = round((Daily_Change / lag(Close)) * 100, 2),
            MA_5 = zoo::rollmean(Close, k = 5, fill = NA, align = "right"),
            MA_20 = zoo::rollmean(Close, k = 20, fill = NA, align = "right"),
            Symbol = symbol
          ) %>%
          arrange(desc(Date))
        
        return(stock_df)
      }
    }
    
    # Return sample data if API fails
    return(generate_sample_stock_data(symbol))
    
  }, error = function(e) {
    return(generate_sample_stock_data(symbol))
  })
}

# Generate sample stock data for demonstration
generate_sample_stock_data <- function(symbol = "DEMO") {
  dates <- seq(from = Sys.Date() - 100, to = Sys.Date(), by = "day")
  dates <- dates[weekdays(dates) %in% c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")]
  
  set.seed(123)
  n <- length(dates)
  base_price <- 150
  
  stock_df <- data.frame(
    Date = dates,
    Open = base_price + cumsum(rnorm(n, 0, 2)),
    stringsAsFactors = FALSE
  )
  
  stock_df <- stock_df %>%
    mutate(
      High = Open + abs(rnorm(n, 1, 0.5)),
      Low = Open - abs(rnorm(n, 1, 0.5)),
      Close = Open + rnorm(n, 0, 1),
      Volume = round(runif(n, 1000000, 5000000)),
      Daily_Change = Close - lag(Close),
      Daily_Change_Pct = round((Daily_Change / lag(Close)) * 100, 2),
      MA_5 = zoo::rollmean(Close, k = 5, fill = NA, align = "right"),
      MA_20 = zoo::rollmean(Close, k = 20, fill = NA, align = "right"),
      Symbol = symbol
    ) %>%
    arrange(desc(Date))
  
  return(stock_df)
}

# Define UI
ui <- dashboardPage(
  dashboardHeader(
    title = "DataViz Pro - Enhanced",
    tags$li(class = "dropdown",
            tags$a(href = "#", class = "dropdown-toggle", `data-toggle` = "dropdown",
                   icon("info-circle"), "About")),
    tags$li(class = "dropdown",
            tags$a(href = "#", class = "dropdown-toggle", `data-toggle` = "dropdown",
                   icon("question-circle"), "Help"))
  ),
  
  dashboardSidebar(
    sidebarMenu(id = "tabs",
                menuItem("Upload Data", tabName = "upload", icon = icon("upload")),
                menuItem("Data Preview", tabName = "preview", icon = icon("table")),
                menuItem("Live Stock Data", tabName = "stocks", icon = icon("chart-line")),
                menuItem("Visualizations", tabName = "viz", icon = icon("chart-bar")),
                menuItem("Analytics", tabName = "analytics", icon = icon("calculator")),
                menuItem("Insights", tabName = "insights", icon = icon("lightbulb")),
                
                # Dynamic sidebar content for stock data
                conditionalPanel(
                  condition = "input.tabs == 'stocks'",
                  br(),
                  h4("Stock Options", style = "color: white; margin-left: 15px;"),
                  
                  textInput("stock_symbol", "Stock Symbol:", 
                            value = "AAPL", placeholder = "e.g., AAPL, GOOGL, MSFT"),
                  
                  textInput("api_key", "API Key (Optional):", 
                            value = "demo", placeholder = "Alpha Vantage API Key"),
                  
                  actionButton("fetch_stock", "Fetch Live Data", 
                               class = "btn-success", style = "margin-left: 15px; margin-bottom: 10px;"),
                  
                  actionButton("refresh_stock", "Refresh Data", 
                               class = "btn-info", style = "margin-left: 15px;")
                ),
                
                # Dynamic sidebar content for visualization options
                conditionalPanel(
                  condition = "input.tabs == 'viz'",
                  br(),
                  h4("Visualization Options", style = "color: white; margin-left: 15px;"),
                  
                  selectInput("chart_type", "Chart Type:",
                              choices = list(
                                "Line Chart" = "line",
                                "Bar Chart" = "bar",
                                "Pie Chart" = "pie",
                                "Histogram" = "histogram",
                                "Scatter Plot" = "scatter",
                                "Box Plot" = "boxplot",
                                "Correlation Heatmap" = "correlation"
                              ),
                              selected = "line"),
                  
                  uiOutput("column_selector"),
                  uiOutput("secondary_column_selector"),
                  
                  br(),
                  actionButton("generate_plot", "Generate Plot", 
                               class = "btn-primary", style = "margin-left: 15px;")
                )
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .nav-tabs-custom > .nav-tabs > li.active {
          border-top-color: #3c8dbc;
        }
        .small-box .icon-large {
          font-size: 90px;
        }
        .stock-positive { color: #28a745; font-weight: bold; }
        .stock-negative { color: #dc3545; font-weight: bold; }
        .stock-neutral { color: #6c757d; }
        .footer {
          position: fixed;
          left: 0;
          bottom: 0;
          width: 100%;
          background-color: #367fa9;
          color: white;
          text-align: center;
          padding: 10px 0;
          z-index: 1000;
        }
      "))
    ),
    
    tabItems(
      # Upload Tab
      tabItem(tabName = "upload",
              fluidRow(
                box(
                  title = "Upload Excel File", status = "primary", solidHeader = TRUE,
                  width = 12, height = "500px",
                  
                  div(style = "text-align: center; padding: 50px;",
                      div(style = "border: 3px dashed #3c8dbc; border-radius: 10px; padding: 50px; background-color: #f9f9f9;",
                          icon("file-excel", style = "font-size: 80px; color: #3c8dbc; margin-bottom: 20px;"),
                          h3("Drop your Excel file here", style = "color: #3c8dbc;"),
                          p("Supports .xlsx and .xls files", style = "color: #666; font-size: 16px;"),
                          br(),
                          fileInput("file", NULL,
                                    accept = c(".xlsx", ".xls"),
                                    buttonLabel = "Choose File",
                                    placeholder = "No file selected")
                      )
                  ),
                  
                  conditionalPanel(
                    condition = "output.file_uploaded",
                    br(),
                    div(style = "text-align: center;",
                        h4("File uploaded successfully!", style = "color: green;"),
                        actionButton("proceed_preview", "Proceed to Data Preview", 
                                     class = "btn-success btn-lg")
                    )
                  )
                )
              )
      ),
      
      # Preview Tab
      tabItem(tabName = "preview",
              fluidRow(
                box(
                  title = "Data Summary", status = "info", solidHeader = TRUE, width = 4,
                  withSpinner(verbatimTextOutput("data_summary"))
                ),
                box(
                  title = "Data Structure", status = "info", solidHeader = TRUE, width = 8,
                  withSpinner(verbatimTextOutput("data_structure"))
                )
              ),
              fluidRow(
                box(
                  title = "Data Preview", status = "primary", solidHeader = TRUE, width = 12,
                  withSpinner(DT::dataTableOutput("data_table"))
                )
              )
      ),
      
      # Live Stock Data Tab
      tabItem(tabName = "stocks",
              fluidRow(
                # Stock summary boxes
                valueBoxOutput("current_price"),
                valueBoxOutput("daily_change"),
                valueBoxOutput("volume_traded")
              ),
              
              fluidRow(
                box(
                  title = "Stock Price Chart", status = "primary", solidHeader = TRUE, width = 12,
                  withSpinner(plotlyOutput("stock_chart", height = "400px"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Live Stock Data", status = "success", solidHeader = TRUE, width = 12,
                  div(style = "margin-bottom: 15px;",
                      fluidRow(
                        column(3, 
                               selectInput("stock_rows_per_page", "Rows per page:",
                                           choices = c(10, 25, 50, 100),
                                           selected = 25)
                        ),
                        column(3,
                               downloadButton("download_stock", "Download CSV", 
                                              class = "btn-info")
                        ),
                        column(6,
                               div(style = "text-align: right; padding-top: 25px;",
                                   textOutput("stock_data_info"))
                        )
                      )
                  ),
                  withSpinner(reactableOutput("stock_table"))
                )
              )
      ),
      
      # Visualizations Tab
      
      
      # Analytics Tab
      tabItem(tabName = "analytics",
              fluidRow(
                # Summary Statistics Boxes
                valueBoxOutput("total_rows"),
                valueBoxOutput("total_cols"),
                valueBoxOutput("missing_values")
              ),
              
              fluidRow(
                box(
                  title = "Descriptive Statistics", status = "primary", solidHeader = TRUE, width = 6,
                  withSpinner(DT::dataTableOutput("descriptive_stats"))
                ),
                box(
                  title = "Missing Values Analysis", status = "warning", solidHeader = TRUE, width = 6,
                  withSpinner(plotOutput("missing_plot"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Correlation Matrix", status = "success", solidHeader = TRUE, width = 12,
                  withSpinner(plotOutput("correlation_plot", height = "500px"))
                )
              )
      ),
      
      # Insights Tab
      tabItem(tabName = "insights",
              fluidRow(
                box(
                  title = "Automated Insights", status = "success", solidHeader = TRUE, width = 12,
                  withSpinner(htmlOutput("insights_content"))
                )
              ),
              
              fluidRow(
                box(
                  title = "Visualization Recommendations", status = "info", solidHeader = TRUE, width = 6,
                  withSpinner(htmlOutput("viz_recommendations"))
                ),
                box(
                  title = "Data Quality Assessment", status = "warning", solidHeader = TRUE, width = 6,
                  withSpinner(htmlOutput("data_quality"))
                )
              )
      )
    ),
    
    # Footer
    tags$div(class = "footer",
             HTML("&copy; 2025 DataViz Pro Enhanced | Live Stock Data Integration | 
                  Contact: developer@datavizpro.com | Version 2.0"))
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive values
  values <- reactiveValues(
    data = NULL,
    original_data = NULL,
    stock_data = NULL,
    last_stock_fetch = NULL
  )
  
  # File upload (existing functionality)
  observeEvent(input$file, {
    req(input$file)
    
    tryCatch({
      ext <- tools::file_ext(input$file$datapath)
      if(ext %in% c("xlsx", "xls")) {
        values$original_data <- read_excel(input$file$datapath)
        values$data <- values$original_data
        
        # Convert character columns to factors for better analysis
        char_cols <- sapply(values$data, is.character)
        values$data[char_cols] <- lapply(values$data[char_cols], as.factor)
        
        showNotification("File uploaded successfully!", type = "success")
      } else {
        showNotification("Please upload an Excel file (.xlsx or .xls)", type = "error")
      }
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Stock data fetching
  observeEvent(input$fetch_stock, {
    req(input$stock_symbol)
    
    showNotification("Fetching stock data...", type = "message")
    
    values$stock_data <- fetch_stock_data(
      symbol = toupper(input$stock_symbol),
      api_key = input$api_key
    )
    
    values$last_stock_fetch <- Sys.time()
    
    showNotification(paste("Stock data fetched for", toupper(input$stock_symbol)), type = "success")
  })
  
  # Refresh stock data
  observeEvent(input$refresh_stock, {
    req(input$stock_symbol)
    
    showNotification("Refreshing stock data...", type = "message")
    
    values$stock_data <- fetch_stock_data(
      symbol = toupper(input$stock_symbol),
      api_key = input$api_key
    )
    
    values$last_stock_fetch <- Sys.time()
    
    showNotification("Stock data refreshed!", type = "success")
  })
  
  # Initialize with sample stock data
  observe({
    if(is.null(values$stock_data)) {
      values$stock_data <- generate_sample_stock_data("DEMO")
      values$last_stock_fetch <- Sys.time()
    }
  })
  
  # Stock value boxes
  output$current_price <- renderValueBox({
    if(!is.null(values$stock_data) && nrow(values$stock_data) > 0) {
      current_price <- values$stock_data$Close[1]
      valueBox(
        value = paste0("$", round(current_price, 2)),
        subtitle = paste("Current Price -", values$stock_data$Symbol[1]),
        icon = icon("dollar-sign"),
        color = "blue"
      )
    } else {
      valueBox(
        value = "--",
        subtitle = "Current Price",
        icon = icon("dollar-sign"),
        color = "blue"
      )
    }
  })
  
  output$daily_change <- renderValueBox({
    if(!is.null(values$stock_data) && nrow(values$stock_data) > 0) {
      change <- values$stock_data$Daily_Change[1]
      change_pct <- values$stock_data$Daily_Change_Pct[1]
      
      if(!is.na(change)) {
        color <- if(change >= 0) "green" else "red"
        sign <- if(change >= 0) "+" else ""
        
        valueBox(
          value = paste0(sign, round(change, 2)),
          subtitle = paste0("Daily Change (", sign, change_pct, "%)"),
          icon = icon(if(change >= 0) "arrow-up" else "arrow-down"),
          color = color
        )
      } else {
        valueBox(
          value = "--",
          subtitle = "Daily Change",
          icon = icon("minus"),
          color = "yellow"
        )
      }
    } else {
      valueBox(
        value = "--",
        subtitle = "Daily Change",
        icon = icon("minus"),
        color = "yellow"
      )
    }
  })
  
  output$volume_traded <- renderValueBox({
    if(!is.null(values$stock_data) && nrow(values$stock_data) > 0) {
      volume <- values$stock_data$Volume[1]
      valueBox(
        value = paste0(round(volume/1000000, 1), "M"),
        subtitle = "Volume Traded",
        icon = icon("chart-bar"),
        color = "purple"
      )
    } else {
      valueBox(
        value = "--",
        subtitle = "Volume Traded",
        icon = icon("chart-bar"),
        color = "purple"
      )
    }
  })
  
  # Stock chart
  output$stock_chart <- renderPlotly({
    req(values$stock_data)
    
    p <- plot_ly(values$stock_data, x = ~Date, type = 'candlestick',
                 open = ~Open, high = ~High, low = ~Low, close = ~Close,
                 name = "Candlestick") %>%
      add_lines(y = ~MA_5, name = "MA 5", line = list(color = "blue", width = 1)) %>%
      add_lines(y = ~MA_20, name = "MA 20", line = list(color = "red", width = 1)) %>%
      layout(
        title = paste("Stock Price Chart -", values$stock_data$Symbol[1]),
        xaxis = list(title = "Date"),
        yaxis = list(title = "Price ($)"),
        showlegend = TRUE
      )
    
    p
  })
  
  # Stock data table with pagination using reactable
  output$stock_table <- renderReactable({
    req(values$stock_data)
    
    reactable(
      values$stock_data %>% select(-Symbol),
      defaultPageSize = as.numeric(input$stock_rows_per_page %||% 25),
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 25, 50, 100),
      searchable = TRUE,
      filterable = TRUE,
      showSortable = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      striped = TRUE,
      columns = list(
        Date = colDef(format = colFormat(date = TRUE)),
        Open = colDef(format = colFormat(prefix = "$", digits = 2)),
        High = colDef(format = colFormat(prefix = "$", digits = 2)),
        Low = colDef(format = colFormat(prefix = "$", digits = 2)),
        Close = colDef(format = colFormat(prefix = "$", digits = 2)),
        Volume = colDef(format = colFormat(separators = TRUE)),
        Daily_Change = colDef(
          format = colFormat(prefix = "$", digits = 2),
          style = function(value) {
            if (is.na(value)) return()
            color <- if (value >= 0) "#28a745" else "#dc3545"
            list(color = color, fontWeight = "bold")
          }
        ),
        Daily_Change_Pct = colDef(
          format = colFormat(suffix = "%", digits = 2),
          style = function(value) {
            if (is.na(value)) return()
            color <- if (value >= 0) "#28a745" else "#dc3545"
            list(color = color, fontWeight = "bold")
          }
        ),
        MA_5 = colDef(format = colFormat(prefix = "$", digits = 2)),
        MA_20 = colDef(format = colFormat(prefix = "$", digits = 2))
      ),
      theme = reactableTheme(
        headerStyle = list(
          "&:hover" = list(background = "#eee")
        )
      )
    )
  })
  
  # Stock data info
  output$stock_data_info <- renderText({
    if(!is.null(values$stock_data) && !is.null(values$last_stock_fetch)) {
      paste("Last updated:", format(values$last_stock_fetch, "%Y-%m-%d %H:%M:%S"),
            "| Total records:", nrow(values$stock_data))
    } else {
      "No data available"
    }
  })
  
  # Download stock data
  output$download_stock <- downloadHandler(
    filename = function() {
      paste0("stock_data_", toupper(input$stock_symbol), "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      if(!is.null(values$stock_data)) {
        write.csv(values$stock_data, file, row.names = FALSE)
      }
    }
  )
  
  # Check if file is uploaded
  output$file_uploaded <- reactive({
    return(!is.null(values$data))
  })
  outputOptions(output, 'file_uploaded', suspendWhenHidden = FALSE)
  
  # Navigate to preview tab
  observeEvent(input$proceed_preview, {
    updateTabItems(session, "tabs", "preview")
  })
  
  # Existing functionality for data preview and analysis
  # (Data summary, structure, table, analytics, etc. - keeping all original functionality)
  
  # Data summary
  output$data_summary <- renderText({
    req(values$data)
    paste(
      paste("Rows:", nrow(values$data)),
      paste("Columns:", ncol(values$data)),
      paste("File size:", format(object.size(values$data), units = "Kb")),
      sep = "\n"
    )
  })
  
  # Data structure
  output$data_structure <- renderPrint({
    req(values$data)
    str(values$data)
  })
  
  # Data table with enhanced pagination
  output$data_table <- DT::renderDataTable({
    req(values$data)
    DT::datatable(values$data, 
                  options = list(
                    scrollX = TRUE, 
                    pageLength = 25,
                    lengthMenu = c(10, 25, 50, 100),
                    searching = TRUE,
                    ordering = TRUE
                  ),
                  class = 'cell-border stripe',
                  filter = 'top')
  })
  
  # Dynamic column selector
  output$column_selector <- renderUI({
    req(values$data)
    
    if(input$chart_type %in% c("histogram", "boxplot")) {
      # Only numeric columns for histogram and boxplot
      numeric_cols <- names(select_if(values$data, is.numeric))
      selectInput("x_column", "Select Column:",
                  choices = numeric_cols,
                  selected = numeric_cols[1])
    } else if(input$chart_type == "pie") {
      # Only categorical columns for pie chart
      cat_cols <- names(select_if(values$data, function(x) is.factor(x) || is.character(x)))
      selectInput("x_column", "Select Column:",
                  choices = cat_cols,
                  selected = cat_cols[1])
    } else {
      # All columns for other chart types
      selectInput("x_column", "Select X Column:",
                  choices = names(values$data),
                  selected = names(values$data)[1])
    }
  })
  
  # Secondary column selector
  output$secondary_column_selector <- renderUI({
    req(values$data)
    
    if(input$chart_type %in% c("scatter", "line", "bar")) {
      if(input$chart_type == "scatter") {
        numeric_cols <- names(select_if(values$data, is.numeric))
        selectInput("y_column", "Select Y Column:",
                    choices = numeric_cols,
                    selected = if(length(numeric_cols) > 1) numeric_cols[2] else numeric_cols[1])
      } else {
        selectInput("y_column", "Select Y Column:",
                    choices = names(values$data),
                    selected = if(ncol(values$data) > 1) names(values$data)[2] else names(values$data)[1])
      }
    }
  })
  
  # Main plot (keeping existing functionality)
  output$main_plot <- renderPlotly({
    req(values$data, input$x_column)
    
    input$generate_plot
    
    isolate({
      tryCatch({
        if(input$chart_type == "histogram") {
          p <- ggplot(values$data, aes_string(x = input$x_column)) +
            geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
            theme_minimal() +
            labs(title = paste("Histogram of", input$x_column))
          
        } else if(input$chart_type == "boxplot") {
          p <- ggplot(values$data, aes_string(y = input$x_column)) +
            geom_boxplot(fill = "lightblue", alpha = 0.7) +
            theme_minimal() +
            labs(title = paste("Box Plot of", input$x_column))
          
        } else if(input$chart_type == "pie") {
          pie_data <- values$data %>%
            count(!!sym(input$x_column)) %>%
            mutate(percentage = n / sum(n) * 100)
          
          p <- plot_ly(pie_data, labels = ~get(input$x_column), values = ~n, type = 'pie',
                       textposition = 'inside',
                       textinfo = 'label+percent',
                       hoverinfo = 'text',
                       text = ~paste(get(input$x_column), '<br>', n, 'items'))
          return(p)
          
        } else if(input$chart_type == "scatter") {
          req(input$y_column)
          p <- ggplot(values$data, aes_string(x = input$x_column, y = input$y_column)) +
            geom_point(alpha = 0.6, color = "steelblue") +
            geom_smooth(method = "lm", se = TRUE, color = "red") +
            theme_minimal() +
            labs(title = paste("Scatter Plot:", input$x_column, "vs", input$y_column))
          
        } else if(input$chart_type == "line") {
          req(input$y_column)
          p <- ggplot(values$data, aes_string(x = input$x_column, y = input$y_column)) +
            geom_line(color = "steelblue", size = 1) +
            geom_point(color = "darkblue") +
            theme_minimal() +
            labs(title = paste("Line Chart:", input$x_column, "vs", input$y_column))
          
        } else if(input$chart_type == "bar") {
          req(input$y_column)
          if(is.numeric(values$data[[input$y_column]])) {
            p <- ggplot(values$data, aes_string(x = input$x_column, y = input$y_column)) +
              geom_col(fill = "steelblue", alpha = 0.7) +
              theme_minimal() +
              theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
              labs(title = paste("Bar Chart:", input$x_column, "vs", input$y_column))
          } else {
            bar_data <- values$data %>%
              count(!!sym(input$x_column))
            p <- ggplot(bar_data, aes_string(x = input$x_column, y = "n")) +
              geom_col(fill = "steelblue", alpha = 0.7) +
              theme_minimal() +
              theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
              labs(title = paste("Bar Chart of", input$x_column), y = "Count")
          }
          
        } else if(input$chart_type == "correlation") {
          numeric_data <- select_if(values$data, is.numeric)
          if(ncol(numeric_data) < 2) {
            return(plot_ly() %>% add_annotations(text = "Need at least 2 numeric columns for correlation", 
                                                 xref = "paper", yref = "paper", x = 0.5, y = 0.5))
          }
          
          cor_matrix <- cor(numeric_data, use = "complete.obs")
          p <- plot_ly(z = cor_matrix, type = "heatmap", 
                       colorscale = "RdBu",
                       hovertemplate = "X: %{x}<br>Y: %{y}<br>Correlation: %{z:.3f}<extra></extra>") %>%
            layout(title = "Correlation Heatmap")
          return(p)
        }
        
        ggplotly(p)
        
      }, error = function(e) {
        plot_ly() %>% 
          add_annotations(text = paste("Error creating plot:", e$message), 
                          xref = "paper", yref = "paper", x = 0.5, y = 0.5)
      })
    })
  })
  
  # Value boxes for analytics
  output$total_rows <- renderValueBox({
    valueBox(
      value = if(is.null(values$data)) 0 else nrow(values$data),
      subtitle = "Total Rows",
      icon = icon("table"),
      color = "blue"
    )
  })
  
  output$total_cols <- renderValueBox({
    valueBox(
      value = if(is.null(values$data)) 0 else ncol(values$data),
      subtitle = "Total Columns",
      icon = icon("columns"),
      color = "green"
    )
  })
  
  output$missing_values <- renderValueBox({
    valueBox(
      value = if(is.null(values$data)) 0 else sum(is.na(values$data)),
      subtitle = "Missing Values",
      icon = icon("exclamation-triangle"),
      color = "yellow"
    )
  })
  
  # Descriptive statistics
  output$descriptive_stats <- DT::renderDataTable({
    req(values$data)
    
    numeric_data <- select_if(values$data, is.numeric)
    if(ncol(numeric_data) == 0) {
      return(data.frame(Message = "No numeric columns found"))
    }
    
    stats_df <- numeric_data %>%
      summarise_all(list(
        Mean = ~round(mean(., na.rm = TRUE), 3),
        Median = ~round(median(., na.rm = TRUE), 3),
        Mode = ~get_mode(.),
        SD = ~round(sd(., na.rm = TRUE), 3),
        Min = ~min(., na.rm = TRUE),
        Max = ~max(., na.rm = TRUE),
        Q1 = ~quantile(., 0.25, na.rm = TRUE),
        Q3 = ~quantile(., 0.75, na.rm = TRUE)
      )) %>%
      gather(key = "Statistic", value = "Value") %>%
      separate(Statistic, into = c("Variable", "Measure"), sep = "_") %>%
      spread(key = "Measure", value = "Value")
    
    DT::datatable(stats_df, options = list(pageLength = 15, scrollX = TRUE))
  })
  
  # Missing values plot
  output$missing_plot <- renderPlot({
    req(values$data)
    VIM::aggr(values$data, col = c('navyblue', 'red'), 
              numbers = TRUE, sortVars = TRUE)
  })
  
  # Correlation plot
  output$correlation_plot <- renderPlot({
    req(values$data)
    numeric_data <- select_if(values$data, is.numeric)
    if(ncol(numeric_data) < 2) {
      plot.new()
      text(0.5, 0.5, "Need at least 2 numeric columns for correlation analysis", 
           cex = 1.5, col = "red")
    } else {
      cor_matrix <- cor(numeric_data, use = "complete.obs")
      corrplot(cor_matrix, method = "color", type = "upper", 
               addCoef.col = "black", tl.cex = 0.8, number.cex = 0.7)
    }
  })
  
  # Insights content
  output$insights_content <- renderText({
    req(values$data)
    
    insights <- c()
    numeric_data <- select_if(values$data, is.numeric)
    categorical_data <- select_if(values$data, function(x) is.factor(x) || is.character(x))
    
    # Data overview insights
    insights <- c(insights, paste("<h4>📊 Data Overview</h4>"))
    insights <- c(insights, paste("• Your dataset contains", nrow(values$data), "rows and", ncol(values$data), "columns"))
    insights <- c(insights, paste("• Found", ncol(numeric_data), "numeric columns and", ncol(categorical_data), "categorical columns"))
    
    # Missing data insights
    missing_pct <- round(sum(is.na(values$data)) / (nrow(values$data) * ncol(values$data)) * 100, 2)
    if(missing_pct > 0) {
      insights <- c(insights, paste("• Missing data:", missing_pct, "% of total values"))
    } else {
      insights <- c(insights, "• ✅ No missing values detected")
    }
    
    # Stock data insights (if stock data is available)
    if(!is.null(values$stock_data)) {
      insights <- c(insights, "<h4>📈 Stock Market Insights</h4>")
      
      current_price <- values$stock_data$Close[1]
      daily_change <- values$stock_data$Daily_Change[1]
      
      if(!is.na(daily_change)) {
        trend <- if(daily_change >= 0) "upward" else "downward"
        insights <- c(insights, paste("• Current stock trend:", trend, "with", abs(round(daily_change, 2)), "change"))
      }
      
      # Volatility analysis
      recent_prices <- values$stock_data$Close[1:min(30, nrow(values$stock_data))]
      volatility <- sd(recent_prices, na.rm = TRUE)
      insights <- c(insights, paste("• Recent volatility (30-day SD):", round(volatility, 2)))
      
      # Moving average analysis
      if(!is.na(values$stock_data$MA_5[1]) && !is.na(values$stock_data$MA_20[1])) {
        ma_signal <- if(values$stock_data$MA_5[1] > values$stock_data$MA_20[1]) "bullish" else "bearish"
        insights <- c(insights, paste("• Technical signal (MA5 vs MA20):", ma_signal))
      }
    }
    
    # Numeric data insights
    if(ncol(numeric_data) > 0) {
      insights <- c(insights, "<h4>🔢 Numeric Data Insights</h4>")
      
      # Find columns with high variability
      cv_data <- numeric_data %>%
        summarise_all(~sd(., na.rm = TRUE) / mean(., na.rm = TRUE)) %>%
        gather(key = "Variable", value = "CV") %>%
        arrange(desc(CV))
      
      if(nrow(cv_data) > 0) {
        high_var_col <- cv_data$Variable[1]
        insights <- c(insights, paste("• Highest variability in:", high_var_col))
      }
      
      # Correlation insights
      if(ncol(numeric_data) >= 2) {
        cor_matrix <- cor(numeric_data, use = "complete.obs")
        cor_matrix[upper.tri(cor_matrix, diag = TRUE)] <- NA
        cor_df <- expand.grid(Var1 = rownames(cor_matrix), Var2 = colnames(cor_matrix)) %>%
          mutate(Correlation = as.vector(cor_matrix)) %>%
          filter(!is.na(Correlation)) %>%
          arrange(desc(abs(Correlation)))
        
        if(nrow(cor_df) > 0) {
          strongest_cor <- cor_df[1, ]
          insights <- c(insights, paste("• Strongest correlation:", strongest_cor$Var1, "vs", strongest_cor$Var2, 
                                        "(r =", round(strongest_cor$Correlation, 3), ")"))
        }
      }
    }
    
    # Categorical data insights
    if(ncol(categorical_data) > 0) {
      insights <- c(insights, "<h4>📋 Categorical Data Insights</h4>")
      
      for(col in names(categorical_data)[1:min(3, ncol(categorical_data))]) {
        unique_vals <- length(unique(categorical_data[[col]]))
        most_common <- names(sort(table(categorical_data[[col]]), decreasing = TRUE))[1]
        insights <- c(insights, paste("•", col, "has", unique_vals, "unique values, most common:", most_common))
      }
    }
    
    HTML(paste(insights, collapse = "<br>"))
  })
  
  # Visualization recommendations
  output$viz_recommendations <- renderText({
    req(values$data)
    
    suggestions <- suggest_visualizations(values$data)
    
    if(length(suggestions) == 0) {
      return(HTML("<p>No specific recommendations available.</p>"))
    }
    
    recommendations <- c("<h4>📈 Recommended Visualizations</h4>")
    for(i in 1:length(suggestions)) {
      recommendations <- c(recommendations, paste("•", suggestions[[i]]))
    }
    
    # Add stock-specific recommendations if stock data is available
    if(!is.null(values$stock_data)) {
      recommendations <- c(recommendations, "<h4>📊 Stock Data Visualizations</h4>")
      recommendations <- c(recommendations, "• Candlestick charts for price action analysis")
      recommendations <- c(recommendations, "• Moving average overlays for trend analysis")
      recommendations <- c(recommendations, "• Volume analysis for market sentiment")
      recommendations <- c(recommendations, "• Volatility charts for risk assessment")
    }
    
    HTML(paste(recommendations, collapse = "<br>"))
  })
  
  # Data quality assessment
  output$data_quality <- renderText({
    req(values$data)
    
    quality_issues <- c()
    
    # Check for missing values
    missing_cols <- colSums(is.na(values$data))
    missing_cols <- missing_cols[missing_cols > 0]
    
    if(length(missing_cols) > 0) {
      quality_issues <- c(quality_issues, paste("⚠️", length(missing_cols), "columns have missing values"))
    }
    
    # Check for duplicate rows
    duplicate_rows <- sum(duplicated(values$data))
    if(duplicate_rows > 0) {
      quality_issues <- c(quality_issues, paste("⚠️", duplicate_rows, "duplicate rows detected"))
    }
    
    # Check for constant columns
    constant_cols <- sapply(values$data, function(x) length(unique(na.omit(x))) == 1)
    if(any(constant_cols)) {
      quality_issues <- c(quality_issues, paste("⚠️", sum(constant_cols), "columns have constant values"))
    }
    
    # Stock data quality assessment
    stock_quality <- c()
    if(!is.null(values$stock_data)) {
      stock_quality <- c(stock_quality, "<h4>📈 Stock Data Quality</h4>")
      
      # Check for data completeness
      missing_stock_data <- sum(is.na(values$stock_data))
      if(missing_stock_data > 0) {
        stock_quality <- c(stock_quality, paste("⚠️", missing_stock_data, "missing values in stock data"))
      } else {
        stock_quality <- c(stock_quality, "• ✅ Stock data is complete")
      }
      
      # Check data freshness
      latest_date <- max(values$stock_data$Date, na.rm = TRUE)
      days_old <- as.numeric(Sys.Date() - latest_date)
      if(days_old > 1) {
        stock_quality <- c(stock_quality, paste("⚠️ Stock data is", days_old, "days old"))
      } else {
        stock_quality <- c(stock_quality, "• ✅ Stock data is current")
      }
      
      # Check for data consistency
      price_anomalies <- sum(values$stock_data$High < values$stock_data$Low, na.rm = TRUE)
      if(price_anomalies > 0) {
        stock_quality <- c(stock_quality, paste("⚠️", price_anomalies, "price anomalies detected"))
      }
    }
    
    if(length(quality_issues) == 0 && length(stock_quality) == 0) {
      quality_assessment <- c("<h4>✅ Data Quality Assessment</h4>", 
                              "• No major data quality issues detected", 
                              "• Dataset appears to be clean and ready for analysis")
    } else {
      quality_assessment <- c("<h4>⚠️ Data Quality Issues</h4>", 
                              quality_issues, 
                              stock_quality,
                              "<br><strong>Consider addressing these issues for better analysis</strong>")
    }
    
    HTML(paste(quality_assessment, collapse = "<br>"))
  })
}

# Run the application
shinyApp(ui = ui, server = server)

