#!/bin/bash

# This script comes with ABSOLUTELY NO WARRANTY, use at own risk
# Copyright (C) 2008-2024 Osiris Alejandro Gomez <osiux@osiux.com>
# Copyright (C) 2008-2024 Osiris Alejandro Gomez <osiris@gcoop.coop>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

CONFIG='config.php'

SAVE_PDF=false
SAVE_PNG=true
SAVE_JPG=false
SAVE_HTM=false
SAVE_RST=false
SAVE_DOT=false
ROTATE=false
GRAPHVIZ_TABLES=false
TMP_PREFIX='/tmp/sugar-graphviz--'
DB_PORT=3306

function usage()
{
    echo
    echo "Use:"
    echo "# $0 [options] -c -m module_name"
    echo " -u, --user     Specify user of database."
    echo " -p, --password Specify password of database."
    echo " -B, --database Specify database name."
    echo " -h, --host     Specify host of database."
    echo " -c, --config   Load configuration from config.php"
    echo " -m, --module   Specify a name of module to draw."
    echo " -d, --dot      Save dot file."
    echo " -f, --pdf      Generate pdf with table structure and relationships."
    echo " -g, --graphviz Create graphviz tables."
    echo " -j, --jpg      Save graph in jpeg format (default png)."
    echo " -t, --htm      Generate html with table structure and relationships."
    echo " -o, --rotate   Rotate image in document pdf/html."
    echo " -r, --rst      Generate rst with table structure and relationships."
    echo " -?, --help     This Help."
    echo
    exit 1
}

if [ -z $1 ]
then
    usage
