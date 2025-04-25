//+------------------------------------------------------------------+
//|                                            Murrey_Math_MT_VG.mq4 |
//|                       Copyright © 2004, Vladislav Goshkov (VG).  |
//|                                           4vg@mail.ru            |
//#property copyright "Vladislav Goshkov (VG)."
//#property link      "4vg@mail.ru"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+
// https://forex-station.com/viewtopic.php?p=1295413887#p1295413887
// https://forex-station.com/viewtopic.php?p=1295414530#p1295414530
// modified by banzai
// July 10th, 2020
// not for sale, rent, auction, nor lease

#property copyright "www,forex-tsd.com"
#property link      "www.forex-station.com"
#property indicator_chart_window
enum timeFrames
{
   tf_cu,         // Current time frame
   tf_m1,         // 1 minute
   tf_m2,         // 2 minutes
   tf_m3,         // 3 minutes
   tf_m4,         // 4 minutes
   tf_m5,         // 5 minutes
   tf_m6,         // 6 minutes
   tf_m10 =10,    // 10 minutes
   tf_m12 =12,    // 12 minutes
   tf_m15 =15,    // 15 minutes
   tf_m20 =20,    // 20 minutes
   tf_m30 =30,    // 30 minutes
   tf_h1  =60,    // 1 hour
   tf_h2  =120,   // 2 hours
   tf_h3  =180,   // 3 hours
   tf_h4  =240,   // 4 hours
   tf_h6  =360,   // 6 hours
   tf_h8  =480,   // 8 hours
   tf_h12 =720,   // 12 hours
   tf_d1  =1440,  // daily
   tf_w1  =10080, // weekly
   tf_mn  =43200  // monthly
};
extern timeFrames TimeFrame                      = tf_d1;
extern color      UpCandleColor                  = clrDeepSkyBlue;
extern color      DownCandleColor                = clrRed;
extern color      NeutralCandleColor             = clrDimGray;
extern int        DrawingWidth                   = 1;
extern bool       FilledCandles                  = FALSE;
extern bool       BoxedWick                      = TRUE;
extern string     UniqueCandlesIdentifier        = "H4";
extern int        barsToDraw                     = 0;
extern bool       DisplayOHLC                    = true;
//+------------------------------------------------------------------------------------------------------------------+
//template code start1
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "CC"; //don't forget to change here
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 33;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";
bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
int WorkTime=0,Periods=0;
//template code end1
int timeFrame;
//+------------------------------------------------------------------+
//template code start2
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
class VisibilityCotroller //don't change anything here
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
      ObjectSetInteger(0,buttonId,OBJPROP_YDISTANCE, button_y);
      ObjectSetInteger(0,buttonId,OBJPROP_XDISTANCE, button_x);
// put init() here
   timeFrame = MathMax(TimeFrame,_Period);
         if (MathFloor(timeFrame/Period())*Period() != timeFrame) timeFrame = Period();
      
   }
//+------------------------------------------------------------------+
   void DeInit() //don't change anything here
   {
      ObjectDelete(ChartID(), buttonId);
      deleteCandles(); Comment("");
   }
//+------------------------------------------------------------------+
   bool HandleButtonClicks() //don't change anything here
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }
//+------------------------------------------------------------------+
   bool IsRecalcNeeded() //don't change anything here
   {
      return recalc;
   }
//+------------------------------------------------------------------+
   void ResetRecalc() //don't change anything here
   {
      recalc = false;
   }
//+------------------------------------------------------------------+
   bool IsVisible() //don't change anything here
   {
      return show_data;
   }
//+------------------------------------------------------------------+
private: //don't change anything here much
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName = GenerateIndicatorName("CustomCandle"); //don't forget to change the name here
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
// don't forget to change the name below
   visibility.Init("show_hide_CustomCandle", IndicatorName, btn_text, button_x, button_y);

