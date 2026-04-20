#!/bin/bash
while true; do
  cd ~/Downloads/restaurant_universal_app
  git add .
  if git diff --cached --quiet; then
    sleep 10
  else
    git commit -m "auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin main
    sleep 10
  fi
done
