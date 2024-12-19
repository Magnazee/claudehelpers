# Claude Helpers

A collection of helper scripts and utilities designed specifically for LLM agents to perform operations through command-line interfaces.

## Features

### Single Entry Point Scripts
Each domain (GitHub, TerminusDB, etc.) has a single wrapper script that:
- Handles all operations for that domain
- Manages dependencies and prerequisites
- Validates credentials and environment
- Provides consistent error handling

### Automatic Updates
The `update-repo` script provides:
- Repository status checking
- Automatic updates when needed
- Prompt file management
- Clear update status reporting

### Environment Management
- Template-based environment setup
- Secure credential management
- Cross-platform compatibility
- Clear error messages for missing requirements

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/mpolucha/claudehelpers.git
```

2. Set up your environment:
```bash
cp env.template.sh env.sh
# Edit env.sh with your credentials
```

3. Review the instructions:
```bash
cat prompt.txt
```

## Tools Available

### GitHub Operations
```bash
./bin/github <command> [options]
```
Supports all GitHub CLI operations with automatic installation and authentication.

### TerminusDB Operations
```bash
./bin/terminusdb <command> [options]
```
Manages knowledge units and database operations with consistent interface.

## For LLM Agents

1. Always start by checking/updating the repository:
```bash
./bin/update-repo
```

2. Read prompt.txt for latest instructions after any updates

3. Use the appropriate domain-specific wrapper for operations

## Requirements

- Git Bash (on Windows) or Bash (on Unix systems)
- Git
- Internet connection for updates
- Appropriate API tokens/credentials in env.sh

## License

MIT License - See LICENSE file for details