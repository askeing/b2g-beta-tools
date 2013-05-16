# Script tools for B2G project

## autoflash.sh

This script was written for download build from server and flash to unagi.

Please create the config file `.autoflash.conf` first.

ex:
```
CONF_100_USR_URL=https://example.build.server/v1.0.0/lastet/
CONF_101_ENG_URL=https://example.build.server/v1.0.1-eng/lastet/
CONF_101_USR_URL=https://example.build.server/v1.0.1/lastet/
CONF_110_ENG_URL=https://example.build.server/v1.1.0-eng/lastet/
CONF_110_USR_URL=https://example.build.server/v1.1.0/lastet/

# optional section
CONF_VERSION=110
CONF_ENGINEER=1
```
The available version are:
`100` (`tef`), `101` (`shira`), and `110` (`v1train`).

PS: The default `.autoflash.conf` is not for normal users, please edit your own config file.


## check_versions.sh

Checking the version of B2G on devices.
Please make sure your devices can be detected by ADB tool.


## enable_captiveportal.sh

This script was written for enable Captive Portal detection for v1.0.1 and above.

Please create the config file `.enable_captiveportal.conf` first.

ex:
```
CONF_URL=http://this.is.example/index.html
CONF_CONTENT=TEST_VALUE\\n
```
The [Bug 869394](https://bugzil.la/869394) turn on Captive Portal detection by default after 2013/05/09.


## download_desktop_client.sh

This script was written for download last desktop from server.

Please create the config file `.download_desktop_client.conf` first.

ex:
```
CONF_LINUX_32_URL=https://path.to.linux32bit.desktopclient.file/
CONF_LINUX_64_URL=https://path.to.linux64bit.desktopclient.file/
CONF_MAC_URL=https://path.to.mac.desktopclient.file/
```

Visit [MDN: Using the B2G desktop client](https://developer.mozilla.org/en-US/docs/Mozilla/Firefox_OS/Using_the_B2G_desktop_client) for more detail information.


## get_crashreports.sh

This is to get the crash reports of submitted/pending.


## grant_geo_permission.sh

This script was written for grant the geolocation permission of unagi.
