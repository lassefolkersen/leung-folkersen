





docker run -v /var/run/docker.sock:/var/run/docker.sock -v \
  "/Users/lassefolkersen:/output" --privileged -t --rm \
  quay.io/singularity/docker2singularity:v3.4.1 \
  lassefolkersen/impute-me:v1.0.4