fi

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
        -P|--port)
            DB_PORT=$2
            shift 2
        ;;
        -m|--module)
            MODULE_NAME=$2
            shift 2
        ;;
        -d|--dot)
            SAVE_DOT=true
            shift 1
        ;;
        -f|--pdf)
            SAVE_PDF=true
            shift 1
        ;;
        -g|--graphviz)
            GRAPHVIZ_TABLES=true
            shift 1
        ;;
        -j|--jpg)
            SAVE_JPG=true
            shift 1
        ;;
        -t|--htm)
            SAVE_HTM=true
            shift 1
        ;;
        -o|--rotate)
            ROTATE=true
            shift 1
        ;;
        -r|--rst)
            SAVE_RST=true
            shift 1
        ;;
        -c|--config)
            SUGAR_CONFIG=true
            DB_USER=$(cat $CONFIG | grep db_user_name | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_PASS=$(cat $CONFIG | grep db_password  | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_NAME=$(cat $CONFIG | grep db_name      | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_HOST=$(cat $CONFIG | grep db_host_name | tr -d \ ,\'\> | awk -F= '{print $2}')
            DB_PORT=$(cat $CONFIG | grep db_port      | tr -d \ ,\'\> | awk -F= '{print $2}')
            shift 1
        ;;
        -?|--help)
            usage
        ;;
        *)
            usage
        ;;
    esac
done

MYSQL=$'mysql -u '$DB_USER$' -p'$DB_PASS$' -B '$DB_NAME$' -h '$DB_HOST$' -P '$DB_PORT
LOG='sugar-graphviz.log'
echo $MYSQL>$LOG

if [ "$GRAPHVIZ_TABLES" = "true" ]
then
    if [ -e ./graphviz.sql ]
    then
        echo 'create graphviz tables in database '$DB_NAME>$LOG
        $MYSQL<graphviz.sql
    else
        echo "Not found graphviz.sql"
        exit 1
    fi
fi

echo $MODULE_NAME>>$LOG
SQL="select 1 as module_name from relationships where lhs_module='$MODULE_NAME' or rhs_module='$MODULE_NAME' limit 1;"
echo $SQL>>$LOG
MODULE_EXISTS=$(echo $SQL | $MYSQL | grep -v module_name)

if [ "$MODULE_EXISTS" = "1" ]
then
    WHERE=" where (lhs_module='$MODULE_NAME' or rhs_module='$MODULE_NAME') "
    DOT=$DB_NAME"-relationships-"$MODULE_NAME".dot"
    PNG=$DB_NAME"-relationships-"$MODULE_NAME".png"
    JPG=$DB_NAME"-relationships-"$MODULE_NAME".jpg"
    RST=$DB_NAME"-relationships-"$MODULE_NAME".rst"
    HTM=$DB_NAME"-relationships-"$MODULE_NAME".htm"
    PDF=$DB_NAME"-relationships-"$MODULE_NAME".pdf"
else
    if [ "$MODULE_NAME" = "all" ]
    then
        WHERE=" "
        DOT=$DB_NAME'-relationships.dot'
        PNG=$DB_NAME'-relationships.png'
        JPG=$DB_NAME'-relationships.jpg'
        RST=$DB_NAME'-relationships.rst'
        HTM=$DB_NAME'-relationships.htm'
        PDF=$DB_NAME'-relationships.pdf'
    else
        usage
    fi
fi

## Remove old files
rm -f $DOT
rm -f $PNG

## Header
echo "digraph Relationships {">>$DOT
echo "node [shape=record,fontname=monospace,fontsize=8,color=gray];">>$DOT
echo 'ranksep=".3;"'>>$DOT
echo 'orientarion="portrait"'>>$DOT
#echo 'graph [fontname=monospace,fontsize=10,labelloc=t,labeljust=l,label="'$MODULE_NAME' relationships\n'$DB_NAME'@'$DB_HOST'"]'>>$DOT
echo 'rankdir=TB'>>$DOT
echo $'\n'>>$DOT


## reSructuredText
echo ".. -*- mode: rst -*-">$RST
echo $'\n'
echo ".. header:: $DB_NAME relationships for $MODULE_NAME module">>$RST
echo $'\n'>>$RST
RST_TITLE=$(echo $MODULE_NAME | tr [:print:] =)
echo $RST_TITLE>>$RST
echo $MODULE_NAME>>$RST
echo $RST_TITLE>>$RST
echo $'\n'>>$RST
echo ".. contents::">>$RST
echo $'\n'>>$RST


echo "## Left Tables">>$DOT
## Left Tables
SQL="select distinct lhs_table as table_name from relationships"
SQL=$SQL" "$WHERE" order by lhs_table;"
echo $SQL>>$LOG
LEFT_TABLES=$(echo $SQL | $MYSQL | grep -v table_name)
echo $LEFT_TABLES>>$LOG
TOTAL_LEFT_TABLES=$(echo $LEFT_TABLES | wc -w)
echo "Left Tables: "$TOTAL_LEFT_TABLES


## reSructuredText
RST_TABLES='Tables'
RST_TITLE=$(echo $RST_TABLES | tr [:print:] -)
echo $RST_TABLES>>$RST
echo $RST_TITLE>>$RST
echo $'\n'>>$RST
RST_TMP=$TMP_PREFIX$DB_NAME'-'$MODULE_NAME'-tables.rst.tmp'
RST_TBL=$TMP_PREFIX$DB_NAME'-'$MODULE_NAME'-table.tmp'
rm -f $RST_TMP


for TABLE in $LEFT_TABLES
do
    echo $TABLE>>$RST_TMP
    SQL="select distinct(lhs_key) as key_name from relationships where lhs_table='$TABLE' order by lhs_key;"
    echo $SQL>>$LOG
    KEY=$(echo $SQL | $MYSQL | grep -v key_name)
    KEY=$(echo $KEY | sed s/\ /\|/g)
    KEY=$(echo $KEY | awk -F\| '{print "<"$1">"$1"|<"$2">"$2"|<"$3">"$3"|<"$4">"$4"|<"$5">"$5"|<"$6">"$6"|<"$7">"$7"|<"$8">"$8"|<"$9">"$9"|<"$10">"$10}' | sed s/\|\<\>//g)
    SQL="select colorname from graphviz_tables where tablename='$TABLE';"
    echo $SQL>>$LOG
    COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
    if [ "$COLOR" = "" ];then COLOR="gray";fi
    echo $TABLE" [color=$COLOR,label=\"{$TABLE|$KEY}\"];">>$DOT
done


echo $'\n'>>$DOT
echo "## Right Tables">>$DOT
## Right Tables
SQL="select distinct rhs_table as table_name from relationships "
SQL=$SQL" "$WHERE" order by rhs_table;"
echo $SQL>>$LOG
RIGHT_TABLES=$(echo $SQL | $MYSQL | grep -v table_name)
TOTAL_RIGHT_TABLES=$(echo $RIGHT_TABLES | wc -w)
echo "Right Tables: "$TOTAL_RIGHT_TABLES

for TABLE in $RIGHT_TABLES
do
    echo $TABLE>>$RST_TMP

    SQL="select distinct(rhs_key) as key_name from relationships where rhs_table='$TABLE' order by rhs_key;"
    KEY=$(echo $SQL | $MYSQL | grep -v key_name)
    KEY=$(echo $KEY | sed s/\ /\|/g)
    KEY=$(echo $KEY | awk -F\| '{print "<"$1">"$1"|<"$2">"$2"|<"$3">"$3"|<"$4">"$4"|<"$5">"$5"|<"$6">"$6"|<"$7">"$7"|<"$8">"$8"|<"$9">"$9"|<"$10">"$10}' | sed s/\|\<\>//g)
    SQL="select colorname from graphviz_tables where tablename='$TABLE';"
    echo $SQL>>$LOG
    COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
    if [ "$COLOR" = "" ];then COLOR="gray";fi
    echo $TABLE" [color=$COLOR,label=\"{$TABLE|$KEY}\"];">>$DOT
done


echo $'\n'>>$DOT
echo "## Join Tables">>$DOT
## Join Tables
SQL="select distinct join_table as table_name from relationships where join_table is not null "
if [ "$MODULE_NAME" != "all" ]
then
    AND=" and "$(echo \($WHERE\) | sed s/where//g)
else
    AND=""
fi
SQL=$SQL$AND" order by join_table;"
echo $SQL>>$LOG
JOIN_TABLES=$(echo $SQL | $MYSQL | grep -v table_name)
TOTAL_JOIN_TABLES=$(echo $JOIN_TABLES | wc -w)
echo "Join Tables: "$TOTAL_JOIN_TABLES

for TABLE in $JOIN_TABLES
do
    echo $TABLE>>$RST_TMP

    SQL="(select distinct(join_key_lhs) as key_name from relationships where join_table='$TABLE') union (select distinct(join_key_rhs) as key_name from relationships where join_table='$TABLE') order by key_name;"
    echo $SQL>>$LOG
    KEY=$(echo $SQL | $MYSQL | grep -v key_name)
    KEY=$(echo $KEY | sed s/\ /\|/g)
    KEY=$(echo $KEY | awk -F\| '{print "<"$1">"$1"|<"$2">"$2"|<"$3">"$3"|<"$4">"$4"|<"$5">"$5"|<"$6">"$6"|<"$7">"$7"|<"$8">"$8"|<"$9">"$9"|<"$10">"$10}' | sed s/\|\<\>//g)
    SQL="select colorname from graphviz_tables where tablename='$TABLE';"
    echo $SQL>>$LOG
    COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
    if [ "$COLOR" = "" ];then COLOR="gray";fi
    echo $TABLE" [color=$COLOR,label=\"{$TABLE|$KEY}\"];">>$DOT
done

## Custom Tables
SQL="show tables"
CUSTOM_TABLES=$(echo $SQL | $MYSQL | grep "_cstm")
echo 'Custom tables query: '$SQL>>$LOG
echo 'Custom tables result: '$CUSTOM_TABLES>>$LOG

## Custom Left Tables
for TABLE in $(echo $CUSTOM_TABLES | sed s/_cstm//g)
do
    CUSTOM=$(echo $LEFT_TABLES | grep -o $TABLE | sort -u)
    if [ ! -z $CUSTOM ]
    then
        CUSTOM_LEFT_TABLES=$CUSTOM_LEFT_TABLES" "$CUSTOM"_cstm"
    fi
done
#echo 'Custom Left Tables: '$CUSTOM_LEFT_TABLES 
#echo 'Custom Left Tables: '$CUSTOM_LEFT_TABLES>>$LOG

## Custom Right Tables
for TABLE in $(echo $CUSTOM_TABLES | sed s/_cstm//g)
do
    CUSTOM=$(echo $RIGHT_TABLES | grep -o $TABLE | sort -u)
    if [ ! -z $CUSTOM ]
    then
        CUSTOM_RIGHT_TABLES=$CUSTOM_RIGHT_TABLES" "$CUSTOM"_cstm"
    fi
done
#echo 'Custom Right Tables: '$CUSTOM_RIGHT_TABLES 
#echo 'Custom Right Tables: '$CUSTOM_RIGHT_TABLES>>$LOG

UNIQUE_CUSTOM_TABLES=$(echo $CUSTOM_LEFT_TABLES" "$CUSTOM_RIGHT_TABLES | tr " " "\n" | sort -u)
echo 'Unique Custom Tables: '$UNIQUE_CUSTOM_TABLES>>$LOG
TOTAL_CUSTOM_TABLES=$(echo $UNIQUE_CUSTOM_TABLES | tr " " "\n" | wc -l)
echo 'Total Custom Tables: '$TOTAL_CUSTOM_TABLES

## Write Unique Custom Tables
for TABLE_CSTM in $UNIQUE_CUSTOM_TABLES
do
    SQL="select colorname from graphviz_tables where tablename='$TABLE';"
    echo $SQL>>$LOG
    COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
    TABLE=$(echo $TABLE_CSTM | sed s/_cstm//g)
    echo $TABLE_CSTM>>$RST_TMP
    echo $TABLE_CSTM" [color=$COLOR,label=\"{$TABLE_CSTM|id_c}\"];">>$DOT
    echo $TABLE_CSTM" -> "$TABLE" [arrowsize=.8,color=$COLOR];">>$DOT
done
## Total Tables
TOTAL_TABLES=$[ $TOTAL_LEFT_TABLES + $TOTAL_RIGHT_TABLES + $TOTAL_JOIN_TABLES + $TOTAL_CUSTOM_TABLES]
echo "Total Tables: "$TOTAL_TABLES




echo $'\n'>>$DOT
echo "## Relationships">>$DOT
## Relationships
SQL="select distinct lhs_table,rhs_table from relationships"
##SQL="select distinct lhs_table,lhs_key,rhs_table,rhs_key from relationships"
SQL=$SQL" "$WHERE" order by lhs_table,rhs_table;"
echo $SQL>>$LOG
RELATIONSHIPS=$(echo $SQL | $MYSQL | grep -v lhs_table | sed s/\\t/\|/g)
##echo $RELATIONSHIPS
TOTAL_SIMPLE_RELATIONSHIPS=$(echo $RELATIONSHIPS | wc -w)
echo "Simple Relationhips: "$TOTAL_SIMPLE_RELATIONSHIPS

for RELATION in $RELATIONSHIPS
do
    LEFT_TABLE=$(echo $RELATION | awk -F\| '{print $1}')
    RIGHT_TABLE=$(echo $RELATION | awk -F\| '{print $2}')
    SQL="select colorname from graphviz_tables where tablename='$LEFT_TABLE';"
    echo $SQL>>$LOG
    COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
    if [ "$COLOR" = "" ];then COLOR="gray";fi
    echo $LEFT_TABLE" -> "$RIGHT_TABLE" [arrowsize=.8,color=$COLOR];">>$DOT
    ##OPTIONS=" [arrowsize=.8,color=$COLOR];"
    ##echo $(echo $RELATION | awk -F\| '{print $1":"$2" -> "$3":"$4}')$OPTIONS>>$DOT
done

echo $'\n'>>$DOT
echo "## Left Join Relationships">>$DOT
# Left Join Tables Relationships
    SQL="select distinct join_table,lhs_table from relationships where join_table is not null"
    if [ "$MODULE_NAME" != "all" ]
    then
        AND=" and "$(echo \($WHERE\) | sed s/where//g)
    else
        AND=""
    fi
    SQL=$SQL$AND" order by lhs_table;"
    echo $SQL>>$LOG
    LEFT_JOIN_RELATIONSHIPS=$(echo $SQL | $MYSQL | grep -v lhs_table | sed s/\\t/\|/g)    
    TOTAL_LEFT_JOIN_RELATIONSHIPS=$(echo $LEFT_JOIN_RELATIONSHIPS | wc -w)
    echo "Left Join Relationhips: "$TOTAL_LEFT_JOIN_RELATIONSHIPS

    for TABLE in $LEFT_JOIN_RELATIONSHIPS
    do
        LEFT_TABLE=$(echo $TABLE | awk -F\| '{print $1}')
        RIGHT_TABLE=$(echo $TABLE | awk -F\| '{print $2}')
        SQL="select colorname from graphviz_tables where tablename='$LEFT_TABLE';"
        echo $SQL>>$LOG
        COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
        if [ "$COLOR" = "" ];then COLOR="gray";fi
        echo $LEFT_TABLE" -> "$RIGHT_TABLE" [arrowsize=.8,color=$COLOR];">>$DOT
    done


echo $'\n'>>$DOT
echo "## Right Join Relationships">>$DOT
# Right Join Tables Relationships
    SQL="select distinct join_table,rhs_table from relationships where join_table is not null"
    if [ "$MODULE_NAME" != "all" ]
    then
        AND=" and "$(echo \($WHERE\) | sed s/where//g)
    else
        AND=""
    fi
    SQL=$SQL$AND" order by rhs_table;"
    echo $SQL>>$LOG
    RIGHT_JOIN_RELATIONSHIPS=$(echo $SQL | $MYSQL | grep -v rhs_table | sed s/\\t/\|/g)
    TOTAL_RIGHT_JOIN_RELATIONSHIPS=$(echo $RIGHT_JOIN_RELATIONSHIPS | wc -w)
    echo "Right Join Relationhips: "$TOTAL_RIGHT_JOIN_RELATIONSHIPS

    for TABLE in $RIGHT_JOIN_RELATIONSHIPS
    do
        LEFT_TABLE=$(echo $TABLE | awk -F\| '{print $1}')
        RIGHT_TABLE=$(echo $TABLE | awk -F\| '{print $2}')
        SQL="select colorname from graphviz_tables where tablename='$LEFT_TABLE';"
        echo $SQL>>$LOG
        COLOR=$(echo $SQL | $MYSQL | grep -v colorname)
        if [ "$COLOR" = "" ];then COLOR="gray";fi
        echo $LEFT_TABLE" -> "$RIGHT_TABLE" [arrowsize=.8,color=$COLOR];">>$DOT
    done

TOTAL_RELATIONSHIPS=$[ $TOTAL_SIMPLE_RELATIONSHIPS + $TOTAL_LEFT_JOIN_RELATIONSHIPS + $TOTAL_RIGHT_JOIN_RELATIONSHIPS ]
echo "Total Relationships: "$TOTAL_RELATIONSHIPS

echo 'graph [fontname=monospace,fontsize=12,labelloc=b,labeljust=l,label="'$MODULE_NAME' relationships '$DB_NAME'@'$DB_HOST' '$TOTAL_TABLES' tables '$TOTAL_RELATIONSHIPS' relationships"]'>>$DOT
## Footer
echo "}">>$DOT


## Save in JPG format
if [ "$SAVE_JPG" = "true" ]
then
    PNG=$JPG
fi

dot -Tpng $DOT -o $PNG
echo "Write "$PNG
identify $PNG

function mysql2rst()
{
    if [ -f $1 ]
    then
        MYSQL_TABLE=$1
        RST_TABLE=$1.tmp

        TBL_LINE=$(cat $MYSQL_TABLE | head -1)
        TBL_HEADER=$(cat $MYSQL_TABLE | head -2 | tail -1)
        cat $MYSQL_TABLE | tail -n +4 | head -n -1 >$RST_TABLE

        echo "$TBL_LINE" >$MYSQL_TABLE
        echo "$TBL_HEADER" >>$MYSQL_TABLE
        echo "$TBL_LINE" | tr "-" "=" >>$MYSQL_TABLE

        cat $RST_TABLE | while read i
        do
            echo "$i" >>$MYSQL_TABLE
            echo "$TBL_LINE" >>$MYSQL_TABLE
        done
    fi
}

for TABLE in $(cat $RST_TMP | sort -u)
do
        echo $'\n'>>$RST
        echo $TABLE>>$RST
        RST_TITLE=$(echo $TABLE | tr [:print:] "~")
        echo $RST_TITLE>>$RST
        echo $'\n'>>$RST
        SQL="desc $TABLE;"
        #echo $SQL | $MYSQL -t | tr "+" "\ " | tr "\|" "\ " | tr "-" "=" >$TMP_PREFIX$TABLE
        echo $SQL | $MYSQL -t >$TMP_PREFIX$TABLE
        mysql2rst $TMP_PREFIX$TABLE
        cat $TMP_PREFIX$TABLE>>$RST
done

    echo $'\n'>>$RST
    RST_RELATION='Relationships'
    echo $RST_RELATION>>$RST
    RST_TITLE=$(echo $RST_RELATION | tr [:print:] "-")
    echo $RST_TITLE>>$RST
    echo $'\n'>>$RST

    ## One to many
    RST_ONE='One to many'
    echo $RST_ONE>>$RST
    RST_TITLE=$(echo $RST_ONE | tr [:print:] "~")
    echo $RST_TITLE>>$RST
    echo $'\n'>>$RST

    if [ ! "$WHERE" = " " ]
    then
        WHERE2=$WHERE$' and '
    else
        WHERE2='where '
    fi

    SQL="select lhs_table, lhs_key, rhs_table, rhs_key from relationships $WHERE2 relationship_type='one-to-many' order by lhs_table, lhs_key, rhs_table, rhs_key"
    echo $SQL>>$LOG
    #echo $SQL | $MYSQL -t | tr "+" "\ " | tr "\|" "\ " | tr "-" "=" >$TMP_PREFIX'relationships-'$MODULE_NAME
    echo $SQL | $MYSQL -t >$TMP_PREFIX'relationships-'$MODULE_NAME
    mysql2rst $TMP_PREFIX'relationships-'$MODULE_NAME
    cat $TMP_PREFIX'relationships-'$MODULE_NAME>>$RST
    echo $'\n'>>$RST

    ## Many to many
    RST_MANY='Many to many'
    echo $RST_MANY>>$RST
    RST_TITLE=$(echo $RST_MANY | tr [:print:] "~")
    echo $RST_TITLE>>$RST
    echo $'\n'>>$RST

    SQL="select lhs_table, lhs_key, rhs_table, rhs_key, join_table from relationships $WHERE2 relationship_type='many-to-many' order by lhs_table, lhs_key, rhs_table, rhs_key"
    echo $SQL>>$LOG
    #echo $SQL | $MYSQL -t | tr "+" "\ " | tr "\|" "\ " | tr "-" "=" >$TMP_PREFIX'relationships-'$MODULE_NAME
    echo $SQL | $MYSQL -t >$TMP_PREFIX'relationships-'$MODULE_NAME
    mysql2rst $TMP_PREFIX'relationships-'$MODULE_NAME
    cat $TMP_PREFIX'relationships-'$MODULE_NAME>>$RST
    echo $'\n'>>$RST

    ## Join Tables
    RST_JOIN='Join tables'
    echo $RST_JOIN>>$RST
    RST_TITLE=$(echo $RST_JOIN | tr [:print:] "~")
    echo $RST_TITLE>>$RST
    echo $'\n'>>$RST

    SQL="select join_table, join_key_lhs, join_key_rhs from relationships $WHERE2 join_table is not null and join_key_lhs is not null and join_key_rhs is not null order by join_table, join_key_lhs, join_key_rhs"
    echo 'join tables query: '$SQL>>$LOG
    #echo $SQL | $MYSQL -t | tr "+" "\ " | tr "\|" "\ " | tr "-" "=" >$TMP_PREFIX'relationships-'$MODULE_NAME
    echo $SQL | $MYSQL -t >$TMP_PREFIX'relationships-'$MODULE_NAME
    mysql2rst $TMP_PREFIX'relationships-'$MODULE_NAME
    cat $TMP_PREFIX'relationships-'$MODULE_NAME>>$RST
    echo $'\n'>>$RST


    echo $'\n'>>$RST
    RST_ERD='Entity-Relationship Diagram'
    echo $RST_ERD>>$RST
    RST_TITLE=$(echo $RST_ERD | tr [:print:] "-")
    echo $RST_TITLE>>$RST
    echo $'\n'>>$RST

    if [ "$ROTATE" = "true" ]
    then
        ROTATED_PNG='rotated_'$PNG
        convert -rotate 90 $PNG $ROTATED_PNG
        PNG=$ROTATED_PNG
    fi

    echo ".. image:: "$PNG>>$RST
    echo "   :align: center">>$RST

    PNG_X=$(identify $PNG | egrep -o "[0-9]*x" | sort -u | tr -d x)
    PNG_Y=$(identify $PNG | egrep -o "x[0-9]*" | sort -u | tr -d x)

    echo "   :width: 16cm ">>$RST

    echo $'\n'>>$RST

if [ "$SAVE_HTM" = "true" ]
then
    echo "Write "$HTM
    rst2html $RST $HTM
fi

if [ "$SAVE_PDF" = "true" ]
then
    echo "Write "$PDF
    rst2pdf $RST -o $PDF
fi

if [ "$SAVE_RST" = "false" ]
then
    rm -f $RST
fi

if [ "$SAVE_DOT" = "false" ]
then
    rm -f $DOT
fi
