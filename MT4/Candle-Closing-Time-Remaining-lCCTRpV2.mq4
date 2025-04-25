//+------------------------------------------------------------------+
//| Candle Closing Time Remaining-(CCTR).mq4                         |
//| Copyright 2013, Foad Tahmasebi                                   |
//| Version 2.0                                                      |
//| http://www.daskhat.ir                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Foad Tahmasebi"
#property link      "http://www.daskhat.ir"

#property indicator_chart_window
//--- input parameters
extern int       location=1;
extern int       displayServerTime=0;
extern int       fontSize=16;
extern color     colour=Red;
extern int       xOffset=10;  // Added input parameter for X offset
extern int       yOffset=10;  // Added input parameter for Y offset

//--- variables
double leftTime;
string sTime;
int days;
string sCurrentTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    EventSetTimer(1); // Set the timer to trigger every second

    //---- indicators
    if(location != 0){
       if(!ObjectCreate(0, "CandleClosingTimeRemaining-CCTR", OBJ_LABEL, 0, 0, 0))
       {
          Print("Error creating object: ", GetLastError());
          return(INIT_FAILED);
       }
       ObjectSetInteger(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_CORNER, location);
       ObjectSetInteger(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_XDISTANCE, xOffset); // Set X offset
       ObjectSetInteger(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_YDISTANCE, yOffset); // Set Y offset
       ObjectSetInteger(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_COLOR, colour);
       ObjectSetInteger(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_FONTSIZE, fontSize);
       ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_FONT, "Verdana");
    }
    //----
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    EventKillTimer(); // Kill the timer
    ObjectDelete("CandleClosingTimeRemaining-CCTR");
    Comment("");
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
    UpdateCandleClosingTime();
  }

//+------------------------------------------------------------------+
//| Update candle closing time function                              |
//+------------------------------------------------------------------+
void UpdateCandleClosingTime()
  {
    sCurrentTime = TimeToStr(TimeCurrent(), TIME_SECONDS);

    leftTime = (Period() * 60) - (TimeCurrent() - Time[0]);
    sTime = TimeToStr(leftTime, TIME_SECONDS);

    if(DayOfWeek() == 0 || DayOfWeek() == 6)
      {
        //if(location == 0)
        //  {
        //    Comment("Candle Closing Time Remaining: " + "Market Is Closed");
        //  }
        //else
        //  {
       //     ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_TEXT, "Market Is Closed");
       //   }
      }
    else
      {
        if(Period() == PERIOD_MN1 || Period() == PERIOD_W1)
          {
            days = ((leftTime / 60) / 60) / 24;
            if(location == 0)
              {
                if(displayServerTime == 0)
                  {
                    Comment("Candle Closing Time Remaining: " + days + "D - " + sTime);
                  }
                else
                  {
                    Comment("Candle Closing Time Remaining: " + days + "D - " + sTime + " [" + sCurrentTime + "]");
                  }
              }
            else
              {
                if(displayServerTime == 0)
                  {
                    ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_TEXT, days + "D - " + sTime);
                  }
                else
                  {
                    ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_TEXT, days + "D - " + sTime + " [" + sCurrentTime + "]");
                  }
              }
          }
        else
          {
            if(location == 0)
              {
                if(displayServerTime == 0)
                  {
                    Comment("Candle Closing Time Remaining: " + sTime);
                  }
                else
                  {
                    Comment("Candle Closing Time Remaining: " + sTime + " [" + sCurrentTime + "]");
                  }
              }
            else
              {
                if(displayServerTime == 0)
                  {
                    ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_TEXT, sTime);
                  }
                else
                  {
                    ObjectSetString(0, "CandleClosingTimeRemaining-CCTR", OBJPROP_TEXT, sTime + " [" + sCurrentTime + "]");
                  }
              }
          }
      }
       ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_ZORDER,0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
    // The main logic is now handled by the timer, so OnCalculate can remain empty.
    return(rates_total);
  }
//+------------------------------------------------------------------+
