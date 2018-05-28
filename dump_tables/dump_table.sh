#set environment argument
envP=$1

#set database name to dump tables of
dbName=$2

#set schema argument
schema=$3

#check if database name and environment is passed
if [ \( "$dbName" = '' \) -o \( "$envP" = '' \) ] ; then
	printf "\nUSAGE: ./dump_table [dev|uat|prod] [database_name] [schema:yes|no]\n\n"
	exit 0
fi

if [ $envP == 'dev' ]
then
	hName='192.168.x.y'
	hUser='user'
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
	print "\nUSAGE: ./dump_table [dev|uat|prod] [database_name] [schema:yes|no]\n\n"
	exit 0
fi

#list of tables to be dumped
tableList=( table_1 table_2 )

printf "\nSTARTED \n\n"

#set password
set PGPASSWORD=$hPass

#set backup directory
backupDir='BACKUP/table/'
mkdir -p $backupDir
cd $backupDir

#for each table to be dumped
for i in "${tableList[@]}"
do
:
	printf "\nRunning for $i\n"

	#make directory for given database
	mkdir -p $envP/$dbName

	#change directory
	cd $envP/$dbName

  #check if schema only dump required
  if [ ! -z "$schema" -a "$schema" != "" ]
  then
		#dump table schema into file
		echo /usr/bin/pg_dump -v -s -U "'$hUser'" -p 5432 -h "'$hName'" -t "'$i'" -d "'$dbName'" -f create_table_$i.sql
		/usr/bin/pg_dump -v -s -U "$hUser" -p 5432 -h "$hName" -t "$i" -d "$dbName" -f create_table_$i.sql
  else
		#dump table data into file
		echo /usr/bin/pg_dump -v -U "'$hUser'" -p 5432 -h "'$hName'" -t "'$i'" -d "'$dbName'" -f data_table_$i.sql
		/usr/bin/pg_dump -v -U "$hUser" -p 5432 -h "$hName" -t "$i" -d "$dbName" -f data_table_$i.sql
  fi

	#move back to main directory
	cd ../../

done

printf "\nCOMPLETED \n\n"
