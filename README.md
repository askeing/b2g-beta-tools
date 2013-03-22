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


## check_versions.sh

Checking the version of B2G.


## enable_captiveportal.sh

This script was written for enable captive portal for v1.0.1 and above.

Please create the config file `.enable_captiveportal.conf` first.

ex:
```
CONF_URL=http://this.is.example/index.html
CONF_CONTENT=TEST_VALUE\\n
```

## get_crashreports.sh

This is to get the crash reports of submitted/pending.

## grant_geo_permission.sh

This script was written for grant the geolocation permission of unagi.