// dont put init () here

   return 0;
};
//+------------------------------------------------------------------+
int deinit()  
  {
   visibility.DeInit();
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    
    //put deinit () here
      deleteCandles(); Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
      start();
}
//+------------------------------------------------------------------+
//template end2
int start2()
{
   int i;
   int barsToDisplay = Bars;
    
   for (i=Bars; i>= 0; i--)
   {
      datetime startingTime;
      int      barsPassed;
      int      startOfThisBar;

         while (true)
         {
            if (timeFrame<60)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+toHour(TimeHour(Time[i])));
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            if (timeFrame<1440)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+" 00:00");
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            startingTime   = iTime(NULL,timeFrame,iBarShift(NULL,timeFrame,Time[i])); if (timeFrame==tf_w1) startingTime+=1440*60;
            startOfThisBar = iBarShift(NULL,0,startingTime);
            break;
         }         
         
            datetime startTime  = Time[startOfThisBar];
            datetime endTime    = startTime+(timeFrame-1)*60;
            double   openPrice  = Open[startOfThisBar];
            double   closePrice = Close[startOfThisBar];
            double   highPrice  = High[startOfThisBar];
            double   lowPrice   = Low[startOfThisBar];
         
            for (int k=1; Time[startOfThisBar-k]>0 && Time[startOfThisBar-k]<=endTime; k++)
               {
                  closePrice = Close[startOfThisBar-k];
                  highPrice  = MathMax(highPrice,High[startOfThisBar-k]);
                  lowPrice   = MathMin(lowPrice,Low[startOfThisBar-k]);
               }
         
         if (i<barsToDisplay) drawCandle(startTime,endTime,openPrice,closePrice,highPrice,lowPrice);
   }
   
   if (DisplayOHLC) Comment("Current "+Symbol()+" "+timeFrameToString(timeFrame)+" candle : ",DoubleToStr(openPrice,Digits),",",DoubleToStr(highPrice,Digits),",",DoubleToStr(lowPrice,Digits),",",DoubleToStr(closePrice,Digits));
   return (0);
}
// end of start2()
//+------------------------------------------------------------------+
int start()
{
//template start3
   visibility.HandleButtonClicks();
   visibility.ResetRecalc();
   
   if (visibility.IsVisible())
   {
//template end3

//put start() here
   static int oldBars = 0;
   int counted_bars=IndicatorCounted();
   int i,limit;
   string name;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (oldBars!=Bars)
           {
               deleteCandles();
                  oldBars = Bars;
                  limit   = Bars-1;
           }               
   
   int barsToDisplay = barsToDraw; if (barsToDisplay<=0) barsToDisplay=Bars;
   for (i=limit; i>= 0; i--)
   {
      datetime startingTime;
      int      barsPassed;
      int      startOfThisBar;

         while (true)
         {
            if (timeFrame<60)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+toHour(TimeHour(Time[i])));
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            if (timeFrame<1440)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+" 00:00");
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            startingTime   = iTime(NULL,timeFrame,iBarShift(NULL,timeFrame,Time[i])); if (timeFrame==tf_w1) startingTime+=1440*60;
            startOfThisBar = iBarShift(NULL,0,startingTime);
            break;
         }         
         
            datetime startTime  = Time[startOfThisBar];
            datetime endTime    = startTime+(timeFrame-1)*60;
            double   openPrice  = Open[startOfThisBar];
            double   closePrice = Close[startOfThisBar];
            double   highPrice  = High[startOfThisBar];
            double   lowPrice   = Low[startOfThisBar];
         
            for (int k=1; Time[startOfThisBar-k]>0 && Time[startOfThisBar-k]<=endTime; k++)
               {
                  closePrice = Close[startOfThisBar-k];
                  highPrice  = MathMax(highPrice,High[startOfThisBar-k]);
                  lowPrice   = MathMin(lowPrice,Low[startOfThisBar-k]);
               }
         
         if (i<barsToDisplay) drawCandle(startTime,endTime,openPrice,closePrice,highPrice,lowPrice);
   }
   
   if (DisplayOHLC) Comment("Current "+Symbol()+" "+timeFrameToString(timeFrame)+" candle : ",DoubleToStr(openPrice,Digits),",",DoubleToStr(highPrice,Digits),",",DoubleToStr(lowPrice,Digits),",",DoubleToStr(closePrice,Digits));
