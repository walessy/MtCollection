//+------------------------------------------------------------------
//| showTrades.mq4 by Squalou
//+------------------------------------------------------------------


#property copyright " Squalou"
#property link      " "

#property indicator_chart_window


//+------------------------------------------------------------------

extern int    MagicNumber=0; // if 0 then will show ALL trades for the pair
extern int    RefreshEvery=1; // refresh every given minutes, 0 will refresh at beginning a each bar only
extern color  ProfitColor = DodgerBlue;// profit rect color
extern color  LossColor   = SandyBrown;// loss rect color

//+------------------------------------------------------------------

string prefix="SQ_showTrades";

string symbol;
double pip;// Points for 1 pip;

datetime lastrefresh=0;

//+------------------------------------------------------------------
int init()
//+------------------------------------------------------------------
{
  IndicatorShortName("showTrades("+MagicNumber+")");

  int pipMultTab[]={0,0,1,10,1,10,100}; // multiplier to convert pips to Points;
  pip = pipMultTab[Digits]*Point;

  RemoveObjects(prefix);

  symbol = Symbol();
  
  if (RefreshEvery==0) RefreshEvery = Period();
  RefreshEvery *= 60;// convert to seconds

  return(0);
}

//+------------------------------------------------------------------
int deinit()
//+------------------------------------------------------------------
{
  RemoveObjects(prefix);
}

//+------------------------------------------------------------------
int start()
//+------------------------------------------------------------------
{
  // run once per bar only, no need to eat-up cpu at each tick!
  if(Time[0]<lastrefresh+RefreshEvery) return;
  lastrefresh=Time[0];

  draw_history_trades(Symbol(), MagicNumber);
  draw_open_trades(Symbol(), MagicNumber);
  draw_backtester_trades();
}

//+------------------------------------------------------------------+
void draw_history_trades(string _symbol, int _magic)
//+------------------------------------------------------------------+
{
  int i;
  
  for(i=0;i<OrdersHistoryTotal();i++)
  {
    if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) break;
    if ((_magic==0 || OrderMagicNumber()==_magic) && OrderSymbol()==_symbol) {
      if (OrderType()<=OP_SELL) 
        drawTrade(prefix, OrderTicket(), OrderType(), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice());
    }
  }
}

//+------------------------------------------------------------------+
void draw_open_trades(string _symbol, int _magic)
//+------------------------------------------------------------------+
{
  int i;
  color c;
  
  for(i=0;i<OrdersHistoryTotal();i++)
  {
    if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) break;
    if ((_magic==0 || OrderMagicNumber()==_magic) && OrderSymbol()==_symbol) {
      switch (OrderType()) {
        case OP_BUY:  drawOrderArrow(prefix+"#"+OrderTicket(), OrderOpenTime(), OrderOpenPrice(), 1, Blue); break;
        case OP_SELL: drawOrderArrow(prefix+"#"+OrderTicket(), OrderOpenTime(), OrderOpenPrice(), 1, Red); break;
      }
    }
  }
}

//--------------------------------------------------------------------------------------
void draw_backtester_trades()
//--------------------------------------------------------------------------------------
{   
   int i,j;
   string name;
   int ticket=0;
   int type;
   datetime openTime;
   double openPrice;
   datetime closeTime;
   double closePrice;

   for (i=0; i<ObjectsTotal(); i++) {
      name = ObjectName(i);
      // MT4 backtester orders are visualized by 2 arrow objects and a trendline:
      // opening orders are OBJ_ARROW objects of names "#1 buy 0.10 GBPUSD at 1.48563" or "#12 sell 0.10 GBPUSD at 1.48563"
      // closing orders are OBJ_ARROW objects of names "#1 buy 0.10 GBPUSD at 1.48563 close by tester at 1.48347"
      // trade opening arrowcode is 1, closing is 3
      // the trendline is OBJ_TREND, Blue for buy, Red for sell, of name like "#2 1.48411 -> 1.48071"
      
      if (ObjectType(name)==OBJ_TREND
          && StringGetChar(name,0)=='#' 
          && StringFind(name, " -> ", 2) > -1
        ) {
       
        ticket++;// should be extracted from the opening arrow, but doesn't actually matter, as these are backtest trades
        if (ObjectGet(name,OBJPROP_COLOR) == Blue) type = OP_BUY; else type = OP_SELL;
        drawTrade(prefix, ticket, type, ObjectGet(name,OBJPROP_TIME1), ObjectGet(name,OBJPROP_PRICE1), ObjectGet(name,OBJPROP_TIME2), ObjectGet(name,OBJPROP_PRICE2));
      }
   }

} //

