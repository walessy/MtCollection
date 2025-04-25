//+------------------------------------------------------------------+
//|                                               xPivotMultiday.mq4 |
//|                                               Based on SDX-Pivots|
//|                                                  Coded by xecret |
//+------------------------------------------------------------------+
//--  via fazi at http://www.forex-tsd.com/305368-post340.html
//--  20090916 xPivotMultiday-with-middle.mq4
//--  renamed xPivot0050s.mq4                 20100715                          // scalpz
//--  aim is to reduce to 00 & 50 sweetspots then repeat for 2nd &or 3rd set    // scalpz
//--  renamed xSweet0050s.mq4                 20100715                          // scalpz

#property indicator_chart_window

extern int  LookBackDays=5, ServerTimeZone=0,LabelShift=5;

extern bool ShowSweetSpots=true;
                           extern color SweetSpots_color=Orange; 
                           extern int   SweetSpots_style=2,SweetSpots_width=1;

extern string LabelFont="Arial";
extern int    LabelSize=6;
extern color  LabelColor=Olive;  //  Olive or Orange

extern int    UpdateInterval=10;


double   H[100],L[100],O[100],C[100];
int      IdxOpen_H1[100],IdxClose_H1[100],Weekday[100],YesterdayOffset[100];
datetime TimeOpen_0[100],TimeClose_0[100];
string   Daymark[100];
datetime lasttime=0,timelastupdate=0;

int      TD, lastweekday=8;
int      RealLookBackDays;
int      PipDelta=1;

