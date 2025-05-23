//+------------------------------------------------------------------+
//|                                        FXPT_ExportHistoryCSV.mq4 |
//|                                         modified by fxprotrader |
//|                                     http://www.fxpro-trader.com" |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, fxprotrader"
#property link      "http://www.fxpro-trader.com"
#property version   "1.00"
#property strict
// #property show_inputs
//-------- HISTORY----------------
// v1.0 Initial release(12162012)
//--------------------------------


//-----------------------------------------------------------------------------------------------//
// Modified on September 4, 2021                                                                 //
// Now you can also download historical data on Holidays when market is closed.                  //
// Decimal Places are now Automatically selected e.g. EURUSD 5, USDJPY 3, DOW JONES 1 or 2, etc. //
// Write Currency Name(Symbol as shown in Market Watch) instead of GBPUSD at line number 35.     //
// Your MT4 must be connected to your Broker to download data.                                   //
// Attach/Insert this Expert Adviser on Chart, then Remove it after One Second.                  //
// If you get Pop-up Alert message, then data is downloaded in a CSV file.                       //
// Locate your CSV file via MT4 > FILE > OPEN DATA FOLDER > MQL4 > FILES : HIST_GBPUSD_15        //
//-----------------------------------------------------------------------------------------------//



//number of bars to export per Symbol
//  int maxBars = 6418;
extern int maxBars = 500;
//test first on several pairs
// string Currencies[] = {"EURUSD","AUDUSD","GBPUSD","EURJPY","GBPJPY","USDCAD"};

string Currencies[] = {"GBPUSD"};

// then add more in the same format
// string Currencies[] = {"EURUSD","GBPJPY","GBPUSD","EURGBP","USDCHF","USDJPY","AUDJPY","CHFJPY","CADJPY","GBPCAD","EURAUD","EURCAD","NZDUSD","NZDJPY"};





string dSymbol;
double Poin;
int handle;
int justonce = 0;
int digitCount()  // MYSELF MADE THIS: COUNT NUMBER OF PIP DIGITS IN SYMBOL.
{
   if(_Digits ==5) { return 5; }
   if(_Digits ==4) { return 4; }
   if(_Digits ==3) { return 3; }
   if(_Digits ==2) { return 2; }
   if(_Digits ==1) { return 1; }
   else { return 0; }
}
int digi = digitCount();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  

      if (Point==0.00001) Poin=0.0001;
   else {
      if (Point==0.001) Poin=0.01;
      else Poin=Point;
   }
  return(0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
   offline();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void offline()
{

if (justonce<1)
{
 int count = ArraySize(Currencies);
 for (int ii=0; ii<count; ii++){
 dSymbol = Currencies[ii];   
 handle = FileOpen("Hist_"+dSymbol+"_"+Period()+".csv", FILE_BIN|FILE_WRITE);

if(handle < 1){
 Print("Err ", GetLastError());
//return(0);
}
 WriteHeader();

for(int i = 0; i < maxBars - 1; i++){
 WriteDataRow(i);
}
 FileClose(handle);
}
Alert("");
Alert("Done. ",maxBars," bars generated ",TimeMonth(TimeLocal()),TimeDay(TimeLocal()),TimeYear(TimeLocal()) ,"_",TimeHour(TimeLocal()),TimeMinute(TimeLocal()));

//return(0);

justonce=5;
}
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteData(string txt){

   FileWriteString(handle, txt,StringLen(txt));

return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteHeader(){

 WriteData("Symbol,");
 WriteData("Date,");
 WriteData("DayOfWeek,");
 WriteData("DayOfYear,");
 WriteData("Open,");
 WriteData("High,");
 WriteData("Low,");
 WriteData("Close,");
 WriteData("EMA20,EMA200,EMA50,EMA100,RSI14,CCI");
 WriteData("\n");
  
  return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteDataRow(int i){
 
 double  dSymTime, dSymOpen, dSymHigh, dSymLow, dSymClose, dSymVolume;
 int dDayofWk,dDayofYr,iDigits;
 dSymTime = (iTime(dSymbol,Period(),i));
 dDayofWk = (TimeDayOfWeek(dSymTime));
 dDayofYr = TimeDayOfYear(dSymTime);


 dSymOpen = (iOpen(dSymbol,Period(),i));

// if(TimeToStr(dSymTime, TIME_DATE)!= "1970."){
if(dSymOpen>0){
 WriteData(dSymbol+",");
 WriteData(TimeToStr(dSymTime, TIME_DATE|TIME_MINUTES)+",");
 
 iDigits=MarketInfo(Symbol(),MODE_DIGITS);
 dSymOpen = (iOpen(dSymbol,Period(),i));
 dSymHigh = (iHigh(dSymbol,Period(),i));
 dSymLow = (iLow(dSymbol,Period(),i));
 dSymClose = (iClose(dSymbol,Period(),i));
 dSymVolume = (iVolume(dSymbol,Period(),i));
 
//  int BarsInBox=8;
 
//  double PeriodHighest = High[iHighest(dSymbol,Period(),MODE_HIGH,BarsInBox+1,i)];
//  double PeriodLowest  =  Low[iLowest(dSymbol,Period(),MODE_LOW,BarsInBox+1,i)];
//  double PeriodRNG  =  (PeriodHighest-PeriodLowest)/Poin;
double EMA20  = iMA(NULL,0,20,0,1,PRICE_CLOSE,i);
double EMA200 = iMA(NULL,0,200,0,1,PRICE_CLOSE,i);
double EMA50  = iMA(NULL,0,50,0,1,PRICE_CLOSE,i);
double EMA100  = iMA(NULL,0,100,0,1,PRICE_CLOSE,i);
double RSI14 = iRSI(NULL,0,14,PRICE_CLOSE,i);
double CCI11_p3 =  iCCI(NULL,0,5,PRICE_CLOSE,i+3);



 WriteData(dDayofWk+","+dDayofYr+",");
 WriteData(DoubleToStr(dSymOpen, iDigits)+",");
 WriteData(DoubleToStr(dSymHigh, iDigits)+",");
 WriteData(DoubleToStr(dSymLow, iDigits)+",");
//  WriteData(DoubleToStr(dSymClose, iDigits)+","+PeriodHighest+","+PeriodLowest+","+PeriodRNG);
 WriteData(DoubleToStr(dSymClose, iDigits)+","+DoubleToStr(EMA20,digi)+","+DoubleToStr(EMA200,digi)+
 ","+DoubleToStr(EMA50,digi)+","+DoubleToStr(EMA100,digi)+","+DoubleToStr(RSI14,digi)+","+DoubleToStr(CCI11_p3,digi)+",");
 WriteData("\n");
 }
 
 return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



string GetPeriodName(){

   switch(Period()){
     
       case PERIOD_D1:  return("Day");
       case PERIOD_H4:  return("4_Hour");
       case PERIOD_H1:  return("Hour");
       case PERIOD_M1:  return("Minute");
       case PERIOD_M15: return("15_Minute");
       case PERIOD_M30: return("30_Minute");
       case PERIOD_M5:  return("5_Minute");
       case PERIOD_MN1: return("Month");
       case PERIOD_W1:  return("Week");
       default: return("Current_Period");
     }
  }

