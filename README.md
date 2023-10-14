# LG C2 PC Input Mode Type Script

The LG C2 TV annoyingly defaults to `HDMI` Input Mode Type.

This mode has hight latency and bad image quality.

The `PC` Input Mode Type fixes that, but it's deeply nested under the webOS Home Dashboard, and resets every time the cable is disconnected (e.g. to plug it into another device).

This script makes it so that your macOS device listens to the TV being available via AirPlay, and changes all HDMI's Input Mode Type to PC.

Tested in macOS Sonoma 14.0


## How to use
1. Install the [bscpylgtv library](https://github.com/chros73/bscpylgtv)
2. Place `lg-pc-mode.sh` in `~/.bin` or equivalent folder.
3. Make it executable
    1. Run `chmod +x ~/.bin/lg-pc-mode.sh`
4. (Optional): Run and test it now:
    1. Run `~/.bin/lg-pc-mode.sh`
    2. You should see your TV listed under "Instance Name"
5. Add cron to run it upon every reboot:
    1. Run `crontab -e`
    2. Add and save: `@reboot ~/.bin/lg-pc-mode.sh`
    3. Confirm it's been added running: `crontab -l`


## Troubleshooting

* You need to have the `bscpylgtvcommand` binary inside `/opt/homebrew/bin`
    * Change the path used in the `debounce` function calls if you have it elsewhere.
* Find your monitor model
    * Run `dns-sd -B _airplay._tcp`
        * Get the model number and update line 22 of the script with it.
        * Example output (your model number would be: `OLED42C24LA`):
```
Browsing for _airplay._tcp
DATE: ---Sat 14 Oct 2023---
 8:48:47.228  ...STARTING...
Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
 8:48:47.229  Add        3  14 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        3   1 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        3  19 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        3  21 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        3  23 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        3  15 local.               _airplay._tcp.       MacBook Pro
 8:48:47.229  Add        2  15 local.               _airplay._tcp.       [LG] webOS TV OLED42C24LA
```


## Special Mentions
- [alin23](https://github.com/alin23) - Helping and providing the simplest solution using dns-sd. Also check out his awesome app for controlling monitors, [Lunar](https://github.com/alin23/Lunar).
- [ToggleHDR](https://github.com/alin23/mac-utils#togglehdr) Apple Shortcut, also from [alin23](https://github.com/alin23) lets you quickly enable/disable HDR in any monitor, including the LG C2 TV. This enhances brightness and arguably improves image quality.
- [bscpylgtv](https://github.com/chros73/bscpylgtv) library by [chros73](https://github.com/chros73/bscpylgtv/commits?author=chros73) lets us control the webOS based LG TVs like the C2.

## Other sources
- [https://www.reddit.com/r/OLED_Gaming/comments/133yz80/fixed_lg_c2_hdmi_input_setting_resetting_after/](https://www.reddit.com/r/OLED_Gaming/comments/133yz80/fixed_lg_c2_hdmi_input_setting_resetting_after/)
