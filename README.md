# docker-iroffer

Simple docker image for running [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

## Usage

```bash
docker run \
  -d \
  -p 50000-50010:50000-50010 \
  --name iroffer \
  avluis/iroffer:latest
```

[iroffer-dinoex]: http://iroffer.dinoex.net/
