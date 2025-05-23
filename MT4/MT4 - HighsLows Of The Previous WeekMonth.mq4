//+------------------------------------------------------------------+
//|                                                 Weekly_HILO_Shj  |
//|                                                                  |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, "
#property link      "http://"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Tomato
#property indicator_color2 DeepSkyBlue
#property indicator_color3 LimeGreen
#property indicator_width1 2
#property indicator_width2 2
//---- input parameters
//---- buffers
extern bool Monatlich=true;
extern bool Jaehrlich=true;
extern bool Stuendlich=true;
extern int space=44;
extern bool Allert = true;
extern string Sound_High="mtp1.wav";
extern string Sound_Low="mtp2.wav";
extern string Sound_Mid="mtp3.wav"; 
extern bool Email = false; 


double PrevWeekHiBuffer[];
double PrevWeekLoBuffer[];
double PrevWeekMidBuffer[];
int fontsize=10;
double x;
double PrevWeekHi, PrevWeekLo, LastWeekHi, LastWeekLo,PrevWeekMid;
string Space;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("PrevWeekHi");
   ObjectDelete("PrevWeekLo");
   ObjectDelete("PrevWeekMid");
   string WHLTrend="WHLTrend "+WindowHandle(Symbol(),0);
   if(GlobalVariableCheck(WHLTrend))GlobalVariableDel(WHLTrend);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   int y;
//----
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(0, PrevWeekHiBuffer);
   SetIndexBuffer(1, PrevWeekLoBuffer);
   SetIndexBuffer(2, PrevWeekMidBuffer);
   short_name="Prev Hi-Lo levels";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexDrawBegin(0,1);
