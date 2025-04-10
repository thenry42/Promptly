#!/bin/bash

# Script to stop and clean up Docker containers when the app is closed

echo "===== SHUTTING DOWN APPLICATION ====="

echo "Stopping Docker containers..."
make down

echo "Cleaning up Docker resources..."
make clean

echo "Application successfully shut down and cleaned up!"