/*
      //look for opening arrow objects
      if (ObjectType(name)==OBJ_ARROW 
          && StringGetChar(name,0)=='#' 
          && (StringFind(name, "buy ", 0) > -1 || StringFind(name, "sell ", 0) > -1)
          && StringFind(name, "close by tester", 0) == -1
        ) {
       
        //extract ticket
        ticket    = StrToInteger(StringSubstr(name,1,StringFind(name, " ", 1)-1));
        openTime  = ObjectGet(name,OBJPROP_TIME1);
        openPrice = ObjectGet(name,OBJPROP_PRICE1);
        //look for the matching closing arrow object

        for (j=0; j<ObjectsTotal(); j++) {
          name = ObjectName(j);
          // MT4 backtester objects:
          // opening orders are OBJ_ARROW objects of names "#1 buy 0.10 GBPUSD at 1.48563" or "#12 sell 0.10 GBPUSD at 1.48563"
          // closing orders are OBJ_ARROW objects of names "#1 buy 0.10 GBPUSD at 1.48563 close by tester at 1.48347"
          // trade opening arrowcode is 1, closing is 3, 

          //look for opening arrow objects
          if (ObjectType(name)==OBJ_ARROW 
              && StringGetChar(name,0)=='#' 
              && (StringFind(name, "buy ", 0) > -1 || StringFind(name, "sell ", 0) > -1)
              && StringFind(name, "close by tester", 0) > -1
              && ticket == StrToInteger(StringSubstr(name,1,StringFind(name, " ", 1)-1))
            ) {

            closeTime  = ObjectGet(name,OBJPROP_TIME1);
            closePrice = ObjectGet(name,OBJPROP_PRICE1);
            drawTrade(prefix, OrderTicket(), OrderType(), OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice());
            break;
          }
        }

*/

//+------------------------------------------------------------------
void drawOrderArrow(string name, datetime t, double price, int arrowcode, color c)
//+------------------------------------------------------------------
{
  ObjectCreate(name, OBJ_ARROW, 0, t, price);
  ObjectSet(name, OBJPROP_ARROWCODE,  arrowcode);
  ObjectSet(name, OBJPROP_COLOR, c);
}

//--------------------------------------------------------------------------------------
void drawTrade(string name, int ticket, int type, datetime openTime, double openPrice, datetime closeTime, double closePrice)
//--------------------------------------------------------------------------------------
{
  int pips;
  color c;
  
  pips = (closePrice-openPrice)/pip;

  if (type==OP_BUY) {
    name=name+".buy.";
    if (closePrice>=openPrice) c = ProfitColor;
    else c = LossColor;
  } else {
    pips=-pips;
    name=name+".sell.";
    if (closePrice<=openPrice) c = ProfitColor;
    else c = LossColor;
  }
  
	drawBox(name+"bg."+ticket, openTime, openPrice, closeTime, closePrice, c, 1, STYLE_SOLID, true);		// filled rect (background)
	drawBox(name+"fr."+ticket, openTime, openPrice, closeTime, closePrice, Gray, 1, STYLE_SOLID, false);	// frame (foreground)
	
	drawLbl(name+"res."+ticket, DoubleToStr(pips, 0) + " p", openTime+2*Period(), MathMin(openPrice, closePrice)-2.0*pip, 10, "Arial Black", Black, 1);

	//WindowRedraw();

} //drawTrade


//--------------------------------------------------------------------------------------
void drawBox (string objname, datetime tStart, double vStart, datetime tEnd, double vEnd, color c, int width, int style, bool bg)
//--------------------------------------------------------------------------------------
{
  if (ObjectFind(objname) == -1) {
    ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
  } else {
    ObjectSet(objname, OBJPROP_TIME1, tStart);
    ObjectSet(objname, OBJPROP_TIME2, tEnd);
    ObjectSet(objname, OBJPROP_PRICE1, vStart);
    ObjectSet(objname, OBJPROP_PRICE2, vEnd);
  }

  ObjectSet(objname,OBJPROP_COLOR, c);
  ObjectSet(objname, OBJPROP_BACK, bg);
  ObjectSet(objname, OBJPROP_WIDTH, width);
  ObjectSet(objname, OBJPROP_STYLE, style);
} /* drawBox */


//--------------------------------------------------------------------------------------
void drawLbl(string objname, string s, int LTime, double LPrice, int FSize, string Font, color c, int width)
//--------------------------------------------------------------------------------------
{
  if (ObjectFind(objname) < 0) {
    ObjectCreate(objname, OBJ_TEXT, 0, LTime, LPrice);
  } else {
    if (ObjectType(objname) == OBJ_TEXT) {
      ObjectSet(objname, OBJPROP_TIME1, LTime);
      ObjectSet(objname, OBJPROP_PRICE1, LPrice);
    }
  }

  ObjectSet(objname, OBJPROP_FONTSIZE, FSize);
  ObjectSetText(objname, s, FSize, Font, c);
} /* drawLbl*/

//--------------------------------------------------------------------------------------
void RemoveObjects(string prefix)
//--------------------------------------------------------------------------------------
{   
   int i;
   string objname;

   for (i = ObjectsTotal(); i >= 0; i--) {
      objname = ObjectName(i);
      if (StringFind(objname, prefix, 0) > -1) ObjectDelete(objname);
   }
} /* RemoveObjects*/


//+------------------------------------------------------------------+
//end

