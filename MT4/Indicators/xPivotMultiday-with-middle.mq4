//+------------------------------------------------------------------+
//|                                               xPivotMultiday.mq4 |
//|                                               Based on SDX-Pivots|
//|                                                  Coded by xecret |
//+------------------------------------------------------------------+
//--  via fazi at http://www.forex-tsd.com/305368-post340.html
//--  20090916 xPivotMultiday-with-middle.mq4

#property indicator_chart_window

extern int  LookBackDays=5, ServerTimeZone=2,LabelShift=9;
extern bool ShowPivot=true; 
                           extern color R_color=Red;      extern int R_style=0,      R_width=1; 
                           extern color S_color=Aqua;     extern int S_style=0,      S_width=1;
                           extern color Pivot_color=LimeGreen; extern int Pivot_style=0,  Pivot_width=2;                  
extern bool ShowFibo=true;
                           extern color Fibo_color=LimeGreen; 
                           extern int   Fibo_style=2,Fibo_width=1;
extern bool ShowCamarilla=true;
                           extern color Camarilla_color=Yellow; 
                           extern int   Camarilla_style=0,Camarilla_width=1;
extern bool ShowOpen=false;
                           extern color Open_color=Yellow; 
                           extern int   Open_style=1,Open_width=1;
extern bool ShowTodayHighLow=false;
                           extern color TodayHighLow_color=Gray; 
                           extern int   TodayHighLow_style=0,TodayHighLow_width=1;
extern bool ShowYesterdayHighLow=false;
                           extern color YesterdayHighLow_color=Yellow; 
                           extern int   YesterdayHighLow_style=0,YesterdayHighLow_width=1;
extern bool ShowSweetSpots=false;
                           extern color SweetSpots_color=Orange; 
                           extern int   SweetSpots_style=2,SweetSpots_width=1;
extern bool PlotMiddle=false;
                           extern color PlotMiddle_color=Tan; 
                           extern int   PlotMiddle_style=0,PlotMiddle_width=0;



