#! /bin/bash

# Author: Simon, Dario
# Created: 16.12.2025
# Last Modified: 04.01.2026
# Description: Read data from a webscraper and format the information into categorized content.
# 
# How to use:
# 1. chmod +x column-generator.sh
# 2. ./column-generator.sh

JSON_FILE="$HOME/news/schlagzeilen.json"
FOCUS_FILE="$HOME/news/focus.json"
BASE_DIR="$HOME/news/rubriken"
KOLUMNE_DIR="$HOME/news/kolumne"

DATUM=$(date +%Y-%m-%d)
MONTH=$(date +%B)
WEEKDAY=$(date +%A)

mkdir -p "$BASE_DIR"

# Create a folder for each category under rubriken/
jq -r '.headlines[].category' "$JSON_FILE" | sort -u | while read -r category; do
  target_dir="$BASE_DIR/$category"

  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo "Directory crated: $target_dir"
  else
    echo "Directory already exists, skipping: $target_dir"
  fi
done

# Create a folder for each month of the year under kolumne/
months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
for month in "${months[@]}"; do
  target_dir="$KOLUMNE_DIR/$month"
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo "Directory created: $target_dir"
  else
    echo "Directory already exists, skipping: $target_dir"
  fi
done

# Create a folder of the current date in the current month's kolumne directory
today_dir="$KOLUMNE_DIR/$MONTH/$DATUM"
if [ ! -d "$today_dir" ]; then
  mkdir -p "$today_dir"
  echo "Directory created: $today_dir"
else
  echo "Directory already exists, skipping: $today_dir"
fi

# Filter headlines for focus categories and sort by text length
focus_categories=$(jq -r --arg weekday "$WEEKDAY" '.[$weekday].category[]' "$FOCUS_FILE")

# Create filtered headlines file
filtered_file="$today_dir/schlagzeilen-relevant-und-gefiltert.json"
echo "Filtering headlines for focus categories: $focus_categories"

# Get all categories and build filter
if [ -n "$focus_categories" ]; then
  category_filter=""
  for cat in $focus_categories; do
    if [ -z "$category_filter" ]; then
      category_filter=".category == \"$cat\""
    else
      category_filter="$category_filter or .category == \"$cat\""
    fi
  done

  # Filter and sort by headline length
  jq '[.headlines[] | select('"$category_filter"')] | sort_by(.headline | length)' \
    "$JSON_FILE" > "$filtered_file"

  echo "Filtered headlines saved to: $filtered_file"
else
  echo "No focus categories found for $WEEKDAY"
  echo "[]" > "$filtered_file"
fi