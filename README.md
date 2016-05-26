# omxscreen
Simple jukebox mp4 player for Raspberry Pi

The Raspberry Pi, with its builtin hardware h.264 decoding, makes an excellent digital signage player.

This project consists of some simple scripts to allow it to run an indefinite loop of video files stored on a USB stick.

How to use
----

1. Get hold of a raspberry pi - RS Online or Farnell stock them, as do Maplin and other retailers
2. Download an up-to-date version of Raspbian and initialise an SD card with it
3. Use apt-get on the pi to install pmount, omxplayer and perl
4. Create a user called omxscreen, or change line 8 of omxscreen.pl
5. Install the omxscreen.pl script to /usr/bin or /usr/local/bin.  You can run the system right away by plugging in a USB stick and running this script; anything under the /media directory (usual mount point) will be played
6. If you want USB sticks to automount when you plug them into the Pi's USB socket, copy the automount.rules file to /etc/udev.d (or /etc/udev/rules.d on Raspbian 2016+).  You'll probably want to reboot once you've this.
7. If you want the system to start up automatically at boot, either: 
    - apply the inittab.diff path to /etc/inittab (for older Raspbian).  This will cause the first console to always be a running version of the player script, and assumes that it is installed to /usr/local/bin
    - if there is no /etc/inittab file, then you should copy the omxscreen.service file to /etc/systemd/system.  Then run sudo systemctl daemon-reload, followed by sudo systemctl enable omxscreen.  This will make the system start at boot.

How to encode the media
-----

The Raspberry Pi expects to have media encoded to the following standards:

- 1920x1080 or 1280x720 resolution
- 24, 25 or 29.97fps
- High profile
- Reasonably high bitrate, >4906kbit/s
- Stereo audio AAC - no more channels than this
- 48kHz audio sample rate
- 128kbit/s plus audio bit rate
- MP4 wrapper format

Just put the files onto a USB stick and plug it in - the script will scan for mp4 files across all subdirectories of the card.

omxjuke
----

omxjuke.pl is a sample test script, playing media from the Guardian's Open Platform
