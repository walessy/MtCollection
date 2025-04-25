//+------------------------------------------------------------------+
//|                    Multi Pair Pivot Point Scanner Alerts 1.4.mq4 |
//|                                                         NickBixy |
//|                           https://www.mql5.com/en/users/nickbixy |
//+------------------------------------------------------------------+
#property copyright "NickBixy"
#property link      "https://www.mql5.com/en/users/nickbixy"
#property version   "1.6"
#property strict
#property description "Indicator Scans Multiple Symbols Looking For When The Price Crosses A Pivot Point or xx points near Then It Alerts The Trader."
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum pivotTypes
  {
   Standard,
   Camarilla,
   Woodie,
   Fibonacci
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum yesnoChoiceToggle
  {
   No,
   Yes
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum alertChoiceToggle
  {
   none,//None
   alert,//Alerts Only (Popup alert)
   notification,//Notifications Only (Mobile alert)
   both//Both Alerts and Notifications
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum alertMode
  {
   CrossAlerts,
   PointsNearAlerts
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enabledisableChoiceToggle
  {
   Disable,
   Enable
  };
  
input int refreshTime=5;//Refresh check every x Seconds
input string pivotPointHeader="-----------------Pivot Point Settings------------------------------------------";//----- Pivot Point Settings
input pivotTypes pivotSelection=Fibonacci;//Pivot Point Type
input alertMode alertModeSelection=PointsNearAlerts;//Alert Mode - Cross/Points Near (Bid Price Cross Or Near)
input int xxPoints=50;//Points Near Pivot - For Alert Mode PointsNearAlerts
input string pointsNearMessage="is Near, ";//PointsNear Alert Msg
input string crossedMessage="Crossed, ";//Cross Alert Msg

input string symbolHeader="-----------------Symbol Settings------------------------------------------";//----- Symbol Settings
input string symbols="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY"; //Symbols To Scan
input string symbolPrefix=""; //Symbol Prefix
input string symbolSuffix=""; //Symbol Suffix

input string timeFrameHeader="-----------------Time Frame Alert---------------------------------------";//----- Pivot Points Time Frame Alert Settings
input yesnoChoiceToggle useDailyPivotAlert=No; //Use Daily TF Pivot Points Alerts
input yesnoChoiceToggle useWeeklyPivotAlert=Yes; //Use Weekly TF Pivot Points Alerts
input yesnoChoiceToggle useMonthlyPivotAlert=No; //Use Monthly TF Pivot Points Alerts

input string printoutAndAlertHeader="-----------------Alert/Printout----------------------------------------------";//----- Alert/Printout Settings
input int alertInternalMinutes=60;//Alert Interval Wait Time In Minutes
input  alertChoiceToggle  alertOptions=both;//Alert Notification Options
input yesnoChoiceToggle printOutPivotPoints=No;//Print Out Pivot Values - For Testing Values
input int printOutPivotPointsSymbolIndex=0;//Index Value Of Symbol To Print Out

input string showAlertsHeader="-----------------Enable/Disable Alerts For Specified Pivot Point----------------------------------";//----- Enable/Disable Pivot Points Alerts Settings
input string showAlertsStandardPivotHeader="Standard Pivot Point--------------------------------------------";//----- Standard Pivot Point Daily Settings
input string StandardDailyPivotHeader="-----------------Standard Daily";//----- Standard Daily
input enabledisableChoiceToggle showStandardPivotDailyR3=Enable;//Standard Daily Pivot R3
input enabledisableChoiceToggle showStandardPivotDailyR2=Enable;//Standard Daily Pivot R2
input enabledisableChoiceToggle showStandardPivotDailyR1=Enable;//Standard Daily Pivot R1
input enabledisableChoiceToggle showStandardPivotDailyPP=Enable;//Standard Daily Pivot PP
input enabledisableChoiceToggle showStandardPivotDailyS1=Enable;//Standard Daily Pivot S1
input enabledisableChoiceToggle showStandardPivotDailyS2=Enable;//Standard Daily Pivot S2
input enabledisableChoiceToggle showStandardPivotDailyS3=Enable;//Standard Daily Pivot S3
input string StandardWeeklyPivotHeader="-----------------Standard Weekly";//----- Standard Weekly
input enabledisableChoiceToggle showStandardPivotWeeklyR3=Enable;//Standard Weekly Pivot R3
input enabledisableChoiceToggle showStandardPivotWeeklyR2=Enable;//Standard Weekly Pivot R2
input enabledisableChoiceToggle showStandardPivotWeeklyR1=Enable;//Standard Weekly Pivot R1
input enabledisableChoiceToggle showStandardPivotWeeklyPP=Enable;//Standard Weekly Pivot PP
input enabledisableChoiceToggle showStandardPivotWeeklyS1=Enable;//Standard Weekly Pivot S1
input enabledisableChoiceToggle showStandardPivotWeeklyS2=Enable;//Standard Weekly Pivot S2
input enabledisableChoiceToggle showStandardPivotWeeklyS3=Enable;//Standard Weekly Pivot S3
input string StandardMonthlyPivotHeader="-----------------Standard Monthly";//----- Standard Monthly
input enabledisableChoiceToggle showStandardPivotMonthlyR3=Enable;//Standard Monthly Pivot R3
input enabledisableChoiceToggle showStandardPivotMonthlyR2=Enable;//Standard Monthly Pivot R2
input enabledisableChoiceToggle showStandardPivotMonthlyR1=Enable;//Standard Monthly Pivot R1
input enabledisableChoiceToggle showStandardPivotMonthlyPP=Enable;//Standard Monthly Pivot PP
input enabledisableChoiceToggle showStandardPivotMonthlyS1=Enable;//Standard Monthly Pivot S1
input enabledisableChoiceToggle showStandardPivotMonthlyS2=Enable;//Standard Monthly Pivot S2
input enabledisableChoiceToggle showStandardPivotMonthlyS3=Enable;//Standard Monthly Pivot S3

input string showAlertsFibonacciPivotHeader="Fibonacci Daily Pivot Point--------------------------------------------";//----- Fibonacci Pivot Point Daily Settings
input string FibonacciDailyPivotHeader="-----------------Fibonacci Daily";//----- Fibonacci Daily
input enabledisableChoiceToggle showFibonacciPivotDailyR200=Enable;//Fibonacci Daily Pivot R200
input enabledisableChoiceToggle showFibonacciPivotDailyR161=Enable;//Fibonacci Daily Pivot R161
input enabledisableChoiceToggle showFibonacciPivotDailyR138=Enable;//Fibonacci Daily Pivot R138
input enabledisableChoiceToggle showFibonacciPivotDailyR100=Enable;//Fibonacci Daily Pivot R100
input enabledisableChoiceToggle showFibonacciPivotDailyR78=Enable;//Fibonacci Daily Pivot R78
input enabledisableChoiceToggle showFibonacciPivotDailyR61=Enable;//Fibonacci Daily Pivot R61
input enabledisableChoiceToggle showFibonacciPivotDailyR38=Enable;//Fibonacci Daily Pivot R38
input enabledisableChoiceToggle showFibonacciPivotDailyPP=Enable;//Fibonacci Daily Pivot PP
input enabledisableChoiceToggle showFibonacciPivotDailyS38=Enable;//Fibonacci Daily Pivot S38
input enabledisableChoiceToggle showFibonacciPivotDailyS61=Enable;//Fibonacci Daily Pivot S61
input enabledisableChoiceToggle showFibonacciPivotDailyS78=Enable;//Fibonacci Daily Pivot S78
input enabledisableChoiceToggle showFibonacciPivotDailyS100=Enable;//Fibonacci Daily Pivot S100
input enabledisableChoiceToggle showFibonacciPivotDailyS138=Enable;//Fibonacci Daily Pivot S138
input enabledisableChoiceToggle showFibonacciPivotDailyS161=Enable;//Fibonacci Daily Pivot S161
input enabledisableChoiceToggle showFibonacciPivotDailyS200=Enable;//Fibonacci Daily Pivot S200
input string FibonacciWeeklyPivotHeader="-----------------Weekly Fibonacci Weekly";//----- Fibonacci Weekly
input enabledisableChoiceToggle showFibonacciPivotWeeklyR200=Enable;//Fibonacci Weekly Pivot R200
input enabledisableChoiceToggle showFibonacciPivotWeeklyR161=Enable;//Fibonacci Weekly Pivot R161
input enabledisableChoiceToggle showFibonacciPivotWeeklyR138=Enable;//Fibonacci Weekly Pivot R138
input enabledisableChoiceToggle showFibonacciPivotWeeklyR100=Enable;//Fibonacci Weekly Pivot R100
input enabledisableChoiceToggle showFibonacciPivotWeeklyR78=Enable;//Fibonacci Weekly Pivot R78
input enabledisableChoiceToggle showFibonacciPivotWeeklyR61=Enable;//Fibonacci Weekly Pivot R61
input enabledisableChoiceToggle showFibonacciPivotWeeklyR38=Enable;//Fibonacci Weekly Pivot R38
input enabledisableChoiceToggle showFibonacciPivotWeeklyPP=Enable;//Fibonacci Weekly Pivot PP
input enabledisableChoiceToggle showFibonacciPivotWeeklyS38=Enable;//Fibonacci Weekly Pivot S38
input enabledisableChoiceToggle showFibonacciPivotWeeklyS61=Enable;//Fibonacci Weekly Pivot S61
input enabledisableChoiceToggle showFibonacciPivotWeeklyS78=Enable;//Fibonacci Weekly Pivot S78
input enabledisableChoiceToggle showFibonacciPivotWeeklyS100=Enable;//Fibonacci Weekly Pivot S100
input enabledisableChoiceToggle showFibonacciPivotWeeklyS138=Enable;//Fibonacci Weekly Pivot S138
input enabledisableChoiceToggle showFibonacciPivotWeeklyS161=Enable;//Fibonacci Weekly Pivot S161
input enabledisableChoiceToggle showFibonacciPivotWeeklyS200=Enable;//Fibonacci Weekly Pivot S200
input string FibonacciMonthlyPivotHeader="-----------------Fibonacci Monthly";//----- Fibonacci Monthly
input enabledisableChoiceToggle showFibonacciPivotMonthlyR200=Enable;//Fibonacci Monthly Pivot R200
input enabledisableChoiceToggle showFibonacciPivotMonthlyR161=Enable;//Fibonacci Monthly Pivot R161
input enabledisableChoiceToggle showFibonacciPivotMonthlyR138=Enable;//Fibonacci Monthly Pivot R138
input enabledisableChoiceToggle showFibonacciPivotMonthlyR100=Enable;//Fibonacci Monthly Pivot R100
input enabledisableChoiceToggle showFibonacciPivotMonthlyR78=Enable;//Fibonacci Monthly Pivot R78
input enabledisableChoiceToggle showFibonacciPivotMonthlyR61=Enable;//Fibonacci Monthly Pivot R61
input enabledisableChoiceToggle showFibonacciPivotMonthlyR38=Enable;//Fibonacci Monthly Pivot R38
input enabledisableChoiceToggle showFibonacciPivotMonthlyPP=Enable;//Fibonacci Monthly Pivot PP
input enabledisableChoiceToggle showFibonacciPivotMonthlyS38=Enable;//Fibonacci Monthly Pivot S38
input enabledisableChoiceToggle showFibonacciPivotMonthlyS61=Enable;//Fibonacci Monthly Pivot S61
input enabledisableChoiceToggle showFibonacciPivotMonthlyS78=Enable;//Fibonacci Monthly Pivot S78
input enabledisableChoiceToggle showFibonacciPivotMonthlyS100=Enable;//Fibonacci Monthly Pivot S100
input enabledisableChoiceToggle showFibonacciPivotMonthlyS138=Enable;//Fibonacci Monthly Pivot S138
input enabledisableChoiceToggle showFibonacciPivotMonthlyS161=Enable;//Fibonacci Monthly Pivot S161
input enabledisableChoiceToggle showFibonacciPivotMonthlyS200=Enable;//Fibonacci Monthly Pivot S200

input string showAlertsWoodiePivotHeader="Woodie Pivot Point--------------------------------------------";//----- Woodie Pivot Point Daily Settings
input string WoodieDailyPivotHeader="-----------------Woodie Daily";//----- Woodie Daily
input enabledisableChoiceToggle showWoodieDailyR1=Enable;//Woodie Daily Pivot R1
input enabledisableChoiceToggle showWoodieDailyR2=Enable;//Woodie  Daily Pivot R2
input enabledisableChoiceToggle showWoodieDailyPP=Enable;//Woodie Daily Pivot PP
input enabledisableChoiceToggle showWoodieDailyS1=Enable;//Woodie Daily Pivot S1
input enabledisableChoiceToggle showWoodieDailyS2=Enable;//Woodie Daily Pivot S2
input string WoodieWeeklyPivotHeader="-----------------Woodie Weekly";//----- Woodie Weekly
input enabledisableChoiceToggle showWoodieWeeklyR1=Enable;//Woodie Weekly Pivot R1
input enabledisableChoiceToggle showWoodieWeeklyR2=Enable;//Woodie Weekly Pivot R2
input enabledisableChoiceToggle showWoodieWeeklyPP=Enable;//Woodie Weekly Pivot PP
input enabledisableChoiceToggle showWoodieWeeklyS1=Enable;//Woodie Weekly Pivot S1
input enabledisableChoiceToggle showWoodieWeeklyS2=Enable;//Woodie Weekly Pivot S2
input string WoodieMonthlyPivotHeader="-----------------Woodie Monthly";//----- Woodie Monthly
input enabledisableChoiceToggle showWoodieMonthlyR1=Enable;//Woodie Monthly Pivot R1
input enabledisableChoiceToggle showWoodieMonthlyR2=Enable;//Woodie Monthly Pivot R2
input enabledisableChoiceToggle showWoodieMonthlyPP=Enable;//Woodie Monthly Pivot PP
input enabledisableChoiceToggle showWoodieMonthlyS1=Enable;//Woodie Monthly Pivot S1
input enabledisableChoiceToggle showWoodieMonthlyS2=Enable;//Woodie Monthly Pivot S2

input string showAlertsCamarillaPivotHeader="Camarilla Pivot Point--------------------------------------------";//----- Camarilla Pivot Point Daily Settings
input string CamarillaDailyPivotHeader="-----------------Camarilla Daily";//----- Camarilla Daily
input enabledisableChoiceToggle showCamarillaDailyR1=Enable;//Camarilla Daily Pivot R1
input enabledisableChoiceToggle showCamarillaDailyR2=Enable;//Camarilla Daily Pivot R2
input enabledisableChoiceToggle showCamarillaDailyR3=Enable;//Camarilla Daily Pivot R3
input enabledisableChoiceToggle showCamarillaDailyR4=Enable;//Camarilla Daily Pivot R4
input enabledisableChoiceToggle showCamarillaDailyPP=Enable;//Camarilla Daily Pivot PP
input enabledisableChoiceToggle showCamarillaDailyS1=Enable;//Camarilla Daily Pivot S1
input enabledisableChoiceToggle showCamarillaDailyS2=Enable;//Camarilla Daily Pivot S2
input enabledisableChoiceToggle showCamarillaDailyS3=Enable;//Camarilla Daily Pivot S3
input enabledisableChoiceToggle showCamarillaDailyS4=Enable;//Camarilla Daily Pivot S4
input string CamarillaWeeklyPivotHeader="-----------------Camarilla Weekly";//----- Camarilla Weekly
input enabledisableChoiceToggle showCamarillaWeeklyR1=Enable;//Camarilla Weekly Pivot R1
input enabledisableChoiceToggle showCamarillaWeeklyR2=Enable;//Camarilla Weekly Pivot R2
input enabledisableChoiceToggle showCamarillaWeeklyR3=Enable;//Camarilla Weekly Pivot R3
input enabledisableChoiceToggle showCamarillaWeeklyR4=Enable;//Camarilla Weekly Pivot R4
input enabledisableChoiceToggle showCamarillaWeeklyPP=Enable;//Camarilla Weekly Pivot PP
input enabledisableChoiceToggle showCamarillaWeeklyS1=Enable;//Camarilla Weekly Pivot S1
input enabledisableChoiceToggle showCamarillaWeeklyS2=Enable;//Camarilla Weekly Pivot S2
input enabledisableChoiceToggle showCamarillaWeeklyS3=Enable;//Camarilla Weekly Pivot S3
input enabledisableChoiceToggle showCamarillaWeeklyS4=Enable;//Camarilla Weekly Pivot S4
input string CamarillaMonthlyPivotHeader="-----------------Camarilla Monthly";//----- Camarilla Monthly
input enabledisableChoiceToggle showCamarillaMonthlyR1=Enable;//Camarilla Monthly Pivot R1
input enabledisableChoiceToggle showCamarillaMonthlyR2=Enable;//Camarilla Monthly Pivot R2
input enabledisableChoiceToggle showCamarillaMonthlyR3=Enable; //CamarillaMonthly Pivot R3
input enabledisableChoiceToggle showCamarillaMonthlyR4=Enable;//Camarilla Monthly Pivot R4
input enabledisableChoiceToggle showCamarillaMonthlyPP=Enable;//Camarilla Monthly Pivot PP
input enabledisableChoiceToggle showCamarillaMonthlyS1=Enable;//Camarilla Monthly Pivot S1
input enabledisableChoiceToggle showCamarillaMonthlyS2=Enable;//Camarilla Monthly Pivot S2
input enabledisableChoiceToggle showCamarillaMonthlyS3=Enable;//Camarilla Monthly Pivot S3
input enabledisableChoiceToggle showCamarillaMonthlyS4=Enable;//Camarilla Monthly Pivot S4

int numSymbols=0; //the number of symbols to scan
int alertIntervalTimeSeconds;

string symbolList[]; // array of symbols
string symbolListFinal[]; // array of symbols after merging post and prefix
datetime symbolTodaysDate[]; //array of symbol dates today used for checking for new day for wach symbol

double dailyPivots[][15]; //stores all the pivot points for each timeframe
double weeklyPivots[][15];
double monthlyPivots[][15];

//stores all the bool flags to help detect price cross pivot point for each timeframe
bool dailyPivotsFlag[][15];
bool weeklyPivotsFlag[][15];
bool monthlyPivotsFlag[][15];

//stores the time to wait for alert time interval for each pivot points timeframe
datetime   dailyPivotsWaitTill[][15];
datetime   weeklyPivotsWaitTill[][15];
datetime   monthlyPivotsWaitTill[][15];

//stores all the bool flags to help detect price cross pivot point for each timeframe
bool dailyPivotsZoneFlag[][15];
bool weeklyPivotsZoneFlag[][15];
bool monthlyPivotsZoneFlag[][15];

bool showStandardDaily[7];
bool showStandardWeekly[7];
bool showStandardMonthly[7];
string standardPivotNames[]=
  {
   "Pivot",
   "S1",
   "S2",
   "S3",
   "R1",
   "R2",
   "R3",
  };

bool showCamarillaDaily[9];
bool showCamarillaWeekly[9];
bool showCamarillaMonthly[9];
string camarillaPivotNames[]=
  {
   "Pivot",
   "S1",
   "S2",
   "S3",
   "S4",
   "R1",
   "R2",
   "R3",
   "R4",
  };
bool showWoodieDaily[5];
bool showWoodieWeekly[5];
bool showWoodieMonthly[5];
string woodiePivotNames[]=
  {
   "Pivot",
   "S1",
   "S2",
   "R1",
   "R2"
  };
bool showFibonacciDaily[15];
bool showFibonacciWeekly[15];
bool showFibonacciMonthly[15];
string fibonacciPivotNames[]=
  {
   "Pivot",
   "R38",
   "R61",
   "R78",
   "R100",
   "R138",
   "R161",
   "R200",
   "S38",
   "S61",
   "S78",
   "S100",
   "S138",
   "S161",
   "S200",
  };
  
//plsoft
string clos;      
string plsoft;  
string subfolder="";
string namafile="";
string date_="";
string time_="";          
string a="|";
int    handlefile=0;
bool   writefile=false;
double lowest= 1000, highest=0, priceLow=0, priceHigh=0;

input string PlSoft="-----------------PlSoft";            //----- PlSoft
input int   x_axis                  = 0;
input int   y_axis                  = 50;
input double flashover              = 7.0;                // Livello Alert Pivot 
input ENUM_TIMEFRAMES timeframe     = PERIOD_M15;         // Timeframe Fibonacci corto
input int lookback                  = 144;                // Numero di candele Fibonacci corto 
input int lastbar                   = 0;                  // Partenza Fibonacci corto
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"PP MultiPair Scanner");

   alertIntervalTimeSeconds=alertInternalMinutes*60;//waiting time between alerts

   getSymbols();//converts the symbol string to list of symbols

   if(testSymbols())//checks if all symbols exits, if not removes indicator from chart and alert message
     {
      initializePivotPoints();//sets all the pivot points values and pivotsFlags 
     }

   if(EventSetTimer(refreshTime)==false)
     {
      Alert("ERROR CODE: "+(string)GetLastError());
     }
/*
   for(int i=0;i<numSymbols;i++)
    {
      
      color MyColor = Aqua; 
      if(GlobalVariableGet(symbolListFinal[i])< flashover*-1 ) MyColor = clrRed;
      if(GlobalVariableGet(symbolListFinal[i])> flashover)   MyColor = clrGreenYellow;  
      
               
      SetText("Symb"+IntegerToString(i),symbolListFinal[i],x_axis+20,(i*16)+y_axis+15,Aqua,8);
      SetText("bLots"+IntegerToString(i),DoubleToStr(GlobalVariableGet(symbolListFinal[i]),2) ,x_axis+80,(i*16)+y_axis+15,MyColor,8);        
      SetText("Price"+IntegerToString(i),DoubleToStr(iClose(symbolListFinal[i],0,0),4),x_axis+120,(i*16)+y_axis+15,MyColor,8);  
         
    }
*/   
      //WriteFile( "s2",1 ,"new",1, 0.0); prova scrittura su file
     
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//check each symbol if thier is a new day , if true recalculate pivot points
 
   for(int i=0;i<numSymbols;i++)
     {
/*       
      color MyColor = Aqua; 
      if(GlobalVariableGet(symbolListFinal[i])<-0.7 ) MyColor = clrRed;
      if(GlobalVariableGet(symbolListFinal[i])>0.7)   MyColor = clrGreenYellow;  

         int passo = 4;
         
         switch(i)//initalize seleted pivot point forumula
           {
            case 2 : passo=3;     break;
            case 6 : passo=3;     break;            
            case 7 : passo=2;     break;
            case 12 : passo=2;     break;            
            case 18 : passo=2;     break;   
            case 23 : passo=3;     break; 
            case 27 : passo=2;     break;                                                
           }   
                      
      SetText("Symb"+IntegerToString(i),symbolListFinal[i],x_axis+20,(i*16)+y_axis+15,Aqua,8);
      SetText("bLots"+IntegerToString(i),DoubleToStr(GlobalVariableGet(symbolListFinal[i]),2) ,x_axis+80,(i*16)+y_axis+15,MyColor,8);  
      SetText("Price"+IntegerToString(i),DoubleToStr(iClose(symbolListFinal[i],0,0),passo),x_axis+120,(i*16)+y_axis+15,MyColor,8);       
      
        color MColor = clrBlack; if(ObjectDescription("centro")==symbolListFinal[i]) MColor = clrGold;
        SetText("pin"+IntegerToString(i),"*",x_axis+160,(i*16)+y_axis+15,MColor,12);  

        if(ObjectDescription(StringSubstr(symbolListFinal[i],0,3)+"currdig")>ObjectDescription(StringSubstr(symbolListFinal[i],3,3)+"currdig"))
         {           
            SetText("val01"+IntegerToString(i),ObjectDescription(StringSubstr(symbolListFinal[i],0,3)+"currdig"),x_axis+180,(i*16)+y_axis+15,clrGreenYellow,8); 
            SetText("val02"+IntegerToString(i),ObjectDescription(StringSubstr(symbolListFinal[i],3,3)+"currdig"),x_axis+210,(i*16)+y_axis+15,clrRed,8);
            SetObjText("val03"+IntegerToString(i),CharToStr(241),x_axis+240,(i*16)+y_axis+15,clrGreenYellow,8);            
         }
        else if (ObjectDescription(StringSubstr(symbolListFinal[i],0,3)+"currdig")<ObjectDescription(StringSubstr(symbolListFinal[i],3,3)+"currdig"))
         {
            SetText("val01"+IntegerToString(i),ObjectDescription(StringSubstr(symbolListFinal[i],0,3)+"currdig"),x_axis+180,(i*16)+y_axis+15,clrRed,8); 
            SetText("val02"+IntegerToString(i),ObjectDescription(StringSubstr(symbolListFinal[i],3,3)+"currdig"),x_axis+210,(i*16)+y_axis+15,clrGreenYellow,8);
            SetObjText("val03"+IntegerToString(i),CharToStr(242),x_axis+240,(i*16)+y_axis+15,clrRed,8); 
         }
        
*/      
      if(IsNewDay(symbolListFinal[i],i))//check if new day
        {
         clearPivotWaitTills(i);

         switch(pivotSelection)//initalize seleted pivot point forumula
           {
            case Standard :       initializeStandardPivot(symbolListFinal[i],i);     break;
            case Camarilla :      initializeCamarillaPivot(symbolListFinal[i],i);    break;
            case Woodie :         initializeWoodiePivot(symbolListFinal[i],i);       break;
            case Fibonacci :      initializeFibonacciPivot(symbolListFinal[i],i);    break;
           }
        }
     }//end of for loop

   switch(pivotSelection)//Checking for when price crosses over the pivot points, then alerts the trader
     {
      case Standard :       standardPivotCrossCheck();      break;
      case Camarilla :      camarillaPivotCrossCheck();     break;
      case Woodie :         woodiePivotCrossCheck();        break;
      case Fibonacci :      fibonacciPivotCrossCheck();     break;
     }
         
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializePivotPoints()
  {
   ArrayResize(symbolTodaysDate,numSymbols);//resize to the number of symbols being used

   if(useDailyPivotAlert==Yes) //get the double 2d arrays ready based on number of symbols
     {
      ArrayResize(dailyPivots,numSymbols);
      ArrayResize(dailyPivotsFlag,numSymbols);
      ArrayResize(dailyPivotsWaitTill,numSymbols);
      ArrayResize(dailyPivotsZoneFlag,numSymbols);
     }

   if(useWeeklyPivotAlert==Yes)
     {
      ArrayResize(weeklyPivots,numSymbols);
      ArrayResize(weeklyPivotsFlag,numSymbols);
      ArrayResize(weeklyPivotsWaitTill,numSymbols);
      ArrayResize(weeklyPivotsZoneFlag,numSymbols);

     }

   if(useMonthlyPivotAlert==Yes)
     {
      ArrayResize(monthlyPivots,numSymbols);
      ArrayResize(monthlyPivotsFlag,numSymbols);
      ArrayResize(monthlyPivotsWaitTill,numSymbols);
      ArrayResize(monthlyPivotsZoneFlag,numSymbols);
     }
//////////////////////////////////////////////////////////////////////
   if(pivotSelection==Standard)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeStandardPivot(symbolListFinal[i],i);
        }
     }
   else if(pivotSelection==Camarilla)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeCamarillaPivot(symbolListFinal[i],i);
        }
     }
   else if(pivotSelection==Woodie)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeWoodiePivot(symbolListFinal[i],i);
        }
     }
   else if(pivotSelection==Fibonacci)
     {
      for(int i=0;i<numSymbols;i++)
        {
         initializeFibonacciPivot(symbolListFinal[i],i);
        }
     }
