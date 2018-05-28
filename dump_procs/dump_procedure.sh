#set environment
envP=$1

#set database name
dbName=$2

#check if database name and environment is set
if [ \( "$dbName" = '' \) -o \( "$envP" = '' \) ] ; then
	printf "\n./dump_procedure [dev|uat|prod] [database_name]\n\n"
	exit 0
fi

#set database configuration based on evironment
if [ $envP == 'dev' ]
then
	hName='192.168.x.y'
	hUser='test'
	hPass='pass'
elif [ $envP == 'uat' ]
then
	hName='db1-xyz.rds.amazonaws.com'
	hUser='user'
	hPass='pass'
elif [ $envP == 'prod' ]
then
	hName='db2-xyz.rds.amazonaws.com'
	hUser='user'
	hPass='pass'
else 
	printf "\n./dump_procedure [dev|uat|prod] [database_name]\n\n"
	exit 0
fi

printf "\nSTARTED \n\n"

#list of procedures to be dumped
procList=( proc_1 proc_2 )

#set password
set PGPASSWORD=$hPass

#create backup directory
backupDir='BACKUP/procs/'
mkdir -p $backupDir
cd $backupDir

#for each procedures in the list
for i in "${procList[@]}"
do
:

	printf "\nRunning for $i\n"

	#create dir for storing procedure
	mkdir -p $envP/$dbName

	#change directory to database name
	cd $envP/$dbName

	#dump procedure schema
	showProc="SELECT prosrc FROM pg_proc WHERE proname = '$i'"
	echo /usr/bin/psql -v -U "'$hUser'" -p 5432 -h "'$hName'" -d "'$dbName'" -c $showProc
	/usr/bin/psql -v -U "$hUser" -p 5432 -h "$hName" -d "$dbName" -c "$showProc" > $i.sql

	#change dir to main dir
	cd ../../

done

printf "\nCOMPLETED \n\n"
