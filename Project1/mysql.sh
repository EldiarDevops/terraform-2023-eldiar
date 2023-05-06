#!/bin/bash

sudo apt update -y
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb