# GitHub Pages Setup - Quick Reference

## ✅ What Has Been Created

1. **GitHub Actions Workflow** (`.github/workflows/deploy-mastermine.yml`)
   - Automatically deploys Mastermine to GitHub Pages
   - Triggers on push to `main` branch when Mastermine files change
   - Can also be manually triggered from Actions tab

2. **Deployment Documentation** (`DEPLOYMENT.md`)
   - Complete guide for setup and usage
   - Troubleshooting tips
   - Advanced deployment options

3. **Updated .gitignore Files**
   - Root `.gitignore` - excludes build artifacts
   - Mastermine `.gitignore` - excludes temporary files

## 🚀 Setup Instructions (3 Steps)

### Step 1: Enable GitHub Pages
1. Go to your repo → **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. Click Save

### Step 2: Push to GitHub
```bash
git add .
git commit -m "Add GitHub Pages deployment for Mastermine"
git push origin main
```

### Step 3: Wait for Deployment
- Go to **Actions** tab to see deployment progress
- Once complete (green checkmark), your files will be live!

## 🌐 Your Deployed URLs

After deployment, access your files at:

```
https://YOUR-USERNAME.github.io/Mastermine/
https://YOUR-USERNAME.github.io/Mastermine/mastermine.lua
```

**Replace `YOUR-USERNAME` with your GitHub username!**

## 🐢 Usage in ComputerCraft

Once deployed, players can install Mastermine with:

```lua
wget https://YOUR-USERNAME.github.io/Mastermine/mastermine.lua
mastermine.lua disk
disk/hub.lua
```

## 📁 What Gets Deployed

The workflow deploys:
- ✅ `mastermine.lua` - The main bundled installer
- ✅ `hub.lua`, `turtle.lua`, `pocket.lua` - Setup scripts
- ✅ All files from `hub_files/`, `turtle_files/`, `pocket_files/`
- ✅ `README.md` and `LICENSE`
- ✅ Beautiful web interface at `/Mastermine/` for browsing

## 🔄 How It Works

1. **You push code** → Workflow triggers
2. **GitHub Actions builds** → Copies files to `_site/Mastermine/`
3. **GitHub Pages deploys** → Files become accessible via HTTPS
4. **Players use wget** → Downloads work just like GitHub raw files!

## 🎯 Key Features

- ✅ Works with `wget` in ComputerCraft
- ✅ Automatic deployment on push
- ✅ Clean URLs (no `.html` needed)
- ✅ Web interface for browsing files
- ✅ Serves files as plain text (raw format)
- ✅ No rate limits (unlike Pastebin)

## ⚠️ Important Notes

1. **First deployment takes ~5 minutes** after enabling Pages
2. **URLs are case-sensitive** - use exact capitalization
3. **HTTP must be enabled** in CC:Tweaked config for `wget` to work
4. **Changes take ~1-2 minutes** to deploy after pushing

## 🔧 Updating Files

Just edit and push! The workflow automatically:
1. Detects changes in `programs/perlytiara/Mastermine/`
2. Rebuilds the deployment
3. Publishes updates to GitHub Pages

## 📝 Next Steps

1. Enable GitHub Pages in your repo settings
2. Push this commit to GitHub
3. Wait for deployment to complete
4. Test the URL in a browser
5. Update your README with the new installation instructions!

## 💡 Pro Tips

- **Bookmark** the Actions tab to monitor deployments
- **Update README.md** with your GitHub Pages URL
- **Share** the URL in your video descriptions
- **Monitor** in Insights → Traffic to see downloads

## 🆘 Need Help?

Check `DEPLOYMENT.md` for:
- Detailed troubleshooting
- Advanced configuration
- Custom domain setup
- Manual deployment options

---

**Ready?** Enable GitHub Pages and push to deploy! 🚀

