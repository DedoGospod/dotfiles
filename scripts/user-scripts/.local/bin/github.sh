#!/bin/bash

# Define the Git configuration settings
GIT_EMAIL="dylanlazarov2002@protonmail.com"
GIT_NAME="DedoGospod"
GIT_HELPER="libsecret"

echo "Starting Git configuration setup..."

# 1. Set the user.email globally
git config --global user.email "$GIT_EMAIL"
if git config --global user.email "$GIT_EMAIL"; then
    echo "✅ user.email set to $GIT_EMAIL"
else
    echo "❌ Error setting user.email"
    exit 1
fi

# 2. Set the user.name globally
git config --global user.name "$GIT_NAME"
if git config --global user.name "$GIT_NAME"; then
    echo "✅ user.name set to $GIT_NAME"
else
    echo "❌ Error setting user.name"
    exit 1
fi

# 3. Set the credential.helper globally
git config --global credential.helper "$GIT_HELPER"
if git config --global credential.helper "$GIT_HELPER"; then
    echo "✅ credential.helper set to $GIT_HELPER"
else
    echo "❌ Error setting credential.helper"
    echo "   (This may be expected if 'libsecret' support isn't installed.)"
fi

echo -e "\nConfiguration complete! Current global settings:"
git config --list --global | grep -E 'user.email|user.name|credential.helper'
