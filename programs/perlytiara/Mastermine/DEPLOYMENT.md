# Mastermine GitHub Pages Deployment Guide

This guide explains how to deploy Mastermine to GitHub Pages so it can be accessed via `wget` in ComputerCraft.

## Setup Steps

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Save the changes

### 2. Trigger Deployment

The deployment will automatically trigger when you:
- Push changes to the `main` branch that affect files in `programs/perlytiara/Mastermine/`
- Manually trigger the workflow from the **Actions** tab

### 3. Access Your Deployed Files

Once deployed, your files will be available at:

```
https://YOUR-USERNAME.github.io/Mastermine/mastermine.lua
https://YOUR-USERNAME.github.io/Mastermine/
```

Replace `YOUR-USERNAME` with your actual GitHub username.

## Usage in ComputerCraft

### Quick Install

In ComputerCraft, run:

```lua
wget https://YOUR-USERNAME.github.io/Mastermine/mastermine.lua
mastermine.lua disk
disk/hub.lua
```

### Individual File Access

You can also download individual files:

```lua
-- Download hub files
wget https://YOUR-USERNAME.github.io/Mastermine/hub_files/startup.lua startup.lua

-- Download turtle files
wget https://YOUR-USERNAME.github.io/Mastermine/turtle_files/actions.lua actions.lua

-- Download pocket files
wget https://YOUR-USERNAME.github.io/Mastermine/pocket_files/info.lua info.lua
```

## File Structure

The deployment creates the following structure:

```
Mastermine/
├── index.html              # Web interface for browsing files
├── mastermine.lua          # Main bundled installer
├── hub.lua                 # Hub setup script
├── turtle.lua              # Turtle setup script
├── pocket.lua              # Pocket computer setup script
├── README.md               # Documentation
├── LICENSE                 # MIT License
├── hub_files/              # All hub computer files
│   ├── startup.lua
│   ├── config.lua
│   ├── whosmineisitanyway.lua
│   └── ...
├── turtle_files/           # All turtle files
│   ├── startup.lua
│   ├── actions.lua
│   ├── basics.lua
│   └── ...
└── pocket_files/           # All pocket computer files
    ├── startup.lua
    ├── info.lua
    └── ...
```

## Customization

### Update URLs in README

After deployment, update the README.md to include your specific GitHub Pages URL:

1. Edit `programs/perlytiara/Mastermine/README.md`
2. Replace the pastebin instructions with your GitHub Pages URL
3. Commit and push the changes

### Custom Domain (Optional)

If you want to use a custom domain:

1. Go to **Settings** → **Pages**
2. Add your custom domain under **Custom domain**
3. Update DNS records as instructed
4. Update URLs in documentation accordingly

## Troubleshooting

### Deployment Failed

- Check the **Actions** tab for error details
- Ensure GitHub Pages is enabled in repository settings
- Verify file paths in the workflow are correct

### Files Not Accessible

- Wait a few minutes after deployment completes
- Clear browser cache
- Check that files exist in the `_site` artifact

### wget Not Working in ComputerCraft

- Verify the URL is correct (case-sensitive)
- Ensure the turtle/computer has a modem attached
- Check that HTTP is enabled in CC:Tweaked config
- Try accessing the URL in a browser first to confirm it works

## Advanced: Manual Deployment

If you prefer to deploy manually:

1. Build the site locally:
   ```bash
   mkdir -p _site/Mastermine
   cp -r programs/perlytiara/Mastermine/* _site/Mastermine/
   ```

2. Push to `gh-pages` branch:
   ```bash
   git checkout --orphan gh-pages
   git rm -rf .
   cp -r _site/* .
   git add .
   git commit -m "Deploy Mastermine"
   git push origin gh-pages
   ```

3. Configure Pages to use `gh-pages` branch

## Security Considerations

- The deployed files are **publicly accessible**
- Do not include sensitive configuration in committed files
- Consider using environment variables for server-specific settings
- Review all files before deployment

## Monitoring

- Check deployment status in the **Actions** tab
- View deployment history in **Settings** → **Pages**
- Monitor traffic in **Insights** → **Traffic** (if available)

## Support

If you encounter issues:
1. Check the [GitHub Actions documentation](https://docs.github.com/en/actions)
2. Review [GitHub Pages documentation](https://docs.github.com/en/pages)
3. Open an issue in the repository

