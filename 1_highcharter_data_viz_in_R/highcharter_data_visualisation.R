# load packages
library(tidyverse) 
library(highcharter)
library(xts)

# Bar charts ----

# Bar chart
mpg |>  
  group_by(class) |>  
  summarise(number_of_cars = n()) |> 
  arrange(desc(number_of_cars)) |>  
  hchart("bar", hcaes(x = class, y = number_of_cars),
         color = "#5c6f7e",
         dataLabels = list(enabled = TRUE, format = "{y}"),
         name = "Number of cars") |> 
  hc_xAxis(title = list(text = "Car type")) |>  
  hc_yAxis(title = list(text = "Number of cars"),
           labels = list(format = "{value}")) |> 
  hc_title(text = list("Distribution of Car Types")) |>  
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Column chart
mpg |>  
  group_by(class) |> 
  summarise(number_of_cars = n()) |> 
  arrange(desc(number_of_cars)) |> 
  hchart("column", hcaes(x = class, y = number_of_cars),
         color = "#5c6f7e",
         dataLabels = list(enabled = TRUE, format = "{y}"),
         name = "Number of cars") |> 
  hc_xAxis(title = list(text = "Car type")) |>  
  hc_yAxis(title = list(text = "Number of cars"),
           labels = list(format = "{value}")) |>  
  hc_title(text = list("Distribution of Car Types")) |>  
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Grouped column chart
mpg |>  
  group_by(class, drv)  |>  
  summarise(number_of_cars = n())  |>  
  arrange(desc(number_of_cars))  |>  
  hchart("column", hcaes(x = class, y = number_of_cars, group= drv),
         dataLabels = list(enabled = TRUE, format = "{y}"))  |>  
  hc_xAxis(title = list(text = "Car type"))  |>  
  hc_yAxis(title = list(text = "Number of Cars"),
           labels = list(format = "{value}"))  |>  
  hc_title(text = list("Distribution of Car Types by Drive Train"))  |>  
  hc_legend(title = list(text = "Type of Drive Train")) |>
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Stacked column chart
mpg  |>  
  group_by(class, drv)  |>  
  summarise(number_of_cars = n()) |>  
  arrange(desc(number_of_cars))  |>  
  hchart("column", hcaes(x = class, y = number_of_cars, group= drv),
         dataLabels = list(enabled = TRUE, format = "{y}"),
         stacking = "normal")  |>  
  hc_colors(c("#005383", "#5c6f7e", "#dc3545")) |>  
  hc_xAxis(title = list(text = "Type of car"))  |>  
  hc_yAxis(title = list(text = "Number of cars"),
           labels = list(format = "{value}"))  |>  
  hc_title(text = list("Distribution of Car Types by Drive Train"))  |> 
  hc_legend(title = list(text = "Type of Drive Train")) |>
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Pie charts ----

