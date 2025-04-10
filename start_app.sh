#!/bin/bash

# Script to build and restart Docker containers, then launch Flutter frontend

echo "Building Docker containers..."
make build

echo "Restarting Docker containers..."
make restart

echo "Docker containers are now running!"

echo "Starting Flutter frontend..."
cd frontend && flutter run

echo "Application startup complete!"