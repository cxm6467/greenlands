# Firebase Hosting - Quick Start Guide

## ✅ Already Complete

I've already done the following for you:
1. ✅ Installed Firebase CLI
2. ✅ Built production web version
3. ✅ Created `firebase.json` configuration
4. ✅ Set up `.firebaserc` template
5. ✅ Updated `.gitignore` for Firebase

## 🚀 Next Steps (You Need to Do This)

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or use an existing project
3. Follow the setup wizard:
   - Enter project name: `the-greenlands` (or any name you prefer)
   - Google Analytics: Optional (you can disable for simplicity)
4. Wait for project creation to complete
5. **Copy your Project ID** (shown in project settings)

### Step 2: Login to Firebase

Run this command in WSL2:
```bash
cd /home/caboose/dev/shire
firebase login
```

This will:
- Open a browser window
- Ask you to authenticate with your Google account
- Grant Firebase CLI access

**Note:** If you're in WSL2 and the browser doesn't open automatically, use:
```bash
firebase login --no-localhost
```
Then follow the URL it provides.

### Step 3: Link Your Project

Edit the `.firebaserc` file and replace `your-project-id-here` with your actual Firebase Project ID:

```json
{
  "projects": {
    "default": "the-greenlands"
  }
}
```

Or run:
```bash
firebase use --add
```
And select your project from the list.

### Step 4: Deploy!

```bash
firebase deploy
```

That's it! 🎉

You'll get a URL like:
```
https://the-greenlands.web.app
https://the-greenlands.firebaseapp.com
```

## 🔄 Future Deployments

Whenever you make changes and want to redeploy:

```bash
# 1. Build the updated web version
~/flutter/bin/flutter build web

# 2. Deploy to Firebase
firebase deploy
```

Or use the convenience script I created:

```bash
./deploy.sh
```

## 📱 Custom Domain (Optional)

After deployment, you can add a custom domain in Firebase Console:
1. Go to Hosting section
2. Click "Add custom domain"
3. Follow DNS configuration steps
4. Firebase provides free SSL certificates!

## 🎮 Your App URLs

After deployment, your app will be available at:
- **Primary:** https://YOUR-PROJECT-ID.web.app
- **Alternate:** https://YOUR-PROJECT-ID.firebaseapp.com

Both URLs will work identically.

## 🐛 Troubleshooting

### Error: "No project active"
Run: `firebase use --add` and select your project

### Error: "Permission denied"
Run: `firebase login` to re-authenticate

### Error: "hosting: Deploy Error"
Check that `build/web` directory exists by running `flutter build web` first

## 📊 Monitoring

View your app's usage in Firebase Console:
- Real-time visitors
- Bandwidth usage
- Error logs
- Performance metrics

Free tier limits:
- ✅ 10GB storage
- ✅ 360MB/day bandwidth
- ✅ Custom domain
- ✅ Automatic SSL

---

## Need Help?

Check the full deployment guide: `DEPLOYMENT_GUIDE.md`

Firebase Hosting Docs: https://firebase.google.com/docs/hosting