//////////////////////////////////////////////////////////////////////

   if(printOutPivotPoints==Yes)
      printOutPivotPoint(printOutPivotPointsSymbolIndex);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getSymbols()
  {
   string sep=",";
   ushort u_sep;
   u_sep=StringGetCharacter(sep,0);
   StringSplit(symbols,u_sep,symbolList);

   numSymbols=ArraySize(symbolList);//get the number of how many symbols are in the symbolList array

   ArrayResize(symbolListFinal,numSymbols);//resize finals symbol list to correct size

   for(int i=0;i<numSymbols;i++)//combines postfix , symbol , prefix names together
     {
      symbolListFinal[i]=symbolPrefix+symbolList[i]+symbolSuffix;
      //printf(symbolListFinal[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool testSymbols()
  {
   bool result=true;
   for(int i=0;i<numSymbols;i++)
     {
      double bid=MarketInfo(symbolListFinal[i],MODE_BID);

      if(GetLastError()==4106) // unknown symbol
        {
         result=false;
         Alert("Can't find this symbol: "+symbolListFinal[i]+" , REMOVING INDICATOR FROM CHART");
         Alert("Double Check Prefix Or Suffix Settings");

         ChartIndicatorDelete(0,0,"PP MultiPair Scanner");
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewDay(string symbol,int index)
  {
   bool result;
   if(symbolTodaysDate[index]!=iTime(symbol,PERIOD_D1,0))
     {
      symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);
      // Print("Its a new day ",TimeToStr(iTime(symbol,PERIOD_D1,0)));
      result=true;
     }
   else
     {
      result=false;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clearPivotWaitTills(int index)
  {
   int numOfPP=ArrayRange(dailyPivotsWaitTill,1);

   for(int j=0;j<numOfPP;j++)
     {
      dailyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
      weeklyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
      monthlyPivotsWaitTill[index][j]=(datetime)"1971.01.01 00:00:00";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string symbol,string pivotLevelName,pivotTypes pType,alertMode alertChoice,int PivotValue)
  {

   double  MyPercent=0.0;

   if(alertOptions==none)
     {
      return;
     }
   else if(alertOptions==alert)
     {
      if(alertChoice==CrossAlerts)
        {
         Alert(symbol+" "+pivotLevelName+" "+crossedMessage+EnumToString(pType));
        }
      else if(alertChoice==PointsNearAlerts)
        {
         Alert(symbol+" "+pivotLevelName+" "+pointsNearMessage+EnumToString(pType));
        }
     }
   else if(alertOptions==notification)
     {
      if(alertChoice==CrossAlerts)
        {
         SendNotification(symbol+" "+pivotLevelName+crossedMessage+EnumToString(pType));
        }
      else if(alertChoice==PointsNearAlerts)
        {
         SendNotification(symbol+" "+pivotLevelName+pointsNearMessage+EnumToString(pType));                        
        }
     }
   else if(alertOptions==both)
     {
      if(alertChoice==CrossAlerts)
        {
          WriteSuperMinMax(symbol); // PlSoft
          
          if(PivotValue >=1 && PivotValue <=7) MyPercent = priceHigh;
          if(PivotValue >=8 && PivotValue <=14) MyPercent = priceLow;
                   
          Alert(symbol+" "+pivotLevelName+" "+crossedMessage+EnumToString(pType));
          SendNotification(symbol+" "+pivotLevelName+crossedMessage+EnumToString(pType)+" Price: "+DoubleToStr(iClose(symbol,0,0),4)+ " % " + DoubleToStr(MyPercent,0));
          WriteFile(symbol, PivotValue, EnumToString(pType), 1, iClose(symbol,0,0));     //PlSoft                
        }
      else if(alertChoice==PointsNearAlerts)
        {

          WriteSuperMinMax(symbol); // PlSoft
                   
          if(PivotValue >=1 && PivotValue <=7) MyPercent = priceHigh;
          if(PivotValue >=8 && PivotValue <=14) MyPercent = priceLow;
                   
          Alert(symbol+" "+pivotLevelName+" "+pointsNearMessage+EnumToString(pType));
          SendNotification(symbol+" "+pivotLevelName+" "+pointsNearMessage+EnumToString(pType)+" Price: "+DoubleToStr(iClose(symbol,0,0),4)+" % " + DoubleToStr(MyPercent,0));
          WriteFile(symbol, PivotValue, EnumToString(pType), 2, iClose(symbol,0,0));      //PlSoft                    
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void standardPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {
   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   double PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,symbolDigits);
   double R1 = NormalizeDouble((PP * 2)-prevLow,symbolDigits);
   double S1 = NormalizeDouble((PP * 2)-prevHigh,symbolDigits);
   double R2 = NormalizeDouble(PP + prevHigh - prevLow,symbolDigits);
   double S2 = NormalizeDouble(PP - prevHigh + prevLow,symbolDigits);
   double R3 = NormalizeDouble(R1 + (prevHigh-prevLow),symbolDigits);
   double S3 = NormalizeDouble(prevLow - 2 * (prevHigh-PP),symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=S3;
   ppArrayRef[symbolIndex][4]=R1;
   ppArrayRef[symbolIndex][5]=R2;
   ppArrayRef[symbolIndex][6]=R3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void camarillaPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {

   double camRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh=iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double R1 = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,symbolDigits);
   double R2 = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,symbolDigits);
   double R3 = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,symbolDigits);
   double R4= NormalizeDouble(((1.1/2) * camRange)+prevClose,symbolDigits);
   double S1= NormalizeDouble(prevClose -((1.1/12) * camRange),symbolDigits);
   double S2= NormalizeDouble(prevClose -((1.1/6) * camRange),symbolDigits);
   double S3 = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),symbolDigits);
   double S4 = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),symbolDigits);
   double PP = NormalizeDouble((R4+S4)/2,symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=S3;
   ppArrayRef[symbolIndex][4]=S4;
   ppArrayRef[symbolIndex][5]=R1;
   ppArrayRef[symbolIndex][6]=R2;
   ppArrayRef[symbolIndex][7]=R3;
   ppArrayRef[symbolIndex][8]=R4;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void woodiePivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {
   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose = iClose(symbolName, timeFrame,1);
   double todayOpen = iOpen(symbolName, timeFrame,0);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double PP = NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,symbolDigits);
   double R1 = NormalizeDouble((PP * 2)-prevLow,symbolDigits);
   double R2 = NormalizeDouble(PP + prevRange,symbolDigits);
   double S1 = NormalizeDouble((PP * 2)-prevHigh,symbolDigits);
   double S2 = NormalizeDouble(PP - prevRange,symbolDigits);

   ppArrayRef[symbolIndex][0]=PP;
   ppArrayRef[symbolIndex][1]=S1;
   ppArrayRef[symbolIndex][2]=S2;
   ppArrayRef[symbolIndex][3]=R1;
   ppArrayRef[symbolIndex][4]=R2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fibonacciPivotPoint(ENUM_TIMEFRAMES timeFrame,double &ppArrayRef[][],int symbolIndex,string symbolName)
  {
   double prevRange= iHigh(symbolName,timeFrame,1)-iLow(symbolName,timeFrame,1);
   double prevHigh = iHigh(symbolName,timeFrame,1);
   double prevLow=iLow(symbolName,timeFrame,1);
   double prevClose=iClose(symbolName,timeFrame,1);

   int symbolDigits=(int)MarketInfo(symbolName,MODE_DIGITS);

   double Pivot=NormalizeDouble((prevHigh+prevLow+prevClose)/3,symbolDigits);

   double R38=  NormalizeDouble(Pivot + ((prevRange) * 0.382),symbolDigits);
   double R61=  NormalizeDouble(Pivot + ((prevRange) * 0.618),symbolDigits);
   double R78=  NormalizeDouble(Pivot + ((prevRange) * 0.786),symbolDigits);
   double R100= NormalizeDouble(Pivot + ((prevRange) * 1.000),symbolDigits);
   double R138= NormalizeDouble(Pivot + ((prevRange) * 1.382),symbolDigits);
   double R161= NormalizeDouble(Pivot + ((prevRange) * 1.618),symbolDigits);
   double R200= NormalizeDouble(Pivot + ((prevRange) * 2.000),symbolDigits);

   double S38 = NormalizeDouble(Pivot - ((prevRange) * 0.382),symbolDigits);
   double S61 = NormalizeDouble(Pivot - ((prevRange) * 0.618),symbolDigits);
   double S78=  NormalizeDouble(Pivot - ((prevRange) * 0.786),symbolDigits);
   double S100= NormalizeDouble(Pivot - ((prevRange) * 1.000),symbolDigits);
   double S138= NormalizeDouble(Pivot - ((prevRange) * 1.382),symbolDigits);
   double S161= NormalizeDouble(Pivot - ((prevRange) * 1.618),symbolDigits);
   double S200= NormalizeDouble(Pivot - ((prevRange) * 2.000),symbolDigits);

   ppArrayRef[symbolIndex][0]=Pivot;

   ppArrayRef[symbolIndex][1]=R38;
   ppArrayRef[symbolIndex][2]=R61;
   ppArrayRef[symbolIndex][3]=R78;
   ppArrayRef[symbolIndex][4]=R100;
   ppArrayRef[symbolIndex][5]=R138;
   ppArrayRef[symbolIndex][6]=R161;
   ppArrayRef[symbolIndex][7]=R200;

   ppArrayRef[symbolIndex][8]=S38;
   ppArrayRef[symbolIndex][9]=S61;
   ppArrayRef[symbolIndex][10]=S78;
   ppArrayRef[symbolIndex][11]=S100;
   ppArrayRef[symbolIndex][12]=S138;
   ppArrayRef[symbolIndex][13]=S161;
   ppArrayRef[symbolIndex][14]=S200;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeStandardPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   double points=MarketInfo(symbol,MODE_POINT);
   double pipPoints=xxPoints*points;

   if(useDailyPivotAlert==Yes)
     {
      standardPivotPoint(PERIOD_D1,dailyPivots,index,symbol);//Gets the values

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            if(bid>=dailyPivots[index][i])
               dailyPivotsFlag[index][i]=true;
            else
               dailyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            double pivotHigh=dailyPivots[index][i]+pipPoints;
            double pivotLow=dailyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               dailyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               dailyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showStandardPivotDailyPP==Disable)showStandardDaily[0]=false;
      else showStandardDaily[0]=true;
      if(showStandardPivotDailyS1==Disable)showStandardDaily[1]=false;
      else showStandardDaily[1]=true;
      if(showStandardPivotDailyS2==Disable)showStandardDaily[2]=false;
      else showStandardDaily[2]=true;
      if(showStandardPivotDailyS3==Disable)showStandardDaily[3]=false;
      else showStandardDaily[3]=true;
      if(showStandardPivotDailyR1==Disable)showStandardDaily[4]=false;
      else showStandardDaily[4]=true;
      if(showStandardPivotDailyR2==Disable)showStandardDaily[5]=false;
      else showStandardDaily[5]=true;
      if(showStandardPivotDailyR3==Disable)showStandardDaily[6]=false;
      else showStandardDaily[6]=true;

     }//end of daily
   if(useWeeklyPivotAlert==Yes)
     {
      standardPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            if(bid>=weeklyPivots[index][i])
               weeklyPivotsFlag[index][i]=true;
            else
               weeklyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            double pivotHigh=weeklyPivots[index][i]+pipPoints;
            double pivotLow=weeklyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               weeklyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               weeklyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showStandardPivotWeeklyPP==Disable)showStandardWeekly[0]=false;
      else showStandardWeekly[0]=true;
      if(showStandardPivotWeeklyS1==Disable)showStandardWeekly[1]=false;
      else showStandardWeekly[1]=true;
      if(showStandardPivotWeeklyS2==Disable)showStandardWeekly[2]=false;
      else showStandardWeekly[2]=true;
      if(showStandardPivotWeeklyS3==Disable)showStandardWeekly[3]=false;
      else showStandardWeekly[3]=true;
      if(showStandardPivotWeeklyR1==Disable)showStandardWeekly[4]=false;
      else showStandardWeekly[4]=true;
      if(showStandardPivotWeeklyR2==Disable)showStandardWeekly[5]=false;
      else showStandardWeekly[5]=true;
      if(showStandardPivotWeeklyR3==Disable)showStandardWeekly[6]=false;
      else showStandardWeekly[6]=true;
     }//end of weekly
   if(useMonthlyPivotAlert==Yes)
     {
      standardPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            if(bid>=monthlyPivots[index][i])
               monthlyPivotsFlag[index][i]=true;
            else
               monthlyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<7;i++)//sets the initial flags
           {
            double pivotHigh=monthlyPivots[index][i]+pipPoints;
            double pivotLow=monthlyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               monthlyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               monthlyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showStandardPivotMonthlyPP==Disable)showStandardMonthly[0]=false;
      else showStandardMonthly[0]=true;
      if(showStandardPivotMonthlyS1==Disable)showStandardMonthly[1]=false;
      else showStandardMonthly[1]=true;
      if(showStandardPivotMonthlyS2==Disable)showStandardMonthly[2]=false;
      else showStandardMonthly[2]=true;
      if(showStandardPivotMonthlyS3==Disable)showStandardMonthly[3]=false;
      else showStandardMonthly[3]=true;
      if(showStandardPivotMonthlyR1==Disable)showStandardMonthly[4]=false;
      else showStandardMonthly[4]=true;
      if(showStandardPivotMonthlyR2==Disable)showStandardMonthly[5]=false;
      else showStandardMonthly[5]=true;
      if(showStandardPivotMonthlyR3==Disable)showStandardMonthly[6]=false;
      else showStandardMonthly[6]=true;

     }//end of monthly
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void standardPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;
   double points;
   double pipPoints;
   int digits;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolListFinal[i];

      bid=MarketInfo(symbolName,MODE_BID);
      points=MarketInfo(symbolName,MODE_POINT);
      digits=(int)MarketInfo(symbolName,MODE_DIGITS);
      pipPoints=xxPoints*points;

      if(useDailyPivotAlert==Yes)//daily pivot point cross check
        {
         pivotLevelName="Daily ";
         for(int j=0;j<7;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=dailyPivots[i][j];
               if(result!=dailyPivotsFlag[i][j])
                 {
                  dailyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showStandardDaily[j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=dailyPivots[i][j]+pipPoints;
               double pivotLow=dailyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));//get 1 or 0
               if(result!=dailyPivotsZoneFlag[i][j])
                 {
                  dailyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showStandardDaily[j]==true && dailyPivotsZoneFlag[i][j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
           }
        }//end of daily code
      if(useWeeklyPivotAlert==Yes)//weekly pivot point cross check
        {
         pivotLevelName="Weekly ";
         for(int j=0;j<7;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=weeklyPivots[i][j];
               if(result!=weeklyPivotsFlag[i][j])
                 {
                  weeklyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showStandardWeekly[j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,j);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=weeklyPivots[i][j]+pipPoints;
               double pivotLow=weeklyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=weeklyPivotsZoneFlag[i][j])
                 {
                  weeklyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showStandardWeekly[j]==true && weeklyPivotsZoneFlag[i][j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,j);
                    }
                 }
              }
           }
        }//end of weekly code
      if(useMonthlyPivotAlert==Yes)//monthly pivot point cross check
        {
         pivotLevelName="Monthly ";
         for(int j=0;j<7;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=monthlyPivots[i][j];
               if(result!=monthlyPivotsFlag[i][j])
                 {
                  monthlyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showStandardMonthly[j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=monthlyPivots[i][j]+pipPoints;
               double pivotLow=monthlyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=monthlyPivotsZoneFlag[i][j])
                 {
                  monthlyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showStandardMonthly[j]==true && monthlyPivotsZoneFlag[i][j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+standardPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeCamarillaPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   double points=MarketInfo(symbol,MODE_POINT);
   double pipPoints=xxPoints*points;

   if(useDailyPivotAlert==Yes)
     {
      camarillaPivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<9;i++)
           {
            if(bid>=dailyPivots[index][i])
               dailyPivotsFlag[index][i]=true;
            else
               dailyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<9;i++)
           {
            double pivotHigh=dailyPivots[index][i]+pipPoints;
            double pivotLow=dailyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               dailyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               dailyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showCamarillaDailyPP==Disable)showCamarillaDaily[0]=false;
      else showCamarillaDaily[0]=true;
      if(showCamarillaDailyS1==Disable)showCamarillaDaily[1]=false;
      else showCamarillaDaily[1]=true;
      if(showCamarillaDailyS2==Disable)showCamarillaDaily[2]=false;
      else showCamarillaDaily[2]=true;
      if(showCamarillaDailyS3==Disable)showCamarillaDaily[3]=false;
      else showCamarillaDaily[3]=true;
      if(showCamarillaDailyS4==Disable)showCamarillaDaily[4]=false;
      else showCamarillaDaily[4]=true;
      if(showCamarillaDailyR1==Disable)showCamarillaDaily[5]=false;
      else showCamarillaDaily[5]=true;
      if(showCamarillaDailyR2==Disable)showCamarillaDaily[6]=false;
      else showCamarillaDaily[6]=true;
      if(showCamarillaDailyR3==Disable)showCamarillaDaily[7]=false;
      else showCamarillaDaily[7]=true;
      if(showCamarillaDailyR4==Disable)showCamarillaDaily[8]=false;
      else showCamarillaDaily[8]=true;

     }//end of daily
   if(useWeeklyPivotAlert==Yes)
     {
      camarillaPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<9;i++)
           {
            if(bid>=weeklyPivots[index][i])
               weeklyPivotsFlag[index][i]=true;
            else
               weeklyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<9;i++)
           {
            double pivotHigh=weeklyPivots[index][i]+pipPoints;
            double pivotLow=weeklyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               weeklyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               weeklyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showCamarillaWeeklyPP==Disable)showCamarillaWeekly[0]=false;
      else showCamarillaWeekly[0]=true;
      if(showCamarillaWeeklyS1==Disable)showCamarillaWeekly[1]=false;
      else showCamarillaWeekly[1]=true;
      if(showCamarillaWeeklyS2==Disable)showCamarillaWeekly[2]=false;
      else showCamarillaWeekly[2]=true;
      if(showCamarillaWeeklyS3==Disable)showCamarillaWeekly[3]=false;
      else showCamarillaWeekly[3]=true;
      if(showCamarillaWeeklyS4==Disable)showCamarillaWeekly[4]=false;
      else showCamarillaWeekly[4]=true;
      if(showCamarillaWeeklyR1==Disable)showCamarillaWeekly[5]=false;
      else showCamarillaWeekly[5]=true;
      if(showCamarillaWeeklyR2==Disable)showCamarillaWeekly[6]=false;
      else showCamarillaWeekly[6]=true;
      if(showCamarillaWeeklyR3==Disable)showCamarillaWeekly[7]=false;
      else showCamarillaWeekly[7]=true;
      if(showCamarillaWeeklyR4==Disable)showCamarillaWeekly[8]=false;
      else showCamarillaWeekly[8]=true;
     }//end of weekly
   if(useMonthlyPivotAlert==Yes)
     {
      camarillaPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<9;i++)
           {
            if(bid>=monthlyPivots[index][i])
               monthlyPivotsFlag[index][i]=true;
            else
               monthlyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<9;i++)
           {
            double pivotHigh=monthlyPivots[index][i]+pipPoints;
            double pivotLow=monthlyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               monthlyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               monthlyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showCamarillaMonthlyPP==Disable)showCamarillaMonthly[0]=false;
      else showCamarillaMonthly[0]=true;
      if(showCamarillaMonthlyS1==Disable)showCamarillaMonthly[1]=false;
      else showCamarillaMonthly[1]=true;
      if(showCamarillaMonthlyS2==Disable)showCamarillaMonthly[2]=false;
      else showCamarillaMonthly[2]=true;
      if(showCamarillaMonthlyS3==Disable)showCamarillaMonthly[3]=false;
      else showCamarillaMonthly[3]=true;
      if(showCamarillaMonthlyS4==Disable)showCamarillaMonthly[4]=false;
      else showCamarillaMonthly[4]=true;
      if(showCamarillaMonthlyR1==Disable)showCamarillaMonthly[5]=false;
      else showCamarillaMonthly[5]=true;
      if(showCamarillaMonthlyR2==Disable)showCamarillaMonthly[6]=false;
      else showCamarillaMonthly[6]=true;
      if(showCamarillaMonthlyR3==Disable)showCamarillaMonthly[7]=false;
      else showCamarillaMonthly[7]=true;
      if(showCamarillaMonthlyR4==Disable)showCamarillaMonthly[8]=false;
      else showCamarillaMonthly[8]=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void camarillaPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;
   double points;
   double pipPoints;
   int digits;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolListFinal[i];

      bid=MarketInfo(symbolName,MODE_BID);
      points=MarketInfo(symbolName,MODE_POINT);
      digits=(int)MarketInfo(symbolName,MODE_DIGITS);
      pipPoints=xxPoints*points;

      if(useDailyPivotAlert==Yes)//daily pivot point cross check
        {
         pivotLevelName="Daily ";
         for(int j=0;j<9;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=dailyPivots[i][j];
               if(result!=dailyPivotsFlag[i][j])
                 {
                  dailyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showCamarillaDaily[j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=dailyPivots[i][j]+pipPoints;
               double pivotLow=dailyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=dailyPivotsZoneFlag[i][j])
                 {
                  dailyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showCamarillaDaily[j]==true && dailyPivotsZoneFlag[i][j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
           }
        }//end of daily code
      if(useWeeklyPivotAlert==Yes)//weekly pivot point cross check
        {
         pivotLevelName="Weekly ";
         for(int j=0;j<9;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=weeklyPivots[i][j];
               if(result!=weeklyPivotsFlag[i][j])
                 {
                  weeklyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showCamarillaWeekly[j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=weeklyPivots[i][j]+pipPoints;
               double pivotLow=weeklyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=weeklyPivotsZoneFlag[i][j])
                 {
                  weeklyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showCamarillaWeekly[j]==true && weeklyPivotsZoneFlag[i][j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }

           }
        }//end of weekly code
      if(useMonthlyPivotAlert==Yes)//monthly pivot point cross check
        {
         pivotLevelName="Monthly ";
         for(int j=0;j<9;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=monthlyPivots[i][j];
               if(result!=monthlyPivotsFlag[i][j])
                 {
                  monthlyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showCamarillaMonthly[j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=monthlyPivots[i][j]+pipPoints;
               double pivotLow=monthlyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=monthlyPivotsZoneFlag[i][j])
                 {
                  monthlyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showCamarillaMonthly[j]==true && monthlyPivotsZoneFlag[i][j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+camarillaPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }

           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeWoodiePivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   double points=MarketInfo(symbol,MODE_POINT);
   double pipPoints=xxPoints*points;

   if(useDailyPivotAlert==Yes)
     {
      woodiePivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<5;i++)
           {
            if(bid>=dailyPivots[index][i])
               dailyPivotsFlag[index][i]=true;
            else
               dailyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<5;i++)
           {
            double pivotHigh=dailyPivots[index][i]+pipPoints;
            double pivotLow=dailyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               dailyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               dailyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showWoodieDailyPP==Disable)showWoodieDaily[0]=false;
      else showWoodieDaily[0]=true;
      if(showWoodieDailyS1==Disable)showWoodieDaily[1]=false;
      else showWoodieDaily[1]=true;
      if(showWoodieDailyS2==Disable)showWoodieDaily[2]=false;
      else showWoodieDaily[2]=true;
      if(showWoodieDailyR1==Disable)showWoodieDaily[3]=false;
      else showWoodieDaily[3]=true;
      if(showWoodieDailyR2==Disable)showWoodieDaily[4]=false;
      else showWoodieDaily[4]=true;
     }//end of daily
   if(useWeeklyPivotAlert==Yes)
     {
      woodiePivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<5;i++)
           {
            if(bid>=weeklyPivots[index][i])
               weeklyPivotsFlag[index][i]=true;
            else
               weeklyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<5;i++)
           {
            double pivotHigh=weeklyPivots[index][i]+pipPoints;
            double pivotLow=weeklyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               weeklyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               weeklyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showWoodieWeeklyPP==Disable)showWoodieWeekly[0]=false;
      else showWoodieWeekly[0]=true;
      if(showWoodieWeeklyS1==Disable)showWoodieWeekly[1]=false;
      else showWoodieWeekly[1]=true;
      if(showWoodieWeeklyS2==Disable)showWoodieWeekly[2]=false;
      else showWoodieWeekly[2]=true;
      if(showWoodieWeeklyR1==Disable)showWoodieWeekly[3]=false;
      else showWoodieWeekly[3]=true;
      if(showWoodieWeeklyR2==Disable)showWoodieWeekly[4]=false;
      else showWoodieWeekly[4]=true;
     }//end of weekly
   if(useMonthlyPivotAlert==Yes)
     {
      woodiePivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<5;i++)
           {
            if(bid>=monthlyPivots[index][i])
               monthlyPivotsFlag[index][i]=true;
            else
               monthlyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<5;i++)
           {
            double pivotHigh=monthlyPivots[index][i]+pipPoints;
            double pivotLow=monthlyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               monthlyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               monthlyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showWoodieMonthlyPP==Disable)showWoodieMonthly[0]=false;
      else showWoodieMonthly[0]=true;
      if(showWoodieMonthlyS1==Disable)showWoodieMonthly[1]=false;
      else showWoodieMonthly[1]=true;
      if(showWoodieMonthlyS2==Disable)showWoodieMonthly[2]=false;
      else showWoodieMonthly[2]=true;
      if(showWoodieMonthlyR1==Disable)showWoodieMonthly[3]=false;
      else showWoodieMonthly[3]=true;
      if(showWoodieMonthlyR2==Disable)showWoodieMonthly[4]=false;
      else showWoodieMonthly[4]=true;
     }//end of monthly
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void woodiePivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;
   double points;
   double pipPoints;
   int digits;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolListFinal[i];

      bid=MarketInfo(symbolName,MODE_BID);
      points=MarketInfo(symbolName,MODE_POINT);
      digits=(int)MarketInfo(symbolName,MODE_DIGITS);
      pipPoints=xxPoints*points;

      if(useDailyPivotAlert==Yes)//daily pivot point cross check
        {
         pivotLevelName="Daily ";
         for(int j=0;j<5;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=dailyPivots[i][j];
               if(result!=dailyPivotsFlag[i][j])
                 {
                  dailyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showWoodieDaily[j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               result=bid>=dailyPivots[i][j];
               if(result!=dailyPivotsFlag[i][j])
                 {
                  dailyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showWoodieDaily[j]==true && dailyPivotsZoneFlag[i][j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }

           }
        }//end of daily code
      if(useWeeklyPivotAlert==Yes)//weekly pivot point cross check
        {
         pivotLevelName="Weekly ";
         for(int j=0;j<5;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=weeklyPivots[i][j];
               if(result!=weeklyPivotsFlag[i][j])
                 {
                  weeklyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showWoodieWeekly[j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               result=bid>=weeklyPivots[i][j];
               if(result!=weeklyPivotsFlag[i][j])
                 {
                  weeklyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showWoodieWeekly[j]==true && weeklyPivotsZoneFlag[i][j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }

           }
        }//end of weekly code
      if(useMonthlyPivotAlert==Yes)//monthly pivot point cross check
        {
         pivotLevelName="Monthly ";
         for(int j=0;j<5;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=monthlyPivots[i][j];
               if(result!=monthlyPivotsFlag[i][j])
                 {
                  monthlyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showWoodieMonthly[j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               result=bid>=monthlyPivots[i][j];
               if(result!=monthlyPivotsFlag[i][j])
                 {
                  monthlyPivotsFlag[i][j]=result;

                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showWoodieMonthly[j]==true && monthlyPivotsZoneFlag[i][j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+woodiePivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }

           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initializeFibonacciPivot(string symbol,int index)
  {
//set the flags using if bid>pivot set to true else false, used to dectect price cross pivot point
   double bid=MarketInfo(symbol,MODE_BID);
   symbolTodaysDate[index]=iTime(symbol,PERIOD_D1,0);//used to find out new day

   double points=MarketInfo(symbol,MODE_POINT);
   double pipPoints=xxPoints*points;

   if(useDailyPivotAlert==Yes)
     {
      fibonacciPivotPoint(PERIOD_D1,dailyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<15;i++)
           {
            if(bid>=dailyPivots[index][i])
               dailyPivotsFlag[index][i]=true;
            else
               dailyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<15;i++)
           {
            double pivotHigh=dailyPivots[index][i]+pipPoints;
            double pivotLow=dailyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               dailyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               dailyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showFibonacciPivotDailyPP==Disable)showFibonacciDaily[0]=false;
      else showFibonacciDaily[0]=true;
      if(showFibonacciPivotDailyR38==Disable)showFibonacciDaily[1]=false;
      else showFibonacciDaily[1]=true;
      if(showFibonacciPivotDailyR61==Disable)showFibonacciDaily[2]=false;
      else showFibonacciDaily[2]=true;
      if(showFibonacciPivotDailyR78==Disable)showFibonacciDaily[3]=false;
      else showFibonacciDaily[3]=true;
      if(showFibonacciPivotDailyR100==Disable)showFibonacciDaily[4]=false;
      else showFibonacciDaily[4]=true;
      if(showFibonacciPivotDailyR138==Disable)showFibonacciDaily[5]=false;
      else showFibonacciDaily[5]=true;
      if(showFibonacciPivotDailyR161==Disable)showFibonacciDaily[6]=false;
      else showFibonacciDaily[6]=true;
      if(showFibonacciPivotDailyR200==Disable)showFibonacciDaily[7]=false;
      else showFibonacciDaily[7]=true;
      if(showFibonacciPivotDailyS38==Disable)showFibonacciDaily[8]=false;
      else showFibonacciDaily[8]=true;
      if(showFibonacciPivotDailyS61==Disable)showFibonacciDaily[9]=false;
      else showFibonacciDaily[9]=true;
      if(showFibonacciPivotDailyS78==Disable)showFibonacciDaily[10]=false;
      else showFibonacciDaily[10]=true;
      if(showFibonacciPivotDailyS100==Disable)showFibonacciDaily[11]=false;
      else showFibonacciDaily[11]=true;
      if(showFibonacciPivotDailyS138==Disable)showFibonacciDaily[12]=false;
      else showFibonacciDaily[12]=true;
      if(showFibonacciPivotDailyS161==Disable)showFibonacciDaily[13]=false;
      else showFibonacciDaily[13]=true;
      if(showFibonacciPivotDailyS200==Disable)showFibonacciDaily[14]=false;
      else showFibonacciDaily[14]=true;

     }//end of daily
   if(useWeeklyPivotAlert==Yes)
     {
      fibonacciPivotPoint(PERIOD_W1,weeklyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<15;i++)
           {
            if(bid>=weeklyPivots[index][i])
               weeklyPivotsFlag[index][i]=true;
            else
               weeklyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<15;i++)
           {
            double pivotHigh=weeklyPivots[index][i]+pipPoints;
            double pivotLow=weeklyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               weeklyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               weeklyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showFibonacciPivotWeeklyPP==Disable)showFibonacciWeekly[0]=false;
      else showFibonacciWeekly[0]=true;
      if(showFibonacciPivotWeeklyR38==Disable)showFibonacciWeekly[1]=false;
      else showFibonacciWeekly[1]=true;
      if(showFibonacciPivotWeeklyR61==Disable)showFibonacciWeekly[2]=false;
      else showFibonacciWeekly[2]=true;
      if(showFibonacciPivotWeeklyR78==Disable)showFibonacciWeekly[3]=false;
      else showFibonacciWeekly[3]=true;
      if(showFibonacciPivotWeeklyR100==Disable)showFibonacciWeekly[4]=false;
      else showFibonacciWeekly[4]=true;
      if(showFibonacciPivotWeeklyR138==Disable)showFibonacciWeekly[5]=false;
      else showFibonacciWeekly[5]=true;
      if(showFibonacciPivotWeeklyR161==Disable)showFibonacciWeekly[6]=false;
      else showFibonacciWeekly[6]=true;
      if(showFibonacciPivotWeeklyR200==Disable)showFibonacciWeekly[7]=false;
      else showFibonacciWeekly[7]=true;
      if(showFibonacciPivotWeeklyS38==Disable)showFibonacciWeekly[8]=false;
      else showFibonacciWeekly[8]=true;
      if(showFibonacciPivotWeeklyS61==Disable)showFibonacciWeekly[9]=false;
      else showFibonacciWeekly[9]=true;
      if(showFibonacciPivotWeeklyS78==Disable)showFibonacciWeekly[10]=false;
      else showFibonacciWeekly[10]=true;
      if(showFibonacciPivotWeeklyS100==Disable)showFibonacciWeekly[11]=false;
      else showFibonacciWeekly[11]=true;
      if(showFibonacciPivotWeeklyS138==Disable)showFibonacciWeekly[12]=false;
      else showFibonacciWeekly[12]=true;
      if(showFibonacciPivotWeeklyS161==Disable)showFibonacciWeekly[13]=false;
      else showFibonacciWeekly[13]=true;
      if(showFibonacciPivotWeeklyS200==Disable)showFibonacciWeekly[14]=false;
      else showFibonacciWeekly[14]=true;
     }//end of weekly
   if(useMonthlyPivotAlert==Yes)
     {
      fibonacciPivotPoint(PERIOD_MN1,monthlyPivots,index,symbol);

      if(alertModeSelection==CrossAlerts)
        {
         for(int i=0;i<15;i++)
           {
            if(bid>=monthlyPivots[index][i])
               monthlyPivotsFlag[index][i]=true;
            else
               monthlyPivotsFlag[index][i]=false;
           }
        }
      else if(alertModeSelection==PointsNearAlerts)
        {
         for(int i=0;i<15;i++)
           {
            double pivotHigh=monthlyPivots[index][i]+pipPoints;
            double pivotLow=monthlyPivots[index][i]-pipPoints;

            if(bid<=pivotHigh && bid>=pivotLow)//check if inzone == false
              {
               monthlyPivotsZoneFlag[index][i]=true;
              }
            else
              {
               monthlyPivotsZoneFlag[index][i]=false;
              }
           }
        }

      if(showFibonacciPivotMonthlyPP==Disable)showFibonacciMonthly[0]=false;
      else showFibonacciMonthly[0]=true;
      if(showFibonacciPivotMonthlyR38==Disable)showFibonacciMonthly[1]=false;
      else showFibonacciMonthly[1]=true;
      if(showFibonacciPivotMonthlyR61==Disable)showFibonacciMonthly[2]=false;
      else showFibonacciMonthly[2]=true;
      if(showFibonacciPivotMonthlyR78==Disable)showFibonacciMonthly[3]=false;
      else showFibonacciMonthly[3]=true;
      if(showFibonacciPivotMonthlyR100==Disable)showFibonacciMonthly[4]=false;
      else showFibonacciMonthly[4]=true;
      if(showFibonacciPivotMonthlyR138==Disable)showFibonacciMonthly[5]=false;
      else showFibonacciMonthly[5]=true;
      if(showFibonacciPivotMonthlyR161==Disable)showFibonacciMonthly[6]=false;
      else showFibonacciMonthly[6]=true;
      if(showFibonacciPivotMonthlyR200==Disable)showFibonacciMonthly[7]=false;
      else showFibonacciMonthly[7]=true;
      if(showFibonacciPivotMonthlyS38==Disable)showFibonacciMonthly[8]=false;
      else showFibonacciMonthly[8]=true;
      if(showFibonacciPivotMonthlyS61==Disable)showFibonacciMonthly[9]=false;
      else showFibonacciMonthly[9]=true;
      if(showFibonacciPivotMonthlyS78==Disable)showFibonacciMonthly[10]=false;
      else showFibonacciMonthly[10]=true;
      if(showFibonacciPivotMonthlyS100==Disable)showFibonacciMonthly[11]=false;
      else showFibonacciMonthly[11]=true;
      if(showFibonacciPivotMonthlyS138==Disable)showFibonacciMonthly[12]=false;
      else showFibonacciMonthly[12]=true;
      if(showFibonacciPivotMonthlyS161==Disable)showFibonacciMonthly[13]=false;
      else showFibonacciMonthly[13]=true;
      if(showFibonacciPivotMonthlyS200==Disable)showFibonacciMonthly[14]=false;
      else showFibonacciMonthly[14]=true;
     }//end of monthly
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fibonacciPivotCrossCheck()
  {
   bool result;//bool for bid>pivot test with flag
   double bid;
   double points;
   double pipPoints;
   int digits;

   string pivotLevelName;
   string symbolName;

   for(int i=0;i<numSymbols;i++)//loops through all the symbols
     {
      symbolName=symbolListFinal[i];

      bid=MarketInfo(symbolName,MODE_BID);
      points=MarketInfo(symbolName,MODE_POINT);
      digits=(int)MarketInfo(symbolName,MODE_DIGITS);
      pipPoints=xxPoints*points;

      if(useDailyPivotAlert==Yes)//daily pivot point cross check
        {
         pivotLevelName="Daily ";
         for(int j=0;j<15;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=dailyPivots[i][j];
               if(result!=dailyPivotsFlag[i][j])
                 {
                  dailyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showFibonacciDaily[j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=dailyPivots[i][j]+pipPoints;
               double pivotLow=dailyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=dailyPivotsZoneFlag[i][j])
                 {
                  dailyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=dailyPivotsWaitTill[i][j] && showFibonacciDaily[j]==true && dailyPivotsZoneFlag[i][j]==true)
                    {
                     dailyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
           }
        }//end of daily code
      if(useWeeklyPivotAlert==Yes)//weekly pivot point cross check
        {
         pivotLevelName="Weekly ";
         for(int j=0;j<15;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=weeklyPivots[i][j];
               if(result!=weeklyPivotsFlag[i][j])
                 {
                  weeklyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showFibonacciWeekly[j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,j);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=weeklyPivots[i][j]+pipPoints;
               double pivotLow=weeklyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=weeklyPivotsZoneFlag[i][j])
                 {
                  weeklyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=weeklyPivotsWaitTill[i][j] && showFibonacciWeekly[j]==true && weeklyPivotsZoneFlag[i][j]==true)
                    {
                     weeklyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,j);
                    }
                 }
              }
           }
        }//end of weekly code 
      if(useMonthlyPivotAlert==Yes)//monthly pivot point cross check
        {
         pivotLevelName="Monthly ";
         for(int j=0;j<15;j++)
           {
            if(alertModeSelection==CrossAlerts)
              {
               result=bid>=monthlyPivots[i][j];
               if(result!=monthlyPivotsFlag[i][j])
                 {
                  monthlyPivotsFlag[i][j]=result;
                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showFibonacciMonthly[j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
            else if(alertModeSelection==PointsNearAlerts)
              {
               double pivotHigh=monthlyPivots[i][j]+pipPoints;
               double pivotLow=monthlyPivots[i][j]-pipPoints;

               result=((bid<=pivotHigh) && (bid>=pivotLow));
               if(result!=monthlyPivotsZoneFlag[i][j])
                 {
                  monthlyPivotsZoneFlag[i][j]=result;
                  if(TimeCurrent()>=monthlyPivotsWaitTill[i][j] && showFibonacciMonthly[j]==true && monthlyPivotsZoneFlag[i][j]==true)
                    {
                     monthlyPivotsWaitTill[i][j]=(TimeCurrent()+alertIntervalTimeSeconds);
                     doAlert(symbolName,pivotLevelName+fibonacciPivotNames[j],pivotSelection,alertModeSelection,0.00);
                    }
                 }
              }
           }
        }//end of monthly code
     }//end of for loop
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printOutPivotPoint(int index)
  {
   if(index>numSymbols-1 || index<0)
     {
      Alert("printOutPivotPointsSymbolIndex invalid index number");
     }
   else
     {
      Alert(EnumToString(pivotSelection)+" - "+symbolListFinal[index]+" - "+(string)symbolTodaysDate[index]);

      if(pivotSelection==Standard)
        {
         if(useDailyPivotAlert==Yes)
           {
            string pivotLevelName="Daily ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<7;j++)//sets the initial flags
              {
               Alert(pivotLevelName+standardPivotNames[j]+" "+DoubleToString(dailyPivots[index][j],digits));
              }
           }
         else if(useWeeklyPivotAlert==Yes)
           {
            string pivotLevelName="Weekly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<7;j++)//sets the initial flags
              {
               Alert(pivotLevelName+standardPivotNames[j]+" "+DoubleToString(weeklyPivots[index][j],digits));
              }
           }
         else if(useMonthlyPivotAlert==Yes)
           {
            string pivotLevelName="Monthly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<7;j++)//sets the initial flags
              {
               Alert(pivotLevelName+standardPivotNames[j]+" "+DoubleToString(weeklyPivots[index][j],digits));
              }
           }
        }
      else if(pivotSelection==Camarilla)
        {
         if(useDailyPivotAlert==Yes)
           {
            string pivotLevelName="Daily ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<9;j++)//sets the initial flags
              {
               Alert(pivotLevelName+camarillaPivotNames[j]+" "+DoubleToString(dailyPivots[index][j],digits));
              }
           }
         else if(useWeeklyPivotAlert==Yes)
           {
            string pivotLevelName="Weekly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<9;j++)//sets the initial flags
              {
               Alert(pivotLevelName+camarillaPivotNames[j]+" "+DoubleToString(weeklyPivots[index][j],digits));
              }
           }
         else if(useMonthlyPivotAlert==Yes)
           {
            string pivotLevelName="Monthly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<9;j++)//sets the initial flags
              {
               Alert(pivotLevelName+camarillaPivotNames[j]+" "+DoubleToString(monthlyPivots[index][j],digits));
              }
           }
        }
      else if(pivotSelection==Woodie)
        {
         if(useDailyPivotAlert==Yes)
           {
            string pivotLevelName="Daily ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<5;j++)//sets the initial flags
              {
               Alert(pivotLevelName+woodiePivotNames[j]+" "+DoubleToString(dailyPivots[index][j],digits));
              }
           }
         else if(useWeeklyPivotAlert==Yes)
           {
            string pivotLevelName="Weekly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<5;j++)//sets the initial flags
              {
               Alert(pivotLevelName+woodiePivotNames[j]+" "+DoubleToString(weeklyPivots[index][j],digits));
              }
           }
         else if(useMonthlyPivotAlert==Yes)
           {
            string pivotLevelName="Monthly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<5;j++)//sets the initial flags
              {
               Alert(pivotLevelName+woodiePivotNames[j]+" "+DoubleToString(monthlyPivots[index][j],digits));
              }
           }
        }
      else if(pivotSelection==Fibonacci)
        {
         if(useDailyPivotAlert==Yes)
           {
            string pivotLevelName="Daily ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<15;j++)//sets the initial flags
              {
               Alert(pivotLevelName+fibonacciPivotNames[j]+" "+DoubleToString(dailyPivots[index][j],digits));               
              }
           }
         else if(useWeeklyPivotAlert==Yes)
           {
            string pivotLevelName="Weekly ***";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<15;j++)//sets the initial flags
              {
               Alert(pivotLevelName+fibonacciPivotNames[j]+" "+DoubleToString(weeklyPivots[index][j],digits));                                            
              }
           }
         else if(useMonthlyPivotAlert==Yes)
           {
            string pivotLevelName="Monthly ";
            int digits=(int)MarketInfo(symbolListFinal[index],MODE_DIGITS);
            for(int j=0;j<15;j++)//sets the initial flags
              {
               Alert(pivotLevelName+fibonacciPivotNames[j]+" "+DoubleToString(monthlyPivots[index][j],digits));
              }
           }
        }
     }
  }

//+----------------------------------------------------------------------------+
// PlSoft Routine ( memorizzazione dati CVS)
//+----------------------------------------------------------------------------+
void WriteFile(string s2,int pivot ,string pivotype,int Id, double Price)
  { 
   
   double res=0.0;
  
 //{"USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"};
                
   switch(pivot) 
     { 

      case 1: 
         res=-0.382;break; //    ppArrayRef[symbolIndex][1]=R38;       
      case 2: 
         res=-0.618;break; //    ppArrayRef[symbolIndex][2]=R61;
      case 3: 
         res=-0.781;break; //    ppArrayRef[symbolIndex][3]=R78;     
      case 4: 
         res=-1.000;break; //    ppArrayRef[symbolIndex][4]=R100;
      case 5: 
         res=-1.382;break; //    ppArrayRef[symbolIndex][5]=R138;
      case 6: 
         res=-1.618;break; //    ppArrayRef[symbolIndex][6]=R161;                       
      case 7: 
         res=-2.000;break; //    ppArrayRef[symbolIndex][7]=R200;
                                  
      case 8: 
         res=0.382;break; //     ppArrayRef[symbolIndex][8]=S38;
      case 9: 
         res=0.618;break; //     ppArrayRef[symbolIndex][9]=S61;
      case 10: 
         res=0.781;break; //     ppArrayRef[symbolIndex][10]=S78;
      case 11: 
         res=1.000;break; //     ppArrayRef[symbolIndex][11]=S100; 
      case 12: 
         res=1.382;break; //     ppArrayRef[symbolIndex][12]=S138;         
      case 13: 
         res=1.618;break; //     ppArrayRef[symbolIndex][13]=S161;               
      case 14: 
         res=2.000;break; //     ppArrayRef[symbolIndex][14]=S200;         
                                                                                                 
     } 
     
   GlobalVariableSet(s2, res); 
           
   subfolder="Research";
   namafile="_data of "+s2+".csv";
   handlefile=FileOpen(subfolder+"\\"+namafile, FILE_CSV|FILE_WRITE|FILE_READ, ";");
      
   if(handlefile>0)
     {  
        date_=TimeToStr(Time[0], TIME_DATE);
        time_=TimeToStr(TimeCurrent(),TIME_MINUTES);

        FileSeek (handlefile, 0 , SEEK_END );
        writefile=FileWrite(handlefile, "Pivot " +"|"+ s2 +"|"+ date_ +"|"+ time_ +"|"+
                            DoubleToStr(res,3)+"|"+
                            pivotype+"|"+
                            DoubleToStr(Price,4)+"|"+
                            DoubleToStr(lowest,4)+"|"+
                            DoubleToStr(highest,4)+"|"+
                            DoubleToStr(priceLow,2)+"|"+
                            DoubleToStr(priceHigh,2)+"|"+
                            DoubleToStr(ObjectDescription("USDcurrdig"),2)+"|"+                                                           
                            DoubleToStr(ObjectDescription("EURcurrdig"),2)+"|"+                               
                            DoubleToStr(ObjectDescription("GBPcurrdig"),2)+"|"+                               
                            DoubleToStr(ObjectDescription("JPYcurrdig"),2)+"|"+                              
                            DoubleToStr(ObjectDescription("AUDcurrdig"),2)+"|"+                                                           
                            DoubleToStr(ObjectDescription("NZDcurrdig"),2)+"|"+                               
                            DoubleToStr(ObjectDescription("CADcurrdig"),2)+"|"+                             
                            DoubleToStr(ObjectDescription("CHFcurrdig"),2)                                                        
                            );
                                            
        FileClose(handlefile);         
      
      }   
      
     // SetText("centro",s2,0,220,clrTomato,12);        
}

//+----------------------------------------------------------------------------+
// PlSoft Routine ( trova superminimo & supermassimo)
//+----------------------------------------------------------------------------+
int WriteSuperMinMax(string MySymbol)
  {

   int    counted_bars=IndicatorCounted();
   
   lowest=1000.0; highest=0.0; priceLow=0; priceHigh=0;
 
//----
   
   for(int i=lookback+lastbar;i>lastbar+1;i--)
   {  
      double curLow0=iClose(MySymbol,timeframe,i-2);
      double curLow1=iClose(MySymbol,timeframe,i+1);
      double curLow2=iClose(MySymbol,timeframe,i);
      double curLow3=iClose(MySymbol,timeframe,i-1);
      double curLow4=iClose(MySymbol,timeframe,i-2);
      
      double curHigh0=iClose(MySymbol,timeframe,i+2);
      double curHigh1=iClose(MySymbol,timeframe,i+1);
      double curHigh2=iClose(MySymbol,timeframe,i);
      double curHigh3=iClose(MySymbol,timeframe,i-1);
      double curHigh4=iClose(MySymbol,timeframe,i-2);
         
      if(curLow2<=curLow1 && curLow2<=curLow1 && curLow2<=curLow0 )
      {
         if(lowest>curLow2){
         lowest=curLow2;}                
      }
      
      if(curHigh2>=curHigh1 && curHigh2>=curHigh3&& curHigh2>=curHigh4)
      {  
         if(highest<curHigh2){
         highest=curHigh2;}    
      } 
  }     
  
      priceLow = 100*(iClose(MySymbol,0,0)-lowest)/lowest;
      priceHigh = 100*(highest-iClose(MySymbol,0,0))/iClose(MySymbol,0,0); 
         
return(0);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
  
  //+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
   ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }   
//+------------------------------------------------------------------+