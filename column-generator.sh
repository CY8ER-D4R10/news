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
BASE_DIR="$HOME/news/rubriken"
KOLUMNE_DIR="$HOME/news/kolumne"

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