#property link          ""
#property version       "1.00"
#property strict
#property copyright     ""
#property description   "Based on 'RVI Indicator With Alert'. Added Bollinger Bands"
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   ""
//#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_separate_window
#property indicator_buffers 9

//RVI and Bands
#property indicator_color1 Yellow
#property indicator_color2 Orange
#property indicator_color3 MediumSeaGreen
#property indicator_color4 MediumSeaGreen
#property indicator_color5 MediumSeaGreen
#property indicator_color6 Blue
#property indicator_color7 Red
//#property indicator_color8 Green - Lower
//#property indicator_color9 SeaGreen 0 Higher


enum ENUM_RVI_TRADE_SIGNAL{
   SIGNAL_RVI_BUY=1,     //BUY
   SIGNAL_RVI_SELL=-1,   //SELL
   SIGNAL_RVI_NEUTRAL=0  //NEUTRAL
};

enum ENUM_BB_TRADE_SIGNAL{
   SIGNAL_BB_BUY=1,     //BUY
   SIGNAL_BB_SELL=-1,   //SELL
   SIGNAL_BB_NEUTRAL=0  //NEUTRAL
};
enum ENUM_CANDLE_TO_CHECK{
   CURRENT_CANDLE=0,    //CURRENT CANDLE
   CLOSED_CANDLE=1      //PREVIOUS CANDLE
};

enum ENUM_RVI_ALERT_SIGNAL{
   RVI_MAIN_SIGNAL_CROSS=0,    //RVI MAIN AND SIGNAL CROSS
   RVI_ZERO_CROSS=1,           //RVI CROSSES ZERO
};

enum ENUM_BB_ALERT_SIGNAL{
   BB_MAIN_SIGNAL_BREAKOUT=0          
};

enum ENUM_RVI_ARROW_SIZE{
   ARROW_SIZE_VERYSMALL=1, //VERY SMALL
   ARROW_SIZE_SMALL=2,     //SMALL
   ARROW_SIZE_MEDIUM=3,    //MEDIUM
   ARROW_SIZE_BIG=4,       //BIG
   ARROW_SIZE_VERYBIG=5,   //VERY BIG
};


input string Comment1="========================";        //MQLTA RVI With Alert
input string IndicatorName="NAW-BBonRVI_With_Alerts";                //Indicator Short Name

input string Comment2="========================RVI";        //Indicator Parameters
input int RVIPeriod=20;                                  //RVI Period
input ENUM_RVI_ALERT_SIGNAL AlertRVISignal=RVI_MAIN_SIGNAL_CROSS;     //Alert Signal When
input ENUM_CANDLE_TO_CHECK CandleToCheck=CURRENT_CANDLE;       //Candle To Use For Analysis
input int BarsToScan=500;                                      //Number Of Candles To Analyse

input string Comment_3="====================RVI Notifications";     //Notification Options
extern bool EnableNotify=false;                    //Enable Notifications Feature
extern bool SendAlert=true;                        //Send Alert Notification
extern bool SendApp=true;                          //Send Notification to Mobile
extern bool SendEmail=false;                        //Send Notification via Email
input int WaitTimeNotify=5;                        //Wait time between notifications (Minutes)

input string Comment_4="====================RVI Arrows";     //Drawing Options
input bool EnableDrawRVIArrows=true;                  //Draw Signal Arrows
input int ArrowRVIBuy=241;                            //Buy Arrow Code
input int ArrowRVISell=242;                           //Sell Arrow Code
input int RVIArrowSize=3;                             //Arrow Size (1-5)

input string Comment_5="====================Bands";     //Drawing Options
input int BandsPeriod=20;
input int BandsDeviation=1;

input string Comment_6="====================Stochastic ";
input int StochKPeriod = 5;
input int StochDPeriod=3 ;
input int StochSlowing =3;
input int StochPriceField = 0;
input ENUM_MA_METHOD StochMAMethod = MODE_SMA;
input int StochMin = 0;
input int StochMax = 100;

double BufferMain[];
double BufferSignal[];

double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];

double StochMainBuffer[];
double StochSignalBuffer[];
double StochHigherBuffer[];
double StochLowerBuffer[];

datetime LastNotificationTime;
//bool bFirstTick; //code copied from Start function
int Shift=0;

int indicatorWindowId;

