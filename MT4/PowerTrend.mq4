//+------------------------------------------------------------------+
//|                                                        Volna.mq4 |
//|                                           Copyright © 2007, SVS. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, SVS."
#property link      ""

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_width1 2
#property indicator_color2 DodgerBlue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
#property indicator_color4 DarkSlateGray 
#property indicator_width4 2
extern int PT_chart=5; 
extern int PT_Period=1;
extern string pair="";
string sym;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(3,ExtMapBuffer4);
   if (StringLen(pair)>0) sym=pair; else sym=Symbol();
   IndicatorShortName("PT("+PT_Period+")"+"("+sym+")");
   SetIndexLabel(0,"PT"+"("+sym+")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+   
int start()
  {
   double vt0,vt1;
   double vj,vk,vd;
   double vts;
   int MODE,p1,p2;
//---- TODO: add your code here
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars-1;
   for(int i=0;i<=limit;i++){                   
//------------------------------------------------------
      MODE=0;
      p1=PT_chart*PT_Period;
      p2=p1*2;
      vts=0;
      for (int c=0;c<=p2;c++){      
         vts=vts+iMA(sym,0,c,0,MODE,PRICE_WEIGHTED,i);         
         if(c==p1)vt0=(vts/p1)-iMA(sym,0,p1,0,MODE,PRICE_WEIGHTED,i);          
         if(c==p2)vt1=(vts/p2)-iMA(sym,0,p2,0,MODE,PRICE_WEIGHTED,i);                   
         }
//---------------------------------------------------------
      //--------------------------------           
      vk=(vt0+vt1)/2;
      vd=(vt0/2);           
      vj=(vt1-vd);    
      //-----------------------------
      ExtMapBuffer4[i]=vj;      
      if(vd<0)ExtMapBuffer3[i]=vd;
      if(vt1<0)ExtMapBuffer1[i]=vt1;
      if(vk<0)ExtMapBuffer2[i]=vk;
      if(vd>0)ExtMapBuffer3[i]=vd;
      if(vt1>0)ExtMapBuffer1[i]=vt1;
      if(vk>0)ExtMapBuffer2[i]=vk; 
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+