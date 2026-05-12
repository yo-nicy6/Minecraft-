$GH_TOKEN = "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"

while($true) {
    Start-Sleep -Seconds 600 # 10 Minutes wait
    
    echo "Backing up world..."
    
    # World ko zip karna (Puran wale ko overwrite karega)
    Compress-Archive -Path "worlds/*" -DestinationPath "world.zip" -Force
    
    # GitHub Push
    git config user.email "vps@server.com"
    git config user.name "VPS-Auto-Backup"
    git add world.zip
    git commit -m "Auto-backup: $(Get-Date)"
    git push origin main
    
    echo "Backup pushed to GitHub."
}