int OnInit(void){
   indicatorWindowId= ChartWindowFind();
   IndicatorSetString(INDICATOR_SHORTNAME,"Bb on " + IndicatorName+" - RVI - ("+string(RVIPeriod)+")");

   OnInitInitialization();
   if(!OnInitPreChecksPass()){
      return(INIT_FAILED);
   }   

   InitialiseBuffers();
//   bFirstTick= false; //code copied from Start function
   return(INIT_SUCCEEDED);
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){

   bool IsNewCandle=CheckIfNewCandle();
   int i,pos,upTo;
   double price;
   pos=0;
   if(prev_calculated==0 || IsNewCandle)
      upTo=BarsToScan-1;
   else
      upTo=0;

/*
https://alpari.com/en/beginner/articles/intro-stochastic-indicator/
%K = (Most Recent Closing Price - Lowest Low) / (Highest High - Lowest Low) × 100
%D = 3-day SMA of %K
Lowest Low = lowest low of the specified time period
Highest High = highest high of the specified time period
*/

/*
//---- minimums countingn  fot stochastic
   i=BarsToScan-StochKPeriod;
   if(BarsToScan>StochKPeriod) i=BarsToScan-StochKPeriod-1;
   
   while(i>=0)
     {
      double min=1000000;
      k=i+StochKPeriod-1;
      while(k>=i)
        {
         price=Low[k];
         if(min>price) min=price;
         k--;
        }
      StochLowerBuffer[i]=min;
      i--;
     }
//---- maximums counting for stochastic
   i=BarsToScan-StochKPeriod;
   if(BarsToScan>StochKPeriod) i=BarsToScan-StochKPeriod-1;
   while(i>=0)
     {
      double max=-1000000;
      k=i+StochKPeriod-1;
      while(k>=i)
        {
         price=High[k];
         if(max<price) max=price;
         k--;
        }
      StochHigherBuffer[i]=max;
      i--;
     }
     
//---- %K line
   i=BarsToScan-StochKPeriod;
   if(BarsToScan>StochKPeriod) i=BarsToScan-StochKPeriod-1;
   while(i>=0)
     {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i+StochSlowing-1);k>=i;k--)
        {
         sumlow+=Close[k]-StochLowerBuffer[k];
         sumhigh+=StochHigherBuffer[k]-StochLowerBuffer[k];
        }
      if(sumhigh==0.0) StochMainBuffer[i]=100.0;
      else StochMainBuffer[i]=sumlow/sumhigh*100;
      i--;
     }
//---- last counted bar will be recounted
   i=BarsToScan-StochKPeriod;
   if(BarsToScan>StochKPeriod) i=BarsToScan-StochKPeriod-1;
//---- signal line is simple movimg average
   for(i=pos; i<=upTo && !IsStopped(); i++){
      StochSignalBuffer[i]=iMAOnArray(StochMainBuffer,BarsToScan,StochKPeriod,0,MODE_SMA,i);
   }
   */
   for(i=pos; i<=upTo && !IsStopped(); i++){
      //StochMain[i] = iStochastic(Symbol(),PERIOD_CURRENT,StochKPeriod,StochDPeriod,StochSlowing,StochMAMethod,StochPriceField,0,i);
      //StochSignal[i] = iStochastic(Symbol(),PERIOD_CURRENT,StochKPeriod,StochDPeriod,StochSlowing,StochMAMethod,StochPriceField,1,i);
      BufferMain[i]=iRVI(Symbol(),PERIOD_CURRENT,RVIPeriod,MODE_MAIN,i);
      BufferSignal[i]=iRVI(Symbol(),PERIOD_CURRENT,RVIPeriod,MODE_SIGNAL,i);

   }
   
   for(i=pos; i<=upTo && !IsStopped(); i++){ 
      //UpperBuffer[i]=iBandsOnArray(RSIBuffer,0,BandsPeriod,Deviation,Shift,MODE_UPPER,i);
      UpperBuffer[i]=iBandsOnArray(BufferMain,0,BandsPeriod,BandsDeviation,0,MODE_UPPER,i);
      MiddleBuffer[i]=iBandsOnArray(BufferMain,0,BandsPeriod,BandsDeviation,0,MODE_MAIN,i);
      LowerBuffer[i]=iBandsOnArray(BufferMain,0,BandsPeriod,BandsDeviation,0,MODE_LOWER,i);    
   }  
  
   
   if(IsNewCandle || prev_calculated==0){
      if(EnableDrawRVIArrows) DrawRVIArrows();
   }
   
   if(EnableDrawRVIArrows)
      DrawRVIArrow(0);

   if(EnableNotify)
      NotifyHit();
      
   return(rates_total);
}
  
  
void OnDeinit(const int reason){
   CleanChart();
}  