# Pie chart
mpg |>  
  group_by(drv)  |>  
  summarise(number_of_cars = n())  |>  
  arrange(desc(number_of_cars)) |>  
  hchart("pie", hcaes(x = drv, y = number_of_cars),
         dataLabels = list(format = "<b>{point.name}</b>:<br>{point.number_of_cars}"),
         name = "Number of cars",
         showInLegend = TRUE)  |>  
  hc_colors(c("#dc3545", "#5c6f7e", "orange"))  |>  
  hc_title(text = list("Drive Train Distribution"))  |>
  hc_legend(title = list(text = "Type of Drive Train")) |>
  hc_exporting(enabled = FALSE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Pie chart with percentage label
mpg  |>  
  group_by(drv) |>  
  summarise(number_of_cars = n())  |>  
  mutate(percentage_of_cars = round(number_of_cars/sum(number_of_cars)*100,1))  |> 
  arrange(desc(percentage_of_cars)) |>  
  hchart("pie", hcaes(x = drv, y = percentage_of_cars),
         dataLabels = list(format = "<b>{point.name}</b>:<br>
                           {point.percentage_of_cars:.1f}%"),
         name = "Percentage of cars",
         showInLegend = TRUE)  |>  
  hc_colors(c("#dc3545", "#5c6f7e", "orange")) |>  
  hc_title(text = list("Drive Train Distribution"))  |> 
  hc_legend(title = list(text = "Type of Drive Train")) |>
  hc_exporting(enabled = FALSE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Column chart alternative
mpg  |>  
  group_by(drv) |>  
  summarise(number_of_cars = n())  |>  
  mutate(percentage_of_cars = round(number_of_cars/sum(number_of_cars)*100,1))  |> 
  arrange(desc(percentage_of_cars)) |>   
  hchart("column", hcaes(x = drv, y = percentage_of_cars),
         color = "#5c6f7e",
         dataLabels = list(enabled = TRUE, format = "{y}%"),
         name = "Percentage of cars")  |>  
  hc_xAxis(title = list(text = "Type of drive train"))  |>  
  hc_yAxis(title = list(text = "Percentage of cars"),
           labels = list(format = "{value}%"))  |>  
  hc_title(text = list("Drive Train Distribution"))  |>  
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Column chart alternative with different colors
mpg  |>  
  group_by(drv) |>  
  summarise(number_of_cars = n())  |>  
  mutate(percentage_of_cars = round(number_of_cars/sum(number_of_cars)*100,1))  |> 
  arrange(desc(percentage_of_cars)) |>   
  hchart("column", hcaes(x = drv, y = percentage_of_cars, 
                         color = c("#dc3545", "#5c6f7e", "#005383")),
         dataLabels = list(enabled = TRUE, format = "{y}%"),
         name = "Percentage of cars")  |>  
  hc_xAxis(title = list(text = "Type of drive train"))  |>  
  hc_yAxis(title = list(text = "Percentage of cars"),
           labels = list(format = "{value}%"))  |>  
  hc_title(text = list("Drive Train Distribution"))  |>  
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Scatter charts ----

# Scatter chart
mpg |>  
  hchart("scatter", hcaes(x = displ, y = cty),
         color = "orange")  |>  
  hc_xAxis(title = list(text = "Engine displacement, in litres")) |>   
  hc_yAxis(title = list(text = "City miles per gallon")) |> 
  hc_title(text = list("Engine Displacement (in litres) vs City Miles Per Gallon"))  |>  
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Grouped scatter chart
mpg  |>  
  hchart("scatter", hcaes(x = displ, y = cty, group = drv))  |>  
  hc_xAxis(title = list(text = "Engine displacement, in litres")) |>   
  hc_yAxis(title = list(text = "City miles per gallon")) |> 
  hc_title(text = list("Engine Displacement (in litres) vs City Miles Per Gallon
                       According to the Type of Drive Train")) |>  
  hc_legend(title = list(text = "Type of Drive Train")) |>
  hc_exporting(enabled = TRUE)  |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Grouped scatter chart with custom colors
mpg  |>  
  hchart("scatter", hcaes(x = displ, y = cty, group = drv))  |>  
  hc_xAxis(title = list(text = "Engine displacement, in litres")) |>   
  hc_yAxis(title = list(text = "City miles per gallon")) |> 
  hc_title(text = list("Engine Displacement (in litres) vs City Miles Per Gallon
                       According to the Type of Drive Train")) |> 
  hc_legend(title = list(text = "Type of Drive Train")) |> 
  hc_exporting(enabled = TRUE)  |> 
  hc_colors(c("#dc3545", "#5c6f7e", "orange"))  |>  
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))

# Line charts ----

# Line chart
globaltemp   |>  
  mutate(year = year(date)) |> 
  group_by(year) |> 
  summarise(average_minimum_tempature = round(mean(lower),2)) |> 
  hchart("line", hcaes(x = year, y = average_minimum_tempature),
         color = "#005383",
         name = "Average Minimum Tempature") |> 
  hc_xAxis(title = list(text = "Year")) |>  
  hc_yAxis(title = list(text = "Average Minimum Temperature")) |>  
  hc_title(text = list("Average Global Minimum Temperature over the Years")) |>  
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))


# Group line chart
vaccines |> 
  filter(state %in% c("Florida", "California")) |> 
  mutate(count = ifelse(is.na(count), 0, count)) |> 
  hchart("line", hcaes(x = year, y = count, group = state)) |> 
  hc_xAxis(title = list(text = "Year")) |>  
  hc_yAxis(title = list(text = "Number of cases per 100k people")) |>  
  hc_title(text = list("Measles Infected Cases per 100k People 
                       in Florida & California")) |> 
  hc_colors(c("#dc3545", "#5c6f7e")) |> 
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))


# Stock line chart
highchart(type = "stock") |> 
  hc_add_series(globaltemp_xts,
                type = "line",
                color = "#005383",
                name = "Minimum Temperature") |> 
  hc_xAxis(title = list(text = "Date")) |>  
  hc_yAxis(title = list(text = "Global Minimum Temperature"),
           opposite = FALSE) |>  
  hc_title(text = list("Global Minimum Temperature over the Years")) |>  
  hc_exporting(enabled = TRUE) |> 
  hc_add_theme(hc_theme(chart = list(backgroundColor = "white")))



