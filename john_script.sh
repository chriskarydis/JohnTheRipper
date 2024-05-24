#!/bin/bash

# Define the path to john.conf
JOHN_CONF="/etc/john/john.conf"

# Function to add custom rules to john.conf
add_custom_rules() {
    local custom_rules=(
        "[List.Rules:Custom]"
        "cd"
    )
    
    for rule in "${custom_rules[@]}"; do
        if ! sudo grep -q "^$rule" "$JOHN_CONF"; then
            echo "$rule" | sudo tee -a "$JOHN_CONF" > /dev/null
        fi
    done
}

# Ensure the john.conf file is writable
sudo chmod +w "$JOHN_CONF"

# Add custom rules to john.conf if they don't already exist
add_custom_rules

# Revert the john.conf file back to read-only
sudo chmod -w "$JOHN_CONF"

# Ensure hashed_Passwords.txt exists
if [ ! -f hashed_Passwords.txt ]; then
    echo "Error: hashed_Passwords.txt not found!"
    exit 1
fi

# Command 1: Brute Force Attack for PINs
john --incremental=Digits --format=Raw-MD5 --fork=20 --min-length=1 --max-length=10 hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Command 2: Brute Force Attack for 6-character alphabetical passwords
john --incremental=alpha --format=Raw-MD5 --fork=20 --min-length=6 --max-length=6 hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Command 3: Simple Dictionary Attack
WORDLIST_URL="https://raw.githubusercontent.com/iam1980/greeklish-wordlist/master/gr_wordlist.txt"
WORDLIST_FILE="gr_wordlist.txt"

if [ ! -f "$WORDLIST_FILE" ]; then
    wget "$WORDLIST_URL" -O "$WORDLIST_FILE"
fi

john --wordlist="$WORDLIST_FILE" --format=Raw-MD5 --fork=20 hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Command 4: Password Walking Attack
john --external=Keyboard --format=raw-md5 --fork=20 hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Command 5: Dictionary Mask Attack
# Non-Dictionary mask attack for pattern "Capital letter + 4 small letters (last is 'a') + 4 digits + special character"
john --format=Raw-MD5 --fork=20 --mask='?u?l?l?la?d?d?d?d?s' hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Dictionary attack with an additional digit at the beginning
john --wordlist="$WORDLIST_FILE" --format=Raw-MD5 --fork=20 --mask='?d?w' hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Dictionary attack with four additional digits at the end
john --wordlist="$WORDLIST_FILE" --format=Raw-MD5 --fork=20 --mask='?w?d?d?d?d' hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Command 6: Dictionary with Custom Rule and Mask Attack
john --wordlist="$WORDLIST_FILE" --format=Raw-MD5 --fork=20 --mask='?w?d?d?d?s' --rules=Custom hashed_Passwords.txt
john --show --format=Raw-MD5 hashed_Passwords.txt

# Display cracked passwords from john.pot
cat ~/.john/john.pot