void OnInitInitialization(){
   LastNotificationTime=TimeCurrent();
   Shift=CandleToCheck;
}


bool OnInitPreChecksPass(){
   if(RVIPeriod<=0){
      Print("Wrong input parameter");
      return false;
   }   
   if(Bars(Symbol(),PERIOD_CURRENT)<RVIPeriod){
      Print("Not Enough Historical Candles");
      return false;
   }  
   if(BandsPeriod<=0){
      Print("Wrong input parameter");
      return false;
   }   
   if(Bars(Symbol(),PERIOD_CURRENT)<BandsPeriod){
      Print("Not Enough Historical Candles");
      return false;
   }   
   return true;
}


void CleanChart(){
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1;i>=0;i--){
      if(StringFind(ObjectName(i),IndicatorName,0)>=0){
         ObjectDelete(ObjectName(i));
      }
   }
}


void InitialiseBuffers(){
   
   IndicatorDigits(Digits);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BufferMain);
   SetIndexShift(0,0);
   SetIndexLabel(0,"RVI MAIN");
   SetIndexDrawBegin(0,RVIPeriod);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BufferSignal);
   SetIndexShift(1,0);
   SetIndexLabel(1,"RVI SIGNAL");
   SetIndexDrawBegin(1,0);
   
   SetIndexBuffer(2,UpperBuffer);
   ArraySetAsSeries(UpperBuffer,true);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexShift(2,0);
   SetIndexLabel(2,"Upper Band");
   SetIndexDrawBegin(2,0);
  
   SetIndexBuffer(3,MiddleBuffer);
   ArraySetAsSeries(MiddleBuffer,true);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexShift(3,0);
   SetIndexLabel(3,"Middle Band");
   SetIndexDrawBegin(3,0);
      
   SetIndexBuffer(4,LowerBuffer);  
   ArraySetAsSeries(LowerBuffer,true);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexShift(4,0);
   SetIndexLabel(4,"Lower Band");
   SetIndexDrawBegin(4,0);

   
   SetIndexBuffer(5,StochMainBuffer);  
   SetIndexStyle(5,DRAW_LINE);
   SetIndexShift(5,0);
   SetIndexLabel(5,"Stoch Main");
   SetIndexDrawBegin(5,0);
   
  
   SetIndexBuffer(6,StochSignalBuffer);  
   SetIndexStyle(6,DRAW_LINE);
   SetIndexShift(6,0);
   SetIndexLabel(6,"Stoch Signal");
   SetIndexDrawBegin(6,0);   
   
   
   SetIndexBuffer(7,StochHigherBuffer);  
   //SetIndexStyle(7,DRAW_LINE);
   //SetIndexShift(7,0);
   //SetIndexLabel(7,"Stoch Higher");
   //SetIndexDrawBegin(7,0);
   
  
   SetIndexBuffer(8,StochLowerBuffer);  
   //SetIndexStyle(8,DRAW_LINE);
   //SetIndexShift(8,0);
   //SetIndexLabel(8,"Stoch Lower");
   //SetIndexDrawBegin(8,0);   
   
   SetLevelValue(0,0);      
   
}


datetime NewCandleTime=TimeCurrent();
bool CheckIfNewCandle(){
   if(NewCandleTime==iTime(Symbol(),0,0)) return false;
   else{
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
   }
}


//Check if it is a trade Signla 0 - Neutral, 1 - Buy, -1 - Sell
ENUM_RVI_TRADE_SIGNAL IsRVISignal(int i){
   int j=i+Shift;
   if(AlertRVISignal==RVI_ZERO_CROSS){
      if(BufferMain[j+1]<0 && BufferMain[j]>0) return SIGNAL_RVI_BUY;
      if(BufferMain[j+1]>0 && BufferMain[j]<0) return SIGNAL_RVI_SELL;
   }
   if(AlertRVISignal==RVI_MAIN_SIGNAL_CROSS){
      if(BufferMain[j+1]<BufferSignal[j+1] && BufferMain[j]>BufferSignal[j]) return SIGNAL_RVI_BUY;
      if(BufferMain[j+1]>BufferSignal[j+1] && BufferMain[j]<BufferSignal[j]) return SIGNAL_RVI_SELL;
   }

   return SIGNAL_RVI_NEUTRAL;
}


datetime LastNotification=TimeCurrent()-WaitTimeNotify*60;

