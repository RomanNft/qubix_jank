#!/bin/bash

# Встановлення Docker та Docker Compose
sudo apt install docker.io -y
sudo snap install docker

# Встановлення .NET SDK
sudo snap install dotnet-sdk --classic
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0

# Встановлення postgresql-client
sudo apt-get install -y postgresql-client

# Встановлення dotnet-ef
dotnet tool install --global dotnet-ef
export PATH="$PATH:/root/.dotnet/tools"

# Виведення шляху для перевірки
echo $PATH
# Права на використання
cd /home/roman/facebook-server/
chmod +x wait-for-postgres.sh
# Запуск Docker Compose для всіх сервісів
cd /home/roman
docker-compose up -d
