#!/bin/bash


for file in `find . -type f -name "*.png"`; do
  dest="${file%.*}.webp"
  echo "$file --> $dest"
  magick $file -resize 720x $dest
done
