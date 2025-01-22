#load libraries
library(tidyr)
library(dplyr) 
library(visdat)
library(proxy)
library(stringdist)
library(purrr)
###############################
#load the two original datasets
anime_data <- read.csv(file = "C:/Users/realj/Desktop/anime.csv") 
rating_data <- read.csv(file = "C:/Users/realj/Desktop/rating.csv") 

###############################
#view the first few rows of the data frame for anime and rating data
head(anime_data)
head(rating_data)

#use glimpse function to get overview of datasets including data types and preview
glimpse(anime_data) 
glimpse(rating_data)

###############################
#concatanate dimn names and sapply for a detailed structure overview
cat("Dimensions: ", dim(anime_data), "\n")
cat("Column Names: ", names(anime_data), "\n")
cat("Data Types:\n") 
#sapply() to get data types of each columns
print(sapply(anime_data, class)) 
#use summary for initial statistical overview of data (good to find NA vals)
summary(anime_data) 

#concatanate dimn names and sapply for a detailed structure overview
cat("Dimensions: ", dim(rating_data), "\n")
cat("Column Names: ", names(rating_data), "\n")
cat("Data Types:\n") 
#sapply() to get data types of each columns
print(sapply(rating_data, class)) 
#use summary for initial statistical overview of data 
summary(rating_data) 

###############################
#finding NA values in columns of data sets 
anime_na_count <-colSums(is.na(anime_data))
cat("NA values by column in anime data set:\n")
print(anime_na_count)

#visualize missing values in anime data 
vis_miss(anime_data)

rating_na_count <-colSums(is.na(rating_data))
cat("NA values by column in rating data set:\n")
print(rating_na_count)

#remove rows that contain NA value in any column
anime1 <- na.omit(anime_data)
#check dimension of anime1 after removing missing vals 
dim(anime1) 

#remove duplicate entries, removes duplicates from anime1
anime2 <-unique(anime1)
#check dimension after removing duplicates 
dim(anime2)

#remove rows that contain NA value in any column
rating1 <- unique(rating_data)
#check dimension after removing duplicates
dim(rating1)

#remove duplicates and check data dimensions after removal
rating2 <- unique(rating1)
#check dimension after removing duplicates
dim(rating2)

###############################
#merge two data sets based on anime_id column, use all.x true to specify that
#all rows from anime2 are included in result even if no match rows in rating2
mergedanimerating <- merge(anime2, rating2, by = "anime_id", all.x = TRUE)
dim(mergedanimerating)
glimpse(mergedanimerating)

#check to see if any missing values are present after merging
#check any missing values will return true or false
any(is.na(mergedanimerating))

#summarize missing vals for each column by getting count of NA vals in each column
#of merged data.
colSums(is.na(mergedanimerating)) 

#calculate percentage of missing vals to understand extent of loss data 
sapply(mergedanimerating, function(x) mean(is.na(x)) * 100)

#remove rows that contain missing values from merged data set
merged_data <- na.omit(mergedanimerating) 
#reassess the dimensions of dataset 
dim(mergedanimerating)
dim(merged_data)

#write the merged dataset to csv file
write.csv(merged_data, "C:/Users/realj/Desktop/merged_data.csv", row.names = FALSE)

###############################
#Remove all instances of -1 from the merged data
merged_data <- read.csv(file = "C:/Users/realj/Desktop/merged_data.csv") 
complete_data <- merged_data %>%
  filter(rating.y != -1)
#write the merged dataset to csv file
write.csv(complete_data, "C:/Users/realj/Desktop/complete_data.csv", row.names = FALSE)

#Import clean data
complete_data <- read.csv(file = "C:/Users/realj/Desktop/complete_data.csv") 

# Creating new variable (feature engineering)
# Calculate the 85th, 90th, and 95th percentiles
rating_85th <- quantile(complete_data$rating.x, 0.85, na.rm = TRUE)
rating_90th <- quantile(complete_data$rating.x, 0.90, na.rm = TRUE)
rating_95th <- quantile(complete_data$rating.x, 0.95, na.rm = TRUE)

# Display the percentiles
cat("85th percentile: ", rating_85th, "\n")
cat("90th percentile: ", rating_90th, "\n")
cat("95th percentile: ", rating_95th, "\n")

# Defining percentile thresholds based on findings for high membership and rating
membership_threshold <- quantile(complete_data$members, 0.75, na.rm = TRUE)
rating_threshold <- quantile(complete_data$rating.x, 0.85, na.rm = TRUE)