int init()
  {
   if(Digits==5 || Digits==3) PipDelta=10;
   TD=ServerTimeZone*3600;
   RealLookBackDays=MathMin(LookBackDays,MathFloor(Bars*Period()/1440)-2);
   int newsize=RealLookBackDays+3;
   ArrayResize(H,newsize);ArrayResize(L,newsize);ArrayResize(O,newsize);ArrayResize(C,newsize);
   ArrayResize(IdxOpen_H1,newsize);ArrayResize(IdxClose_H1,newsize);ArrayResize(Weekday,newsize);ArrayResize(YesterdayOffset,newsize);
   ArrayResize(TimeOpen_0,newsize);ArrayResize(TimeClose_0,newsize);ArrayResize(Daymark,newsize);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int obj_total= ObjectsTotal();
   
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,6)=="xSweet") 
         ObjectDelete(name);
   }   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if(TimeDayOfWeek(Time[0]-TD)!=lastweekday){
     lastweekday=TimeDayOfWeek(Time[0]-TD);
     ComputeData(RealLookBackDays);
     double today_high,today_low,today_open,yesterday_high,yesterday_low,yesterday_close;
     double d,q,p,r1,r2,r3,s1,s2,s3,h3,h4,l3,l4,m0,m1,m2,m3,m4,m5;
     for(int i=0;i<=RealLookBackDays;i++){
       today_high=H[i];today_low=L[i];today_open=O[i];
       yesterday_high=H[i+YesterdayOffset[i]];yesterday_low=L[i+YesterdayOffset[i]];yesterday_close=C[i+YesterdayOffset[i]];

     } //--  for(int i=0;i<=RealLookBackDays;i++)
   } //--  if(TimeDayOfWeek(Time[0]-TD)!=lastweekday)
        
   UpdateToday();
   return(0);
}  
//---------------------------------------------------------
void ComputeData(int lookbackdays)
{
  int i,j;
  IdxClose_H1[0]=0;
  //TimeClose_0[0]=Time[0];
  TimeClose_0[0]=Time[0]+Period()*60;
  for(i=0;i<=lookbackdays+2;i++){
    Weekday[i]=TimeDayOfWeek(iTime(NULL,PERIOD_H1,IdxClose_H1[i])-TD);
    for(j=IdxClose_H1[i]+1;j<=IdxClose_H1[i]+24;j++){
      if(TimeDayOfWeek(iTime(NULL,PERIOD_H1,j)-TD)!=Weekday[i]){
        IdxOpen_H1[i]=j-1;
        IdxClose_H1[i+1]=j;
        break;        
      }      
    }
    C[i]=iClose(NULL,PERIOD_H1,IdxClose_H1[i]);
    O[i]=iOpen(NULL,PERIOD_H1,IdxOpen_H1[i]);
    H[i]=iHigh(NULL,PERIOD_H1,iHighest(NULL,PERIOD_H1,MODE_HIGH,IdxOpen_H1[i]-IdxClose_H1[i]+1,IdxClose_H1[i]));
    L[i]=iLow(NULL,PERIOD_H1,iLowest(NULL,PERIOD_H1,MODE_LOW,IdxOpen_H1[i]-IdxClose_H1[i]+1,IdxClose_H1[i]));
    TimeOpen_0[i]=iTime(NULL,PERIOD_H1,IdxOpen_H1[i]);
    TimeClose_0[i+1]=iTime(NULL,0,iBarShift(NULL,0,TimeOpen_0[i])+1);
  }
  
  for(i=0;i<=lookbackdays;i++){
    for(j=1;j<=3;j++){
      if(Weekday[i+j]!=0 && Weekday[i+j]!=6){
        YesterdayOffset[i]=j;
        break;
      }
    }
    Daymark[i]=WeekDayToChar(Weekday[i]);
  }
  Daymark[0]="";
  Daymark[YesterdayOffset[0]]=Daymark[YesterdayOffset[0]] + "(Y)";
}
//---------------------------------------------------------
void SetLevel(string text, double level, color col1, int linestyle, datetime startofday, datetime endofday=0,int IdxDay=1,int Width=1)
{
   if(endofday==0) endofday=Time[0];
   int digits= Digits;
   text=  Daymark[IdxDay] + " " + text;
   string labelname= "xSweet " + text + " Label",
          linename= "xSweet " + text + " Line",
          pricelabel; 

   // create or move the horizontal line   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, startofday, level, endofday,level);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, Width);
      if(IdxDay!=0) ObjectSet(linename, OBJPROP_RAY, false);
   }
   else {
      ObjectMove(linename, 1, endofday,level);
      ObjectMove(linename, 0, startofday, level);
   }
   

   // put a label on the line   
   datetime lableposition;
   if(IdxDay<1) lableposition=Time[0]+Period()*60*LabelShift;else lableposition=startofday+Period()*60*LabelShift;
   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, lableposition, level);
   }
   else {
      ObjectMove(labelname, 0, lableposition, level);
   }

   pricelabel=text;                      // I dont think these 2 lines get actioned     // scalpz
   ObjectSetText(labelname, pricelabel, LabelSize, LabelFont, LabelColor);
}
//---------------------------------------------------------
void UpdateToday(){
  if(Time[0]!=lasttime){
    lasttime=Time[0]; 
  }
  
  if(TimeCurrent()-timelastupdate < UpdateInterval) return (0);      
  timelastupdate= TimeCurrent();

  if(ShowSweetSpots){
    int ssp1, ssp2, ssp3, ssp4, ssp5, ssp6;
    double ds1, ds2, ds3, ds4, ds5, ds6;
      
    ssp1= Bid / Point;
    ssp1= ssp1 - ssp1%(50*PipDelta);
    ssp2= ssp1 + 50*PipDelta;
    ssp3= ssp2 + 50*PipDelta;  // extra line above
    ssp4= ssp1 - 50*PipDelta;  // extra line below
    ssp5= ssp3 + 50*PipDelta;  // another extra line above
    ssp6= ssp4 - 50*PipDelta;  // another extra line below
      
    ds1= ssp1*Point;
    ds2= ssp2*Point;
    ds3= ssp3*Point;
    ds4= ssp4*Point;
    ds5= ssp5*Point;
    ds6= ssp6*Point;
      
    SetLevel(DoubleToStr(ds1,Digits), ds1, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds2,Digits), ds2, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds3,Digits), ds3, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds4,Digits), ds4, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds5,Digits), ds5, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds6,Digits), ds6, SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
  }
}
//---------------------------------------------------------
string WeekDayToChar(int weekday){
  switch(weekday){
    case 0: return("Sun");
    case 1: return("Mon");
    case 2: return("Tue");
    case 3: return("Wed");
    case 4: return("Thu");
    case 5: return("Fri");
    case 6: return("Sat");
    default: return("Err");
  }
}
//---------------------------------------------------------
void MoveToday(string text){
  ObjectSet("xSweet  " + text + " Label0",OBJPROP_TIME1,Time[0]+Period()*60*LabelShift);
}
//---------------------------------------------------------