// end of start()

//template start4
      if( (WorkTime != Time[0]) || (Periods != Period()) ) 
      {
         if (show_data) //on button function
         {
          start2();
         } //if (show_data)
         else //off button function
         {
          deleteCandles(); Comment("");
         }
      }
   }
   else //again, put the off button function here again
   {
          deleteCandles(); Comment("");
   }
//template end4  
   return(0);
}
//+------------------------------------------------------------------+
string toHour(int hour)
{
   if (hour<10)
         return(" 0"+hour+":00");
   else  return(" " +hour+":00");
}
//+------------------------------------------------------------------+
void deleteCandles()
{
   int searchLength = StringLen(UniqueCandlesIdentifier);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
         if (StringSubstr(name,0,searchLength) == UniqueCandlesIdentifier)  ObjectDelete(name);
   }
}
//+------------------------------------------------------------------+
void drawCandle(datetime startTime, datetime endTime, double openPrice, double closePrice, double highPrice, double lowPrice)
{
string name;
   color candleColor = NeutralCandleColor;
   
      if (closePrice>openPrice) candleColor = UpCandleColor;
      if (closePrice<openPrice) candleColor = DownCandleColor;
      
      if (candleColor == UpCandleColor)   
         name = UniqueCandlesIdentifier+":Up"+startTime;
      else
         name = UniqueCandlesIdentifier+":Down"+startTime;

      if (ObjectFind(name)==-1)      
          ObjectCreate(name,OBJ_RECTANGLE,0,startTime,openPrice,endTime,closePrice);
             ObjectSet(name,OBJPROP_PRICE1,openPrice);
             ObjectSet(name,OBJPROP_PRICE2,closePrice);
             ObjectSet(name,OBJPROP_TIME1 ,startTime);
             ObjectSet(name,OBJPROP_TIME2 ,endTime);
             ObjectSet(name,OBJPROP_COLOR ,candleColor);
             ObjectSet(name,OBJPROP_STYLE ,STYLE_DASHDOTDOT);
             ObjectSet(name,OBJPROP_BACK  ,FilledCandles);
             ObjectSet(name,OBJPROP_WIDTH ,DrawingWidth);
                   
      datetime wickTime = startTime+(endTime-startTime)/2;
      double   upPrice  = MathMax(closePrice,openPrice);
      double   dnPrice  = MathMin(closePrice,openPrice);
      
      if (BoxedWick)
      {
         string   wname = name+":+";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_RECTANGLE,0,startTime,highPrice,endTime,lowPrice);
                ObjectSet(wname,OBJPROP_PRICE1,highPrice);
                ObjectSet(wname,OBJPROP_PRICE2,lowPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,startTime);
                ObjectSet(wname,OBJPROP_TIME2 ,endTime);
                ObjectSet(wname,OBJPROP_COLOR ,candleColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_DOT);
                ObjectSet(wname,OBJPROP_BACK  ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);
      }
      else
      {
         wname = name+":+";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_TREND,0,wickTime,highPrice,wickTime,upPrice);
                ObjectSet(wname,OBJPROP_PRICE1,highPrice);
                ObjectSet(wname,OBJPROP_PRICE2,upPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
                ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
                ObjectSet(wname,OBJPROP_COLOR ,candleColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
                ObjectSet(wname,OBJPROP_RAY   ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);

         wname = name+":-";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_TREND,0,wickTime,dnPrice,wickTime,lowPrice);
                ObjectSet(wname,OBJPROP_PRICE1,dnPrice);
                ObjectSet(wname,OBJPROP_PRICE2,lowPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
                ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
                ObjectSet(wname,OBJPROP_COLOR ,candleColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
                ObjectSet(wname,OBJPROP_RAY   ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);
      }                
}
//+-------------------------------------------------------------------
string sTfTable[] = {"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
int    iTfTable[] = {1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//+------------------------------------------------------------------+

