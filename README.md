# SugarGraphviz

Draw entity diagram relationships of Sugar modules including custom
tables. The graph is draw from records in relationships table of Sugar
database.

## Dependeces

You need graphviz.

## Example

### Calls
 
![SugarCRM 5.2 Calls Relationships](https://raw.githubusercontent.com/gcoop-libre/sugar-graphviz/master/examples/sugar52/sugar52-relationships-calls.png "SugarCRM 5.2 Calls Relationships")

## Usage

First edit mininal ``config.php`` with database setting.

### ``sugar-graphviz.sh``

    Draw single module:

        ./sugar-graphviz.sh [options] -c -m module_name

        -u, --user     Specify user of database.
        -p, --password Specify password of database.
        -B, --database Specify database name.
        -h, --host     Specify host of database.
        -c, --config   Load configuration from config.php
        -m, --module   Specify a name of module to draw.
        -d, --dot      Save dot file.
        -f, --pdf      Generate pdf with table structure and relationships.
        -g, --graphviz Create graphviz tables.
        -j, --jpg      Save graph in jpeg format (default png).
        -t, --htm      Generate html with table structure and relationships.
        -o, --rotate   Rotate image in document pdf/html.
        -r, --rst      Generate rst with table structure and relationships.
        -?, --help     This Help.

### ``sugar-modules.sh``

    Draw all modules:

        ./sugar-modules [options]

        -u, --user     Specify user of database.
        -p, --password Specify password of database.
        -B, --database Specify database name.
        -P, --port     Specify port of database.
        -h, --host     Specify host of database.
        -c, --config   Load configuration from config.php
        -?, --help

### ``sugar-relationships.sh``

    Draw all modules in single graph for human readable:

        ./sugar-relationships.sh [options]

        -u, --user     Specify user of database.
        -p, --password Specify password of database.
        -B, --database Specify database name.
        -P, --port     Specify port of database.
        -h, --host     Specify host of database.
        -c, --config   Load configuration from config.php
        -i, --ignore   File with tablenames to ignore
        -?, --help

