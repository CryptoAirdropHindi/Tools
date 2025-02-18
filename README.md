# <h2 align=center>Setup & Installation Guide by CryptoAirdropHindi</h2>

- This guide will help you automate the installation and setup of essential tools for your system.
- The following steps will ensure that your system is equipped with necessary utilities 
- like Docker, Node.js, Python, screen, and tools for monitoring CPU, memory, and disk usage.
--------------------------------------------------------------------------------------------------------------


# 1. System Information Tools (Initial Setup)
Before installing additional tools, it's useful to gather information about
your system's resources, such as vCPU cores, RAM, and SSD usage.

<h2 align=center>Check System’s vCPU Cores, RAM, and SSD Usage</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/info.sh)
```
This command fetches and executes a script that will provide a snapshot of your system's vCPU cores, RAM, and SSD usage.

# 2. Docker Installation (Essential Tool)
Docker is crucial for containerizing applications,
so it is recommended to install it early in the process.

<h2 align=center>Download and Install Docker</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/docker.sh)
```
This script will automatically install Docker on your system.

# 3. Install Node.js (Development Tool)
Node.js is essential if you plan to run server-side
JavaScript or set up backend services.

<h2 align=center>Install Node.js</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/install-node.sh)
```
This script installs Node.js to allow you to execute JavaScript code server-side.

# 4. Install Python (Development Tool)
Python is widely used for scripting and automation.
Install it next if your system needs it for running Python scripts.

<h2 align=center>Install Python</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/install-python.sh)
```
This will install Python on your system for various automation or development tasks.

# 5. CPU Information Check (System Monitoring)
Once essential tools are set up, it's helpful to verify CPU usage and performance.

<h2 align=center>First Method: Basic CPU Information</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/dashboard.sh)
```
This method provides a basic overview of your system’s CPU information.

<h2 align=center>Second Method: Detailed CPU Usage</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/monitor_cpu_space.sh)
```
This script provides a more detailed overview of CPU usage and system performance.

# 6. Check Available Space and Memory (System Monitoring)
Now that the tools are installed, monitoring disk space and memory
usage is important to ensure your system isn’t running low on resources.

<h2 align=center>Check Available Space and Memory</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/check_space_memory.sh)
```
This script will check the available disk space and memory usage on your system.

# 7. Install Screen (Session Management)
Screen is useful for session management, especially for running long tasks in the terminal.
Install it when you're ready to manage multiple terminal sessions.

<h2 align=center>Install Screen</h2>
```
source <(wget -O - https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/install-screen.sh)
```
This script installs screen, which lets you run multiple shell sessions within one terminal window.

------------------------------------------------------------------------------------------------------------------------------------

# Important Notes
- Root or Sudo Privileges: These scripts may require elevated privileges,
so ensure you have root or sudo access to execute them.
- Compatibility: These scripts are designed for Debian-based systems (like Ubuntu).
 If you're using another Linux distribution, you might need to modify the commands.
- Security: Always review each script before running it to verify its contents and ensure it's compatible with your environment.

------------------------------------------------------------------------------------------------------------------------------------------

"Great, all set! If you have any questions, don’t hesitate to ask in our Telegram channel."
Or if you'd like something more friendly and engaging:
- Telegram - https://t.me/Crypto_airdropHM
- Youtube - https://www.youtube.com/@CryptoAirdropHindi6
