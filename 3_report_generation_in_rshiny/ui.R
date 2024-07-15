library(bs4Dash)
library(shiny)
library(tidyverse)
library(highcharter)
library(xts)
library(DT)
library(shinyWidgets)
library(waiter)
library(shinycssloaders)
library(zip)

dashboardPage(
  # preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#18191A"),
  fullscreen = TRUE,
  dashboardHeader(title = dashboardBrand(
    title = "Patient Admissions",
    color = "gray-dark",
    image = "logo.jpg"
  ),
  .list = list(
    uiOutput("hospital_filter_ui"),
    tags$pre(" "),
    uiOutput("admission_dates_filter_ui"),
    tags$pre(" "),
    downloadBttn(
      outputId = "patient_admission_report_download",
      label = "Download Report",
      style = "unite",
      size = "sm"
      ),
    downloadBttn(
      outputId = "patient_admission_bulk_report_download",
      label = "Download Multiple Reports",
      style = "unite",
      size = "sm"
    )
  ),
  titleWidth = 500), # end of header
  dashboardSidebar(disable = TRUE), # end of Sidebar
  dashboardBody(
    fluidPage(
      # zoom out the dashboard page to 80%
      tags$style(HTML("
      body {
      zoom: 90%;
    }
  ")),
      fluidRow(
        column(4,
               box(title = "Top 5 diagnoses by admissions", status = "white", solidHeader = TRUE,
                   width = 12, icon = icon("chart-bar"), collapsible = FALSE,
                   withSpinner(highchartOutput("top_5_diagnosis_by_admission", height = 270)))),
        column(4,
               infoBoxOutput("number_of_admissions", width = 12),
               infoBoxOutput("unique_number_of_patients_treated", width = 12),
               infoBoxOutput("average_daily_admissions", width = 12)),
        column(4,
               infoBoxOutput("average_stay_length", width = 12),
               infoBoxOutput("most_common_admission_hour", width = 12),
               infoBoxOutput("total_treatment_cost", width = 12))
      ),
      fluidRow(
        column(6,
               box(title = "Daily patient admissions", status = "gray-dark", solidHeader = TRUE,
                   width = 12, icon = icon("chart-line"), collapsible = FALSE,
                   withSpinner(highchartOutput("patient_admission_trend", height = 400)))),
        column(6,
               box(title = "Hourly patient admissions across the week", status = "gray-dark", solidHeader = TRUE,
                   width = 12, icon = icon("clock"), collapsible = FALSE,
                   withSpinner(highchartOutput("patient_admission_by_weekday_and_hour", height = 400))))
      ),
      fluidRow(
        box(title = "Patient admission data",
            status = "gray-dark", solidHeader = TRUE, width = 12,
            icon = icon("table"),
            maximizable = FALSE, collapsible = TRUE,
            DTOutput("patient_admission_datatable"))
      )
    ) # end of page
  ) # end of body
) # end of dashboard page