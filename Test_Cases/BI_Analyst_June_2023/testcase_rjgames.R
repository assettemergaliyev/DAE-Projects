library(readr)
library(tidyverse)

# Reading the CSV file
zomato <- read_csv("zomato.csv")

# Viewing the data frame
View(zomato)


# Task 1
# Create df with Top 75 most popular restaurants
# Sorting the zomato df by votes in desc order
sorted_zomato <- zomato[order(-zomato$votes), ]

# Selecting the top 75 rows (restaurants) from the sorted df
top_restaurants <- sorted_zomato[1:75, ]

# Printing the top 75 restaurants
print(top_restaurants)


# Task 2
# Create df with the Top 5% of the most favorite dishes and their popularity
# Calculating the number of rows corresponding to the top 5% out of sorted df by votes
num_rows <- ceiling(0.05 * nrow(sorted_zomato))

# Selecting the top 5% rows (dishes) from the sorted df
top_dishes <- sorted_zomato[1:num_rows, c("dish_liked", "votes")]

# Printing the top dishes and their popularity
print(top_dishes)


# Task 3
# Create df for 10 random restaurants with a known average check, 
# and converting of the average check to the current exchange rate of USD and EUR

library(jsonlite)
library(rvest)

# Function to extract the exchange rate using Google Finance website
get_exchange_rate <- function(url) {
  webpage <- read_html(url)
  exchange_rate <- webpage %>%
    html_nodes(".YMlKec.fxKbKc") %>%
    html_text() %>%
    as.numeric()
  return(exchange_rate)
}

# Getting the exchange rates from Google Finance
usd_to_inr <- get_exchange_rate("https://www.google.com/finance/quote/INR-USD?sa=X&ved=2ahUKEwjKzeWAh7n_AhXp-ioKHRSzDHwQmY0JegQIERAc")
eur_to_inr <- get_exchange_rate("https://www.google.com/finance/quote/INR-EUR?sa=X&ved=2ahUKEwjf9-6nh7n_AhXEmIsKHQyIDCEQmY0JegQIARAY")

# Randomly selecting 10 rows (restaurants) from the zomato df
random_restaurants <- zomato[sample(nrow(zomato), 10), ]

# Creating a new df with the required columns
df <- data.frame(
  restaurant_name = random_restaurants$name,
  avg_check_inr = random_restaurants$`approx_cost(for two people)`,
  avg_check_usd = random_restaurants$`approx_cost(for two people)` * usd_to_inr,
  avg_check_eur = random_restaurants$`approx_cost(for two people)` * eur_to_inr
)

# Printing new df
print(df)
