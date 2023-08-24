#!/bin/bash

# S3 Backup Manager
#
# This script provides functionalities to backup, restore, and manage files from an AWS S3 bucket.
# Developer: Hamid Reza Salimian
# Repository: https://github.com/hamid/s3-backup-manager
# Email: xsx.hamid@gmail.com
#
# Make sure to configure the backup_manager.conf before executing this script.

# Source the configuration file
source backup_manager.conf

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
RESET='\033[0m'
DIVIDER="-------------------------------------------"

# Function to display a message
print_message() {
    color=$1
    message=$2
    echo -e "${color}${message}${RESET}"
    echo -e "${DIVIDER}\n"
}

# Function to display a boxed message
print_boxed_message() {
    color=$1
    message=$2
    echo -e "${color}+${DIVIDER}+"
    echo "| ${message} |"
    echo -e "+${DIVIDER}+\n${RESET}"
}

# Global array to store the list of backups
declare -a backups

# Function to update the global list of available backups
update_backups() {
    backups=($(aws s3 ls s3://$BACKUP_BUCKET/$BACKUP_FOLDER/ | awk '{print $NF}' | sed '/^$/d'))
}

# Function to display the list of backups
show_backups() {
    update_backups
    print_message "${BLUE}" "Available Backups:"
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[i]}"
    done
    echo -e "\n\n"
}

# Function to select a backup from the global list
select_backup() {
    print_message "${BLUE}" "\nAvailable Backups:"
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[i]}"
    done
    echo -e "\n\n"
    read -p "Select a backup by number: " choice
    if [[ "$choice" -ge 1 && "$choice" -le "${#backups[@]}" ]]; then
        SELECTED_FOLDER="${backups[$((choice-1))]}"
    else
        echo "Invalid choice."
        exit 1
    fi
}

# Function to restore a backup
restore_backup() {
    update_backups
    select_backup
    aws s3 sync s3://$BACKUP_BUCKET/$BACKUP_FOLDER/$SELECTED_FOLDER s3://$SOURCE_BUCKET/ --delete
    if [ $? -eq 0 ]; then
        print_boxed_message "${GREEN}" "Restoration from $SELECTED_FOLDER successful."
    else
        print_message "${RED}" "Restoration failed. Please check and try again."
    fi
}

# Function to create a backup
create_backup() {
    aws s3 sync s3://$SOURCE_BUCKET/ s3://$BACKUP_BUCKET/$BACKUP_FOLDER/$CURRENT_DATE --exclude "backups/*"
    if [ $? -eq 0 ]; then
        print_boxed_message "${GREEN}" "Backup successful. New folder $CURRENT_DATE created."
    else
        print_message "${RED}" "Backup failed. Please check and try again."
    fi
}

# Function to show all files of main bucket
show_files_main_bucket() {
    aws s3 ls s3://$SOURCE_BUCKET/
}

# Function to show all files of a selected backup
show_files_backup() {
    update_backups
    select_backup
    aws s3 ls s3://$BACKUP_BUCKET/$BACKUP_FOLDER/$SELECTED_FOLDER
}

# Main menu
while true; do
    print_message "${BLUE}" "Backup Manager"
    echo "1. Show available backups"
    echo "2. Restore"
    echo "3. Backup"
    echo "4. Show All files of Main Bucket"
    echo "5. Show All files of backups"
    echo "6. Exit"
    echo -n "Please select an option [1-6]: "
    read option

    case $option in
        1) show_backups ;;
        2) restore_backup ;;
        3) create_backup ;;
        4) show_files_main_bucket ;;
        5) show_files_backup ;;
        6) exit 0 ;;
        *) print_message "${RED}" "Invalid option, please try again." ;;
    esac
done
