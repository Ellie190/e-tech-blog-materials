library(rmarkdown)

# Set parameters to pass to Rmd document
params <- list(
  hospital = c('Eltech Medical Center', 'Bayestry Hosipital', 'Anival Health Clinic'),
  admission_date = c("2024-01-01", "2024-07-12")
)

# Generate one rmd report in a .html format
rmarkdown::render(
  input = "rmarkdown_html_report.Rmd",
  output_format = "html_document",
  output_file = paste0(Sys.Date(), "_report.html"),
  params = params,
  envir = new.env()
)


# Generate multiple rmd reports in a .html format
# Function to generate a single report for a hospital
# for a particular date range.
generate_report <- function(hospital, admission_date) {
  
  
  # Render the rmarkdown report
  rmarkdown::render(
    input = "rmarkdown_html_report.Rmd",
    params = params,
    output_file = paste0(hospital, "_report.html"),
    envir = new.env()
    )
}

# Generate reports for all selected hospitals
hospitals <- c('Eltech Medical Center', 'Bayestry Hosipital', 'Anival Health Clinic')
report_files <- lapply(hospitals, function(hospital) {
  generate_report(hospital, admission_dates)
})

# Create a list of report file names
# Ensure these names match the output file names 
report_filenames <- paste0(hospitals, "_report.html")

# Zip the reports
zip(zipfile = "hospital_reports.zip", files = report_filenames)
