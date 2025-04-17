#!/bin/bash

# ==============================
# Linux User & Group Management Script (DRY RUN MODE)
# ==============================

CSV_FILE="users.csv"
LOG_DIR="./logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/user-creation-$TIMESTAMP.log"
DRY_RUN=true  # Set to false to actually create users

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

echo "🔧 Starting user provisioning - $TIMESTAMP" | tee -a "$LOG_FILE"

# Read CSV (skip header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username group ssh_key status; do

  echo "\n🔍 Processing user: $username" | tee -a "$LOG_FILE"

  # Group creation
  if ! getent group "$group" > /dev/null; then
    if [ "$DRY_RUN" = true ]; then
      echo "💡 [DRY RUN] Would create group: $group" | tee -a "$LOG_FILE"
    else
      groupadd "$group"
      echo "✅ Group '$group' created." | tee -a "$LOG_FILE"
    fi
  else
    echo "ℹ️ Group '$group' already exists." | tee -a "$LOG_FILE"
  fi

  # User creation
  if ! id "$username" &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
      echo "💡 [DRY RUN] Would create user: $username and add to group: $group" | tee -a "$LOG_FILE"
    else
      useradd -m -s /bin/bash -g "$group" "$username"
      echo "✅ User '$username' created and added to group '$group'." | tee -a "$LOG_FILE"
    fi
  else
    echo "⚠️ User '$username' already exists." | tee -a "$LOG_FILE"
  fi

  # SSH key handling
  if [[ -n "$ssh_key" ]]; then
    if [ "$DRY_RUN" = true ]; then
      echo "💡 [DRY RUN] Would add SSH key for $username" | tee -a "$LOG_FILE"
    else
      USER_HOME="/home/$username"
      SSH_DIR="$USER_HOME/.ssh"
      AUTH_KEYS="$SSH_DIR/authorized_keys"

      mkdir -p "$SSH_DIR"
      echo "$ssh_key" > "$AUTH_KEYS"
      chown -R "$username":"$group" "$SSH_DIR"
      chmod 700 "$SSH_DIR"
      chmod 600 "$AUTH_KEYS"

      echo "🔑 SSH key added for user '$username'." | tee -a "$LOG_FILE"
    fi
  else
    echo "ℹ️ No SSH key provided for '$username'." | tee -a "$LOG_FILE"
  fi

  # Status: active or locked
  if [ "$DRY_RUN" = true ]; then
    if [[ "$status" == "ACTIVE" ]]; then
      echo "💡 [DRY RUN] Would set default password and expire for $username" | tee -a "$LOG_FILE"
    else
      echo "💡 [DRY RUN] Would lock account for $username" | tee -a "$LOG_FILE"
    fi
  else
    if [[ "$status" == "ACTIVE" ]]; then
      echo "$username:TempP@ss123" | chpasswd
      passwd --expire "$username"
      echo "🔓 Account for '$username' is active with a default password." | tee -a "$LOG_FILE"
    else
      usermod --lock "$username"
      echo "🔒 Account for '$username' has been locked." | tee -a "$LOG_FILE"
    fi
  fi

done

echo -e "\n✅ Script complete. Log saved to $LOG_FILE"
