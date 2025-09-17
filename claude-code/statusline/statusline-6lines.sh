#!/bin/bash

# 5-Line Claude Code Status Line
# Line 1: Model and output style
# Line 2: Project info and git branch
# Line 3: Context usage (from ccusage when available, fallback to file size estimate)
# Line 4: All cost-related information
# Line 5: Horizontal separator line
#
# Note: Uses ccusage tool for both cost and context data when available.
# Falls back to transcript file size estimates if ccusage is unavailable.

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
model_id=$(echo "$input" | jq -r '.model.id // "unknown"')
cwd=$(echo "$input" | jq -r '.cwd // "."')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // "."')
version=$(echo "$input" | jq -r '.version // "unknown"')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Get relative path from project to current directory
get_relative_path() {
    local project_path="$1"
    local current_path="$2"

    # If paths are the same, return root
    if [ "$project_path" = "$current_path" ]; then
        echo "/"
        return
    fi

    # Get basename if current is subdirectory of project
    if [[ "$current_path" == "$project_path"* ]]; then
        rel_path="${current_path#$project_path}"
        rel_path="${rel_path#/}"  # Remove leading slash
        echo "/$rel_path"
    else
        # Just show the basename of current directory
        echo "/$(basename "$current_path")"
    fi
}

# Get cost and context information from ccusage
get_ccusage_data() {
    if command -v npx >/dev/null 2>&1; then
        # Pass the input JSON to ccusage and get full output
        result=$(echo "$input" | npx -y ccusage statusline --visual-burn-rate emoji 2>/dev/null)

        # Check if we got a valid result
        if [ -n "$result" ] && ! echo "$result" | grep -q "Invalid input\|Error\|❌" 2>/dev/null; then
            echo "$result"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Extract cost information from ccusage output
get_cost_info() {
    local ccusage_output="$1"

    if [ -n "$ccusage_output" ]; then
        # Extract the section between 💰 and the next |
        cost_section=$(echo "$ccusage_output" | sed -n 's/.*💰 \([^|]*\).*/\1/p')

        # Extract the burn rate section starting with 🔥
        burn_section=$(echo "$ccusage_output" | sed -n 's/.*\(🔥 [^|]*\).*/\1/p')

        if [ -n "$cost_section" ]; then
            # Parse the individual components from the cost section
            # Expected format: "N/A session / $65.77 today / $70.67 block (2h 14m left)"
            session_part=$(echo "$cost_section" | sed -n 's/^\([^/]*\) session.*/\1/p' | sed 's/^ *//' | sed 's/ *$//')
            today_part=$(echo "$cost_section" | sed -n 's/.* \([^/]*\) today.*/\1/p' | sed 's/^ *//' | sed 's/ *$//')

            # Extract block amount and time separately
            # First get the full block part with time
            block_full=$(echo "$cost_section" | sed -n 's/.* \([^/]*\) block.*/\1/p' | sed 's/^ *//' | sed 's/ *$//')
            # Extract just the dollar amount (everything before the opening parenthesis or space)
            block_amount=$(echo "$block_full" | sed 's/ *(.*//')
            # Extract the time part (everything inside parentheses) - look for it in the full cost section
            block_time=$(echo "$cost_section" | sed -n 's/.*(\([^)]*\)).*/(\1)/p')

            # Reorder to: session / block / today without labels (without time)
            formatted_cost="${session_part} / ${block_amount} / ${today_part}"

            # Combine cost and burn sections, adding block time at the end if it exists
            if [ -n "$burn_section" ]; then
                if [ -n "$block_time" ]; then
                    echo "${formatted_cost} | ${burn_section} | ${block_time}"
                else
                    echo "${formatted_cost} | ${burn_section}"
                fi
            else
                if [ -n "$block_time" ]; then
                    echo "${formatted_cost} | ${block_time}"
                else
                    echo "$formatted_cost"
                fi
            fi
        else
            # Fallback if parsing failed - return the original cost part
            fallback=$(echo "$ccusage_output" | sed -E 's/^[^💰]*💰 //' | sed -E 's/ \| 🧠.*//')
            echo "$fallback"
        fi
    else
        echo "\$0.00 / N/A / \$0.00 | 🔥 \$0.00/hr"
    fi
}

# Extract context information from ccusage output
get_context_info() {
    local ccusage_output="$1"

    if [ -n "$ccusage_output" ]; then
        # Extract context part: 🧠 context
        context_part=$(echo "$ccusage_output" | sed -n 's/.*🧠 \([^|]*\).*/\1/p')
        if [ -n "$context_part" ]; then
            echo "$context_part"
        else
            # Fallback to file-based calculation if ccusage doesn't provide context
            get_context_usage_fallback
        fi
    else
        # Fallback to file-based calculation if ccusage is not available
        get_context_usage_fallback
    fi
}

# Fallback context calculation from transcript file (when ccusage doesn't provide context)
get_context_usage_fallback() {
    # Extract transcript path from JSON input
    transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

    # Check if transcript file exists and get its size
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        # Get file size in bytes
        size_bytes=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")

        # Calculate approximate tokens (1.8 characters per token - more accurate)
        # Based on real tokenization patterns: adjusted to match Claude Code's tokenization
        # Using integer arithmetic: multiply by 10 then divide by 18 for 1.8 ratio
        tokens=$((size_bytes * 10 / 18))

        # Calculate percentage of max context (assuming 200K max tokens)
        max_tokens=200000
        percentage_used=$((tokens * 100 / max_tokens))

        # Calculate percentage to auto-compact (assuming auto-compact at 80% = 160K tokens)
        compact_threshold=160000
        if [ $tokens -le $compact_threshold ]; then
            percentage_to_compact=$((tokens * 100 / compact_threshold))
        else
            percentage_to_compact=100
        fi

        # Format tokens with K/M suffixes
        if [ $tokens -ge 1000000 ]; then
            formatted_tokens="$(echo "scale=1; $tokens / 1000000" | bc -l)M"
        elif [ $tokens -ge 1000 ]; then
            formatted_tokens="$(echo "scale=1; $tokens / 1000" | bc -l)K"
        else
            formatted_tokens="$tokens"
        fi

        echo "~${formatted_tokens}/200K (~${percentage_used}%) | Use /context for actual data"
    else
        # Fallback if transcript file not found
        echo "0 (0%) | Use /context for actual data"
    fi
}

# Get current git branch
get_git_branch() {
    cd "$cwd" 2>/dev/null
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
        # Check if there are uncommitted changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo -e "\\033[33m⚡ ${branch}*\\033[0m"  # Yellow with asterisk for dirty
        else
            echo -e "\\033[32m🌿 ${branch}\\033[0m"   # Green for clean
        fi
    else
        echo -e "\\033[90m📁 No git repo\\033[0m"     # Gray for no repo
    fi
}


# Gather all data for the status lines
ccusage_output=$(get_ccusage_data)
cost_info=$(get_cost_info "$ccusage_output")
project_path=$(get_relative_path "$project_dir" "$current_dir")
project_name=$(basename "$project_dir")
git_info=$(get_git_branch)
context_usage_line=$(get_context_info "$ccusage_output")

# Output all 6 status lines
# Line 1: Model and output style
echo -e "\\033[1;30;47m ◉ \\033[0m ${model_name} | \\033[1;30;45m ✦ \\033[0m ${output_style}"

# Line 2: Project info and git branch
echo -e "\\033[1;30;43m ▲ \\033[0m ${project_name}\\033[36m${project_path}\\033[0m | ${git_info}"

# Line 3: Context usage
echo -e "\\033[1;30;44m ● \\033[0m Context: \\033[96m${context_usage_line}\\033[0m"

# Line 4: Cost information
echo -e "\\033[1;30;42m $ \\033[0m ${cost_info}"

# Line 5: Horizontal separator line
echo "-------------------------------"