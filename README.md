# Linux Bluetooth Audio Keepalive Fix 🎧🐧

A lightweight background (keepalive) script that solves the **"first 1-2 seconds of audio cut off"**, **"device going to sleep"**, and occasional **"complete connection drop"** issues experienced with Bluetooth headphones and speakers when using PulseAudio/PipeWire on Linux systems.

🔗 **Repository Link:** <https://github.com/renardozt/linux-bluetooth-fix>

## 🛑 Problem: Why Do We Need This?

Many Bluetooth headphones (especially TWS earbuds and portable speakers) put themselves into **sleep mode (standby)** to save battery if they don't receive any audio signal for a few seconds.

When a notification sound suddenly plays from your computer or you start a video, it takes 1-2 seconds for the headphones to wake up and play the audio. Because of this delay:

* You completely miss short message/notification sounds.
* The first few words of videos or songs are cut off.

## 💡 Solution: How Does This Script Work?

This Bash script creates a completely **silent and fake audio stream** in the background (using `null-sink` and `loopback` modules) to trick your Bluetooth device into thinking "something is constantly playing." The device stays awake continuously, and the audio delay is completely eliminated.

* **Smart:** It constantly monitors your Bluetooth hardware using `rfkill`.
* **Resource-friendly:** It only loads the virtual audio modules when Bluetooth is turned ON. When you turn off Bluetooth or the hardware is disconnected, it cleans up the modules, preventing CPU and battery waste.

## 🛠️ Requirements

The following must be installed on your system for this script to work (They come pre-installed in most modern Linux distributions):

* `pactl` (PulseAudio or PipeWire-Pulse)
* `rfkill`
* `bash`

## 🚀 Installation and Usage

### 1. Clone the Repository

First, open your terminal and download the script to your computer:

git clone https://github.com/renardozt/linux-bluetooth-fix.git
cd linux-bluetooth-fix


### 2. Automated Installation (RECOMMENDED)

The easiest way to use this fix is to install it as a background service. We have provided an installation script that does all the setup (copying files, creating systemd service, and enabling autostart) automatically.

Simply run:

chmod +x install.sh
./install.sh


**That's it!** The keepalive service is now active and will automatically start running in the background every time you log in. Your headphones will no longer fall asleep.

### 3. Manual Testing (Optional)

If you just want to test the script without installing it permanently:

chmod +x bluetooth_keepalive.sh
./bluetooth_keepalive.sh


The script will continue to run until you close the terminal. To view the logs, you can open a new terminal window and enter the following command:
`tail -f ~/.bluetooth_reconnect.log`

## ⚙️ Manual Installation (Advanced)

If you prefer not to use the automated `install.sh` and want to set up the systemd service yourself, follow these steps:

**1.** Move the script to a safe location (e.g., the `~/.local/bin/` directory):

mkdir -p ~/.local/bin
cp bluetooth_keepalive.sh ~/.local/bin/
chmod +x ~/.local/bin/bluetooth_keepalive.sh


**2.** Create the Systemd user service file:

mkdir -p ~/.config/systemd/user/
nano ~/.config/systemd/user/bluetooth-keepalive.service


**3.** Paste the following configuration inside, save, and exit (in nano: `Ctrl+O`, `Enter`, `Ctrl+X`):

[Unit]
Description=Bluetooth Audio Keepalive Service
After=pulseaudio.service pipewire-pulse.service

[Service]
ExecStart=%h/.local/bin/bluetooth_keepalive.sh
Restart=always
RestartSec=10

[Install]
WantedBy=default.target


**4.** Enable and start the service:

systemctl --user daemon-reload
systemctl --user enable --now bluetooth-keepalive.service


To check the status of the service, you can use this command:
`systemctl --user status bluetooth-keepalive.service`

## 🗑️ Uninstall

If you want to stop and completely remove the service, you can run the following commands in order:

systemctl --user disable --now bluetooth-keepalive.service
rm ~/.config/systemd/user/bluetooth-keepalive.service
systemctl --user daemon-reload
rm ~/.local/bin/bluetooth_keepalive.sh
rm ~/.bluetooth_reconnect.log


## 📜 Logs

The script logs its background activities to a hidden file in your home directory. If you want to check it out:

cat ~/.bluetooth_reconnect.log


## 🤝 Contributing

I am open to any Issues, Pull Requests, or feedback! Feel free to contribute if you have ideas for new features or optimizations.
