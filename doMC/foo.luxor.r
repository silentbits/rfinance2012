############################# LOOP ##########################################

#for (i in seq(2,22,2)) 
#{  
#  for (j in seq(25,55,3))
#  { 
 
i = 10  
j = 35
############################ VARIABLES ######################

FAST = i
SLOW = j

############################## ORIGINAL SCRIPT ##############



#!/usr/bin/Rscript --vanilla
#
# Jan Humme (@opentrades) - June 2012
#
# Tested and found to work correctly using blotter r1082
#
# From Jaekle & Tamasini: A new approach to system development and portfolio optimisation (ISBN 978-1-905641-79-6)
#
# Paragraph 3.2: luxor without any optimizations, but with $30 tnx costs + slippage

.qty=100000
.th=0.0005
.txn=-30
#.txn=0

initDate = '2002-10-21'
.from='2002-10-21'
#.to='2008-07-04'
#.to='2003-12-31'
.to='2008-07-04'

####

s = 'luxor'
p = 'forex'
a = 'IB1'

options(width = 240)
#Sys.setenv(TZ="GMT")

###

require(quantstrat)

currency(c('GBP', 'USD'))

exchange_rate(c('GBPUSD'), tick_size=0.0001)

#setSymbolLookup.FI('~/R.symbols/', 'GBPUSD')
setSymbolLookup.FI('~/Desktop', 'GBPUSD')

###

getSymbols('GBPUSD', from=.from, to=.to, verbose=FALSE)
GBPUSD = to.minutes30(GBPUSD)
GBPUSD = align.time(to.minutes30(GBPUSD), 1800)

###

initPortf(p, symbols='GBPUSD', initDate=initDate, currency='USD')
initAcct(a, portfolios=p, initDate=initDate, currency='USD')

###

initOrders(p, initDate=initDate)

### strategy ######################################################################

strategy(s, store=TRUE)

### indicators

add.indicator(s, name = "SMA",
	arguments = list(
		x = quote(Cl(mktdata)),
		n = FAST
	),
	label="nFast"
)

add.indicator(s, name="SMA",
	arguments = list(
		x = quote(Cl(mktdata)),
		n = SLOW
	),
	label="nSlow"
)

### signals

add.signal(s, 'sigCrossover',
	arguments = list(
		columns=c("nFast","nSlow"),
		relationship="gte"
	),
	label='long'
)

add.signal(s, 'sigCrossover',
	arguments = list(
		columns=c("nFast","nSlow"),
		relationship="lt"
	),
	label='short'
)

### rules

add.rule(s, 'ruleSignal',
	arguments=list(sigcol='long' , sigval=TRUE,
		replace=TRUE,
		orderside='short',
		ordertype='market',
		TxnFees=.txn,
		orderqty='all',
		orderset='ocoshort'
	),
	type='exit',
	label='Exit2LONG'
)

add.rule(s, 'ruleSignal',
	arguments=list(sigcol='short', sigval=TRUE,
		replace=TRUE,
		orderside='long' ,
		ordertype='market',
		TxnFees=.txn,
		orderqty='all',
		orderset='ocolong'
	),
	type='exit',
	label='Exit2SHORT')

add.rule(s, 'ruleSignal',
	arguments=list(sigcol='long' , sigval=TRUE,
		replace=FALSE,
		orderside='long' ,
		ordertype='stoplimit',
		prefer='High',
		threshold=.th,
		TxnFees=0,
		orderqty=+.qty,
		orderset='ocolong'
	),
	type='enter',
	label='EnterLONG'
)

add.rule(s, 'ruleSignal',
	arguments=list(sigcol='short', sigval=TRUE,
		replace=FALSE,
		orderside='short',
		ordertype='stoplimit',
		prefer='Low',
		threshold=-.th,
		TxnFees=0,
		orderqty=-.qty,
		orderset='ocoshort'
	),
	type='enter',
	label='EnterSHORT'
)

#

###############################################################################

#applyStrategy(s, p, verbose = FALSE)
applyStrategy(s, p, prefer='Open', verbose = FALSE)

updatePortf(p, Symbols='GBPUSD', ,Dates=paste('::',as.Date(Sys.time()),sep=''))

###############################################################################

#chart.Posn(p, "GBPUSD")

#print(getOrderBook(p))

#txns <- getTxns(p, 'GBPUSD')
#txns
##txns$Net 
#cat('Net profit:', sum(txns$Net.Txn.Realized.PL), '\n')

stratStats = tradeStats(p, 'GBPUSD')

cat('Number of transactions fast ', i, 'and slow ',j, 'is: ', stratStats$Num.Txns, '\n')


suppressWarnings(rm("order_book.forex",pos=.strategy))
suppressWarnings(rm("account.IB1","portfolio.forex",pos=.blotter))
suppressWarnings(rm("GBPUSD","p","a","initEq","initDate", ".qty", ".th", ".txn"))



#  }
#}
