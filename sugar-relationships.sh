#!/bin/bash

CONFIG='config.php'
DB_PASS='sugar'
DB_USER='sugar'
DB_NAME='sugar'
DB_PORT='3306'
DB_HOST='localhost'
IGNORE_TABLES='ignore-tables'

function usage()
{
    echo
    echo "Use:"
    echo "# $0 [options]"
    echo " -u, --user     Specify user of database."
    echo " -p, --password Specify password of database."
    echo " -B, --database Specify database name."
    echo " -P, --port     Specify port of database."
    echo " -h, --host     Specify host of database."
    echo " -c, --config   Load configuration from config.php"
    echo " -i, --ignore   File with tablenames to ignore"
    echo " -?, --help"
    echo
    exit 1
}

while [ ! -z "$1" ]
do
  case "$1" in
    -u|--user)
      DB_USER=$2
      shift 2
      ;;  
    -p|--password)
      DB_PASS=$2
      shift 2
      ;;  
    -P|--port)
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
    -i|--ignore)
      IGNORE_TABLES=$2
      shift 2
      ;;
    -?|--help)
      usage
      ;;  
  esac
done

SQL='mysql --default-character-set=utf8 -u'$DB_USER' -p'$DB_PASS' -B '$DB_NAME' -h '$DB_HOST' --port '$DB_PORT 

cat graphviz-colors.sql | $SQL

DOT='sugar-relationships.dot'
PNG='sugar-relationships.png'

MYSQL_TABLES='mysql_tables.tmp'
SUGAR_TABLES='sugar_tables.tmp'
SUGAR_JOIN_TABLES='sugar_join_tables.tmp'
SUGAR_NODES='sugar_nodes.tmp'

touch $IGNORE_TABLES
TOTAL_IGNORE=$(wc -l $IGNORE_TABLES)

echo "show tables" | $SQL -N | grep -v -w -f $IGNORE_TABLES | sort -u >$MYSQL_TABLES
wc -l $MYSQL_TABLES

echo "
(
  SELECT    lhs_table AS tablename
  FROM      relationships
  WHERE     lhs_table != 'users'
  GROUP BY  lhs_table
)
UNION ALL
(
  SELECT    rhs_table AS tablename
  FROM      relationships
  WHERE     lhs_table != 'users'
  GROUP BY  rhs_table
)
ORDER BY tablename
" | $SQL -N | grep -v -w -f $IGNORE_TABLES | sort -u >$SUGAR_TABLES

TOTAL_TABLES=$(wc -l $SUGAR_TABLES)
TOTAL_JOIN_TABLES=$(wc -l $SUGAR_JOIN_TABLES)
cat $SUGAR_TABLES $SUGAR_JOIN_TABLES | sort -u >$SUGAR_NODES
TOTAL_NODES=$(wc -l $SUGAR_NODES)

echo "digraph sugar {" >$DOT

echo "graph [ratio=fill, overlap=false, bgcolor=white, fontname=inconsolata, fontsize=12, labelloc=b, labeljust=l, label=\"db: $DB_NAME@$DB_HOST\ntotal tables: $TOTAL_TABLES\ntotal join tables: $TOTAL_JOIN_TABLES\ntotal ignore: $TOTAL_IGNORE\ntotal nodes: $TOTAL_NODES \"]" >>$DOT
echo "node [penwidth=2,color=gray]" >>$DOT
echo "edge [penwidth=2,color=gray]" >>$DOT
echo "rankdir=TB" >>$DOT

echo "
SELECT  DISTINCT
        join_table
FROM    relationships
WHERE   join_table != 'users'
" | $SQL -N | grep -v -w -f $IGNORE_TABLES | sort -u >$SUGAR_JOIN_TABLES

echo "TRUNCATE TABLE graphviz_tables;" | $SQL

cat $SUGAR_NODES | sort -u | grep -v "NULL" | while read NODO
do
    echo "
    INSERT INTO   graphviz_tables
                  (tablename,colorname)
    SELECT        '$NODO',(
                            SELECT    colorname
                            FROM      graphviz_colors
                            ORDER BY  RAND()
                            LIMIT 1
                            );
    " | $SQL
done

N='\n'

