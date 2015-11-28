# docker-ngircd

Simple docker image for running [ngircd][ngircd] as IRC server and [iroffer mod dinoex][iroffer-dinoex] as DCC bot.

This image is not for production usage, but just for learning purposes.

## Usage

```bash
# when using docker-machine (if using docker directly, use the
# external ip of the docker host)
docker run \
  -d \
  -p 6667:6667 \
  -p 50000-50010:50000-50010 \
  --env EXTERNAL_IP=$(docker-machine ip default) \
  --name iroffer \
  choffmeister/iroffer:latest
```

## Note on image size

This image contains some test files. So the image is quite large on paper (> 1.3 GiB), but since these file only contain binary zeros, the compressions reduces the actual transferred data amount while pulling a lot.

[ngircd]: http://ngircd.barton.de/
[iroffer-dinoex]: http://iroffer.dinoex.net/
