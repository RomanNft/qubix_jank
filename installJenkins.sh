#!/bin/bash

# Додаємо ключ Jenkins до системи
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Додаємо репозиторій Jenkins до списку джерел
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Оновлюємо список пакетів
sudo apt-get update

# Встановлюємо необхідні пакети
sudo apt-get install -y fontconfig openjdk-17-jre
sudo apt-get install -y jenkins

# Перезапускаємо Jenkins
sudo systemctl restart jenkins

# Додаємо користувача Jenkins до групи Docker (припустимо, що Docker вже встановлений)
sudo usermod -aG docker jenkins

# Перезапускаємо Jenkins для застосування змін
sudo service jenkins restart

# Виводим пароль:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
