# docker-iroffer

Simple docker image for running [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

## Usage

```bash
docker create \
--name iroffer \
-v </path/to/config>:/config \
-p 30000-31000:30000-31000 \
avluis/iroffer:latest
```

[iroffer-dinoex]: http://iroffer.dinoex.net/