//----
   for(y=0;y<=space;y++)
     {
      Space=Space+" ";
     }
   string WHLTrend="WHLTrend "+Symbol();
   if(GlobalVariableCheck(WHLTrend))GlobalVariableDel(WHLTrend);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit, i;
   if (counted_bars==0)
     {
      x=Period();
      //if (x>10080) return(-1);
      ObjectCreate("PrevWeekHi", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekHi", Space+"HIGH minggu lalu",fontsize,"Arial", Tomato);
      ObjectCreate("PrevWeekLo", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekLo", Space+"LOW minggu lalu",fontsize,"Arial", DeepSkyBlue);
      ObjectCreate("PrevWeekMid", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("PrevWeekMid", Space+"50% hi-low ",fontsize,"Arial", LimeGreen);
     }
     
     
   limit=(Bars-counted_bars)-1;
 
   for(i=limit; i>=0;i--)
     {
      if (High[i+1]>LastWeekHi) LastWeekHi=High[i+1];
      if (Low [i+1]<LastWeekLo) LastWeekLo=Low [i+1];
      
      if(Monatlich){
         if (TimeMonth(Time[i])!=TimeMonth(Time[i+1]))
           {
            //if(TimeDayOfWeek(Time[i])==1)
              //{
               PrevWeekHi =LastWeekHi;
               PrevWeekLo =LastWeekLo;
               LastWeekHi =Open[i];
               LastWeekLo =Open[i];
               PrevWeekMid=(PrevWeekHi + PrevWeekLo)/2;
              //}
           }
      }
      else if(Jaehrlich){
         if ( TimeYear(Time[i])!= TimeYear(Time[i+1]) )
           {
            //if(TimeDayOfWeek(Time[i])==1)
              //{               
               PrevWeekHi =LastWeekHi;
               PrevWeekLo =LastWeekLo;
               LastWeekHi =Open[i];
               LastWeekLo =Open[i];
               PrevWeekMid=(PrevWeekHi + PrevWeekLo)/2;
              //}
           }
      }
       else if(Stuendlich){
         if ( TimeHour(Time[i])!= TimeHour(Time[i+1]) )
           {
            //if(TimeDayOfWeek(Time[i])==1)
              //{               
               PrevWeekHi =LastWeekHi;
               PrevWeekLo =LastWeekLo;
               LastWeekHi =Open[i];
               LastWeekLo =Open[i];
               PrevWeekMid=(PrevWeekHi + PrevWeekLo)/2;
              //}
           }
      }      
      else
      {
          if (TimeDay(Time[i])!=TimeDay(Time[i+1]))
           {
            if(TimeDayOfWeek(Time[i])==1)
              {
               PrevWeekHi =LastWeekHi;
               PrevWeekLo =LastWeekLo;
               LastWeekHi =Open[i];
               LastWeekLo =Open[i];
               PrevWeekMid=(PrevWeekHi + PrevWeekLo)/2;
              }
           }

      } 
        
      PrevWeekHiBuffer [i]=PrevWeekHi;
      PrevWeekLoBuffer [i]=PrevWeekLo;
      PrevWeekMidBuffer[i]=PrevWeekMid;
//----
      ObjectMove("PrevWeekHi" , 0, Time[i], PrevWeekHi);
      ObjectMove("PrevWeekLo" , 0, Time[i], PrevWeekLo);
      ObjectMove("PrevWeekMid", 0, Time[i], PrevWeekMid);
     }
//+------------------------------------------------------------------+
//| Alert                                                            |
//+------------------------------------------------------------------+
static int al1,al2,al3;
string str;
if(Monatlich)str="Monat";
else if(Jaehrlich)str="Jahres";
else if(Stuendlich)str="Stündliche";
else str="Wochen";
string WHLTrend="WHLTrend "+WindowHandle(Symbol(),0);
if(Allert==true && al1!=1 && Bid>=PrevWeekHiBuffer[0])
		    {
      GlobalVariableSet(WHLTrend,1);
		    al2=0;al3=0;al1=1;
		    Alert("Weekly HILO Indikator ",str," Highlinie berührt , Symbol ",Symbol()," - Chartperiode ",Period());PlaySound(Sound_High);
		    if(Email)SendMyMessage("Weekly HILO Indikator Highlinie","Weekly HILO Indikator "+str+" Highlinie berührt , Symbol "+Symbol()+" - Chartperiode "+Period());
		    }
if(Allert==true && al2!=1 && Bid<=PrevWeekLoBuffer[0])
		    {
      GlobalVariableSet(WHLTrend,2);
		    al2=1;al3=0;al1=0;
		    Alert("Weekly HILO Indikator ",str," Lowlinie berührt , Symbol ",Symbol()," - Chartperiode ",Period());PlaySound(Sound_Low);
		    if(Email)SendMyMessage("Weekly HILO Indikator Lowlinie","Weekly HILO Indikator "+str+" Lowlinie berührt , Symbol "+Symbol()+" - Chartperiode "+Period());
		    }
if(Allert==true && al3!=1 && Bid<=PrevWeekMidBuffer[0]+Point*2 && Bid>=PrevWeekMidBuffer[0]-Point*2)
		    {
		    al2=0;al3=1;al1=0;
		    Alert("Weekly HILO Indikator ",str," Mittellinie berührt , Symbol ",Symbol()," - Chartperiode ",Period());PlaySound(Sound_Mid);
		    if(Email)SendMyMessage("Weekly HILO Indikator Mittellinie", "Weekly HILO Indikator "+str+" Mittellinie berührt , Symbol "+Symbol()+" - Chartperiode "+Period());
		    }
int trend=GlobalVariableGet(WHLTrend);		Comment(trend,"  ",PrevWeekHiBuffer[0]);    
if(trend==1 && Bid<PrevWeekHiBuffer[0] && al1==1)GlobalVariableSet(WHLTrend,2);
//else if(trend==2 && Bid>PrevWeekLoBuffer[0] && al2==1)GlobalVariableSet(WHLTrend,1);


   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Email                                                            |
//+------------------------------------------------------------------+
int SendMyMessage(string betrf, string text)
  {
   int check;
   SendMail(betrf, text);
   check=GetLastError();
   if(check!=0)
   {
    Print("Cannot send message, error: ",check);
    return(1);
   }
   else return(0);
  }