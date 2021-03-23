



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

# #ok try with the --writebale and the --cleanenv
# cd ~
# mkdir temp
# 
# 
# echo "prepare_individual_genome('/home/ubuntu/input/HaplotypeCaller_synt0046.vcf.gz')" > test.R
# 
# $singularityBinary shell --cleanenv --bind /ngc/people/lwf/temp:/home/ubuntu/data --writable --overlay /ngc/people/lwf/temp $singularityImage 
# 
# $singularityBinary image.create my-overlay.img
# 
# singularity exec --cleanenv -B $HOME/script_out:/dir myimage.sif bash script.sh
# 
# 
# 
# $singularityBinary exec --bind /ngc/people/lwf:/home/ubuntu/data --writable $singularityImage Rscript /home/ubuntu/srv/impute-me/imputeme/vcf_handling_cron_job.R
# $singularityBinary exec --bind /ngc/people/lwf/temp:/home/ubuntu/data --writable $singularityImage Rscript /home/ubuntu/data/test.R
# $singularityBinary exec --bind /ngc/people/lwf/temp:/home/ubuntu/data --writable $singularityImage Rscript /home/ubuntu/data/test.R
# 
# 
# 
# 
# $singularityBinary exec \
# --bind /ngc/people/lwf/temp/vcfs:/home/ubuntu/vcfs,/ngc/people/lwf/temp/data:/home/ubuntu/data \
# $singularityImage Rscript /home/ubuntu/data/test.R
# #doesn't work because of permissions
# 
# $singularityBinary exec \
# --bind /ngc/people/lwf/temp/vcfs:/home/ubuntu/vcfs,/ngc/people/lwf/temp/data:/home/ubuntu/data \
# $singularityImage Rscript /home/ubuntu/data/test.R
# $singularityBinary exec --bind /ngc/people/lwf/temp/vcfs:/home/ubuntu/vcfs,/ngc/people/lwf/temp/data:/home/ubuntu/data $singularityImage ls /home/ubuntu
# #doesn't work because of permissions
# 
# 
# $singularityBinary exec \
# --bind /ngc/people/lwf/temp/vcfs:/home/ubuntu/vcfs,\
# /ngc/people/lwf/temp/data:/home/ubuntu/data,\
# /ngc/people/lwf/temp/misc_files:/home/ubuntu/misc_files,\
# /ngc/people/lwf/temp/logs:/home/ubuntu/logs,\
# /ngc/people/lwf/temp:/home/ubuntu/input \
# $singularityImage Rscript /home/ubuntu/input/test.R
# #this actually works - apparently needs to mount every folder in the docker
# #that needs writing. Otherwise the singularity won't run as non-admin
# #ok, let's try to make that a bit smoother
# 
# 




#prepare launch script
#first create a run-sh with the analysis-lines required + the source of a sequencing vcf

singularityBinary=/cm/local/apps/singularity/3.4.1/bin/singularity
singularityImage=~/impute-me_v1.0.04.sif

cd ~
mkdir temp

vi run.sh
source("/home/ubuntu/srv/impute-me/functions.R")
prepare_individual_genome('/home/ubuntu/input/HaplotypeCaller_synt0046.vcf.gz')
uniqueID<-check_for_cron_ready_jobs("vcf")
#run the coversion
convert_vcfs_to_simple_format(uniqueID)
#Run the genotype extraction routine
crawl_for_snps_to_analyze(uniqueIDs=uniqueID)
#Run the json extraction routine
run_export_script(uniqueIDs=uniqueID)
#final transfer of files
transfer_cleanup_and_mailout(uniqueID=uniqueID)


#then call this run.sh script with the following setup
#each folder has to be loaded separately apparently, if it is to be writable according
#to singularity rules. However that also overwrites the contents of the folder, so 
#unfortunately there can not be folders that both contain pre-loaded data and are writable
#luckily - most folders in impute-me are either or, so it's no big problem
$singularityBinary exec \
--bind /ngc/people/lwf/temp/vcfs:/home/ubuntu/vcfs,\
/ngc/people/lwf/temp/data:/home/ubuntu/data,\
/ngc/people/lwf/temp/misc_files:/home/ubuntu/misc_files,\
/ngc/people/lwf/temp/logs:/home/ubuntu/logs,\
/ngc/people/lwf/temp:/home/ubuntu/input \
$singularityImage Rscript run.sh



#may want to put this into ~/misc_files (it's usually preloaded but ~/misc_files needs to be writable, with the bind 
# command so it gets overwritten. Not very smart behaviour in singularity, but whatever)
# maxImputations <- 1           #the max number of parallel imputations to run
# maxImputationsInQueue <- 200           #the max number of imputations allowed waiting in a queue
# serverRole <- 'Hub'           #the role of this computer, can be either Hub or Node
# hubAddress <- ''           #if serverRole is Node, then the IP-address of the Hub is required
# from_email_password <- ''           #optional password for sending out emails
# from_email_address <- ''           #optional email-address/username for sending out emails
# routinely_delete_this <- c('')           #delete these parts in routine 14-day data deletion. May put in 'link' and/or 'data', which is the default online. But docker-running defaults to not deleting anything.
# paypal <- ''           #suggest to donate to this address in emails
# bulk_node_count <- 1           #count of bulk-nodes, used only for calculating timings in receipt mail
# error_report_mail <- ''           #optional email-address to send (major) errors to
# seconds_wait_before_start <- 0           #a delay that is useful only with CPU-credit systems
# running_as_docker <- TRUE           #adapt to docker running
# max_imputation_chunk_size <- 400           #how much stuff to put into the memory in each chunk. Lower values results in slower running with less memory-requirements.
# verbose <- 1           #how much info to put into logs (min 0, max 10)

