#property copyright "Copyright © 2013, www.FxAutomated.com"
#property link      "http://www.FxAutomated.com"

#property indicator_chart_window

extern color BrokerTimeColor=Red;
extern color ComputerTimeColor=Lime;
extern int   DistanceFromTopLeft=10;
extern double ZoomLevel=1;

int init()
  {

      CreateObject();

   return(0);
  }

void deleteClock(){
   if(ObjectFind("Label_ct")>0){
      ObjectDelete("Label_ct");
   }
   if(ObjectFind("Label_bt")>0){
      ObjectDelete("Label_bt");
   }
}

void OnTimer()
  {
  }
  
  
int start()
  {
  
   if(CHART_IS_MAXIMIZED){
      CreateObject();
      ObjectSetText("Label_bt",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),2*ZoomLevel,"Arial",BrokerTimeColor);
      ObjectSetText("Label_ct",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),2*ZoomLevel,"Arial",ComputerTimeColor);
   }
   else{
      deleteClock();
   }
   return(0);
  }

void CreateObject(){
   ObjectCreate("Label_bt", OBJ_LABEL, 0, 0, 0);  // Creating obj.
   ObjectSet("Label_bt", OBJPROP_CORNER, 0);    // Reference corner
   ObjectSet("Label_bt", OBJPROP_XDISTANCE, DistanceFromTopLeft*ZoomLevel);// X coordinate   
   ObjectSet("Label_bt", OBJPROP_YDISTANCE, 30*ZoomLevel);// Y coordinate

   ObjectCreate("Label_ct", OBJ_LABEL, 0, 0, 0);  // Creating obj.
   ObjectSet("Label_ct", OBJPROP_CORNER, 0);    // Reference corner
   ObjectSet("Label_ct", OBJPROP_XDISTANCE, DistanceFromTopLeft*ZoomLevel);// X coordinate   
   ObjectSet("Label_ct", OBJPROP_YDISTANCE, 60*ZoomLevel);// Y coordinate

}

int deinit()
  {
      deleteClock();

   return(0);
  }