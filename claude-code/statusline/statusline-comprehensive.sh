#!/bin/bash

# Comprehensive Claude Code Status Line
# Displays: Model, Session Cost, Today's Cost, Session Block, Burn Rate, Context Usage

# Read JSON input from stdin
input=$(cat)

# Extract basic info from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

# Function to get cost information using ccusage
get_cost_info() {
    if command -v npx >/dev/null 2>&1; then
        # Pass the input JSON to ccusage and get cost information
        cost_output=$(echo "$input" | npx -y ccusage statusline --cost-source both 2>/dev/null || echo "")
        if [ -n "$cost_output" ]; then
            echo "$cost_output"
        else
            echo "Session: \$0.00 | Today: \$0.00 | Block: N/A | Rate: \$0.00/hr"
        fi
    else
        echo "Session: \$0.00 | Today: \$0.00 | Block: N/A | Rate: \$0.00/hr"
    fi
}

# Function to get context usage
get_context_usage() {
    # Try to estimate context usage from transcript if available
    transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
    
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        # Rough estimation based on file size
        size_bytes=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
        # Approximate tokens (very rough: ~4 chars per token)
        approx_tokens=$((size_bytes / 4))
        
        # Format with K/M suffixes
        if [ $approx_tokens -gt 1000000 ]; then
            printf "%.1fM" $(echo "$approx_tokens / 1000000" | bc -l 2>/dev/null || echo "0")
        elif [ $approx_tokens -gt 1000 ]; then
            printf "%.1fK" $(echo "$approx_tokens / 1000" | bc -l 2>/dev/null || echo "0")
        else
            printf "%d" $approx_tokens
        fi
    else
        echo "0"
    fi
}

# Get all the information
cost_info=$(get_cost_info)
context_usage=$(get_context_usage)

# Format and display the comprehensive status line
printf "\033[2m%s | %s | Context: %s tokens\033[0m" "$model_name" "$cost_info" "$context_usage"
