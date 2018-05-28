#set environment argument
envP=$1

#set schema only
schema=$2

#check if environment variable not empty
if [ -z "$envP" -a "$envP" == "" ] 
then
	printf "\nUSAGE: ./dump_database.sh [dev|uat|prod] [schema:yes|no]\n\n"
	exit 0
fi

#set db configs based on given environment
if [ $envP == 'dev' ]
then
	hName='192.168.x.y'
	hUser='user'
	hPass='pass'
	dbList=( db1 db2 )
elif [ $envP == 'uat' ]
then
	hName='db1-xyz.rds.amazonaws.com'
	hUser='user'
	hPass='pass'
	dbList=( db1 db2 )
elif [ $envP == 'prod' ]
then
	hName='db2-xyz.rds.amazonaws.com'
	hUser='user'
	hPass='pass'
	dbList=( db1 db2 )
else 
	printf "\nUSAGE: ./dump_database.sh [dev|uat|prod] [schema:yes|no]\n\n"
	exit 0
fi

printf "\nSTARTED \n\n"

set PGPASSWORD=$hPass

#create backup directory if not exists
backupDir='BACKUP/DATABASE/'
mkdir -p $backupDir 
cd $backupDir

#loop over db's configured
for i in "${dbList[@]}"
do
:
	printf "\nRunning for $i\n"

	#create env and db folder 
	mkdir -p $envP/$i

	#change directory 
	cd $envP/$i

	#check if schema only dump required
	if [ ! -z "$schema" -a "$schema" != "" ] 
	then
		echo /usr/bin/pg_dump -v -s -U "'$hUser'" -p 5432 -h "'$hName'" -d "'$i'" -f dump_$i.sql
		/usr/bin/pg_dump -v -s -U "$hUser" -p 5432 -h "$hName" -d "$i" -f dump_$i.sql
	else
		echo /usr/bin/pg_dump -v -U "'$hUser'" -p 5432 -h "'$hName'" -d "'$i'" -f dump_$i.sql
		/usr/bin/pg_dump -v -U "$hUser" -p 5432 -h "$hName" -d "$i" -f dump_$i.sql
	fi

	#move back to main dir
	cd ../../

done

printf "\nCOMPLETED \n\n"
