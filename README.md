# docker-ngircd

Simple docker image for running [ngircd][ngircd] as IRC server and [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

This image is not for production usage, but just for learning purposes.

## Usage

```bash
# when using docker-machine (if using docker directly, use the
# external ip of the docker host)
docker run \
  -p 6667:6667 \
  -p 8000:8000 \
  -p 50000-50010:50000-50010 \
  --env EXTERNAL_IP=$(docker-machine ip default) \
  --name iroffer \
  choffmeister/iroffer:latest
```

[ngircd]: http://ngircd.barton.de/
[iroffer-dinoex]: http://iroffer.dinoex.net/
