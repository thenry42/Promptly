#!/bin/bash

# Get the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if Python virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python -m venv venv
fi

# Create data directory for conversation history if it doesn't exist
if [ ! -d "data" ]; then
    echo "Creating data directory for conversation history..."
    mkdir -p data
    touch data/.gitkeep
fi

# Activate virtual environment
source venv/bin/activate

# Install requirements if needed
echo "Checking for dependencies..."
pip install -r "$SCRIPT_DIR/requirements.txt"

# Set optimized environment variables
export STREAMLIT_SERVER_MAX_UPLOAD_SIZE=10
export STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
export STREAMLIT_THEME_BASE="dark"
export STREAMLIT_THEME_PRIMARY_COLOR="#4B8BF5"
export STREAMLIT_RUNNER_FAST_RERUNS=true
export PYTHONOPTIMIZE=2  # Enable Python optimizations (level 2)

# Run the app with optimized parameters
echo "Starting Promptly in dark mode..."
"$SCRIPT_DIR/venv/bin/streamlit" run "$SCRIPT_DIR/Chat.py" --server.maxUploadSize=10 --browser.serverAddress="localhost" --browser.gatherUsageStats=false --client.showErrorDetails=false --client.toolbarMode=minimal --theme.base=dark