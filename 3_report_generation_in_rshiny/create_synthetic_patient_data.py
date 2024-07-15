# Import libraries
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Set seed for reproducibility
np.random.seed(123)

# Number of patients and visits
num_patients = 4300
num_visits = 20000

# Generate Patient IDs (some patients will have multiple visits)
patient_ids = np.random.choice(range(1, num_patients + 1), num_visits, replace=True)

# Generate Patient Ages
patient_ages = np.random.choice(range(1, 101), num_visits, replace=True)

# Generate Patient Genders
patient_genders = np.random.choice(['Male', 'Female'], num_visits, replace=True)

# Generate Admission Dates
start_date = datetime.strptime("2022-01-01", "%Y-%m-%d")
end_date = datetime.strptime("2024-07-12", "%Y-%m-%d")
admission_dates = np.random.choice(pd.date_range(start_date, end_date), 
                                   num_visits, replace=True)
admission_dates = pd.to_datetime(admission_dates).to_pydatetime()

# Generate Length of Stay (in days)
length_of_stay = np.random.choice(range(1, 21), num_visits, replace=True)

# Generate Discharge Dates
discharge_dates = [admission_dates[i] + timedelta(days=int(length_of_stay[i])) for i in range(num_visits)]

# Generate Admission Times
hours = np.random.choice(range(24), num_visits, replace=True)
minutes = np.random.choice(range(60), num_visits, replace=True)
admission_times = [f"{hour:02d}:{minute:02d}" for hour, minute in zip(hours, minutes)]

# Generate Treatment Costs
treatment_costs = np.round(np.random.uniform(500, 100000, num_visits), 2)

# Generate Hospital Names
hospitals = np.random.choice(['Eltech Medical Center',
                              'Bayestry Hospital',
                              'Anival Health Clinic'],
                             num_visits, replace=True, p=[0.6, 0.3, 0.1])

# Generate Diagnoses
diagnoses = np.random.choice(['Hypertension', 'Diabetes Mellitus Type 2',
                              'Chronic Obstructive Pulmonary Disease', 'Acute Myocardial Infarction',
                              'Asthma', 'Gastroesophageal Reflux Disease', 
                              'Major Depressive Disorder', 'Generalized Anxiety Disorder',
                              'Osteoarthritis', 'Rheumatoid Arthritis', 
                              'Hypothyroidism', 'Chronic Kidney Disease',
                              'Hyperlipidemia', 'Urinary Tract Infection',
                              'Migraine', 'Pneumonia',
                              'Psoriasis', 'Irritable Bowel Syndrome',
                              'Atrial Fibrillation', 'Anemia', 'Covid-19'],
                             num_visits, replace=True)

# Create the DataFrame
patient_data = pd.DataFrame({
    'patient_id': patient_ids,
    'age': patient_ages,
    'gender': patient_genders,
    'admission_date': admission_dates,
    'admission_time': admission_times,
    'discharge_date': discharge_dates,
    'treatment_cost': treatment_costs,
    'length_of_stay': length_of_stay,
    'hospital': hospitals,
    'diagnosis': diagnoses
})

# Ensure discharge dates are not before admission dates
patient_data['discharge_date'] = np.where(patient_data['discharge_date'] < patient_data['admission_date'],
                                          patient_data['admission_date'], patient_data['discharge_date'])

# Save to CSV
patient_data.to_csv("patient_data_python.csv", index=False)
