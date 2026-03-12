#!/bin/bash
# Deploy The Greenlands to Firebase Hosting

set -e  # Exit on error

echo "🏰 Building The Greenlands for production..."
~/flutter/bin/flutter build web

echo ""
echo "📦 Deploying to Firebase Hosting..."
firebase deploy

echo ""
echo "✨ Deployment complete!"
echo ""
echo "Your app is now live at:"
firebase hosting:channel:list | grep -A 1 "live" || echo "Run 'firebase open hosting' to see your live URL"
