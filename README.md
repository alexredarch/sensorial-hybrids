
# 🌿 Sensorial Hybrids — Raspberry Pi Setup Guide

Welcome to the **Sensorial Hybrids** project! This guide will walk you through the process of setting up the project on a **Raspberry Pi**. By the end, you’ll be able to run the **sonification.py** script and experience sound directly generated from live video captured by the Pi's camera.

---

## **🛠️ What You Will Need**
Before starting, make sure you have the following:
- **Raspberry Pi (Bookworm OS, 64-bit)**
- **Internet connection (Wi-Fi or Ethernet)**
- **SSH access (optional, but recommended)**
- **USB keyboard and monitor (optional, if no SSH)**
- **Bluetooth headphones (optional) or 3.5mm headphones**
- **Raspberry Pi Camera (connected properly and tested)**

---

## **📂 Folder Structure**
This is what the file structure will look like after you pull from GitHub:

```
sensorial-hybrids/
├── .gitignore
├── global-libraries.txt   # System libraries installed globally
├── setup.sh               # Installs venv, Python libraries, and system requirements
├── requirements.txt       # Python libraries for the virtual environment (venv)
├── sonification.py        # The main script to run
├── README.md              # This instructions file
└── config.env.example     # Template for environment variables (if needed)
```

---

## **⚙️ Step 1: Install Global Libraries**

These libraries are installed **globally** on your system and are required for working with the camera, sound, and Python tools.

1️⃣ **Update system packages**:  
```bash
sudo apt update && sudo apt upgrade -y
```

2️⃣ **Install global libraries**:  
```bash
sudo apt install -y \
    python3 python3-pip python3-venv python3-full \
    ffmpeg alsa-utils libasound2-dev \
    python3-opencv python3-picamera2 \
    bluez pulseaudio pulseaudio-module-bluetooth
```

> **What these packages do**:
- **Python3, pip, venv** — Ensures the Raspberry Pi has Python, pip, and venv.
- **ffmpeg, alsa-utils** — Used for sound processing.
- **OpenCV & Picamera2** — Handles the live camera.
- **PulseAudio & Bluetooth** — Enables Bluetooth headphone support.

3️⃣ **Check the installation**:  
```bash
python3 --version
pip3 --version
ffmpeg -version
```

If you see the versions listed, you’re good to go!

---

## **📂 Step 2: Pull Files from GitHub**

1️⃣ **Navigate to your home directory**:  
```bash
cd ~
```

2️⃣ **Clone the project from GitHub**:  
```bash
git clone https://github.com/your-username/sensorial-hybrids.git
```

> **What this does**:  
This will create a folder called **sensorial-hybrids** with all the files you need.

3️⃣ **Navigate into the folder**:  
```bash
cd ~/sensorial-hybrids
```

> **Check the files**:  
```bash
ls
```

You should see:  
```
.global-libraries.txt
setup.sh
requirements.txt
sonification.py
README.md
config.env.example
```

---

## **🐍 Step 3: Set Up the Python Virtual Environment (venv)**

1️⃣ **Run the setup script**:  
```bash
./setup.sh
```

> **What this does**:
- Creates a **Python virtual environment (venv)**.
- Installs **Python libraries** listed in **requirements.txt**.

> **Troubleshooting**:  
If you see **Permission denied**, you might need to make the script executable:  
```bash
chmod +x setup.sh
./setup.sh
```

2️⃣ **Activate the venv** (this only needs to be done if you want to manually use the venv):  
```bash
source venv/bin/activate
```

> **Note**: Once you activate the venv, your prompt will look like this:  
```
(venv) pi@raspberrypi:~/sensorial-hybrids $
```

---

## **🎉 Step 4: Run the Project!**

Once everything is set up, you can run the **sonification.py** script.

1️⃣ **Make sure the venv is activated**:  
```bash
source venv/bin/activate
```

2️⃣ **Run the script**:  
```bash
python3 sonification.py
```

> **What happens**:  
- The Pi camera will capture live video.  
- The script will convert colors to sound, which you’ll hear on headphones.  

---

## **⚙️ Optional: How to Activate Bluetooth Headphones**

If you want to use **Bluetooth headphones**, follow these steps:

1️⃣ **Turn on the Raspberry Pi Bluetooth service**:  
```bash
sudo systemctl start bluetooth
```

2️⃣ **Scan for Bluetooth devices**:  
```bash
bluetoothctl
```

> Inside the Bluetooth prompt, run:  
```
agent on
scan on
```

When you see your headphones' MAC address (e.g., `00:1A:7D:DA:71:13`), copy it.

3️⃣ **Connect to your headphones**:  
```bash
pair 00:1A:7D:DA:71:13
connect 00:1A:7D:DA:71:13
trust 00:1A:7D:DA:71:13
```

---

## **📚 Useful Commands**

| **Command**         | **What it Does**                        |
|--------------------|-----------------------------------------|
| `source venv/bin/activate` | Activates the venv. |
| `deactivate`           | Deactivates the venv.  |
| `./setup.sh`           | Runs the setup process from start. |
| `git pull`             | Pulls the latest changes from GitHub. |
| `git status`           | Checks if there are uncommitted changes. |
| `ffmpeg -version`      | Check if ffmpeg is installed. |

---

## **💡 Troubleshooting**
| **Problem**                     | **Solution**                          |
|---------------------------------|--------------------------------------|
| **Permission denied on ./setup.sh** | Run `chmod +x setup.sh` to make it executable. |
| **Python module not found**       | Run `source venv/bin/activate`, then `pip install <module>`. |
| **Bluetooth headphones not connecting** | Run `bluetoothctl` and follow the steps to pair and connect. |
| **"Command not found" for pip** | Run `sudo apt install python3-pip`. |
| **Virtual environment not activating** | Make sure you are in the correct folder, and run `source venv/bin/activate`. |

---

## **🎉 Congratulations!**
You’ve successfully set up **sensorial-hybrids** on your Raspberry Pi. You can now run **sonification.py** and hear live sound from the camera's color input. Enjoy experimenting and feel free to customize the scripts.

For any issues, please check the **Troubleshooting** section or contact the project maintainers.

---

