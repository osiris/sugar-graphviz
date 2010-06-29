#!/bin/bash

CONFIG='config.php'
DB_PASS='sugarcct15'
DB_USER='sugarcct15'
DB_NAME='sugarcct15'
DB_HOST='localhost'

function usage()
{
    echo
    echo "Use:"
    echo "# $0 [options]"
    echo " -u, --user     Specify user of database."
    echo " -p, --password Specify password of database."
    echo " -B, --database Specify database name."
    echo " -h, --host     Specify host of database."
    echo " -c, --config   Load configuration from config.php"
    echo " -?, --help"
    echo
    exit 1
}

#if [ -z $1 ]
#then
#    usage
#fi

while [ ! -z "$1" ];do
    case "$1" in
        -u|--user)
            DB_USER=$2
            shift 2
        ;;  
        -p|--password)
            DB_PASS=$2
            shift 2
        ;;  
        -B|--database)
            DB_NAME=$2
            shift 2
        ;;  
        -h|--host)
            DB_HOST=$2
            shift 2
        ;;  
        -c|--config)
            SUGAR_CONFIG=true
            DB_USER=$(cat $CONFIG | grep db_user_name | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_PASS=$(cat $CONFIG | grep db_password  | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_NAME=$(cat $CONFIG | grep db_name      | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_HOST=$(cat $CONFIG | grep db_host_name | tr -d \ ,\'\> | awk -F= '{print $2}')
            shift 1
        ;;
        -?|--help)
            usage
#        *)  
#            usage
        ;;  
    esac
done

MYSQL="mysql -u"$DB_USER" -p"$DB_PASS" -B "$DB_NAME" -h "$DB_HOST
SQL="(select distinct lhs_module as module_name from relationships) union (select distinct rhs_module as module_name from relationships) order by module_name;"
MODULES=$(echo $SQL | $MYSQL | grep -v module_name)

for MODULE in $MODULES
do
    MODULE=$(echo $MODULE | tr [A-Z] [a-z])
    ./sugar-graphviz.sh -u $DB_USER -p $DB_PASS -B $DB_NAME -h $DB_HOST -r -m $MODULE
done

