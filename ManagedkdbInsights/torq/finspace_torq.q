"TorQ FinSpace Starting"

setenv[`KDBDATABASETRADE; "finspace-database"];

opts:.Q.opt .z.x;
codeDir:$[`codeDir in key opts; first opts`codeDir; "/opt/kx/app/code"];
hdbDir:$[`hdbDir in key opts; first opts`hdbDir; "/opt/kx/app/db/", getenv `KDBDATABASETRADE];

torqDir:codeDir,"/TorQ";
appDir:codeDir,"/TorQ-Amazon-FinSpace-Starter-Pack";

setenv[`TORQHOME; torqDir];
setenv[`TORQAPPHOME; appDir];

/setenv[`KDBSCRATCH; "/opt/kx/app/scratch"];
setenv[`KDBSCRATCH; "/opt/kx/app/shared/SHARED_torq/common"];
/setenv[`KDBSCRATCH; "/tmp"];

/setenv[`KDBDATABASETRADE; "finspace-database"];
setenv[`KDBFINSPACE; "true"];

setenv[`KDBCODE; torqDir,"/code"];
setenv[`KDBCONFIG; torqDir,"/config"];
setenv[`KDBLOG; getenv[`KDBSCRATCH],"/logs"];
setenv[`KDBHTML; torqDir,"/html"]
setenv[`KDBLIB; torqDir,"/lib"];
setenv[`KDBHDB; hdbDir];

setenv[`KDBAPPCONFIG; appDir,"/appconfig"];
setenv[`KDBAPPCODE; appDir,"/code"];

setenv[`KDBBASEPORT; "17000"];
setenv[`KDBSTACKID; "-stackid ",getenv`KDBBASEPORT];
setenv[`TORQPROCESSES; getenv[`KDBAPPCONFIG],"/process.csv"];

/ TODO - remove this once we can pass in the env file as a cmd line parameter
system"l ",torqDir,"/torq.q";

"TorQ FinSpace Started"
