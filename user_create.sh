#!/bin/bash

# ==============================
# Linux User & Group Management Script
# ==============================

CSV_FILE="users.csv"
LOG_DIR="./logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/user-creation-$TIMESTAMP.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

echo "🔧 Starting user provisioning - $TIMESTAMP" | tee -a "$LOG_FILE"

# Read CSV line by line (skip header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username group ssh_key; do

  echo "Processing user: $username" | tee -a "$LOG_FILE"

  # Create group if it doesn't exist
  if ! getent group "$group" > /dev/null; then
    groupadd "$group"
    echo "✅ Group '$group' created." | tee -a "$LOG_FILE"
  else
    echo "ℹ️ Group '$group' already exists." | tee -a "$LOG_FILE"
  fi

  # Create user if it doesn't exist
  if ! id "$username" &>/dev/null; then
    useradd -m -s /bin/bash -g "$group" "$username"
    echo "✅ User '$username' created and added to group '$group'." | tee -a "$LOG_FILE"
  else
    echo "⚠️ User '$username' already exists." | tee -a "$LOG_FILE"
  fi

done

echo "✅ Script complete. Log saved to $LOG_FILE"

