 //+------------------------------------------------------------------+
//| WK MN DY LINES.mq4                                                |
//|   Simpler than it looked :)   codobro                             |
//+-------------------------------------------------------------------+

#property copyright "WK NM DY LINES, c 2008 codobro"
#property indicator_chart_window

double Weekly[][6];
double Monthly[][6];
double Daily[][6];

double W1H;
double W1L;
double MNH;
double MNL;
double D1H;
double D1L;
//+--------
int init() {
   return(0);
   }

//+----
int deinit() {

   ObjectDelete("Weekly_Line_High");
   ObjectDelete("Monthly_Line_High");
   ObjectDelete("Daily_Line_High");
   ObjectDelete("Weekly_Line_Low");
   ObjectDelete("Monthly_Line_Low");
   ObjectDelete("Daily_Line_Low");

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start() {

   int shift, i;

   for (shift=Bars-1; shift>=0; shift--)

      ArrayCopyRates(Weekly, Symbol(), 10080);
      TimeToStr(CurTime());           

      W1H = Weekly[0][3];
      W1L = Weekly[0][2];
      
      ObjectCreate("Weekly_Line_High", OBJ_HLINE,0, CurTime(),W1H);
      ObjectSet("Weekly_Line_High", OBJPROP_COLOR, SteelBlue);
      ObjectSet("Weekly_Line_High", OBJPROP_STYLE, STYLE_SOLID);

      ObjectCreate("Weekly_Line_Low", OBJ_HLINE,0, CurTime(),W1L);
      ObjectSet("Weekly_Line_Low", OBJPROP_COLOR, SteelBlue);
      ObjectSet("Weekly_Line_Low", OBJPROP_STYLE, STYLE_SOLID);

      ArrayCopyRates(Monthly, Symbol(), 43200);
      TimeToStr(CurTime());           

      MNH = Monthly[0][3];
      MNL = Monthly[0][2];

      ObjectCreate("Monthly_Line_High", OBJ_HLINE,0, CurTime(),MNH);
      ObjectSet("Monthly_Line_High", OBJPROP_COLOR, Orange);
      ObjectSet("Monthly_Line_High", OBJPROP_STYLE, STYLE_SOLID);

      ObjectCreate("Monthly_Line_Low", OBJ_HLINE,0, CurTime(),MNL);
      ObjectSet("Monthly_Line_Low", OBJPROP_COLOR, Orange);
      ObjectSet("Monthly_Line_Low", OBJPROP_STYLE, STYLE_SOLID);

      ArrayCopyRates(Daily, Symbol(), 1440);
      TimeToStr(CurTime());           

      D1H = Daily[0][3];
      D1L = Daily[0][2];      

      ObjectCreate("Daily_Line_High", OBJ_HLINE,0, CurTime(),D1H);
      ObjectSet("Daily_Line_High", OBJPROP_COLOR, White);
      ObjectSet("Daily_Line_High", OBJPROP_STYLE, STYLE_SOLID);
      
      ObjectCreate("Daily_Line_Low", OBJ_HLINE,0, CurTime(),D1L);
      ObjectSet("Daily_Line_Low", OBJPROP_COLOR, White);
      ObjectSet("Daily_Line_Low", OBJPROP_STYLE, STYLE_SOLID);




       return(0);
   
}
//+------------------------------------------------------------------+ 