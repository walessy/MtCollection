//+------------------------------------------------------------------+
//|                                               Complex_Common.mq4 |
//|                                              SemSemFX@rambler.ru |
//|              http://onix-trade.net/forum/index.php?showtopic=107 |
//|                 http://forum.alpari-idc.ru/viewtopic.php?t=46916 |
//+------------------------------------------------------------------+
#property copyright "SemSemFX@rambler.ru"
#property link      "http://onix-trade.net/forum/index.php?showtopic=107"
#property link      "http://forum.alpari-idc.ru/viewtopic.php?t=46916"

#property indicator_separate_window
#property indicator_buffers 8
/*
//"USD:Green; EUR:Maroon; GBP:Red; CHF:Blue; JPY:Pink; AUD:Aqua; NZD:Yellow; CAD: Purple"

#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 clrNONE
#property indicator_color5 clrNONE
#property indicator_color6 clrNONE
#property indicator_color7 clrNONE
#property indicator_color8 clrNONE
*/
input bool USD_display=true;
input bool EUR_display=true;
input bool GBP_display=true;
input bool CHF_display=true;
input bool JPY_display=true;
input bool AUD_display=true;
input bool NZD_display=true;
input bool CAD_display=true;

//---- buffers
double USD[];
double EUR[];
double GBP[];
double CHF[];
double JPY[];
double AUD[];
double NZD[];
double CAD[];

