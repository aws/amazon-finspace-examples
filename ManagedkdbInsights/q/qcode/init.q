/ so text of log messages are wide enough
\c 30 200

/ command line arguments
params:.Q.opt .z.X

show "Init Script: START"
show system "pwd"

show "Command Line Arguments..."
show params

/ START: TO BE MOVED TO SYSTEM's INIT ----------------------------------------------

/ get the name of the database given to use
dbname:first params`dbname

code_dir: "/opt/kx/app/code/"

/ cd to code directory
system "cd ", code_dir

/ link the (sibling) db dir to code dir

/ read-only code directory: getting error here
show "Link db directory to (this) code directory"
/system "ln -s /opt/kx/app/db ." 

/ TEMP TO BE REMOVED WHEN ONE CAN WRITE THE SYMLINK: cd to db dir
system "cd /opt/kx/app"

/ load the db
system "l db/", dbname

/ run this to capture counts of partitioned tables (updated global variables)
count each value each tables[]

/ MUST FINISH IN THIS DIRECTORY
system "cd ", code_dir

/ END: TO BE MOVED TO SYSTEM's INIT ----------------------------------------------

/ load libraries (relative to /opt/kx/app/code directory)

\l lib.q

show "Finished in directory..."
show system "pwd"

show "Init Script: DONE"