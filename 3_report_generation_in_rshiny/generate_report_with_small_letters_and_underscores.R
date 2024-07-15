# Report with small letters and underscores
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
  
  # Convert hospital name to lowercase and replace spaces with underscores
  output_file <- paste0(gsub(" ", "_", tolower(hospital)), "_report.html")
  
  # Render the RMarkdown report
  rmarkdown::render(
    input = "rmarkdown_html_report.Rmd",
    params = list(hospital = hospital,
                  admission_date = admission_date),
    output_file = output_file,
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
    
    # Create a list of report filenames
    report_filenames <- paste0(gsub(" ", "_", tolower(hospitals)), "_report.html")
    
    # Zip the reports
    zip(zipfile = file, files = report_filenames)
  }
)