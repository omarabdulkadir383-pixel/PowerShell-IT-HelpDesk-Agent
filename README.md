# Custom PowerShell IT Help Desk Assistant (V4)

An interactive, host-native PowerShell automation script designed to interface with conversational AI models for real-time IT desktop troubleshooting support.

## Key Technical Features
* **Secure Token Handshakes**: Leverages Windows system registry memory allocation via environment variables rather than hardcoding API authentication credentials directly into source script files.
* **Persistent Session Arrays**: Implements rolling JSON objects dynamically to retain contextual dialogue structures between user prompts and the model.
* **Local Auditing Logs**: Dynamically captures user entries and assistant replies to create automatic file diagnostic reports inside the host user profile (`IT_Chat_Log.txt`).
