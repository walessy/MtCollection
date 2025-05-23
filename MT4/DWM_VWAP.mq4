//+------------------------------------------------------------------+
//|                                                         VWAP.mq4 |
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

extern bool Show_Daily=true;
extern bool Show_Weekly=true;
extern bool Show_Monthly=true;

double Daily[], Weekly[], Monthly[];
double WP[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Daily);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Weekly);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Monthly);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,WP);

 return(0);
}

int deinit()
{

 return(0);
}

double CalcDaily(int pos)
{
 int index=pos;
 double Sum1=0.;
 double Sum2=0.;
 int DT=TimeDay(Time[pos]);
 while (TimeDay(Time[index])==DT && index<Bars)
 {
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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
 while (TimeDayOfWeek(Time[index+1])<=TimeDayOfWeek(Time[index]) && index<Bars)
 {
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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
 while (TimeMonth(Time[index])==DT && index<Bars)
 {
  Sum1+=WP[index];
  Sum2+=Volume[index];
  
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
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  WP[pos]=Volume[pos]*(High[pos]+Low[pos]+Close[pos])/3;
  
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  if (Show_Daily)
  {
   Daily[pos]=CalcDaily(pos);
  }
  
  if (Show_Weekly)
  {
   Weekly[pos]=CalcWeekly(pos);
  }
  
  if (Show_Monthly)
  {
   Monthly[pos]=CalcMonthly(pos);
  }

  pos--;
 } 
 return(0);
}

