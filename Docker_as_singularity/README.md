
The first file - build.sh - is a copy of the standard NGC-HPC script to have docker images run on the NGC high-performance computer ("HPC"). Should work on computerome too, but haven't tested. The idea is basically to use the docker2singularity pluging to convert a dockerhub image to a .sif image, which can be run (almost) anywhere, even without being sudo.


