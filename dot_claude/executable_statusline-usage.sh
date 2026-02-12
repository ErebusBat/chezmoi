#!/bin/bash

# Read Claude Code JSON from stdin
input=$(cat)

# ============================================
# MODEL AND GIT INFO
# ============================================
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
# Shorten context window display: "Sonnet 4.5 (1M context)" -> "Sonnet 4.5 (1M)"
MODEL=$(echo "$MODEL" | sed 's/ context)/)/g')
BRANCH=$(git branch --show-current 2>/dev/null || echo "")


# Get current directory, replacing home with ~
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
if [ -n "$CURRENT_DIR" ]; then
    CURRENT_DIR_DISPLAY="${CURRENT_DIR/#$HOME/~}"

    # Path shortening rules - easy to add/remove/modify
    # Format: "pattern|replacement" - one per line
    # Paths starting with pattern will have pattern replaced with replacement
    PATH_SHORTCUTS=(
        "~/src/lshq/|"
        "~/src/erebusbat/|"
    )

    # Apply path shortcuts in order
    for shortcut in "${PATH_SHORTCUTS[@]}"; do
        pattern="${shortcut%%|*}"
        replacement="${shortcut##*|}"
        if [[ "$CURRENT_DIR_DISPLAY" == "$pattern"* ]]; then
            CURRENT_DIR_DISPLAY="${CURRENT_DIR_DISPLAY/$pattern/$replacement}"
            break  # Only apply first matching rule
        fi
    done
else
    CURRENT_DIR_DISPLAY=""
fi

# ============================================
# SESSION DATA (5-hour billing block from ccusage)
# ============================================
# Cache expensive ccusage calls for 30 seconds
CACHE_FILE="/tmp/claude-statusline-cache.json"
CACHE_AGE=30

