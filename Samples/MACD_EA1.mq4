//+------------------------------------------------------------------+
//|                                                MACD_EA1.mq4      |
//|                                   Copyright (c) 2015-, FX509.COM |
//|                                            http://www.fx509.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2015-, FX509.COM"
#property link      "http://www.fx509.com"

// Let's set all parameters here first

extern double  Lots        = 0.1;
extern int     StopLoss    = 50;
extern int     TakeProfit  = 100;
extern int     Slippage    = 3;
extern int     MagicNumber = 123456;

extern int     MAperiod    = 21;
extern int     MACDfast    = 12;
extern int     MACDslow    = 26;
extern int     MACDsignal  = 9;


// Global variabel

int bar;      // Remember when and where you entered

//+------------------------------------------------------------------+
//
// int init() and　int deinit() isn't included here, since there is no use. 
//
//+------------------------------------------------------------------+

int start()
{

   // Creating THE Signal.
   
   
   // Define all conditions
   
   // Moving Average, Current Value, and Current Bar - 1
   double ma0, ma1;
   ma0 = iMA(NULL, 0, MAperiod, 0, MODE_SMA, PRICE_CLOSE, 0);
   ma1 = iMA(NULL, 0, MAperiod, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   //MACD Current Value and Current -1 Value
   double macd0, macd1;
   macd0 = iMACD(NULL, 0, MACDfast, MACDslow, MACDsignal, PRICE_CLOSE, MODE_MAIN, 0);
   macd1 = iMACD(NULL, 0, MACDfast, MACDslow, MACDsignal, PRICE_CLOSE, MODE_MAIN, 1);
   
   //MACD Current Signal and Current - 1 Signal
   double sig0, sig1;
   sig0 = iMACD(NULL, 0, MACDfast, MACDslow, MACDsignal, PRICE_CLOSE, MODE_SIGNAL, 0);
   sig1 = iMACD(NULL, 0, MACDfast, MACDslow, MACDsignal, PRICE_CLOSE, MODE_SIGNAL, 1);
   
   
   // Degin conditions, signals
   int sign;
   
   if(ma1 < ma0)                             // Moving Average is going up
   {
      if(macd1 <= sig1 && macd0 > sig0)      // MACD, The golden cross
      {
         sign = 1;
      }
   }
   else if(ma1 > ma0)                        // Moving Average is going down
   {
      if(macd1 >= sig1 && macd0 < sig0)      // MACD, The dead cross
      {
         sign = -1;
      }
   }
   
   
   // Orders
   
   // Tell me where I am right now.
   
   int pos = -1;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
      {
         pos = i;
         break;
      }
   }
   
   // If you current have a position
   if(pos >= 0)
   {
      //  If moving average change to down wards, then close the position
      if((OrderType() == OP_BUY && ma1 > ma0) || (OrderType() == OP_SELL && ma1 < ma0))
      {
         OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Yellow);
      }
   }
   
   int ticket = 0;    // Place order number here.
   double sl, tp;     // short loss, take profit variable here.
   
   //  If not yet have any entry and have no position
   if(bar != Bars && pos < 0)
   {
      //  sign is 1
      if(sign == 1)
      {
         sl = Ask - StopLoss * Point;
         tp = Ask + TakeProfit * Point;
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, sl, tp, NULL, MagicNumber, 0, Blue);
      }
      //  sign is -1
      if(sign == -1)
      {
         sl = Bid + StopLoss * Point;
         tp = Bid - TakeProfit * Point;
         ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, sl, tp, NULL, MagicNumber, 0, Red);
      }
      
      //  Enter position of entry
      if(ticket > 0)
      {
         bar = Bars;
      }
   }
   
//----
   return(0);
}
//+------------------------------------------------------------------+