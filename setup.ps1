# --- CONFIGURATION ---
$GH_TOKEN = "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"
$GH_USER = "APNA_GITHUB_USERNAME"  # <--- Yahan apna username likhein
$GH_REPO = "minecraft-a717e"
$FIREBASE_API_KEY = "AIzaSyAbs5-EwQM8XUM4OP1eWKvamoYgNfuZf7M"
$PROJECT_ID = "minecraft-a717e"

# 1. Get Current VPS IP
$vpsIP = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
echo "VPS IP: $vpsIP"

# 2. Update Firebase Status (REST API)
$url = "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/server_info/status_doc?key=$FIREBASE_API_KEY&updateMask.fieldPaths=ip&updateMask.fieldPaths=state"
$body = @{
    fields = @{
        ip = @{ stringValue = "$vpsIP" }
        state = @{ stringValue = "Online" }
    }
} | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri $url -Body $body -ContentType "application/json"

# 3. Clone World from GitHub
git clone --depth 1 "https://$($GH_TOKEN)@github.com/$GH_USER/$GH_REPO.git" server_data
cd server_data

# 4. Download Minecraft Bedrock Server (Windows)
Invoke-WebRequest -Uri "https://minecraft.azureedge.net/bin-win/bedrock-server-1.20.81.01.zip" -OutFile "bds.zip"
Expand-Archive -Path "bds.zip" -DestinationPath "." -Force
rm bds.zip

# 5. Extract World from Repo
if (Test-Path "world.zip") {
    Expand-Archive -Path "world.zip" -DestinationPath "worlds/" -Force
}

# 6. Start Backup Script in Background
Start-Process powershell -ArgumentList "-File .\backup.ps1" -WindowStyle Hidden

# 7. Run Server
.\bedrock_server.exe