void NotifyHit(){
   if(!EnableNotify || TimeCurrent()<(LastNotification+WaitTimeNotify*60)) return;
   if(!SendAlert && !SendApp && !SendEmail) return;
   if(Time[0]==LastNotificationTime) return;
   ENUM_RVI_TRADE_SIGNAL Signal=IsRVISignal(0);
   if(Signal==SIGNAL_RVI_NEUTRAL) return;
   string EmailSubject=IndicatorName+" "+Symbol()+" Notification ";
   string EmailBody="\r\n"+AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+"\r\n\r\n"+IndicatorName+" Notification for "+Symbol()+"\r\n\r\n";
   string AlertText=IndicatorName+" - "+Symbol()+" Notification\r\n";
   string AppText=AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+" - "+IndicatorName+" - "+Symbol()+" - ";
   string Text="";
   
   if(Signal!=SIGNAL_RVI_NEUTRAL){      
      Text+="The RVI indicator triggered a signal";
   }
   
   EmailBody+=Text+"\r\n\r\n";
   AlertText+=Text+"\r\n";
   AppText+=Text+"";
   if(SendAlert) Alert(AlertText);
   if(SendEmail){
      if(!SendMail(EmailSubject,EmailBody)) Print("Error sending email "+IntegerToString(GetLastError()));
   }
   if(SendApp){
      if(!SendNotification(AppText)) Print("Error sending notification "+IntegerToString(GetLastError()));
   }
   LastNotification=TimeCurrent();
   Print(IndicatorName+"-"+Symbol()+" last notification sent "+TimeToString(LastNotification));
}


void DrawRVIArrows(){
   RemoveRVIArrows();
   if(!EnableDrawRVIArrows || BarsToScan==0) return;
   int MaxBars=Bars(Symbol(),PERIOD_CURRENT);
   if(MaxBars>BarsToScan) MaxBars=BarsToScan;
   for(int i=MaxBars-2;i>=1;i--){
      DrawRVIArrow(i);
   }
}


void RemoveRVIArrows(){
   int Window=-1;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1;i>=0;i--){
      if(StringFind(ObjectName(i),IndicatorName+"-ARWS-",0)>=0){
         ObjectDelete(ObjectName(i));
      }
   }
}

int SignalRVIWidth=0;

void DrawRVIArrow(int i){
   RemoveRVIArrowCurr();
   if(!EnableDrawRVIArrows){
      RemoveRVIArrows();
      return;
   }
   ENUM_RVI_TRADE_SIGNAL Signal=IsRVISignal(i);
   if(Signal==SIGNAL_RVI_NEUTRAL) return;
   datetime ArrowDate=iTime(Symbol(),0,i);
   string ArrowName=IndicatorName+"-ARWS-"+IntegerToString(ArrowDate);
   double ArrowPrice=0;
   int ArrowType=0;
   color ArrowColor=0;
   int ArrowAnchor=0;
   int ArrowCode=0;
   string ArrowDesc="";
   if(Signal==SIGNAL_RVI_BUY){
      ArrowPrice=Low[i];
      ArrowType=ArrowRVIBuy; 
      ArrowColor=clrGreen;  
      ArrowAnchor=ANCHOR_TOP;
      ArrowDesc="BUY";
   }
   if(Signal==SIGNAL_RVI_SELL){
      ArrowPrice=High[i];
      ArrowType=ArrowRVISell;
      ArrowColor=clrRed;
      ArrowAnchor=ANCHOR_BOTTOM;
      ArrowDesc="SELL";
   }
   ObjectCreate(0,ArrowName,OBJ_ARROW,0,ArrowDate,ArrowPrice);
   ObjectSetInteger(0,ArrowName,OBJPROP_COLOR,ArrowColor);
   ObjectSetInteger(0,ArrowName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,ArrowName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,ArrowName,OBJPROP_ANCHOR,ArrowAnchor);
   ObjectSetInteger(0,ArrowName,OBJPROP_ARROWCODE,ArrowType);
   SignalRVIWidth=RVIArrowSize;
   ObjectSetInteger(0,ArrowName,OBJPROP_WIDTH,SignalRVIWidth);
   ObjectSetInteger(0,ArrowName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,ArrowName,OBJPROP_BGCOLOR,ArrowColor);
   ObjectSetString(0,ArrowName,OBJPROP_TEXT,ArrowDesc);
   datetime CurrTime=iTime(Symbol(),0,0);

}


void RemoveRVIArrowCurr(){
   datetime ArrowDate=iTime(Symbol(),0,Shift);
   string ArrowName=IndicatorName+"-ARWS-"+IntegerToString(ArrowDate);
   ObjectDelete(0,ArrowName);
}

