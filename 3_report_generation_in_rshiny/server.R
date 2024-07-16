server <- function(input, output, session) {
  
  # Functions ----
  
  # Function to to get the most common value (mode)
  get_mode <- function(x) {
    uniqx <- unique(x)
    uniqx[which.max(tabulate(match(x, uniqx)))]
  }
  
  # Function to convert hours to AM/PM format
  convert_to_ampm <- function(hours) {
    # 1. Convert hours to POSIXct time object
    # 2. Format time object in AM/PM format
    
    time_obj <- strptime(sprintf("%d", hours), format = "%H")
    formatted_time <- format(time_obj, "%I %p")
    
    return(formatted_time)
  }
  
  # Function to add space between big numbers e.g., 1000 to 1 000
  format_number_with_space <- function(number) {
    formatted_number <- format(number, big.mark = " ")
    return(formatted_number)
  }
  
  # Function to convert dates in the format day month year
  convert_date <- function(date) {
    formatted_date <- format(as.Date(date), "%d %B %Y")
    return(formatted_date)
  }
  
  # Data read ----
  # Unfiltered patient data
  patient_data_unfiltered <- reactive({
    read_csv("patient_data.csv") |> 
      mutate(
        admission_hour = hour(admission_time),
        admission_weekday = weekdays(admission_date),
        admission_weekday = factor(admission_weekday,
                                   levels = c("Monday", "Tuesday", "Wednesday", 
                                              "Thursday", "Friday", "Saturday", "Sunday"),
                                   ordered = TRUE),
        admission_hour = factor(admission_hour, levels = 0:23, ordered = TRUE)
      )
  })
  
  # Data filtering ----
  
  # Hospital filter
  output$hospital_filter_ui <- renderUI({
    pickerInput(
      inputId = "hospital",
      label = NULL,
      choices = unique(patient_data_unfiltered()$hospital),
      multiple = TRUE,
      selected = unique(patient_data_unfiltered()$hospital),
      options = pickerOptions(
        actionsBox = TRUE,
        size = 5,
        liveSearch = TRUE,
        selectedTextFormat = "count > 1"
      ),
      inline = TRUE,
      width = "fit"
    )
  })
  
  # Patient data filtered by hospital
  patient_data_filtered_by_hospital <- reactive({
    # Ensure hospital filter input is available
    req(input$hospital)
    patient_data_unfiltered() |> 
      filter(hospital %in% input$hospital)
  })
  
  
  # Update admission date filter based on selected hospital(s)
  output$admission_dates_filter_ui <- renderUI({
    # Ensure filtered data by hospital is available
    req(patient_data_filtered_by_hospital())
    
    # Get admission dates of the selected hospitals
    date_choices <- patient_data_filtered_by_hospital() |> 
      pull(admission_date) |> 
      unique() |> 
      sort()
    
    # Create date range input for admission dates
    airDatepickerInput(
      inputId = "admission_date",
      label = NULL,
      value = c(min(date_choices), max(date_choices)),
      range = TRUE,
      update_on = "close",
      autoClose = TRUE,
      toggleSelected = FALSE,
      separator = " - ",
      minDate = min(date_choices),
      maxDate = max(date_choices),
      dateFormat = "yyyy-MM-dd"
    )
  })
  
  # Filtered patient data 
  patient_data <- reactive({
    # Ensure the admission date filter is available 
    req(input$admission_date) 
    patient_data_filtered_by_hospital() |> 
      filter(admission_date >= input$admission_date[1] & 
               admission_date <= input$admission_date[2])
  })
  
  
  # Metrics ----
  
  # Number of admissions
  output$number_of_admissions <- renderInfoBox({
    infoBox(
      title = "Number of admissions",
      color = "gray-dark",
      value = format_number_with_space(nrow(patient_data())),
      icon = icon("hospital"))
  })
  
  # Unique number of patients treated
  output$unique_number_of_patients_treated <- renderInfoBox({
    infoBox(
      title = "Unique number of patients treated",
      color = "gray-dark",
      value = format_number_with_space(length(unique(patient_data()$patient_id))),
      icon = icon("user"))
  })
  
  # Average number of patients admitted daily
  output$average_daily_admissions <- renderInfoBox({
    infoBox(
      title = "Average number of patients admitted daily",
      color = "gray-dark",
      value = format_number_with_space(round(mean(table(patient_data()$admission_date)),0)),
      icon = icon("users"))
  })
  
  # Average stay length
  output$average_stay_length <- renderInfoBox({
    infoBox(
      title = "Average stay length",
      color = "gray-dark",
      value = paste(format_number_with_space(round(mean(patient_data()$length_of_stay), 0)), "days"),
      icon = icon("bed"))
  })
  
  # Hour of day when patients are mostly admitted
  output$most_common_admission_hour <- renderInfoBox({
    infoBox(
      title = "When patients are mostly admitted",
      color = "gray-dark",
      value = convert_to_ampm(get_mode(patient_data()$admission_hour)),
      icon = icon("clock"))
  })
  
  # Total treatment cost
  output$total_treatment_cost <- renderInfoBox({
    infoBox(
      title = "Total treatment cost",
      color = "gray-dark",
      value = paste("R", format_number_with_space(sum(patient_data()$treatment_cost))),
      icon = icon("wallet"))
  })
  
  # Data visualization ----
  
  # Top 5 diagnoses by number of admissions
  output$top_5_diagnosis_by_admission <- renderHighchart({
    # Ensure the data has at least one row
    req(nrow(patient_data()) > 0)
    
    patient_data() |> 
      group_by(diagnosis) |> 
      summarise(admissions = n()) |> 
      arrange(desc(admissions)) |> 
      head(5) |> 
      hchart("bar", hcaes(x = diagnosis, y = admissions),
             color = "#005383",
             dataLabels = list(enabled = TRUE, format = "{y}"),
             name = "Admissions") %>% 
      hc_title(text = NULL) %>% 
      hc_xAxis(title = list(text = "Diagnosis")) %>% 
      hc_yAxis(title = list(text = "Admissions"),
               labels = list(format = "{value}")) %>% 
      hc_exporting(enabled = TRUE) %>% 
      hc_add_theme(
        hc_theme(chart = list(
          backgroundColor = "white")))
  })
  
  # Daily patient admissions
  output$patient_admission_trend <- renderHighchart({
    patient_admission_trend <- patient_data() |> 
      group_by(admission_date) |> 
      summarise(admissions = n()) |> 
      arrange(admission_date)
    
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
    
  })
  
  # Hourly patient admissions across the week
  output$patient_admission_by_weekday_and_hour <- renderHighchart({
    # Ensure the data has at least one row
    req(nrow(patient_data()) > 0)
    
    patient_admission_by_weekday_and_hour <- patient_data() |> 
      group_by(admission_weekday, admission_hour) |> 
      summarise(admissions = n()) |> 
      mutate(admission_hour = convert_to_ampm(admission_hour))
    
    # Sort weekdays and day hours for the heatmap
    patient_admission_by_weekday_and_hour <- patient_admission_by_weekday_and_hour |> 
      mutate(admission_hour = factor(admission_hour,
                                     levels = c("12 am", "01 am", "02 am", "03 am",
                                                "04 am", "05 am", "06 am", "07 am",
                                                "08 am", "09 am", "10 am", "11 am",
                                                "12 pm", "01 pm", "02 pm", "03 pm",
                                                "04 pm", "05 pm", "06 pm", "07 pm",
                                                "08 pm", "09 pm", "10 pm", "11 pm"),
                                     ordered = TRUE),
             admission_weekday = factor(admission_weekday,
                                        levels = c("Sunday", "Saturday", "Friday",
                                                   "Thursday", "Wednesday", "Tuesday", "Monday"),
                                        ordered = TRUE)) 
    
    # Plot patient admissions by weekday and hour of day
    patient_admission_by_weekday_and_hour |> 
      hchart("heatmap", hcaes(x = admission_hour, y = admission_weekday, value = admissions),
             name = "admissions",
             dataLabels = list(enabled = TRUE, format = "{point.admissions}")) |> 
      hc_xAxis(title = list(text = "hour")) |>  
      hc_yAxis(title = list(text = "Weekday")) |>  
      hc_exporting(enabled = TRUE) |> 
      hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))
  })
  
  # Patient data table ----
  output$patient_admission_datatable <- renderDT({
    patient_data() |> 
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
  })
  
  # Report download ---- 
  
  # Download patient admission report for a one or multiple hospitals combined
  output$patient_admission_report_download <- downloadHandler(
    # Downloaded file name
    filename = function() {
      paste0(Sys.Date(), "_report.html")
    },
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "rmarkdown_html_report.Rmd")
      file.copy("rmarkdown_html_report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        hospital = input$hospital,
        admission_date = input$admission_date
        )
      
      # A user message to indicate a report is being created
      id <- showNotification(
        "creating report...",
        duration = NULL,
        closeButton = FALSE,
        type = "message"
      )
      on.exit(removeNotification(id), add = TRUE)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(
        input = "rmarkdown_html_report.Rmd",
        output_format = "html_document",
        output_file = file,
        params = params,
        envir = new.env()
      )
    }
  )
  
  # Download individual hospital reports in a zip file
  
  # Function to generate a single report for a hospital
  # for a particular date range.
  generate_report <- function(hospital, admission_date) {
    
    # Display a notification while the report is being created
    id <- showNotification(
      "Creating report...",
      duration = NULL,
      closeButton = FALSE,
      type = "message"
    )
    on.exit(removeNotification(id), add = TRUE)
    
    # Render the RMarkdown report
    rmarkdown::render(
      input = "rmarkdown_html_report.Rmd",
      params = list(hospital = hospital,
                    admission_date = admission_date),
      output_file = paste0(hospital, "_report.html"),
      envir = new.env(parent = globalenv()))
  }
  
  # download multiple hospital reports
  output$patient_admission_bulk_report_download <- downloadHandler(
    filename = function() {
      "hospital_reports.zip"
    },
    content = function(file) {
      hospitals <- input$hospital
      admission_dates <- input$admission_date
      
      # Generate reports for all selected hospitals
      report_files <- lapply(hospitals, function(hospital) {
        generate_report(hospital, admission_dates)
      })
      
      # Create a list of report file names
      # Ensure these names match the output file names 
      report_filenames <- paste0(hospitals, "_report.html")
      
      # Zip the reports
      zip(zipfile = file, files = report_filenames)
    }
  )
  
  
}