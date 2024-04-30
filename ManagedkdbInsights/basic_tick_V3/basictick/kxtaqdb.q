\S 104831
.z.zd:17 2 6 
dst:`:hdb
end:.z.D
num:10
stm:0D09:30
etm:0D17:30
nt:58000    / trades per stock per day
qpt:5      / quotes per trade
vex:1.0005 / average volume growth per day
ccf:0.5    / correlation coefficient

info :([sym:`$()]name:())
info,:(`AMD;"ADVANCED MICRO DEVICES")
info,:(`AIG;"AMERICAN INTL GROUP INC")
info,:(`AAPL;"APPLE INC COM STK")
info,:(`DELL;"DELL INC")
info,:(`DOW;"DOW CHEMICAL CO")
info,:(`GOOG;"GOOGLE INC CLASS A")
info,:(`HPQ;"HEWLETT-PACKARD CO")
info,:(`INTC;"INTEL CORP")
info,:(`IBM;"INTL BUSINESS MACHINES CORP")
info,:(`MSFT;"MICROSOFT CORP")
info,:(`ORCL;"ORACLE CORPORATION")
info,:(`PEP;"PEPSICO INC")
info,:(`PRU;"PRUDENTIAL FINANCIAL INC")
info,:(`SBUX;"STARBUCKS CORPORATION")
info,:(`TXN;"TEXAS INSTRUMENTS")
s:exec sym from info
n:exec name from info
p:33 27 84 12 20 72 36 51 42 29 35 22 59 63 18
w:3 2 5 2 1 6 2 3 2 3 2 4 2 4 1

pi:acos -1
int01:{til[x]%x-1}
normalrand:{(cos 2*pi*x?1.)*sqrt -2*log x?1.}
rnd:{.01*floor .5+x*100}
xrnd:{exp x*-2|2&normalrand y}
shiv:{(last x)&(first x)|asc x+-2+(count x)?5}
vol:{10+x?90}

dates@:where 2<=mod[;7]dates:reverse end-til 1+num
cnt:count info 
nd:count dates

choleski:{[A]
 if[1>=n:count A;:sqrt A];
 p:ceiling n%2;
 X:p#'p#A;
 Y:p _'p#A;
 Z:p _'p _A;
 T:(flip Y) mmu inv X;
 L0:n #' (choleski X) ,\: (n-1)#0.0;
 L1:choleski Z-T mmu Y;
 L0,(T mmu p#'L0),'L1}

choleskicor:{
 n:count y;
 c:.1|(n,n)#1.,x,((n-2)#0.),x;
 (choleski c)mmu y}

volprof:{
 p:1.75;
 c:floor x%3;
 b:(c?1.)xexp p;
 e:2-(c?1.)xexp p;
 m:(x-2*c)?1.;
 neg[x]?m,.5*b,e}

cgen:{while[any(p<reciprocal y)|y<p:prds 1.+x*normalrand z];p}

makeprices:{
 r:cgen[.0375;3]each cnt#nd;
 r:choleskicor[ccf]1.,'r;
 (p%first each r)*r*\:1.1 xexp int01 nd+1}

makevolumes:{
 v:cgen[.03;3]x;
 a:vex xexp neg x;
 .05|2&v*a+((reciprocal last v)-a)*int01 x}

prices:makeprices nd+1
volumes:floor cnt*nt*qpt*makevolumes nd

/ qx index, qb/qa margins, qp price, qn position
batch:{[x;len]
  p0:prices[;x];
  p1:prices[;x+1];
  d:xrnd[0.0003]len;
  qx::len?where w;
  qb::rnd len?1.0;
  qa::rnd len?1.0;
  n:where each qx=/:til cnt;
  s:p0*{prds 1.0,-1_ x}each d n;
  s:s + (p1-last each s)*{int01 count x} each s;
  qp::len#0.0;
  (qp n):rnd s;
  qn::0}

{
 len:volumes x;
 batch[x;len];
 sa:string dx:dates x;
 r:asc stm+floor(etm-stm)*volprof len;
 cn:count n:where 0=cx:len?qpt;
 t:([]time:dx+shiv r n;sym:s qx n;price:qp n;size:vol cn);
 cn:count n:where cx<qpt;
 n:til cn:count cx;
 q:([]time:dx+r n;sym:s qx n;bid:(qp-qb)n;ask:(qp+qa)n;bsize:vol cn;asize:vol cn);
 (` sv dst,`$sa,"/trade/")set .Q.en[dst]update`p#sym from`sym`time xasc t;
 (` sv dst,`$sa,"/quote/")set .Q.en[dst]update`p#sym from`sym`time xasc q;
 0N!"Generated trade|quote records: ",.Q.s1 count each (t;q); 
 } each -1_til nd;

.Q.gc[];
