# avluis/iroffer

An IRC File Server using DCC: [iroffer mod dinoex][iroffer-dinoex]
<br>
Compiled with cUrl, GeoIP, Ruby & UPnP.

### Usage:

```bash
docker create --name=iroffer \
--net=host \
-v <path to config>:/config \
-v <path to files>:/files \
-p 30000-31000:30000-31000 \
avluis/iroffer
```

### Parameters:
- `-v /config` Where we look for `mybot.config`
- `-v /files` Local path for files
- `-p 30000-31000` The port(s)

### Initial Run:
Upon first run, you will find a sample config named `mybot.config`.
<br>
By default (with the sample config) the bot will connect to the [Rizon IRC Network][rizon].
<br>
This is done as a way to verify that the bot can connect.
<br>
Make your edits to `mybot.config` and re-run. Pay special attention to volumes and their file paths!
<br>
If `mybot.config` already exists, then that file will be loaded instead.

### Generating a password hash:
If you need to hash a password, run `docker run -it avluis/iroffer -c`.
<br>
Follow the prompts to generate your password hash.
<br>
You can include the path to your config if desired (appends the hash to file):
<br>
`docker run -it avluis/iroffer -c /config/mybot.config`

### Networking:
You don't need to open every port defined above.
<br>
Just create as many as you think you will need (x amount of connections).
<br>
Make certain to start container with host flag; NAT & DCC don't mix very well.
<br>
You can try enabling UPnP mode if you can't enable host networking for your container.

### Organizing Files:
Additional volumes can be mounted and then defined in the `mybot.config` file if needed.
<br>
This is done by appending additional volume mount flags when creating/running this image.
<br>
Ex:
```bash
docker create --name=iroffer \
--net=host \
-v <path to config>:/config \
-v <path to files>:/files \
-v <path to more-file>:/more-files
-p 30000-31000:30000-31000 \
avluis/iroffer
```
You can add as many volume mounts as you need.

### Environment Variables:
This image makes use of environment variables to allow for customization if needed.
<br>
These variables match what is used on the sample `mybot.config` while building the image.
<br>
The only variable to pay special attention to is `IROFFER_CONFIG_DIR`.
<br>
This variable takes care of pointing iroffer to `mybot.config` so it is recommended to leave as is.
<br>
If your volume mounting structure differs from default then you need to define this variable:
<br>
```bash
docker create --name=iroffer \
--net=host \
-e <alt-path to config>:/alt-path/config \
-v <alt-path to config>:/alt-path/config \
-v <path to files>:/files \
-p 30000-31000:30000-31000 \
avluis/iroffer
```
The same applies to `IROFFER_DATA_DIR`, `IROFFER_LOG_DIR` and several other variables.

#### Important:
Make certain that you update the paths in `mybot.config` when setting `IROFFER_DATA_DIR` and `IROFFER_LOG_DIR`.
<br>
You will also need to update the path entries for `pidfile`, `logfile`, `statefile` and `xdcclistfile`.
<br>
Make certain to updates the paths for any features that you have enabled as well.
<br>
If you don't care for logs, you can disable them by prefixing `#` to `logfile` in `mybot.config` (line 23).
<br>
This applies to all other features -- so make certain to look over `mybot.config` before adding files or joining a channel.

### Additional commands:
Version: `docker run -it avluis/iroffer -v`
<br>
Help: `docker run -it avluis/iroffer -?|-h`
<br>
Bypass EntryPoint: `docker run -it --entrypoint /bin/bash avluis/iroffer`

[iroffer-dinoex]: https://github.com/dinoex/iroffer-dinoex
[rizon]: https://www.rizon.net
