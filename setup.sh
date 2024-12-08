#!/bin/bash

set -e  # Exit on any error

echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing global libraries from global-libraries.txt..."
if [ ! -f global-libraries.txt ]; then
    echo "❌ ERROR: global-libraries.txt not found!"
    exit 1
fi

while read -r library; do
    if [ -n "$library" ] && [[ ! "$library" =~ ^# ]]; then  # Ignore empty lines and comments
        echo "📦 Installing: $library"
        sudo apt install -y $library
    fi
done < global-libraries.txt

echo "📦 Creating and activating Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Virtual environment created."
else
    echo "⚠️ Virtual environment already exists. Skipping creation."
fi

source venv/bin/activate

echo "📦 Upgrading pip..."
pip install --upgrade pip

echo "📦 Installing Python dependencies from requirements.txt..."
if [ ! -f requirements.txt ]; then
    echo "❌ ERROR: requirements.txt not found!"
    exit 1
fi
pip install -r requirements.txt

echo "📂 Loading sensitive environment variables from config.env"
if [ -f config.env ]; then
    export $(grep -v '^#' config.env | xargs)
else
    echo "⚠️ WARNING: config.env not found! Create it using config.env.example."
fi

echo "🔗 Linking global libraries to venv for OpenCV access..."
echo "import site; site.addsitedir('/usr/lib/python3/dist-packages')" >> venv/lib/python3.11/site-packages/global-packages.pth

echo "✅ Setup complete! Run this to activate the venv in the future:"
echo "source venv/bin/activate"

