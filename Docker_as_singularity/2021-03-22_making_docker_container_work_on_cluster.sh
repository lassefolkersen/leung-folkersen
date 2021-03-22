



#Run this locally (just have to have docker installed, i.e. gotta be admin)

docker run -v /var/run/docker.sock:/var/run/docker.sock -v \
  "/Users/lassefolkersen:/output" --privileged -t --rm \
  quay.io/singularity/docker2singularity:v3.4.1 \
  lassefolkersen/impute-me:v1.0.4



#the file it produces (lassefolkersen_impute-me_v1.0.4-2021-03-12-1c80e0ab1f4e.sif) should 
#then be transferred to the cluster computerome (don't need to be admin anymore)
#(first had to split it before transfer, this makes it go up to max 1GB)
split -b 1073741824 lassefolkersen_impute-me_v1.0.4-2021-03-12-1c80e0ab1f4e.sif 
cat x* > impute-me_v1.0.04.sif


singularityBinary=/cm/local/apps/singularity/3.4.1/bin/singularity
singularityImage=~/impute-me_v1.0.04.sif

 $singularityBinary exec --bind /ngc/people/lwf:/home/ubuntu/data $singularityImage Rscript /home/ubuntu/srv/impute-me/imputeme/vcf_handling_cron_job.R
# Error in check_for_cron_ready_jobs("vcf") :
#   could not find function "check_for_cron_ready_jobs"
# Execution halted

#odd, this is supposed to work. Auto-loading check_for_cron_ready_jobs
