\d .fx

/ fx tick schema
schema:([Date:`timestamp$()]Time:`timestamp$();Open:`float$();High:`float$();Low:`float$();Close:`float$();Volume:`long$());
syms: `id xkey ("SF"; enlist ",") 0: `:sample/data/pairs.csv;
{x set `Date xkey ("PFFFFJ"; enlist ",") 0:`$":sample/data/fx/",ssr[string x;"\/";""],"20191230.csv"} each exec id from syms;

// generate inverse data for missing major pairs
majors: ("USD";"EUR";"JPY";"GBP";"AUD";"CAD";"CHF";"NZD");
{{sym:`$ x,"/",y; if[(not x like y) and 101h=type .fx[sym];invSym:`$ y,"/",x;`.fx.syms insert (sym; 0.0001);.fx[sym]: `Date xkey select Date, Open:1%Open, High:1%Low, Low:1%High, Close:1%Close, Volume from .fx[invSym]]}[;x] each majors} each majors;

\d .

book:([]sym:`symbol$();MDEntrySize:`long$();MDEntryPx:`float$();MDEntryType:`byte$();FloorCode:`int$());
book1Agg:([]sym:`symbol$();MDEntrySize:`long$();MDEntryPx:`float$();MDEntryType:`byte$();FloorCode:`int$());
book2Agg:([]sym:`symbol$();MDEntrySize:`long$();MDEntryPx:`float$();MDEntryType:`byte$();FloorCode:`int$());

lastTime:.z.t;
nowSticks:()!();

// initialise kdb+tick 
// all tables in the top level namespace (`.) become publish-able
// tables that can be published can be seen in .u.w
\l tick/u.q
.u.init[];

// generate fx book
generateBook:{[sym]
	depth:6;
	ns:nowSticks[`$"stream_",string sym];
	pip:.fx.syms[sym]`pipsize;
	spread: {{x + (y * z)}[x;y;] (neg 1+til z),1+til z};
  	t:([]sym:(depth*2)#sym;
		MDEntrySize:1000000 * 1 + rand each (depth*2)#6;
		MDEntryPx: spread[ns`Close;pip;depth];
		MDEntryType:(depth#0x00),depth#0x01;
		MDTWAP: spread[(sum ns`Close`Open`High`Low) % 4;pip;depth];
		FloorCode:(2*depth)?(0ni;1i;2i;3i));

	update MDVWAP: {x wavg y}'[sum each MDEntrySize;MDEntryPx] from t
	}


generateOHLC:{[sym;dir]
	refs:dir sym;sym:`$"stream_",string s:sym;
	nowMin: `minute$.z.p;
	refSticks: select from refs where nowMin=`minute$Date;
	if[count refSticks;
		/ nowStick is not current
		if[$[not count nowSticks[sym]; 1b; not nowMin=`minute$nowSticks[sym]`Date];
			/ if existing publish the ref stick before moving on
			nowSticks[sym]:`Date`Time`Open`High`Low`Close`Volume!((2#`timestamp$.z.d+`time$nowMin),(4#(first refSticks)`Open),0)
		];
	
		ref: first refSticks;
		ns: nowSticks[sym];
		/ TODO should take steps to high low instead of flitting
		ns[`Close]: first (ref`Low)+1?(ref`High)-ref`Low;
		ns[`High]: max ns[`High],ns[`Close];
		ns[`Low]: min ns[`Low],ns[`Close];
		nowSticks[sym]: ns;
		:enlist ns,enlist[`sym]!enlist s
	];
 ()
 }


mode:{ $[x~`realtime;
			[
				.awscust.z.ts:{};
				upd:upd_function
			];
			[
				.awscust.z.ts:timer_function;
				upd:{[t;x] }
			]
		]
 }

upd_function:{[t;x]
	if[t~`trade;
		.u.pub[`vwap; select vwap:wavg[price;size] by sym from t];
	  ];
	if[t~`example;
		.u.pub[`example; select avg number by sym from t];
	  ];
 }

timer_function:{

	// publish up to 10 random fx syms
	fxsyms: neg[1+rand 9]?exec id from .fx.syms;

	generateOHLC[;`.fx]each fxsyms;

	// publish book
	tag:{update state:x from y};
	.u.pub[`book;tag[`stream] 	  raze generateBook each fxsyms];
	.u.pub[`book1Agg;tag[`stream] raze generateBook each fxsyms];
	.u.pub[`book2Agg;tag[`stream] raze generateBook each fxsyms];

 }


// snap function handlers
.stream.snap:`book`book1Agg`book2Agg`vwap`example!(
	{raze generateBook each $[-11h=type x;exec id from .fx.syms;x]};
	{raze generateBook each $[-11h=type x;exec id from .fx.syms;x]};
	{raze generateBook each $[-11h=type x;exec id from .fx.syms;x]};
	{([]sym:10?`3;price:10?200)};
	{([]sym:10?`3;price:10?200)}	
 );

// add .u.snap to support snapshots
.u.snap:{[x]
	update state:`snap from .stream.snap[x 0]x 1
 }

.u.subSnap:{[x;y]
 	.u.sub .(x;y);
	.u.snap (x;y)
 }	

system"t 5000"

/ load datafilter analytics
\l sample/dfilt.q_
\l sample/querybuilder.q


qryBuilderQueries: `id xkey ("SS"; enlist "\t") 0: `$":sample/data/qryBuilderQueries.csv";
fxPips: ("SF"; enlist ",") 0: `$":sample/data/fxSyms.csv";
tradePanels: `id xkey ("SS"; enlist "\t") 0: `$":sample/data/tradePanels.csv";
tradeBook: ("SJFXIFF"; enlist ",") 0: `$":sample/data/tradeBook.csv";

mode[`timer];

\
q)h:hopen`::6812
q)upd:{[tabname;tabdata] show tabname; show tabdata}
q)h(`.u.subSnap;`book;`)
