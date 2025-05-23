#include <ere\include1v2.mqh>
#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 clrYellow  //Bull Upper
#property indicator_color2 clrYellow  //Bull Lower
#property indicator_color3 clrYellow  //Bear Upper
#property indicator_color4 clrYellow  //Bear Lower

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID


extern int ATR_Period=14;
extern double SL =1.5;
extern double TP=1;
extern double RiskPercent=1;


double UpperBullBuffer[];
double LowerBullBuffer[];
double UpperBearBuffer[];
double LowerBearBuffer[];
string sIndiName=WindowExpertName();

int init()
{
   CleanChart(sIndiName);
   IndiGlobalIsLoaded(true);
   ArrayFree(UpperBearBuffer);
   ArrayFree(LowerBearBuffer);
   ArrayFree(UpperBullBuffer);
   ArrayFree(LowerBullBuffer); 
   
   SetIndexBuffer(0,UpperBullBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 216);
   
   SetIndexDrawBegin(0,ATR_Period);
   SetIndexLabel(1,"Lower ATR");
   
   SetIndexBuffer(1,LowerBullBuffer);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 216);
   SetIndexDrawBegin(1,ATR_Period);
   SetIndexLabel(1,"Upper ATR");
   
   SetIndexBuffer(2,UpperBearBuffer);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 216);
   SetIndexLabel(2,"Upper ATR+Open price");
   
   SetIndexBuffer(3,LowerBearBuffer);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 216);
   SetIndexLabel(3,"Lower ATR+Open price");

   return(0);
}


void deinit()
{
   IndiGlobalIsLoaded(false);
   CleanChart(sIndiName);
   ArrayFree(UpperBearBuffer);
   ArrayFree(LowerBearBuffer);
   ArrayFree(UpperBullBuffer);
   ArrayFree(LowerBullBuffer);   

}


int start()

{
      CleanChart(sIndiName);
      
      double dATR, dSLATR, dTPATR;

      if(IsNewBar()){
         UpperBullBuffer[1] = NULL;
         LowerBullBuffer[1] = NULL;
         UpperBearBuffer[1] = NULL;
         LowerBearBuffer[1] = NULL;  
      }
   
         //Get previous candle atr
         dATR = iATR(Symbol(),0,ATR_Period,1);
         //dATR = High[i]-Low[i];
         dSLATR=(SL * dATR);
         dTPATR = (TP * dATR);
        

         UpperBearBuffer[0] = Close[0] + 1.5* dTPATR;
         LowerBearBuffer[0] = Close[0] - 1 *dTPATR;
         UpperBullBuffer[0] = Close[0] + 1 * dTPATR;
         LowerBullBuffer[0] = Close[0] - 1.5 * dTPATR;

      

   return(0);
}