extern string LabelFont="Arial";
extern int    LabelSize=6;
extern color  LabelColor=Yellow;

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
    
      if (StringSubstr(name,0,7)=="[PIVOT]") 
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
     
       if(ShowPivot){
         d = (today_high - today_low);
         q = (yesterday_high - yesterday_low);
         p = (yesterday_high + yesterday_low + yesterday_close) / 3;
         
         r1 = (2*p)-yesterday_low;
         r2 = p+(yesterday_high - yesterday_low);              //	r2 = p-s1+r1;
	      r3 = (2*p)+(yesterday_high-(2*yesterday_low));
         s1 = (2*p)-yesterday_high;
         s2 = p-(yesterday_high - yesterday_low);              //	s2 = p-r1+s1;
	      s3 = (2*p)-((2* yesterday_high)-yesterday_low);
	      
	      //middle pivots
	      m0=0.5*(s2+s3);
         m1=0.5*(s1+s2);
         m2=0.5*(p+s1);
         m3=0.5*(p+r1);
         m4=0.5*(r1+r2);
         m5=0.5*(r2+r3);
	     
	      //m2 = 0.5*(((yesterday_high + yesterday_low + yesterday_close) / 3)+((2*p)-yesterday_high));
	      //m2 = 0.5*(p+s1);
	      
	      SetLevel("R1", r1,      R_color, R_style, TimeOpen_0[i],TimeClose_0[i],i,R_width);
         SetLevel("R2", r2,      R_color, R_style, TimeOpen_0[i],TimeClose_0[i],i,R_width);
         SetLevel("R3", r3,      R_color, R_style, TimeOpen_0[i],TimeClose_0[i],i,R_width);
           
         SetLevel("Pivot", p,    Aqua, 1, TimeOpen_0[i],TimeClose_0[i],i,2);
            
         SetLevel("S1", s1,      S_color, S_style, TimeOpen_0[i],TimeClose_0[i],i,S_width);
         SetLevel("S2", s2,      S_color, S_style, TimeOpen_0[i],TimeClose_0[i],i,S_width);
         SetLevel("S3", s3,      S_color, S_style, TimeOpen_0[i],TimeClose_0[i],i,S_width);
         
         SetLevel("M0", m0,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
         SetLevel("M1", m1,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
         SetLevel("M2", m2,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
         SetLevel("M3", m3,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
         SetLevel("M4", m4,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
         SetLevel("M5", m5,      PlotMiddle_color, PlotMiddle_style, TimeOpen_0[i],TimeClose_0[i],i,PlotMiddle_width);
       }
        
       if(ShowFibo){
         SetLevel("L-62%", yesterday_low - q*0.618,      Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("L-38%", yesterday_low - q*0.382,      Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("L+38%", yesterday_low + q*0.382,      Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("LH50%", yesterday_low + q*0.5,        Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("H-38%", yesterday_high - q*0.382,    Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("H+38%", yesterday_high + q*0.382,    Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
         SetLevel("H+62%", yesterday_high +  q*0.618,   Fibo_color, Fibo_style, TimeOpen_0[i],TimeClose_0[i],i,Fibo_width);
       }
        
       if (ShowCamarilla==true) {
         h4 = (q*0.55)+yesterday_close;
	      h3 = (q*0.27)+yesterday_close;
	      l3 = yesterday_close-(q*0.27);	
	      l4 = yesterday_close-(q*0.55);	
	        
         SetLevel("H3", h3,   Camarilla_color, Camarilla_style, TimeOpen_0[i],TimeClose_0[i],i,Camarilla_width);
         SetLevel("H4", h4,   Camarilla_color, Camarilla_style, TimeOpen_0[i],TimeClose_0[i],i,Camarilla_width);
         SetLevel("L3", l3,   Camarilla_color, Camarilla_style, TimeOpen_0[i],TimeClose_0[i],i,Camarilla_width);
         SetLevel("L4", l4,   Camarilla_color, Camarilla_style, TimeOpen_0[i],TimeClose_0[i],i,Camarilla_width);
       }
     
       if (ShowOpen) {         
         SetLevel("T Open", today_open,      Open_color, Open_style, TimeOpen_0[i],TimeClose_0[i],i,Open_width);
       }
       if (ShowTodayHighLow){
         SetLevel("T High", today_high,  TodayHighLow_color, TodayHighLow_style, TimeOpen_0[i],TimeClose_0[i],i,TodayHighLow_width);         
         SetLevel("T Low", today_low,    TodayHighLow_color, TodayHighLow_style, TimeOpen_0[i],TimeClose_0[i],i,TodayHighLow_width);         
       }     
       if (ShowYesterdayHighLow){  
         SetLevel("Y High", yesterday_high,  YesterdayHighLow_color, YesterdayHighLow_style, TimeOpen_0[i],TimeClose_0[i],i,YesterdayHighLow_width);         
         SetLevel("Y Low", yesterday_low,    YesterdayHighLow_color, YesterdayHighLow_style, TimeOpen_0[i],TimeClose_0[i],i,YesterdayHighLow_width);
       }    
       
       SetTimeLine("Start"+i, WeekDayToChar(Weekday[i]), TimeOpen_0[i], Orange, O[i] - 10*Point*PipDelta);
     }
     

   }
        
   UpdateToday();
   
   return(0);
}  
//+------------------------------------------------------------------+
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

void SetLevel(string text, double level, color col1, int linestyle, datetime startofday, datetime endofday=0,int IdxDay=1,int Width=1)
{
   if(endofday==0) endofday=Time[0];
   int digits= Digits;
   text=  Daymark[IdxDay] + " " + text;
   string labelname= "[PIVOT] " + text + " Label"+IdxDay,
          linename= "[PIVOT] " + text + " Line"+IdxDay,
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

   pricelabel=text;
   //if (ShowLevelPrices && StrToInteger(text)==0) 
   //   pricelabel= pricelabel + ": "+DoubleToStr(level, Digits);
   
   ObjectSetText(labelname, pricelabel, LabelSize, LabelFont, LabelColor);
}

void SetTimeLine(string objname, string text, datetime x, color col1, double vleveltext) 
{
   string name= "[PIVOT] " + objname;
   //int x= iTime(NULL, PERIOD_H1, idx);

   if (ObjectFind(name) != 0) 
      ObjectCreate(name, OBJ_TREND, 0, x, 0, x, 100);
   else {
      ObjectMove(name, 0, x, 0);
      ObjectMove(name, 1, x, 100);
   }
   
   ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name, OBJPROP_COLOR, DarkGray);
   
   if (ObjectFind(name + " Label") != 0) 
      ObjectCreate(name + " Label", OBJ_TEXT, 0, x, vleveltext);
   else
      ObjectMove(name + " Label", 0, x, vleveltext);
            
   ObjectSetText(name + " Label", text, 8, "Arial", col1);
}

void UpdateToday(){
  
  if(Time[0]!=lasttime){
    lasttime=Time[0]; 
    if(ShowPivot){
      MoveToday("R3");MoveToday("R2");MoveToday("R1");           MoveToday("Pivot");
      MoveToday("S1");MoveToday("S2");MoveToday("S3");
    }
    if(ShowFibo){  
      MoveToday("L-62%");MoveToday("L-38%");MoveToday("L+38%");  MoveToday("LH50%");
      MoveToday("H-38%");MoveToday("H+38%");MoveToday("H+62%");
    }
    if(ShowCamarilla){    
      MoveToday("H3");MoveToday("H4");MoveToday("L3");MoveToday("L4");
    }
    if(ShowYesterdayHighLow){    
      MoveToday("Y High");MoveToday("Y Low");MoveToday("T Open");
    }
    if(ShowOpen){    
      MoveToday("T Open");
    }
  }
  
  if (TimeCurrent()-timelastupdate < UpdateInterval) return (0);      
  timelastupdate= TimeCurrent();
  
  if (ShowTodayHighLow) {  
    IdxOpen_H1[0]=iBarShift(NULL,PERIOD_H1,TimeOpen_0[0]);
    IdxClose_H1[0]=0;
    H[0]=iHigh(NULL,PERIOD_H1,iHighest(NULL,PERIOD_H1,MODE_HIGH,IdxOpen_H1[0]-IdxClose_H1[0]+1,IdxClose_H1[0]));
    L[0]=iLow(NULL,PERIOD_H1,iLowest(NULL,PERIOD_H1,MODE_LOW,IdxOpen_H1[0]-IdxClose_H1[0]+1,IdxClose_H1[0]));    
    SetLevel("T High", H[0],  Yellow, STYLE_DASH, TimeOpen_0[0],TimeClose_0[0],0);         
    SetLevel("T Low", L[0],    Yellow, STYLE_DASH, TimeOpen_0[0],TimeClose_0[0],0);         
  }
  
  if (ShowSweetSpots) {
    int ssp1, ssp2;
    double ds1, ds2;
      
    ssp1= Bid / Point;
    ssp1= ssp1 - ssp1%(50*PipDelta);
    ssp2= ssp1 + 50*PipDelta;
      
    ds1= ssp1*Point;
    ds2= ssp2*Point;
      
    SetLevel(DoubleToStr(ds1,Digits), ds1,  SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
    SetLevel(DoubleToStr(ds2,Digits), ds2,  SweetSpots_color, SweetSpots_style, Time[10],Time[0]+Period()*60*LabelShift,-1,SweetSpots_width);
  }
}

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

void MoveToday(string text){
  ObjectSet("[PIVOT]  " + text + " Label0",OBJPROP_TIME1,Time[0]+Period()*60*LabelShift);
}