.utl.require"qib/app/ib.q"
syms:("SSSS";enlist csv)0:.Q.dd[.utl.PKGSLOADED"qib"]`app`syms.csv

out"Connecting"
.ib.connect[`$"127.0.0.1";7497;1];
$[.ib.isConnected[]; out"Connected"; [out"Connection failed";exit 1]]

.ib.nextSubId:1

subscribe:{[cont]
	out"Subscribing to ",format cont;
	if[count ?[`contract;{(=;x;enlist y)}.'flip(key;value)@\:cont;0b;()];out"Already subscribed";:];
	`contract upsert cont:cont,enlist[`id]!enlist .ib.nextSubId;
	upsert[;select id,sym:symbol from enlist cont] each `trade`quote;
	.ib.reqMktData[cont`id;cont _`id;"";0b];
	.ib.nextSubId+:1;
 };


serverVersion:{out"Server version: ",string .ib.serverVersion[]};
currentTime:{out"Requesting current time";.ib.reqCurrentTime[]};
TwsConnectionTime:{out"TWS connection time: ",.ib.TwsConnectionTime[]}
reqMktData:{out"Requesting mkt data"; subscribe each syms;}
reqAccountUpdates:{out"Requesting account updates";.ib.reqAccountUpdates[1b;first .ib.managedAccounts];}
reqPositions:{out"Requesting positions";.ib.reqPositions[];}
reqAllOpenOrders:{out"Requesting all open orders";.ib.reqAllOpenOrders[]};
reqContractDetails:{out"Requesting contract details";.ib.reqContractDetails[1;first contract]}
reqManagedAccts:{out"Requesting managed accounts";.ib.reqManagedAccts[]}
reqExecutions:{.ib.reqExecutions[first 1?100;enlist[`acctCode]!enlist first .ib.managedAccounts]}
reqHistoricalData:{
	// void IBClient::reqHistoricalData(TickerId id, const Contract &contract, const IBString &endDateTime, const IBString &durationStr, const IBString &barSizeSetting, const IBString &whatToShow, int useRTH, int formatDate, const TagValueListSPtr &chartOptions)
	tickerId:1;
	contract:`symbol`secType`exchange`currency!(`IBM;`STK;`SMART;`USD);
	endDateTime:"z"$2017.01.01;
	durationStr:"1 D";
	barSizeSetting:"1 day";
	whatToShow:"MIDPOINT";
	useRTH:1b;
	.ib.reqHistoricalData[tickerId;contract;endDateTime;durationStr;barSizeSetting;whatToShow;useRTH];
 };

start:{
	serverVersion[];
	currentTime[];
	TwsConnectionTime[];
	reqMktData[];
	reqAccountUpdates[];
	reqPositions[];
	reqExecutions[];
	reqHistoricalData[];
	reqAllOpenOrders[];
	reqContractDetails[];
 };

started:0b

.ib.reg[`nextValidId] {
	.ib.callbacks[`nextValidId];
	if[not started;start[];started::1b];
 };

\
reqManagedAccts[];
.ib.onrecv:{[fname;args] show (fname;args)};
\c 50 500
.ib.reqContractDetails[1;enlist[`conId]!enlist 272093]

out"Placing order"

c:(enlist`conId)!enlist 272093
.ib.reqContractDetails[100;c]

lmtOrder:`action`totalQuantity`orderType`lmtPrice!(`BUY;1000;`LMT;0.01)
mktOrder:`action`totalQuantity`orderType!(`BUY;1000;`MKT)

/ .ib.placeOrder[1^.ib.nextId;first contract] lmtOrder
/ .ib.reqMktData[4;cont _`conId;"";0b];
