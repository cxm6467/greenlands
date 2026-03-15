# Deployment Guide - Greenfield

## Local Network Access (Phone/Tablet)

### From Your Phone
Connect to the same WiFi network and visit:
```
http://172.21.67.178:8080
```

### Windows Firewall Fix
If connection fails, run in PowerShell (as Administrator):
```powershell
New-NetFirewallRule -DisplayName "Flutter Dev Server" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

---

## Free Web Hosting Options

### Option 1: Firebase Hosting (Recommended)
**Best for:** Production-ready hosting with automatic HTTPS

**Setup:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize in project directory
cd /home/caboose/dev/shire
firebase init hosting

# Build Flutter web
~/flutter/bin/flutter build web

# Deploy
firebase deploy
```

**Free Tier:**
- 10GB storage
- 360MB/day bandwidth
- Custom domain support
- Automatic HTTPS
- Global CDN

**Result:** Your app at `https://your-project.web.app`

---

### Option 2: Netlify
**Best for:** Quick deploys with drag-and-drop

**Setup:**
```bash
# Build Flutter web
~/flutter/bin/flutter build web

# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd /home/caboose/dev/shire/build/web
netlify deploy --prod
```

**Or use Web UI:**
1. Go to https://app.netlify.com
2. Drag and drop the `build/web` folder
3. Done!

**Free Tier:**
- 100GB bandwidth/month
- Automatic HTTPS
- Custom domain support
- Continuous deployment from Git

**Result:** Your app at `https://random-name.netlify.app`

---

### Option 3: Vercel
**Best for:** GitHub integration

**Setup:**
```bash
# Install Vercel CLI
npm install -g vercel

# Build Flutter web
~/flutter/bin/flutter build web

# Deploy
cd /home/caboose/dev/shire
vercel --prod
```

**Free Tier:**
- 100GB bandwidth
- Automatic HTTPS
- Custom domain
- Git integration

**Result:** Your app at `https://your-project.vercel.app`

---

### Option 4: GitHub Pages
**Best for:** Open source projects

**Setup:**
```bash
# Build Flutter web with base href
~/flutter/bin/flutter build web --base-href "/shire/"

# Create gh-pages branch
cd /home/caboose/dev/shire
git checkout -b gh-pages
git rm -rf .
cp -r build/web/* .
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages

# Enable in GitHub repo settings → Pages
```

**Free Tier:**
- Unlimited bandwidth for public repos
- Automatic HTTPS
- Custom domain support

**Result:** Your app at `https://yourusername.github.io/shire/`

---

### Option 5: Cloudflare Pages
**Best for:** Global performance

**Setup:**
```bash
# Install Wrangler CLI
npm install -g wrangler

# Build Flutter web
~/flutter/bin/flutter build web

# Deploy
wrangler pages publish build/web --project-name=greenfield
```

**Free Tier:**
- Unlimited bandwidth
- Unlimited requests
- Automatic HTTPS
- 500 builds/month

**Result:** Your app at `https://greenfield.pages.dev`

---

## Quick Deploy Script

Create a deployment script for easy updates:

```bash
#!/bin/bash
# deploy.sh

echo "🏰 Building Greenfield..."
~/flutter/bin/flutter build web

echo "📦 Deploying to Firebase..."
firebase deploy

echo "✨ Deployment complete!"
```

Make executable:
```bash
chmod +x deploy.sh
```

Run anytime:
```bash
./deploy.sh
```

---

## Recommended Choice

For **Greenfield**, I recommend:

1. **Development/Testing:** Local network access (already working!)
2. **Public Demo:** **Firebase Hosting** (best free tier, reliable, fast)
3. **Alternative:** **Netlify** (easiest setup, drag-and-drop)

Both Firebase and Netlify have excellent free tiers and won't shut down your app.

---

## Environment Variables for Production

Remember to set your `.env` values when deploying:
- Don't commit `.env` to Git!
- Use hosting platform's environment variable settings
- For Firebase: Use Firebase Functions environment config
- For Netlify/Vercel: Use dashboard environment variables

---

## Mobile App Distribution (Future)

When ready for native mobile builds:

### Android (APK)
```bash
~/flutter/bin/flutter build apk --release
# File at: build/app/outputs/flutter-apk/app-release.apk
```

**Free Distribution:**
- Google Play Store (one-time $25 fee)
- F-Droid (free, open source)
- Direct APK download from your website

### iOS (IPA)
```bash
~/flutter/bin/flutter build ios --release
```

**Distribution:**
- TestFlight (free beta testing via App Store Connect)
- App Store ($99/year Apple Developer Program)

---

## Next Steps

1. Try local network access from phone first
2. Choose a hosting platform (Firebase recommended)
3. Build for web: `flutter build web`
4. Deploy and share the link!
