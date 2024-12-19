# Claude Helpers

A collection of helper scripts and utilities for use with Anthropic's Claude AI assistant.

## Tools

### webfetch

A robust web content fetching tool that handles both static and JavaScript-rendered pages.

#### Features:
- Automatic fallback from simple HTTP to browser automation
- Intelligent content extraction
- Dependency management
- Progress reporting
- Error handling

#### Usage:
```bash
./bin/webfetch URL [options]

Options:
  -s, --selector  CSS selector to target specific content
  -o, --output    Output file (defaults to stdout)
  -t, --timeout   Timeout in milliseconds (default: 30000)
  --raw           Output raw HTML instead of extracted text
```

### TerminusDB Functions

Helper functions for interacting with TerminusDB through Claude.

#### Features:
- Knowledge unit management
- Memory persistence
- Context retrieval

## Installation

1. Clone the repository:
```bash
git clone https://github.com/mpolucha/claudehelpers.git
```

2. Add the bin directory to your PATH:
```bash
export PATH="$PATH:/path/to/claudehelpers/bin"
```

## Requirements

- Python 3.7+
- Git Bash (on Windows) or Bash (on Unix systems)
- Additional requirements per tool (automatically managed)

## License

MIT License - See LICENSE file for details