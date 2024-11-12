"initdb script: START"
\c 2000 2000

/ what is the current directory?
\cd /opt/kx/app/code
\cd

system "l ", .aws.akdbp, "/", .aws.akdb

"initdb script: END"