//---- parameters
// for monthly
int mn_per = 12;
int mn_fast = 3;
// for weekly
int w_per = 9;
int w_fast = 3;
// for daily
int d_per = 5;
int d_fast = 3;
// for H4
int h4_per = 12;
int h4_fast = 2;
// for H1
int h1_per = 24;
int h1_fast = 8;
// for M30
int m30_per = 16;
int m30_fast = 2;
// for M15
int m15_per = 16;
int m15_fast = 4;
// for M5
int m5_per = 12;
int m5_fast = 3;
// for M1
int m1_per = 30;
int m1_fast = 10;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorShortName("USD:Green; EUR:Maroon; GBP:Red; CHF:Blue; JPY:Pink; AUD:Aqua; NZD:Yellow; CAD: Purple");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,USD);
   SetIndexLabel(0, "USD"); 
   if(USD_display){SetIndexStyle(0,DRAW_LINE,EMPTY,2,clrGreen);}
   else{SetIndexStyle(0,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,EUR);
   SetIndexLabel(1, "EUR"); 
   if(EUR_display){SetIndexStyle(1,DRAW_LINE,EMPTY,2,clrMaroon);}
   else{SetIndexStyle(1,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,GBP);
   SetIndexLabel(2, "GBP");
   if(GBP_display){SetIndexStyle(2,DRAW_LINE,EMPTY,2,clrRed);}
   else{SetIndexStyle(2,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,CHF);
   SetIndexLabel(3, "CHF"); 
   if(CHF_display){SetIndexStyle(3,DRAW_LINE,EMPTY,2,clrBlue);}
   else{SetIndexStyle(3,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,JPY);
   SetIndexLabel(4, "JPY");
   if(JPY_display){SetIndexStyle(4,DRAW_LINE,EMPTY,2,clrPink);}
   else{SetIndexStyle(4,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(5,DRAW_LINE); 
   SetIndexBuffer(5,AUD);
   SetIndexLabel(5, "AUD");
   if(AUD_display){SetIndexStyle(5,DRAW_LINE,EMPTY,2,clrAqua);}
   else{SetIndexStyle(5,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(6,DRAW_LINE); 
   SetIndexBuffer(6,NZD);
   SetIndexLabel(6, "NZD");
   if(NZD_display){SetIndexStyle(6,DRAW_LINE,EMPTY,2,clrYellow);}
   else{SetIndexStyle(6,DRAW_LINE,EMPTY,2,clrNONE);};

   SetIndexStyle(7,DRAW_LINE); 
   SetIndexBuffer(7,CAD);
   SetIndexLabel(7, "CAD");
   if(CAD_display){SetIndexStyle(7,DRAW_LINE,EMPTY,2,clrPurple);}
   else{SetIndexStyle(7,DRAW_LINE,EMPTY,2,clrNONE);};

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
     int limit;
     int counted_bars=IndicatorCounted();
  //---- ïðîâåðêà íà âîçìîæíûå îøèáêè
     if(counted_bars<0) return(-1);
  //---- ïîñëåäíèé ïîñ÷èòàííûé áàð áóäåò ïåðåñ÷èòàí
     if(counted_bars>0) counted_bars-=10;
     limit=Bars-counted_bars;
  //---- îñíîâíîé öèêë
      int Price=6;
      int Mode=3;
      int per1,per2;
      switch(Period())
        {
         case 1:     per1 = m1_per; per2 = m1_fast; break;
         case 5:     per1 = m5_per; per2 = m5_fast; break;
         case 15:    per1 = m15_per;per2 = m15_fast; break;
         case 30:    per1 = m30_per;per2 = m30_fast; break;
         case 60:    per1 = h1_per; per2 = h1_fast; break;
         case 240:   per1 = h4_per; per2 = h4_fast; break;
         case 1440:  per1 = d_per;  per2 = d_fast; break;
         case 10080: per1 = w_per;  per2 = w_fast; break;
         case 43200: per1 = mn_per; per2 = mn_fast; break;
        }
     for(int i=0; i<limit; i++)
       {
        USD[i]=
            (iMA("EURUSD",0,per1,0,Mode,Price,i)-
            iMA("EURUSD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("GBPUSD",0,per1,0,Mode,Price,i)-
            iMA("GBPUSD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("USDCHF",0,per2,0,Mode,Price,i)-
            iMA("USDCHF",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("USDJPY",0,per2,0,Mode,Price,i)-
            iMA("USDJPY",0,per1,0,Mode,Price,i))*100
            ;
        EUR[i]=
            (iMA("EURUSD",0,per2,0,Mode,Price,i)-
            iMA("EURUSD",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("EURGBP",0,per2,0,Mode,Price,i)-
            iMA("EURGBP",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("EURCHF",0,per2,0,Mode,Price,i)-
            iMA("EURCHF",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("EURJPY",0,per2,0,Mode,Price,i)-
            iMA("EURJPY",0,per1,0,Mode,Price,i))*100
            ;
        GBP[i]=
            (iMA("GBPUSD",0,per2,0,Mode,Price,i)-
            iMA("GBPUSD",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("EURGBP",0,per1,0,Mode,Price,i)-
            iMA("EURGBP",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("GBPCHF",0,per2,0,Mode,Price,i)-
            iMA("GBPCHF",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("GBPJPY",0,per2,0,Mode,Price,i)-
            iMA("GBPJPY",0,per1,0,Mode,Price,i))*100
            ;
        CHF[i]=
            (iMA("USDCHF",0,per1,0,Mode,Price,i)-
            iMA("USDCHF",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("EURCHF",0,per1,0,Mode,Price,i)-
            iMA("EURCHF",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("GBPCHF",0,per1,0,Mode,Price,i)-
            iMA("GBPCHF",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("CHFJPY",0,per2,0,Mode,Price,i)-
            iMA("CHFJPY",0,per1,0,Mode,Price,i))*100
            ;
        JPY[i]=
            (iMA("USDJPY",0,per1,0,Mode,Price,i)-
            iMA("USDJPY",0,per2,0,Mode,Price,i))*100
            +
            (iMA("EURJPY",0,per1,0,Mode,Price,i)-
            iMA("EURJPY",0,per2,0,Mode,Price,i))*100
            +
            (iMA("GBPJPY",0,per1,0,Mode,Price,i)-
            iMA("GBPJPY",0,per2,0,Mode,Price,i))*100
            +
            (iMA("CHFJPY",0,per1,0,Mode,Price,i)-
            iMA("CHFJPY",0,per2,0,Mode,Price,i))*100
            ;
        AUD[i]=
            (iMA("AUDUSD",0,per2,0,Mode,Price,i)-
            iMA("AUDUSD",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("EURAUD",0,per1,0,Mode,Price,i)-
            iMA("EURAUD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("AUDNZD",0,per2,0,Mode,Price,i)-
            iMA("AUDNZD",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("AUDJPY",0,per2,0,Mode,Price,i)-
            iMA("AUDJPY",0,per1,0,Mode,Price,i))*100
            ;
        NZD[i]=
            (iMA("NZDUSD",0,per2,0,Mode,Price,i)-
            iMA("NZDUSD",0,per1,0,Mode,Price,i))*10000
            +
            (iMA("AUDNZD",0,per1,0,Mode,Price,i)-
            iMA("AUDNZD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("EURNZD",0,per1,0,Mode,Price,i)-
            iMA("EURNZD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("NZDJPY",0,per2,0,Mode,Price,i)-
            iMA("NZDJPY",0,per1,0,Mode,Price,i))*100
            ;
        CAD[i]=
            (iMA("USDCAD",0,per1,0,Mode,Price,i)-
            iMA("USDCAD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("EURCAD",0,per1,0,Mode,Price,i)-
            iMA("EURCAD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("AUDCAD",0,per1,0,Mode,Price,i)-
            iMA("AUDCAD",0,per2,0,Mode,Price,i))*10000
            +
            (iMA("CADJPY",0,per2,0,Mode,Price,i)-
            iMA("CADJPY",0,per1,0,Mode,Price,i))*100
            ;
       }
       
  //----
    return(0);
  }
//+------------------------------------------------------------------+