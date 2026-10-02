#!/bin/bash

# Configuration settings
DRONE_IP="192.168.1.1"       # Replace with your drone's IP address
MAVLINK_PORT=14550          # Standard MAVLink UDP port
RTSP_PORT=554               # RTSP stream port
PYTHON_SCRIPT="marine_monitor.py"

echo "=========================================="
echo "    MARINE DRONE SYSTEM PRE-FLIGHT CHECK   "
echo "=========================================="

# 1. Check Python installation
echo -n "[1/5] Checking Python installation... "
if command -v python3 &>/dev/null; then
    echo "OK ($(python3 --version))"
else
    echo "FAILED! Please install Python 3."
    exit 1
fi

# 2. Check Python packages
echo -n "[2/5] Checking required Python packages... "
python3 -c "import cv2, numpy" &>/dev/null
if [ $? -eq 0 ]; then
    echo "OK"
else
    echo "MISSING! Installing opencv-python and numpy..."
    pip3 install opencv-python numpy
fi

# 3. Check IP connection to Drone
echo -n "[3/5] Pinging Drone at $DRONE_IP... "
ping -c 2 $DRONE_IP &>/dev/null
if [ $? -eq 0 ]; then
    echo "CONNECTED"
else
    echo "WARNING: Drone unreachable at $DRONE_IP. (Continuing in offline/simulation mode)"
fi

# 4. Check Telemetry / RTSP Ports
echo -n "[4/5] Checking telemetry port ($MAVLINK_PORT)... "
nc -z -v -w5 $DRONE_IP $MAVLINK_PORT &>/dev/null
if [ $? -eq 0 ]; then
    echo "PORT OPEN"
else
    echo "CLOSED/NO SIGNAL"
fi

# 5. Launch Python Script
echo "[5/5] Executing Python Monitor Pipeline..."
echo "------------------------------------------"
python3 $PYTHON_SCRIPT

echo "------------------------------------------"
echo "[COMPLETE] Verification and run completed."
