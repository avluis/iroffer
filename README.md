# docker-iroffer

Simple docker image for running [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

## Usage

```bash
docker create \
--name=iroffer \
--net=host \
-v </path/to/config>:/config \
-v </path/to/files>:/files \
-p 30000-31000:30000-31000 \
avluis/iroffer
```

## Notes:
You don't need to open every port defined here!
Just create as many as you think you will need (x amount of connections).
Make certain to start container with host flag; NAT & DCC don't mix very well.

The config volume will contain a sample.config file for setting up iroffer.
Copy/rename this file to mybot.config and edit as appropriate.
Mount the config volume and include this file.

The files volume can be used as needed;
Make certain that your mybot.config has the proper path set where needed.
You can always create additional subfolders in your host (as well as in mybot.config)


## TODO
Additional environment variables to modify mybot.config instead of editing the file directly.


[iroffer-dinoex]: http://iroffer.dinoex.net/
