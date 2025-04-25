//+------------------------------------------------------------------+
//|                                             _HOD_LOD_Close_1.mq4 |
//|                                          Copyright © 2010, Okane |
//|                                                                  |
//| Indicator to display yesterday's high, low and close levels      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Okane"
#property link      ""

#property indicator_chart_window

//  Global constants here
#define SUNDAY            0

//---- input parameters
extern color     colHiLo=Purple;
extern color     colClose=Purple;

//---- global variables
datetime    dtD1LastCandle=0;
datetime    dtLastCandle=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  //---- draw initial SRDC lines and close line
  create_day_current();

//----
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

  ObjectDelete("Day_Hi");
  ObjectDelete("Day_Lo");
  ObjectDelete("Yes_Close");  
  
//----
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  int    i;
//----

  //do at the start of each bar (whatever period)
  if(dtLastCandle!=iTime(NULL,0,0)) // only at the start of every bar 
    {
    dtLastCandle=iTime(NULL,0,0);
    //-- extend the SRDC and close lines
    ObjectSet("Day_Hi",OBJPROP_TIME2,TimeCurrent());
    ObjectSet("Day_Lo",OBJPROP_TIME2,TimeCurrent());
    ObjectSet("Yes_Close",OBJPROP_TIME2,TimeCurrent());
  
    WindowRedraw();
    }

  //do at the start of each day 
  if(dtD1LastCandle!=iTime(NULL,PERIOD_D1,0))
    {
    dtD1LastCandle=iTime(NULL,PERIOD_D1,0);
    //-- create new High, Low, Close lines
    ObjectDelete("Day_Hi");
    ObjectDelete("Day_Lo");
    ObjectDelete("Yes_Close");  
    create_day_current();
    }

//----
  return(0);
  }
//+------------------------------------------------------------------+


//--------------------------------------------------------------
// Function to create High, Low, Close lines
//  
//
void create_day_current()
  {
  if(TimeDayOfWeek(   iTime(NULL,0,iBarShift(NULL,0,iTime(NULL,PERIOD_D1,0))+1)  )==SUNDAY)
    {
    ObjectCreate("Day_Hi",OBJ_TREND,0,iTime(NULL,PERIOD_D1,1)+1,iHigh(NULL,PERIOD_D1,2),TimeCurrent(),iHigh(NULL,PERIOD_D1,2));
    ObjectCreate("Day_Lo",OBJ_TREND,0,iTime(NULL,PERIOD_D1,1)+1,iLow(NULL,PERIOD_D1,2),TimeCurrent(),iLow(NULL,PERIOD_D1,2));
    ObjectCreate("Yes_Close",OBJ_TREND,0,iTime(NULL,PERIOD_D1,0)-Period(),iClose(NULL,PERIOD_D1,2),TimeCurrent(),iClose(NULL,PERIOD_D1,2));
    }
  else
    {
    ObjectCreate("Day_Hi",OBJ_TREND,0,iTime(NULL,PERIOD_D1,1)+1,iHigh(NULL,PERIOD_D1,1),TimeCurrent(),iHigh(NULL,PERIOD_D1,1));
    ObjectCreate("Day_Lo",OBJ_TREND,0,iTime(NULL,PERIOD_D1,1)+1,iLow(NULL,PERIOD_D1,1),TimeCurrent(),iLow(NULL,PERIOD_D1,1));
    ObjectCreate("Yes_Close",OBJ_TREND,0,iTime(NULL,PERIOD_D1,0)-Period(),iClose(NULL,PERIOD_D1,1),TimeCurrent(),iClose(NULL,PERIOD_D1,1));
    }
  ObjectSet("Day_Hi",OBJPROP_COLOR,colHiLo);
  ObjectSet("Day_Hi",OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("Day_Hi",OBJPROP_WIDTH,1);
  ObjectSet("Day_Hi",OBJPROP_RAY,false);
  ObjectSet("Day_Lo",OBJPROP_COLOR,colHiLo);
  ObjectSet("Day_Lo",OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("Day_Lo",OBJPROP_WIDTH,1);
  ObjectSet("Day_Lo",OBJPROP_RAY,false);
  ObjectSet("Yes_Close",OBJPROP_COLOR,colClose);
  ObjectSet("Yes_Close",OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("Yes_Close",OBJPROP_WIDTH,1);
  ObjectSet("Yes_Close",OBJPROP_RAY,false);
  
  return;
  }


