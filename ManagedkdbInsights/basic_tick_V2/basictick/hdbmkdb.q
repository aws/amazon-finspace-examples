show "HDB: START"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
dbname:first params`dbname
tphostfile:first params`tphostfile

/ assign paths
dbpath: "/opt/kx/app/db/", dbname

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the code path

\l query.q
\l example.schema.q

/ END load libraries

/ If database exists, mount it, AFTER having loaded the empty schema
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; .Q.l `$dbpath;];
    [show "no database at: ", dbpath;]]

/ must be in this path for db reads to work
\cd /opt/kx/app

/ count partitioned tables
count each value each tables[]

show "HDB: DONE"
