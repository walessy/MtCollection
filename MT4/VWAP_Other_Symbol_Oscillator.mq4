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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Blue
#property indicator_color6 Blue

input string symbol = "EURUSD"; // Symbol
input bool Show_m5 = true;
input bool Show_m15 = true;
input bool Show_m30 = true;
input bool Show_H4 = true;
input bool Show_Daily=true;
input bool Show_Weekly=true;
input int bars_limit = 1000; // Bars limit

double H4[], Daily[], Weekly[], m5[], m15[], m30[];
double RawH4[], RawDaily[], RawWeekly[], RawMonthly[], RawM5[], RawM15[], RawM30[];
double WP[];

int init()
{
   IndicatorBuffers(14);
   
   IndicatorShortName("VWAP Oscillator");
   IndicatorDigits(Digits);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Daily);
   SetIndexLabel(0, "Daily");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Weekly);
   SetIndexLabel(1, "Weekly");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,H4);
   SetIndexLabel(2, "H4");

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,m30);
   SetIndexLabel(3, "m30");
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,m15);
   SetIndexLabel(4, "m15");
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,m5);
   SetIndexLabel(5, "m5");
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,RawDaily);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,RawWeekly);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexBuffer(8,RawMonthly);
   SetIndexStyle(13,DRAW_NONE);
   SetIndexBuffer(13,RawH4);

   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,RawM30);
   SetIndexStyle(10,DRAW_NONE);
   SetIndexBuffer(10,RawM15);
   SetIndexStyle(11,DRAW_NONE);
   SetIndexBuffer(11,RawM5);
   
   SetIndexStyle(12,DRAW_NONE);
   SetIndexBuffer(12,WP);
   
   
   return(0);
}

int deinit()
{
   return(0);
}

int GetHour(datetime date)
{
   MqlDateTime current_time;
   TimeToStruct(date, current_time);
   return current_time.hour;
}

double CalcCustom(int pos, ENUM_TIMEFRAMES tf)
{
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   
   int DT = iBarShift(_Symbol, tf, Time[pos]);
   while (index < Bars && iBarShift(_Symbol, tf, Time[index]) == DT)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2 != 0.)
   {
      return Sum1 / Sum2;
   }
   return EMPTY_VALUE;
}

double CalcH4(int pos)
{
   int index = pos;
   double Sum1 = 0.;
   double Sum2 = 0.;
   
   int DT = GetHour(Time[pos]);
   while (index < Bars && GetHour(Time[index])==DT)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

double CalcDaily(int pos)
{
   int index=pos;
   double Sum1=0.;
   double Sum2=0.;
   int DT=TimeDay(Time[pos]);
   while (index < Bars && TimeDay(Time[index])==DT)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

double CalcWeekly(int pos)
{
   int index=pos+1;
   double Sum1=WP[pos];
   double Sum2=Volume[pos];
   while (index < Bars && TimeDayOfWeek(Time[index+1])<=TimeDayOfWeek(Time[index]))
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2!=0.)
   {
   return (Sum1/Sum2);
   }
   else
   {
   return (EMPTY_VALUE);
   }
}

double CalcMonthly(int pos)
{
   int index=pos;
   double Sum1=0.;
   double Sum2=0.;
   int DT=TimeMonth(Time[pos]);
   while (index < Bars && TimeMonth(Time[index])==DT)
   {
      if (WP[index] != EMPTY_VALUE)
      {
         Sum1 += WP[index];
         Sum2 += Volume[index];
      }
      
      index++;
   }
   
   if (Sum2!=0.)
   {
      return (Sum1/Sum2);
   }
   else
   {
      return (EMPTY_VALUE);
   }
}

int start()
{
   if (Bars <= 1) 
   {
      return 0;
   }
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
   {
      return -1;
   }
   int limit = ExtCountedBars > 1 ? MathMin(bars_limit, Bars - ExtCountedBars - 1) : MathMin(bars_limit, Bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = pos == 0 ? 0 : iBarShift(_Symbol, _Period, Time[pos]);
      if (index < 0)
      {
         continue;
      }
      WP[pos] = iVolume(symbol, _Period, index) * (iHigh(symbol, _Period, index) + iLow(symbol, _Period, index) + iClose(symbol, _Period, index)) / 3;
      RawM5[pos] = CalcCustom(pos, PERIOD_M5);
      RawM15[pos] = CalcCustom(pos, PERIOD_M15);
      RawM30[pos] = CalcCustom(pos, PERIOD_M30);

      RawH4[pos]=CalcH4(pos);
      RawDaily[pos]=CalcDaily(pos);
      RawWeekly[pos]=CalcWeekly(pos); 
      RawMonthly[pos]=CalcMonthly(pos);
      if (Show_H4)
         H4[pos] = RawH4[pos] - RawMonthly[pos];
      if (Show_Daily)
         Daily[pos]= RawDaily[pos]-RawMonthly[pos];  
      if (Show_Weekly)
         Weekly[pos]= RawWeekly[pos]-RawMonthly[pos]; 
      if (Show_m30 && _Period <= PERIOD_M30)
      {
         m30[pos] = RawM30[pos] - RawMonthly[pos];
      }
      if (Show_m15 && _Period <= PERIOD_M15)
      {
         m15[pos] = RawM15[pos] - RawMonthly[pos];
      }
      if (Show_m5 && _Period <= PERIOD_M5)
      {
         m5[pos] = RawM5[pos] - RawMonthly[pos];
      }
   } 
   return 0;
}