# Normalize ratings and member count to calculate popularity
complete_data$popularity <- with(complete_data, {
  # Normalize values into the [0, 1] range
  normalize <- function(x) { (x - min(x)) / (max(x) - min(x)) }
  
  # Normalize the rating.x and members columns
  rating_norm <- normalize(rating.x)
  members_norm <- normalize(members)
  
  # Calculate the weighted score
  rating_weight <- 0.5
  members_weight <- 0.5
  
  # Generate popularity score based on whether each factor is above the 85th percentile
  rating_score <- ifelse(rating.x >= rating_85th, rating_norm * rating_weight, 0)
  members_score <- ifelse(members >= membership_threshold, members_norm * members_weight, 0)
  
  # Sum up individual scores to get the popularity score
  rating_score + members_score
})

# Keep the original columns and add popularity
required_columns <- c('anime_id', 'name', 'genre', 'type', 'episodes', 'rating.x', 'members', 'user_id', 'rating.y', 'popularity')

# Subset the data to add required columns
final_data <- complete_data[required_columns]

# Write the updated data to a new CSV file
write.csv(final_data, "C:/Users/realj/Desktop/updated_anime_data.csv", row.names = FALSE)

############################################################################

# Import new data
anime_data <- read.csv(file = "C:/Users/realj/Desktop/updated_anime_data.csv")

# Remove duplicates to improve speed of calculations
anime_data_unique <- anime_data %>% distinct(anime_id, .keep_all = TRUE)

# View the first few lines of updated anime_data_unique
head(anime_data_unique)

# Evaluation function to calculate cosine similarity
calculate_cosine_similarity <- function(vector1, vector2) {
  sum(vector1 * vector2) / (sqrt(sum(vector1^2)) * sqrt(sum(vector2^2)))
}

# Function to convert genres into a binary vector for cosine similarity
convert_genres_to_vector <- function(genres, all_genres) {
  sapply(all_genres, function(x) as.integer(x %in% genres))
}

# Define all genres
all_genres <- unique(unlist(strsplit(paste(anime_data_unique$genre, collapse=", "), ", ")))

# Function to calculate similar anime
calculate_similarity <- function(target_anime_row, comparison_anime_row) {
  common_genres <- length(intersect(strsplit(target_anime_row$genre, ", ")[[1]], 
                                    strsplit(comparison_anime_row$genre, ", ")[[1]]))
  rating_difference <- abs(target_anime_row$rating.x - comparison_anime_row$rating.x)
  type_match <- ifelse(target_anime_row$type == comparison_anime_row$type, 1, 0)
  
  if (target_anime_row$type == "Movie") {
    genre_weight <- 30
    rating_weight <- 0.03
    type_weight <- 35 
  } else {
    genre_weight <- 50
    rating_weight <- 0.005
    type_weight <- 18 
  }

  score <- (common_genres * genre_weight + type_match * type_weight) /
           (rating_difference * rating_weight + 0.01)
  return(score)
}

# Function to recommend animes and calculate similarity
recommend_animes <- function(anime_data_unique, target_anime_id) {
  target_anime_row <- anime_data_unique %>% filter(anime_id == target_anime_id)
  
  # Print the target anime attributes before generating recommendations
  cat("Attributes of the target anime (Anime ID", target_anime_id, "):\n")
  print(target_anime_row)
  cat("\n--- Generating recommendations based on the target anime ---\n")
  
  target_vector <- convert_genres_to_vector(strsplit(target_anime_row$genre, ", ")[[1]], all_genres)
  
  similarity_scores <- map_dbl(anime_data_unique$anime_id, function(x) {
    comparison_anime_row <- anime_data_unique %>% filter(anime_id == x)
    if (nrow(comparison_anime_row) == 0 || target_anime_row$anime_id == x) {
      return(NA)
    }
    calculate_similarity(target_anime_row, comparison_anime_row)
  })
  
  # Mutate the similarity score to each unique anime
  anime_data_unique <- anime_data_unique %>% mutate(similarity_score = similarity_scores)
  recommendations <- anime_data_unique %>%
    filter(!is.na(similarity_score), anime_id != target_anime_id) %>%
    arrange(desc(similarity_score)) %>%
    slice_head(n = 5) %>%
    select(anime_id, name, genre, type, episodes, rating.x, members, user_id, rating.y, similarity_score) # Excluding popularity

  # Add the cosine similarity to each anime
  recommended_vectors <- sapply(recommendations$genre, function(x) convert_genres_to_vector(strsplit(x, ", ")[[1]], all_genres))
  cosine_similarities <- apply(recommended_vectors, 2, function(x) calculate_cosine_similarity(target_vector, x))
  
  recommendations$cosine_similarity <- cosine_similarities
  return(recommendations)
}

# Print the top 5 recommendations for target anime
recommended_animes <- recommend_animes(anime_data_unique, target_anime_id = 263)
head(recommended_animes)
