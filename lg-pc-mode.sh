#!/bin/zsh
declare -i throttle_by=2
tmpdir=$(mktemp -d)

# Wait 2 seconds for the trigger to settle down before executing the command
debounce() {
  # Name of the command to check in the process list
  local cmd_name="debounce_$1"

  # If the command is already running, exit
  if pgrep -f "$cmd_name" > /dev/null; then
      return
  fi

  # Run the command in the background with a prefix for easy identification
  (sleep 2; "$@") &
}

# Wait for LGwebOSTV.local to appear for the _airplay._tcp service (usually happens on TV boot)
dns-sd -B _airplay._tcp local | while read -r line ; do
    printf '%s\n' "$line"
    if [[ $line == *Add*OLED42C24LA* ]]; then
    printf '%s\n' "LGwebOSTV.local found"
        debounce /opt/homebrew/bin/bscpylgtvcommand LGwebOSTV.local set_device_info HDMI_1 pc PC
        debounce /opt/homebrew/bin/bscpylgtvcommand LGwebOSTV.local set_device_info HDMI_2 pc HDMI
        debounce /opt/homebrew/bin/bscpylgtvcommand LGwebOSTV.local set_device_info HDMI_3 pc PC
        debounce /opt/homebrew/bin/bscpylgtvcommand LGwebOSTV.local set_device_info HDMI_4 pc PC
    fi
done