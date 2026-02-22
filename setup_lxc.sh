#!/bin/bash

# בדיקה שהסקריפט רץ כ-root
if [ "$EUID" -ne 0 ]; then 
  echo "אנא הרץ את הסקריפט כ-root (sudo)"
  exit
fi

echo "=== הגדרת LXC חדש (גרסה מודולרית ל-GitHub) ==="

# 1. קבלת קלט בסיסי מהמשתמש
read -p "הכנס שם משתמש חדש: " NEW_USER
read -s -p "הכנס סיסמה למשתמש: " PASSWORD
echo ""

# 2. שאלות התקנה אופציונליות
read -p "האם להתקין Docker? (y/n): " INSTALL_DOCKER
read -p "האם להתקין Tailscale? (y/n): " INSTALL_TAILSCALE

# 3. עדכון המערכת והתקנת כלים בסיסיים
echo "מעדכן חבילות ומערכת..."
apt update && apt upgrade -y
apt install -y sudo curl wget git vim htop zsh # Zsh הוא ברירת המחדל המועדפת עליך

# 4. יצירת המשתמש והגדרת הרשאות
echo "יוצר משתמש: $NEW_USER..."
useradd -m -s /bin/zsh "$NEW_USER"
echo "$NEW_USER:$PASSWORD" | chpasswd
usermod -aG sudo "$NEW_USER"

# 5. התקנת Docker (אופציונלי)
if [[ "$INSTALL_DOCKER" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "מתקין Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker "$NEW_USER" # מאפשר עבודה עם דוקר ללא sudo
    rm get-docker.sh
else
    echo "מדלג על התקנת Docker."
fi

# 6. התקנת Tailscale (אופציונלי)
if [[ "$INSTALL_TAILSCALE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "מתקין Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "מדלג על התקנת Tailscale."
fi

# 7. הגדרת ZSH כברירת מחדל
chsh -s /bin/zsh "$NEW_USER"

echo "=== ההתקנה הסתיימה בהצלחה! ==="
echo "1. התחבר כמשתמש החדש: su - $NEW_USER"
if [[ "$INSTALL_TAILSCALE" == "y" ]]; then echo "2. חבר את Tailscale: sudo tailscale up"; fi
