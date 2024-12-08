#!/bin/bash

# -------------------------------
# 1️⃣ Check for Required Packages
# -------------------------------

echo "📦 Checking for required system packages..."
sudo apt update && sudo apt install -y git curl jq

# -------------------------------
# 2️⃣ Set GitHub Username and Email
# -------------------------------

read -p "Enter your GitHub username: " github_username
read -p "Enter your GitHub email (used for commits): " github_email

echo "📦 Configuring git user information..."
git config --global user.name "$github_username"
git config --global user.email "$github_email"

# -------------------------------
# 3️⃣ Generate SSH Key (if it doesn't exist)
# -------------------------------

if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔐 Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$github_email" -N "" -f ~/.ssh/id_rsa
    echo "✅ SSH key created."
else
    echo "🔐 SSH key already exists, skipping generation."
fi

# -------------------------------
# 4️⃣ Display the SSH Key and Prompt to Add It to GitHub
# -------------------------------

echo "🔑 Here is your public SSH key (copy it and add it to your GitHub account):"
cat ~/.ssh/id_rsa.pub

echo ""
echo "👉 Go to https://github.com/settings/keys"
echo "👉 Click 'New SSH Key'"
echo "👉 Paste the SSH key you just copied"
echo ""
read -p "Press ENTER once you've added the SSH key to GitHub..."

# -------------------------------
# 5️⃣ Create a New Repository on GitHub
# -------------------------------

read -p "Enter the name of your new GitHub repository (e.g., sonification-project): " repo_name

# Check if GitHub Personal Access Token (PAT) exists
if [ ! -f ~/.github_pat ]; then
    echo "🚀 You need a GitHub Personal Access Token to create the repository."
    echo "👉 Go to https://github.com/settings/tokens"
    echo "👉 Click 'Generate new token (classic)'"
    echo "👉 Enable 'repo' permissions and copy the token"
    read -p "Enter your GitHub Personal Access Token (PAT): " github_pat

    # Save the token for future use
    echo $github_pat > ~/.github_pat
else
    echo "🔐 Using saved GitHub PAT from ~/.github_pat"
    github_pat=$(cat ~/.github_pat)
fi

# Create the GitHub repository using the GitHub API
echo "🌐 Creating new GitHub repository: $repo_name"
response=$(curl -s -H "Authorization: token $github_pat" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"name\":\"$repo_name\", \"private\":false}" \
    https://api.github.com/user/repos)

# Extract the clone URL from the response
clone_url=$(echo $response | jq -r .ssh_url)

if [[ "$clone_url" == "null" ]]; then
    echo "❌ Failed to create GitHub repository. Check your PAT or permissions."
    exit 1
else
    echo "✅ Successfully created GitHub repository: $clone_url"
fi

# -------------------------------
# 6️⃣ Set up Local Git Repository
# -------------------------------

cd ~/sensorial-hybrids

echo "📦 Initializing local git repository..."
git init

echo "📦 Adding remote origin for $repo_name..."
git remote add origin $clone_url

# Create .gitignore to exclude unnecessary files
echo "venv/" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo "*.pyo" >> .gitignore

# Add all files to the repository
git add .
git commit -m "Initial commit: Added setup.sh, requirements.txt, and .gitignore"

# -------------------------------
# 7️⃣ Push Files to GitHub
# -------------------------------

echo "🚀 Pushing files to GitHub..."
git branch -M main
git push -u origin main

echo "✅ All files have been successfully pushed to GitHub!"
echo "🌐 View your repository at: https://github.com/$github_username/$repo_name"
