# Load libraries 
library(tidyverse)
library(highcharter)
library(xts)
library(DT)

# Read data
patient_data <- read_csv("patient_data.csv") |> 
  filter(admission_date >= params$admission_date[1] & 
           admission_date >= params$admission_date[1] & 
           hospital %in% params$hospital) |> 
  mutate(admission_hour = hour(admission_time),
         admission_weekday = weekdays(admission_date)) |> 
  mutate(admission_weekday = factor(admission_weekday,
                                    levels = c("Monday", "Tuesday",
                                               "Wednesday", "Thursday",
                                               "Friday", "Saturday", "Sunday"),
                                    ordered = TRUE),
         admission_hour = factor(admission_hour, levels = c(0:23),
                                 ordered = TRUE))
# Daily admissions 
patient_admission_trend <- patient_data |> 
  group_by(admission_date) |> 
  summarise(admissions = n()) |> 
  arrange(admission_date)


# Daily Admissions stock chart
patient_admission_trend_xts <- xts(x = patient_admission_trend$admissions,
                                   order.by = patient_admission_trend$admission_date)
highchart(type = "stock") |> 
  hc_add_series(patient_admission_trend_xts,
                type = "line",
                color = "#005383",
                name = "Admissions") |> 
  hc_xAxis(title = list(text = "Date")) |>  
  hc_yAxis(title = list(text = "Admissions"),
           opposite = FALSE) |>  
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))
  

# Data table
patient_data |> 
  select(-c(admission_hour, admission_weekday)) |> 
  arrange(desc(admission_date)) |> 
  DT::datatable(rownames = F,
                extensions = 'Buttons',
                filter = "top",
                options = list(pageLength = 5, scrollX = TRUE, info = TRUE,
                               dom = 'Blfrtip',
                               buttons = c('csv', 'excel', 'pdf', 'print'),
                               lengthMenu = list(c(5, 10,30, 50, -1),
                                                 c('5', '10', '30', '50', 'All')),
                               paging = T),
                colnames = c(
                  "Patient ID" = 1,
                  "Age" = 2,
                  "Gender" = 3,
                  "Admission date" = 4,
                  "Admission time" = 5,
                  "Discharge date" = 6,
                  "Treatment cost" = 7,
                  "Length of stay" = 8,
                  "Hospital" = 9,
                  "Diagnosis" = 10
                )) |> 
  formatCurrency(c("Treatment cost"), currency = "R", mark = " ")
