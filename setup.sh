#!/bin/bash

echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing global libraries..."
while read -r library; do
    echo "Installing: $library"
    sudo apt install -y $library
done < global-libraries.txt

echo "📦 Creating and activating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "📦 Installing Python dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

echo "📂 Loading sensitive environment variables from config.env"
if [ -f config.env ]; then
    export $(grep -v '^#' config.env | xargs)
else
    echo "⚠️ WARNING: config.env not found! Create it using config.env.example."
fi

echo "✅ Setup complete! Run this to activate the venv in the future:"
echo "source venv/bin/activate"
