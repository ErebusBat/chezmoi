
# Fetch updates from all mirrors
[group('Mirrors')]
mirror-fetch-all:
  just mirror-fetch-repo vendor/mcp-memory-service.git

  just mirror-fetch-repo vendor/agent-safe-engineering.git
  just mirror-fetch-repo vendor/agent-safe-engineering.git ravi

