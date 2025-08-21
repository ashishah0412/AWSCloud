#!/bin/bash
sudo apt update -y
sudo apt install -y apache2 php libapache2-mod-php php-mysql
sudo systemctl start apache2
sudo systemctl enable apache2

# Replace with your actual S3 bucket name for app code
aws s3 sync s3://YOUR_APP_CODE_S3_BUCKET_NAME/web-app/ /var/www/html/

# Update database connection details in config.php
sudo sed -i "s/DB_HOST_PLACEHOLDER/${aws_db_instance.main.address}/g" /var/www/html/config.php
sudo sed -i "s/DB_NAME_PLACEHOLDER/${var.db_name}/g" /var/www/html/config.php
sudo sed -i "s/DB_USER_PLACEHOLDER/${var.db_username}/g" /var/www/html/config.php
sudo sed -i "s/DB_PASSWORD_PLACEHOLDER/${var.db_password}/g" /var/www/html/config.php

sudo systemctl restart apache2


