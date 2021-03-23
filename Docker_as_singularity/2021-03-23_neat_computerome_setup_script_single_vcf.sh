

#set variables - set these as relevant for system
# singularityBinary -- depends on the system, maybe check 'module load' 
singularityBinary=/cm/local/apps/singularity/3.4.1/bin/singularity
singularityImage=~/programs/2021-03-23_imputeme_sif/lassefolkersen_impute-me_v1.0.4-2021-03-12-1c80e0ab1f4e.sif
baseFolder=~/testrunning


#Get the singularity image (can also build from scratch according to 2021-03-22_making_docker_container_work script)
#online through browser
https://drive.google.com/file/d/1xlNOCQppkuY7edwmXdazczY8mTffmieg/view?usp=sharing
#or through this <complex> wget command (found it online after googling 'wget google-drive commands')
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1xlNOCQppkuY7edwmXdazczY8mTffmieg' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1xlNOCQppkuY7edwmXdazczY8mTffmieg" -O lassefolkersen_impute-me_v1.0.4-2021-03-12-1c80e0ab1f4e.sif && rm -rf /tmp/cookies.txt

#move to final destination
mv lassefolkersen_impute-me_v1.0.4-2021-03-12-1c80e0ab1f4e.sif $singularityImage


#Create a write-able folder structure to bind into the singularity image 
#(one line for every folder that needs to be writable in the singularity environment, this is already
#done inside the docker folder, but the singularity-bind command unfortunately overwrites it)
mkdir ${baseFolder}
mkdir ${baseFolder}/misc_files
mkdir ${baseFolder}/vcfs
mkdir ${baseFolder}/imputations
mkdir ${baseFolder}/data
mkdir ${baseFolder}/logs
mkdir ${baseFolder}/logs/submission
touch ${baseFolder}/misc_files/supercronic.txt

#Re-write the configuration file (it gets overwritten inside the singularity because of the above bind-command)
vi ${baseFolder}/misc_files/configuration.R

#then write this (and more if necessary - there's an example in the Dockerfile here: https://github.com/lassefolkersen/impute-me/blob/f3d0b5e764ca33ce3ffe60a8b56f6ed9273f72d6/Dockerfile#L154-L168)
serverRole <- 'Hub'           #the role of this computer, can be either Hub or Node
running_as_docker <- TRUE           #adapt to docker running
max_imputation_chunk_size <- 400           #how much stuff to put into the memory in each chunk. Lower values results in slower running with less memory-requirements.
verbose <- 1           #how much info to put into logs (min 0, max 10)

#save and exit



#copy the input file to the singularity data-folder
cp <some_full_path_to_data>/HaplotypeCaller_synt0046.vcf.gz ${baseFolder}/data/




#Make a run script for inserting a single vcf file with the relevant calls 
#More inspiration for combinations in the cron-jobs here: https://github.com/lassefolkersen/impute-me/tree/master/imputeme
#I'll make a few others for the more biobank-cohort oriented ones with multiple microarray samples
#just make it in whatever directory you are already in, and intend to run the $singularityBinary command from
vi run.sh

#<WRITE THIS IN THE run.sh file>
#load functions
source("/home/ubuntu/srv/impute-me/functions.R")
#give the sample a name 
predefined_uniqueID <- "id_111111111"
#prepare a folder with input data+meta-data
prepare_individual_genome('/home/ubuntu/data/HaplotypeCaller_synt0046.vcf.gz', predefined_uniqueID=predefined_uniqueID)
#run the coversion
convert_vcfs_to_simple_format(uniqueID=predefined_uniqueID)
#Run the genotype extraction routine
crawl_for_snps_to_analyze(uniqueIDs=predefined_uniqueID)
#Run the json extraction routine
run_export_script(uniqueIDs=predefined_uniqueID)
#final transfer of files
transfer_cleanup_and_mailout(uniqueID=predefined_uniqueID)

#save and exit




#Execute singularity
$singularityBinary exec \
--bind \
${baseFolder}/vcfs:/home/ubuntu/vcfs,\
${baseFolder}/imputations:/home/ubuntu/imputations,\
${baseFolder}/data:/home/ubuntu/data,\
${baseFolder}/misc_files:/home/ubuntu/misc_files,\
${baseFolder}/logs:/home/ubuntu/logs, \
$singularityImage Rscript run.sh




