#!/bin/bash
# small script that build the imputeme as a docker image and then converts it
# into a singularity image. The previous image is removed first.

## WARNING:
## If you are uploading new versions to the citrix with the same name it will
## use the old version it has stored in its cache.
## Add the git hash to the name and you should be good to go
echo "Building imputeme image after updating from git"


# Remove old sif files
rm -f *.sif


docker run -v /var/run/docker.sock:/var/run/docker.sock -v \
  "/Users/lassefolkersen:/output" --privileged -t --rm \
  quay.io/singularity/docker2singularity:v3.4.1 \
  lassefolkersen/impute-me:v1.0.4



