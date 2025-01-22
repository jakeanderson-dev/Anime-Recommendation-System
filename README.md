# Anime Recommendation System

## Introduction
Finding the perfect anime to watch can be challenging due to the vast number of options and a lack of tools to tailor suggestions to individual preferences. This Anime Recommendation System provides a solution by predicting user interests to make choosing anime easier and more enjoyable.

## Problem Statement
Anime enthusiasts face difficulties selecting shows due to:
- Overwhelming choices.
- Limited knowledge of user preferences.

### Solution
A recommendation system that:
- Uses data-driven algorithms to identify user interests.
- Suggests personalized anime options based on content and user behavior.

## Features
- **Content-Based Filtering**: Analyzes anime attributes (genres, ratings, type) to recommend similar shows.
- **Hybrid Filtering**: Combines user preferences and content attributes for personalized recommendations.
- **Evaluation Metrics**: Measures recommendation accuracy with Average Precision at K (AP@K) and Cosine Similarity.

## How It Works
### Data Preprocessing
- Handles missing values and removes duplicates.
- Merges datasets (anime and ratings).
- Transforms data:
  - Extracts genre information.
  - Normalizes values (0-1 range).
  - Filters out low-rated entries and invalid data.

### Recommendation Logic
1. **Content-Based Filtering**:
   - Calculates similarity scores using genres, average ratings, and type.
   - Ranks anime by similarity and selects the top recommendations.
2. **Hybrid Filtering**:
   - Identifies top genres from user history.
   - Filters for unwatched anime matching those genres.
   - Combines user-based filtering with content attributes.
   - Outputs the top 5 recommendations.

### Evaluation Metrics
- **Average Precision at K (AP@K)**:
  - Measures relevance and precision of top recommendations.
  - Higher AP@K indicates better performance.
- **Cosine Similarity**:
  - Converts genres into binary vectors for similarity calculations.
  - Higher scores reflect closer matches.

## Results
- Recommendations align with user preferences, focusing on genres like Action, Comedy, and Shounen.
- AP@K achieved a score of 1 for specific users, indicating highly relevant suggestions.
- Cosine similarity efficiently handles content alignment, offering scalable solutions for larger datasets.

## Usage
### Libraries Used
- **dplyr**: Data manipulation.
- **tidyr**: Data transformation.
- **stringr**: String operations.

### Steps
1. Preprocess the data to clean and filter.
2. Apply the recommendation logic.
3. Evaluate the results using AP@K and similarity scores.
4. Output the top 5 recommended anime for a user.

## Future Improvements
- Enhance genre diversity in recommendations.
- Incorporate more factors to refine relevance criteria.
- Address scalability challenges for larger datasets.

## Screenshots
### Example Results
![User Interaction Example](screenshot1_placeholder.png)
*Figure 1: User interactions with anime data.*

### Evaluation Metrics
![Evaluation Metrics](screenshot2_placeholder.png)
*Figure 2: Visualization of AP@K and similarity scores.*

## Conclusion
While both content-based and hybrid filtering methods produced good results, the content-based approach was preferred for its deeper analysis and scalability. Future improvements will aim to enhance diversity and user satisfaction further.

 
