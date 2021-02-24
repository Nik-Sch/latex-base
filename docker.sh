#!/bin/bash
docker run -ti -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --net=host \
  -v $(pwd):/home/developer/project -w /home/developer/project --rm g0t00/latexbloat $@