if [ -f "$CACHE_FILE" ]; then
    CACHE_MTIME=$(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
    CACHE_DIFF=$((CURRENT_TIME - CACHE_MTIME))
else
    CACHE_DIFF=999
fi

if [ $CACHE_DIFF -gt $CACHE_AGE ]; then
    # Cache is stale, refresh it
    BLOCK_DATA=$(ccusage blocks --json 2>/dev/null | jq '.blocks[-1]' 2>/dev/null)
    WEEKLY_DATA=$(ccusage weekly --json 2>/dev/null | jq '.weekly[-1]' 2>/dev/null)
    echo "{\"block\": $BLOCK_DATA, \"weekly\": $WEEKLY_DATA}" > "$CACHE_FILE"
else
    # Use cached data
    BLOCK_DATA=$(cat "$CACHE_FILE" | jq '.block')
    WEEKLY_DATA=$(cat "$CACHE_FILE" | jq '.weekly')
fi

# Use weighted tokens for session too
BLOCK_INPUT=$(echo "$BLOCK_DATA" | jq -r '.inputTokens // 0')
BLOCK_OUTPUT=$(echo "$BLOCK_DATA" | jq -r '.outputTokens // 0')
BLOCK_CACHE_CREATE=$(echo "$BLOCK_DATA" | jq -r '.cacheCreationTokens // 0')
BLOCK_CACHE_READ=$(echo "$BLOCK_DATA" | jq -r '.cacheReadTokens // 0')
BLOCK_TOKENS=$(echo "scale=0; $BLOCK_INPUT + $BLOCK_OUTPUT + $BLOCK_CACHE_CREATE + ($BLOCK_CACHE_READ * 0.1)" | bc)

BLOCK_END_TIME=$(echo "$BLOCK_DATA" | jq -r '.endTime // ""')
REMAINING_MINS=$(echo "$BLOCK_DATA" | jq -r '.projection.remainingMinutes // 0')

# Convert block end time to human readable
if [ -n "$BLOCK_END_TIME" ]; then
    BLOCK_END_HOUR=$(TZ='America/Denver' date -d "$BLOCK_END_TIME" +%I:%M%p 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${BLOCK_END_TIME%.*}" +%I:%M%p 2>/dev/null)
fi

# Calculate hours and minutes until block reset
HOURS_UNTIL_SESSION=$((REMAINING_MINS / 60))
MINS_UNTIL_SESSION=$((REMAINING_MINS % 60))

# Session limit based on Claude Desktop showing 7% at current usage
# Using weighted tokens to match Claude Desktop calculation
# Approximate: 40M weighted tokens per 5hr session
BLOCK_LIMIT=40000000

# Calculate session percentage
if [ $BLOCK_LIMIT -gt 0 ]; then
    SESSION_PCT=$(echo "scale=0; ($BLOCK_TOKENS * 100) / $BLOCK_LIMIT" | bc)
else
    SESSION_PCT=0
fi

# Project session usage (use ccusage projection if available)
# Note: projection.totalTokens is raw total, we need to estimate weighted projection
PROJECTED_RAW=$(echo "$BLOCK_DATA" | jq -r '.projection.totalTokens // 0')
if [ $PROJECTED_RAW -gt 0 ]; then
    # Rough estimate: assume similar cache ratio as current usage
    # This is imperfect but better than nothing
    if [ $(echo "$BLOCK_DATA" | jq -r '.totalTokens // 0') -gt 0 ]; then
        RAW_TOTAL=$(echo "$BLOCK_DATA" | jq -r '.totalTokens // 0')
        WEIGHT_RATIO=$(echo "scale=4; $BLOCK_TOKENS / $RAW_TOTAL" | bc)
        PROJECTED_BLOCK_TOKENS=$(echo "scale=0; $PROJECTED_RAW * $WEIGHT_RATIO" | bc)
    else
        PROJECTED_BLOCK_TOKENS=$BLOCK_TOKENS
    fi
    PROJECTED_SESSION_PCT=$(echo "scale=0; ($PROJECTED_BLOCK_TOKENS * 100) / $BLOCK_LIMIT" | bc)
else
    PROJECTED_SESSION_PCT=$SESSION_PCT
fi

# ============================================
# WEEKLY DATA (from cache loaded above)
# ============================================
# Use weighted tokens (cache reads count as 0.1x, matching Claude Desktop)
WEEKLY_INPUT=$(echo "$WEEKLY_DATA" | jq -r '.inputTokens // 0')
WEEKLY_OUTPUT=$(echo "$WEEKLY_DATA" | jq -r '.outputTokens // 0')
WEEKLY_CACHE_CREATE=$(echo "$WEEKLY_DATA" | jq -r '.cacheCreationTokens // 0')
WEEKLY_CACHE_READ=$(echo "$WEEKLY_DATA" | jq -r '.cacheReadTokens // 0')
WEEKLY_TOKENS=$(echo "scale=0; $WEEKLY_INPUT + $WEEKLY_OUTPUT + $WEEKLY_CACHE_CREATE + ($WEEKLY_CACHE_READ * 0.1)" | bc)

# Calculate time until Tuesday 9pm weekly reset (Denver time)
DAY_OF_WEEK=$(TZ='America/Denver' date +%u)  # 1=Mon, 2=Tue, 7=Sun
CURRENT_HOUR_24=$(TZ='America/Denver' date +%H)

if [ $DAY_OF_WEEK -eq 2 ]; then
    # Today is Tuesday
    if [ $CURRENT_HOUR_24 -lt 21 ]; then
        # Before 9pm, resets today
        DAYS_UNTIL_WEEKLY=0
        HOURS_UNTIL_WEEKLY=$((21 - CURRENT_HOUR_24))
    else
        # After 9pm, resets next Tuesday
        DAYS_UNTIL_WEEKLY=7
        HOURS_UNTIL_WEEKLY=$((24 - CURRENT_HOUR_24 + 21))
    fi
elif [ $DAY_OF_WEEK -lt 2 ]; then
    # Monday (day 1) - Tuesday is tomorrow or later this week
    DAYS_UNTIL_WEEKLY=$((2 - DAY_OF_WEEK))
    if [ $CURRENT_HOUR_24 -lt 21 ]; then
        HOURS_UNTIL_WEEKLY=$((21 - CURRENT_HOUR_24))
    else
        HOURS_UNTIL_WEEKLY=$((24 - CURRENT_HOUR_24 + 21))
        DAYS_UNTIL_WEEKLY=$((DAYS_UNTIL_WEEKLY - 1))
    fi
else
    # Wed-Sun (days 3-7) - Tuesday is next week
    DAYS_UNTIL_WEEKLY=$((9 - DAY_OF_WEEK))
    if [ $CURRENT_HOUR_24 -lt 21 ]; then
        HOURS_UNTIL_WEEKLY=$((21 - CURRENT_HOUR_24))
    else
        HOURS_UNTIL_WEEKLY=$((24 - CURRENT_HOUR_24 + 21))
        DAYS_UNTIL_WEEKLY=$((DAYS_UNTIL_WEEKLY - 1))
    fi
fi

TOTAL_HOURS_UNTIL_WEEKLY=$(echo "scale=1; ($DAYS_UNTIL_WEEKLY * 24) + $HOURS_UNTIL_WEEKLY" | bc)

# Calculate weekly burn rate (tokens per hour over the week so far)
# Week starts Tuesday 9pm, so calculate hours since last Tuesday 9pm
if [ $DAY_OF_WEEK -ge 2 ]; then
    # Tuesday or later this week
    HOURS_ELAPSED_THIS_WEEK=$(echo "scale=1; ((($DAY_OF_WEEK - 2) * 24) + $CURRENT_HOUR_24 - 21)" | bc)
else
    # Monday (before Tuesday) - we're in the last day of previous week
    HOURS_ELAPSED_THIS_WEEK=$(echo "scale=1; ((6 * 24) + $CURRENT_HOUR_24 - 21)" | bc)
fi
if (( $(echo "$HOURS_ELAPSED_THIS_WEEK > 1" | bc -l) )); then
    WEEKLY_TOKENS_PER_HOUR=$(echo "scale=0; $WEEKLY_TOKENS / $HOURS_ELAPSED_THIS_WEEK" | bc)
else
    WEEKLY_TOKENS_PER_HOUR=0
fi

# Project weekly usage at current burn rate
PROJECTED_WEEKLY_TOKENS=$(echo "scale=0; $WEEKLY_TOKENS + ($WEEKLY_TOKENS_PER_HOUR * $TOTAL_HOURS_UNTIL_WEEKLY)" | bc)

# Weekly limit based on Claude Desktop showing 3% at ~24M weighted tokens
# 24M / 0.03 = 800M weighted tokens/week
WEEKLY_LIMIT=800000000
WEEKLY_PCT=$(echo "scale=0; ($WEEKLY_TOKENS * 100) / $WEEKLY_LIMIT" | bc)
PROJECTED_WEEKLY_PCT=$(echo "scale=0; ($PROJECTED_WEEKLY_TOKENS * 100) / $WEEKLY_LIMIT" | bc)

# ============================================
# SMART COLOR SELECTION
# ============================================
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Element colors for better visual organization
CYAN='\033[36m'      # Model name
BLUE='\033[34m'      # Folder/Branch name
MAGENTA='\033[35m'   # Percentages and times

# Session bar color: Based on PROJECTED percentage
if [ $PROJECTED_SESSION_PCT -lt 70 ]; then
    SESSION_COLOR="$GREEN"
    SESSION_ICON=""
elif [ $PROJECTED_SESSION_PCT -lt 90 ]; then
    SESSION_COLOR="$YELLOW"
    SESSION_ICON=" ⚠️"
else
    SESSION_COLOR="$RED"
    SESSION_ICON=" 🚨"
fi

# Weekly bar color: Based on PROJECTED percentage
if [ $PROJECTED_WEEKLY_PCT -lt 70 ]; then
    WEEKLY_COLOR="$GREEN"
    WEEKLY_ICON=""
elif [ $PROJECTED_WEEKLY_PCT -lt 90 ]; then
    WEEKLY_COLOR="$YELLOW"
    WEEKLY_ICON=" ⚠️"
else
    WEEKLY_COLOR="$RED"
    WEEKLY_ICON=" 🚨"
fi

# Percentage text colors: Based on ACTUAL usage (not projected)
if [ $SESSION_PCT -lt 70 ]; then
    SESSION_PCT_COLOR="$GREEN"
elif [ $SESSION_PCT -lt 90 ]; then
    SESSION_PCT_COLOR="$YELLOW"
else
    SESSION_PCT_COLOR="$RED"
fi

if [ $WEEKLY_PCT -lt 70 ]; then
    WEEKLY_PCT_COLOR="$GREEN"
elif [ $WEEKLY_PCT -lt 90 ]; then
    WEEKLY_PCT_COLOR="$YELLOW"
else
    WEEKLY_PCT_COLOR="$RED"
fi

# ============================================
# BUILD COLORIZED PROGRESS BARS
# ============================================
build_colored_bar() {
    local pct=$1
    local color=$2
    local filled=$((pct / 10))
    [ $filled -gt 10 ] && filled=10
    [ $filled -lt 0 ] && filled=0
    local empty=$((10 - filled))

    local bar=""
    if [ $filled -gt 0 ]; then
        bar="${color}$(printf "%${filled}s" | tr ' ' '▓')${RESET}"
    fi
    if [ $empty -gt 0 ]; then
        bar="${bar}$(printf "%${empty}s" | tr ' ' '░')"
    fi
    echo -e "$bar"
}

SESSION_BAR=$(build_colored_bar $SESSION_PCT "$SESSION_COLOR")
WEEKLY_BAR=$(build_colored_bar $WEEKLY_PCT "$WEEKLY_COLOR")

# ============================================
# OUTPUT
# ============================================
WEEKLY_TOKENS_M=$(echo "scale=1; $WEEKLY_TOKENS / 1000000" | bc)

# Format session time string
if [ $HOURS_UNTIL_SESSION -eq 0 ]; then
    SESSION_TIME="${MINS_UNTIL_SESSION}m"
else
    SESSION_TIME="${HOURS_UNTIL_SESSION}h${MINS_UNTIL_SESSION}m"
fi

# Format weekly reset display
if [ $DAYS_UNTIL_WEEKLY -eq 0 ]; then
    # Resets today - check if less than 4 hours away
    if [ $HOURS_UNTIL_WEEKLY -lt 4 ]; then
        # Less than 4 hours - show countdown
        CURRENT_MIN=$(TZ='America/Denver' date +%M)
        WEEKLY_MINS_REMAINING=$(( (HOURS_UNTIL_WEEKLY * 60) + (60 - CURRENT_MIN) ))
        WEEKLY_HOURS=$((WEEKLY_MINS_REMAINING / 60))
        WEEKLY_MINS=$((WEEKLY_MINS_REMAINING % 60))
        if [ $WEEKLY_HOURS -eq 0 ]; then
            WEEKLY_RESET_DISPLAY="resets in ${WEEKLY_MINS}m"
        else
            WEEKLY_RESET_DISPLAY="resets in ${WEEKLY_HOURS}h${WEEKLY_MINS}m"
        fi
    else
        # More than 4 hours - show absolute time
        WEEKLY_RESET_DISPLAY="resets 9pm"
    fi
else
    WEEKLY_RESET_DISPLAY="resets in ${DAYS_UNTIL_WEEKLY}d"
fi

# Build branch/directory display
# Always show directory, add branch when in git repo
LOCATION_DISPLAY=""
if [ -n "$CURRENT_DIR_DISPLAY" ]; then
    LOCATION_DISPLAY=" 📁 ${BLUE}${CURRENT_DIR_DISPLAY}${RESET}"
fi
if [ -n "$BRANCH" ]; then
    LOCATION_DISPLAY="${LOCATION_DISPLAY} 🌿 ${BLUE}${BRANCH}${RESET}"
fi
if [ -n "$LOCATION_DISPLAY" ]; then
    LOCATION_DISPLAY="${LOCATION_DISPLAY}"
fi

echo -e "[${CYAN}${MODEL}${RESET}]${LOCATION_DISPLAY}"
echo -e "S: ${SESSION_BAR} ${SESSION_PCT_COLOR}${SESSION_PCT}%${RESET}${SESSION_ICON} ${MAGENTA}${SESSION_TIME}${RESET}"
echo -e "W: ${WEEKLY_BAR} ${WEEKLY_PCT_COLOR}${WEEKLY_PCT}%${RESET}${WEEKLY_ICON} ${MAGENTA}${WEEKLY_TOKENS_M}M${RESET} ${MAGENTA}${WEEKLY_RESET_DISPLAY}${RESET}"
