#!/bin/bash

# Build
for dir in */; do
  if [ -f "$dir/Dockerfile" ]; then
    image_name=${dir%/}
    echo "Building Docker image for $image_name..."
    docker build -t "$image_name" "$dir"
    echo "Built $image_name successfully."
  else
    echo "Skipping $dir"
  fi
done

echo "All images built."

# Deploy
cd k8s
kubectl apply -R -f .