cat $SUGAR_NODES | while read NODO
do
    TABLE_EXISTS=false
    echo "DESC $NODO" | $SQL -N | awk '{print $1}'  >$$NODO 2>/dev/null
    LINES=$(wc -l $$NODO | awk '{print $1}')

    if [ $LINES -ne 0 ]
    then
        TABLE_EXISTS=true
        echo "DESC $NODO" | $SQL -N | awk '{print $1,$3}' | grep NO | grep -v $NODO | awk '{print $1}'  >$$NODO 2>/dev/null
        LINES=$(wc -l $$NODO | awk '{print $1}')
        
        if [ $LINES -eq 0 ]
        then
          TABLE_EXISTS=false
        fi
    fi

    if [ $TABLE_EXISTS == "true" ]
    then
      COLOR=$(echo "
      SELECT    colorname
      FROM      graphviz_tables
      WHERE     tablename='$NODO';
      " | $SQL -N)

      echo -n $NODO" [shape=record,color=\"$COLOR\",label=\"{$NODO|" >>$DOT

      cat $$NODO | while read CAMPO
      do
       echo -n $CAMPO$N >>$DOT
      done

      echo -n "}\"];" >>$DOT
      echo "">>$DOT
    else
      echo "TABLE DON'T EXISTS "$NODO
    fi
done

echo "" >>$DOT

cat $SUGAR_TABLES | while read NODO1
do
  TABLAS=$(echo "
  SELECT DISTINCT(rhs_table)
  FROM   relationships
  WHERE  lhs_table = '$NODO1'
  AND    relationship_type='one-to-many'
  AND    rhs_table NOT IN
  (
    SELECT lhs_table
    FROM   relationships
    WHERE  relationship_type='many-to-many'
  )
  AND    rhs_table NOT IN
  (
    SELECT rhs_table
    FROM   relationships
    WHERE  relationship_type='many-to-many'
  );
  " | $SQL -N | grep -v -w -f $IGNORE_TABLES )

  for NODO2 in $TABLAS
  do
    COLOR=$(echo "
    SELECT  colorname
    FROM    graphviz_tables
    WHERE   tablename='$NODO1'
    " | $SQL -N)
    echo $NODO1" -> "$NODO2" [color=\"$COLOR\"];" >>$DOT
  done
done

cat $SUGAR_TABLES | while read NODO1
do
  TABLAS=$(echo "
  SELECT DISTINCT(rhs_table)
  FROM   relationships
  WHERE  lhs_table = '$NODO1'
  AND    relationship_type='one-to-many'
  AND    rhs_table IN
  (
    SELECT lhs_table
    FROM   relationships
    WHERE  relationship_type='many-to-many'
  )
  AND    rhs_table IN
  (
    SELECT rhs_table
    FROM   relationships
    WHERE  relationship_type='many-to-many'
  );
  " | $SQL -N | grep -v -w -f $IGNORE_TABLES )

 for NODO2 in $TABLAS
 do
   COLOR=$(echo "
   SELECT colorname
   FROM   graphviz_tables
   WHERE  tablename='$NODO1';
   " | $SQL -N | grep -v -w -f $IGNORE_TABLES )
   echo $NODO1" -> "$NODO2" [color=\"$COLOR\"];" >>$DOT
 done
done

cat $SUGAR_TABLES | while read NODO1
do
 TABLAS=$(echo "
  SELECT DISTINCT(rhs_table)
  FROM   relationships
  WHERE  lhs_table = '$NODO1'
  AND    relationship_type='many-to-many'
  AND    join_table IS NULL;
  " | $SQL -N | grep -v -w -f $IGNORE_TABLES )

 for NODO2 in $TABLAS
 do
   COLOR=$(echo "
   SELECT colorname
   FROM   graphviz_tables
   WHERE  tablename='$NODO1';
   " | $SQL -N | grep -v -w -f $IGNORE_TABLES )
   echo $NODO1" -> "$NODO2" [color=\"$COLOR\"];" >>$DOT
 done
done

cat $SUGAR_TABLES | while read NODO1
do
 echo "
  (
    SELECT
            DISTINCT
            lhs_table,
            join_table
    FROM    relationships
    WHERE   lhs_table = '$NODO1'
    AND     relationship_type='many-to-many'
    AND     join_table IS NOT NULL
  )
  UNION
  (
    SELECT  DISTINCT
            join_table,
            rhs_table
    FROM    relationships
    WHERE   lhs_table = '$NODO1'
    AND     relationship_type='many-to-many'
    AND     join_table IS NOT NULL
  );
  " | $SQL -N | grep -v -w -f $IGNORE_TABLES 
done | while read NODOS
do
    NODO1=$(echo $NODOS | awk '{print $1}')
    NODO2=$(echo $NODOS | awk '{print $2}')
    COLOR=$(echo "
    SELECT  colorname
    FROM    graphviz_tables
    WHERE   tablename='$NODO1';
    " | $SQL -N)
    echo $NODO1" -> "$NODO2" [color=\"$COLOR\"];" >>$DOT
done

echo "}" >>$DOT

dot -Tpng -Gsplines=ortho $DOT >$PNG

