# Simple Makefile for Streamlit project

# Variables
VENV_NAME = venv
PYTHON = python3
APP_FILE = Chat.py
EXE_NAME = promptly

.PHONY: setup run clean exe debug-exe

# Create and activate virtual environment, then install dependencies
setup:
	$(PYTHON) -m venv $(VENV_NAME)
	. $(VENV_NAME)/bin/activate && \
	pip install --upgrade pip && \
	pip install -r requirements.txt

# Run the Streamlit app
run: setup
	. $(VENV_NAME)/bin/activate && \
	streamlit run $(APP_FILE)

# Run without creating a new venv (if it already exists)
run-only:
	. $(VENV_NAME)/bin/activate && \
	streamlit run $(APP_FILE)

# Clean everything (remove virtual environment)
clean:
	rm -rf $(VENV_NAME)
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf build dist *.spec

re: clean setup run

# Help command
help:
	@echo "Available commands:"
	@echo "  make setup      - Create virtual environment and install dependencies"
	@echo "  make run        - Setup and run the Streamlit app"
	@echo "  make run-only   - Run the Streamlit app (without setup)"
	@echo "  make clean      - Remove virtual environment and cached files"
	@echo "  make help       - Show this help message" 
	@echo "  make re         - Clean, setup and run the Streamlit app"