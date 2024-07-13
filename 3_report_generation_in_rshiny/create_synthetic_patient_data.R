# Load necessary libraries
library(dplyr)
library(lubridate)

# Set seed for reproducibility
set.seed(123)

# Number of patients and visits
num_patients <- 4300
num_visits <- 20000

# Generate Patient IDs (some patients will have multiple visits)
patient_ids <- sample(1:num_patients, num_visits, replace = TRUE)

# Generate Patient Ages
patient_ages <- sample(1:100, num_visits, replace = TRUE)

# Generate Patient Genders
patient_genders <- sample(c('Male', 'Female'), num_visits, replace = TRUE)

# Generate Admission Dates
admission_dates <- sample(seq.Date(from = as.Date("2022-01-01"), 
                                   to = as.Date("2024-07-12"), by = "day"), 
                          num_visits, replace = TRUE)

# Generate Length of Stay (in days)
length_of_stay <- sample(1:20, num_visits, replace = TRUE)

# Generate Discharge Dates
discharge_dates <- admission_dates + days(length_of_stay)

# Generate Admission Times
admission_times <- format(strptime(sprintf("%02d:%02d", sample(0:23, num_visits, replace = TRUE), 
                                           sample(0:59, num_visits, replace = TRUE)), 
                                   format="%H:%M"), "%H:%M")

# Generate Treatment Costs
treatment_costs <- round(runif(num_visits, min = 500, max = 100000), 2)

# Generate Hospital Names
# Eltech - This is combination of Eli and tech
# Bayestry - This is a combination of bayesian and try
# Anival - This is a combination of anime and val
hospitals <- sample(c('Eltech Medical Center', 'Bayestry Hosipital', 'Anival Health Clinic'), 
                    num_visits, replace = TRUE, 
                    prob = c(0.6, 0.3, 0.1))

# Generate Diagnoses
diagnoses <- sample(c('Hypertension', 'Diabetes Mellitus Type 2', 'Chronic Obstructive Pulmonary Disease',
                      'Acute Myocardial Infarction', 'Asthma', 'Gastroesophageal Reflux Disease', 
                      'Major Depressive Disorder', 'Generalized Anxiety Disorder', 'Osteoarthritis',
                      'Rheumatoid Arthritis', 'Hypothyroidism', 'Chronic Kidney Disease',
                      'Hyperlipidemia', 'Urinary Tract Infection', 'Migraine', 'Pneumonia', 'Psoriasis', 
                      'Irritable Bowel Syndrome', 'Atrial Fibrillation', 'Anemia', 'Covid-19'), 
                    num_visits, replace = TRUE)

# Create the data frame
patient_data <- data.frame(
  patient_id = patient_ids,
  age = patient_ages,
  gender = patient_genders,
  admission_date = admission_dates,
  admission_time = admission_times,
  discharge_date = discharge_dates,
  treatment_cost = treatment_costs,
  length_of_stay = length_of_stay,
  hospital = hospitals,
  diagnosis = diagnoses
)

# Ensure discharge dates are not before admission dates
patient_data <- patient_data |> 
  mutate(discharge_date = if_else(discharge_date < admission_date, admission_date, discharge_date))

# Save to CSV
write.csv(patient_data, "patient_data.csv", row.names = FALSE)
