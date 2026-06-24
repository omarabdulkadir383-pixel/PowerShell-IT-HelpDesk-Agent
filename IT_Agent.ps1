$ScriptBlock = [scriptblock]::Create(@'
# description: AI help desk agent (Version 4 - Identity Fixed)
# Author: Abdulkadir Omar

# Force unlock execution constraints for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force | Out-Null

Clear-Host

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         IT HELP DESK ASSISTANT (V4) - HOST ENGINE        " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Fetch key from the OS User Profile environment
$Apikey = [Environment]::GetEnvironmentVariable("GROQ_API_KEY", "User")

# SECURITY GUARD: Stop execution instantly if the machine is missing the key
if ([string]::IsNullOrWhiteSpace($Apikey)) {
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host " SECURITY CRITICAL: API Key Missing from Host Machine!    " -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host "Your script stopped safely because no 'GROQ_API_KEY' environment variable was found."
    return
}

# AI endpoint 
$Url = "https://api.groq.com/openai/v1/chat/completions"

# Headers 
$Header = @{
	"Authorization" = "Bearer $Apikey"
	"Content-type"  = "Application/json"
}

# Initialize conversation history array with fixed system prompt layout
$Messages = @(
    @{
        role    = "system"
        content = "Your name is TechBot. You are a custom-built IT Help Desk Assistant created by Abdulkadir Omar using PowerShell. If the user asks who you are or what your name is, you must state clearly that you are TechBot. Do not refer to yourself as ChatGPT, OpenAI, or Gemini under any circumstances."
    }
)

# Setup log file path using your host user documents folder
$LogFile = "$env:USERPROFILE\Documents\IT_Chat_Log.txt"
"=== IT ASSISTANT CHAT SESSION LOG ===" | Out-File -FilePath $LogFile

# --- START OF THE INTERACTIVE LOOP ---
while ($true) {

    # Get User issue
    $Issue = Read-Host "`nWhat seems to be the problem (Type 'exit' to quit)"

    # Check if user wants to close the program
    if ($Issue -eq "exit" -or $Issue -eq "quit") {
        Write-Host "`nThank you for using IT Help Desk. Chat log saved to your Documents folder!" -ForegroundColor Cyan
        break
    }

    # Don't send empty inputs to the AI
    if ([string]::IsNullOrWhiteSpace($Issue)) {
        Write-Host "Input cannot be empty. Please describe an issue or type 'exit'." -ForegroundColor Yellow
        continue
    }

    Write-Host "AI is analyzing your issue..." -ForegroundColor DarkGray

    # Log user input locally to file
    "User: $Issue" | Out-File -FilePath $LogFile -Append

    # Append user message smoothly to the chat history
    $Messages += @{ role = "user"; content = $Issue }

    # Body construction
    $bodyhash = @{
        model    = "openai/gpt-oss-20b"
        messages = $Messages
    } 
    $bodyjson = $bodyhash | ConvertTo-Json -Depth 10

    # Protected network block with Try/Catch
    try {
        $responseRaw = Invoke-RestMethod -Uri $Url -Method Post -Headers $Header -Body $bodyjson
        $response = $responseRaw.choices[0].message.content
        
        if ([string]::IsNullOrEmpty($response)) {
            $response = $responseRaw.choices[0].text
        }
    }
    catch {
        $response = "System Alert: I had trouble reaching the AI server. Please make sure your computer has active internet access and try again."
    }

    # Show results
    Write-Host ""
    Write-Host "AI Response:" -ForegroundColor Green
    Write-Host $response

    # Save to file log
    "AI: $response" | Out-File -FilePath $LogFile -Append
    "--------------------------------------------------" | Out-File -FilePath $LogFile -Append

    # Append assistant response for the next loop turn to maintain active memory
    $Messages += @{ role = "assistant"; content = $response }
}
'@)

# Run the stored script block safely
& $ScriptBlock
