# DisableLostMode
Disables Lost Mode for iOS Devices in Jamf Pro

This script resolves an issue where Lost Mode cannot be disabled from the Jamf Pro GUI after it has been enabled. It uses the Jamf Pro API to send a command that disables Lost Mode for a specified device.

⚠️ Disclaimer

This script is not an official product of Jamf Software and is provided as-is without warranty or support. By using this script, you agree that Jamf Software is under no obligation to support, debug, or otherwise maintain it.

🛠 Requirements

A valid Jamf Pro API account with permissions to manage devices and Lost Mode commands.
The jq command-line utility for parsing JSON responses.
Bash shell (#!/bin/bash) for script execution.

🚀 Usage

Replace the following placeholders with your actual values:
JAMF_URL: Your Jamf Pro instance URL.
USERNAME: Your Jamf Pro API username.
PASSWORD: Your Jamf Pro API password.
DEVICE_ID: The ID of the device for which you want to disable Lost Mode.
Step 3: Make the Script Executable
chmod +x DisableLostMode.sh
Step 4: Run the Script
./DisableLostMode.sh

🔐 Security Notes

The script invalidates the API token after each use for security purposes.
Avoid storing plaintext credentials in scripts. Use environment variables or secret management tools if possible.

🛑 Troubleshooting

Issue: Missing jq Dependency

Install jq with one of the following commands:

Ubuntu/Debian:
```
sudo apt-get install jq
```
macOS:
```
brew install jq
```
Issue: "Failed to retrieve Bearer Token"
Verify your Jamf Pro URL, username, and password.
Ensure the API account has proper permissions.

📄 License

This script is provided under the MIT License.

🧑‍💻 Contributing

Feel free to fork the repository and submit pull requests for improvements or new features.

📧 Support

This script is provided without support. For questions or suggestions, feel free to open an issue on GitHub.
