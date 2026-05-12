# --- CONFIGURATION ---
$GH_TOKEN = "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"
$GH_USER = "yo-nicy6"  
$GH_REPO = "Minecraft-"
$FIREBASE_API_KEY = "AIzaSyAbs5-EwQM8XUM4OP1eWKvamoYgNfuZf7M"
$PROJECT_ID = "minecraft-a717e"
$MC_PORT = "19132"

# 1. Open Windows Firewall for Minecraft Bedrock (UDP)
echo "Opening Firewall Port $MC_PORT..."
netsh advfirewall firewall add rule name="Minecraft_Bedrock" dir=in action=allow protocol=UDP localport=$MC_PORT

# 2. Get Current VPS IP
$vpsIP = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
echo "VPS IP: $vpsIP"

# 3. Update Firebase Status (IP, Port, State)
$url = "https://firestore.googleapis.com/v1/projects/$PROJECT_ID/databases/(default)/documents/server_info/status_doc?key=$FIREBASE_API_KEY&updateMask.fieldPaths=ip&updateMask.fieldPaths=port&updateMask.fieldPaths=state"
$body = @{
    fields = @{
        ip = @{ stringValue = "$vpsIP" }
        port = @{ stringValue = "$MC_PORT" }
        state = @{ stringValue = "Online" }
    }
} | ConvertTo-Json
Invoke-RestMethod -Method Patch -Uri $url -Body $body -ContentType "application/json"

# 4. Clone World from GitHub
# Purana folder delete karke fresh clone (agar exist karta hai)
if (Test-Path "server_data") { rm -rf server_data }
git clone --depth 1 "https://$($GH_TOKEN)@github.com/$GH_USER/$GH_REPO.git" server_data
cd server_data

# 5. Download Minecraft Bedrock Server (Windows)
Invoke-WebRequest -Uri "https://minecraft.azureedge.net/bin-win/bedrock-server-1.20.81.01.zip" -OutFile "bds.zip"
Expand-Archive -Path "bds.zip" -DestinationPath "." -Force
rm bds.zip

# 6. Extract World from Repo
if (Test-Path "world.zip") {
    Expand-Archive -Path "world.zip" -DestinationPath "worlds/" -Force
}

# 7. Start Backup Script in Background
Start-Process powershell -ArgumentList "-File .\backup.ps1" -WindowStyle Hidden

# 8. Run Server
echo "Starting Minecraft Server..."
.\bedrock_server.exe
