#!/bin/bash

# GitHub Configuration
#export GITHUB_TOKEN="your_github_token_here"  # Personal access token from https://github.com/settings/tokens

# TerminusDB Configuration
#export TERMINUSDB_SERVER="your_server_url_here"  # e.g., https://cloud.terminusdb.com/
#export TERMINUSDB_USER="your_username_here"
#export TERMINUSDB_PASSWORD="your_password_here"
#export TERMINUSDB_TEAM="your_team_here"

# OpenAI Configuration (if needed for vector embeddings)
#export OPENAI_API_KEY="your_openai_api_key_here"

# Application Settings
#export CLAUDEHELPERS_HOME="/path/to/claudehelpers"  # Base directory for the project
#export CLAUDEHELPERS_LOG_LEVEL="INFO"  # Logging level (DEBUG, INFO, WARNING, ERROR)
#export CLAUDEHELPERS_TIMEOUT="30000"   # Default timeout for operations in milliseconds

# Instructions:
# 1. Copy this file to env.sh (which is git-ignored)
# 2. Uncomment and fill in the values you need
# 3. Source the file: source env.sh