# S3 Backup Manager

## Table of Contents
- [Introduction](#introduction)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [Configuration](#configuration)
- [Automate with Crontab](#automate-with-crontab)
- [Contribution](#contribution)

## Introduction
**S3 Backup Manager** is a command-line tool built using Bash. Its primary aim is to simplify the process of managing, backing up, restoring, and viewing files from an AWS S3 bucket. With the rise of data-driven applications and the need for data integrity and recovery, this tool becomes an indispensable utility for any system administrator or developer interacting with S3 buckets.

<img width="488" alt="image" src="https://github.com/hamid/s3-backup-manager/assets/1645233/53903b54-cbb7-44e4-b475-dfef9f0e1425">


## How It Works
This tool operates with a source bucket and a backup bucket:

1. **Source Bucket**: This is where your active data resides. Any files or directories in this bucket are what you would consider "live" or "production" data.

2. **Backup Bucket**: This bucket is the destination for all backup operations. The tool uses AWS's sync command to create backups into folders named after the current date. For example, a backup performed on the 15th of August, 2023 would reside in a folder named `2023-08-15`.

    Example Backup Bucket Structure:
    ```
    ├── 2023-08-12
    │   ├── file1.txt
    │   ├── file2.txt
    │   └── data/
    ├── 2023-08-13
    │   ├── file1.txt
    │   ├── file2.txt
    │   └── data/
    ├── 2023-08-14
    │   ├── file1.txt
    │   ├── file2.txt
    │   └── data/
    ```

3. **Backup**: Creates a snapshot of the source bucket and stores it into the backup bucket under a folder named with the current date.

4. **Restore**: Lets you select a specific date from the available backups and syncs its content to the source bucket, effectively restoring your data to that point in time.

5. **Show**: There are two show options: 
    - Show all files in the main source bucket.
    - Display all files of a selected backup.

## Installation

Before you begin, ensure you have the following installed:

1. **AWS CLI**: Install AWS CLI. Depending on your OS, the installation method may vary. Here's how you can install it on Ubuntu:
    ```bash
    sudo apt-get install awscli
    ```
    on the centos
    ```bash
    sudo pip install awscli --upgrade
    ```
Please note that you should have the last version of AWS-CLI so please check [official-aws-installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. **JQ**: This is a lightweight and flexible command-line JSON processor. 
    ```bash
    sudo apt-get install jq
    ```
    on the centos
    ```bash
    sudo yum install jq
    ```

4. **Backup Manager Script**: Ensure the `backup_manager.sh` script is present on your system and is executable. You can clone it from the repository and make it executable:
    ```bash
    git clone git@github.com:hamid/s3-backup-manager.git
    chmod +x backup_manager.sh
    ```

## Configuration

1. **AWS CLI Configuration**: Before you can use the tool, you must configure the AWS CLI with your credentials.
    ```bash
    aws configure
    ```
    Follow the prompts to input your AWS Access Key ID, Secret Access Key, default region, and default output format.

2. **Backup Configuration**: To keep your configuration tidy and separate from the main script, all configurations are stored in `backup_config.conf`. Open this file and replace the placeholders with the appropriate values for your setup. The script will source this file to get the configuration values.
```
# Define our buckets and folder
SOURCE_BUCKET="your-source-bucket-name"
BACKUP_BUCKET="your-backup-bucket-name"
BACKUP_FOLDER="file-backups"
CURRENT_DATE=$(date +\%Y-\%m-\%d)

```

## Automate with Crontab
To automate the backup process, you can leverage `crontab`. Here's an example of how you can set up the script to run automatically:

1. Open the crontab for editing:
    ```bash
    crontab -e
    ```

2. Add the following line to run the backup at 10:10 AM every day and then exit the script:
    ```
    10 10 * * * (echo "3"; sleep 2; echo "7") | /path/to/backup_manager.sh
    ```

    Remember to adjust the path and time according to your preferences.

## Contribution
If you think of a feature that would enhance this tool or encounter a bug, please raise an issue or submit a pull request. Your contributions are highly welcomed!
