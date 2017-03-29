# docker-ngircd

Simple docker image for running [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

## Usage

```bash
# when using docker-machine (if using docker directly, use the
# external ip of the docker host)
docker run \
  -d \
  -p 50000-50010:50000-50010 \
  --name iroffer \
  avluis/iroffer:latest
```

[iroffer-dinoex]: http://iroffer.dinoex.net/
