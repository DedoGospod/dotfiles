#!/usr/bin/env bash

# Swap to main branch
git switch main

# Merge branches
git merge testing

# Push changes
git push

# Switch back to testing
git switch testing
