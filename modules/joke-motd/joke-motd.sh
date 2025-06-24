#!/usr/bin/env bash

CACHE_FILE="/tmp/motd-joke.txt"
LOCK_FILE="/tmp/motd-joke.lock"

# Function to fetch a new joke
fetch_joke() {
  local temp_file="/tmp/motd-joke.tmp"
  
  # Try to fetch a joke from icanhazdadjoke API (more reliable)
  if @curl@/bin/curl -s -m 10 -H "Accept: text/plain" "https://icanhazdadjoke.com/" > "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
    # Ensure there's a newline at the end
    echo "" >> "$temp_file"
    mv "$temp_file" "$CACHE_FILE"
  # Try the original JokeAPI as fallback
  elif @curl@/bin/curl -s -m 10 "https://official-joke-api.appspot.com/random_joke" | @jq@/bin/jq -r '"\(.setup) \(.punchline)"' 2>/dev/null > "$temp_file" && [ -s "$temp_file" ] && [ "$(cat "$temp_file")" != "null null" ]; then
    # Ensure there's a newline at the end
    echo "" >> "$temp_file"
    mv "$temp_file" "$CACHE_FILE"
  else
    # Fallback joke if API is unavailable
    echo "Why do programmers prefer dark mode? Because light attracts bugs! 🐛" > "$CACHE_FILE"
  fi
  
  rm -f "$temp_file"
}

# Main execution: Check if we need to refresh the joke (if file doesn't exist or is older than 10 minutes)
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt 600 ]; then
  # Use flock to prevent multiple simultaneous fetches
  (
    @util-linux@/bin/flock -n 200 || exit 1
    fetch_joke
  ) 200>"$LOCK_FILE"
fi

# Display welcome message with system info and joke  
echo ""
echo "╭─────────────────────────────────────────────────────────────╮"
echo "│  🖥️  Welcome to $(@nettools@/bin/hostname)                                    │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│  📊 System Information                                      │"
echo "├─────────────────────────────────────────────────────────────┤"

# Uptime (using simpler approach)
uptime_info=$(@coreutils@/bin/cat /proc/uptime | @gawk@/bin/awk '{print int($1/86400)"d "int($1%86400/3600)"h "int($1%3600/60)"m"}')
printf "│  ⏱️  Uptime: %-44s │\n" "$uptime_info"

# Load average
load_avg=$(@coreutils@/bin/cat /proc/loadavg | @coreutils@/bin/cut -d' ' -f1-3)
printf "│  📈 Load: %-46s │\n" "$load_avg"

# Memory usage
memory=$(@procps@/bin/free -h | @gawk@/bin/awk 'NR==2{printf "%s/%s", $3, $2}')
printf "│  🧠 Memory: %-44s │\n" "$memory"

# Disk usage
disk=$(@coreutils@/bin/df -h / | @gawk@/bin/awk 'NR==2{print $3"/"$2}')
printf "│  💾 Disk: %-46s │\n" "$disk"

echo "├─────────────────────────────────────────────────────────────┤"
echo "│  💡 Daily Dose of Humor                                     │"
echo "╰─────────────────────────────────────────────────────────────╯"

# Display the cached joke or fallback
if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
  echo ""
  # Simple word wrapping without external tools
  while IFS= read -r line; do
    echo "   $line"
  done < "$CACHE_FILE"
  echo ""
else
  echo ""
  echo "   Why do programmers prefer dark mode?"
  echo "   Because light attracts bugs! 🐛"
  echo ""
fi
