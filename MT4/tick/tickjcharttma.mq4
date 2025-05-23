//+------------------------------------------------------------------+
//|                                                   Tick Chart.mq4 |
//|     Copyright © 2005, MetaQuotes Software Corp. © 2010, J.Arent. |
//|              http://www.metaquotes.net/, http://www.fxtools.info |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Cornsilk
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 Green

int period=2000;
int width=50;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];

int tik,t;
double buf[],buf2[],MaxB,MinB=1000;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int i,b;
//---- 
t++;
b=period;
ArrayResize(buf,b); 
ArrayResize(buf2,b); 

if(tik==0)
   {
   for(i=0;i<b;i++)
      {
      buf[i]=Bid;
      buf2[i]=Ask;
      }
   ExtMapBuffer2[0]=Bid+width*Point;   
   ExtMapBuffer2[1]=Bid-width*Point;
   tik=1;
   }
   MaxB=0;MinB=1000;
   for(i=b-1;i>0;i--)
      {
      buf[i]=buf[i-1];
      if(MaxB<buf[i])MaxB=buf[i];
      if(MinB>buf[i])MinB=buf[i];
      buf2[i]=buf2[i-1];
      if(MaxB<buf2[i])MaxB=buf2[i];
      if(MinB>buf2[i])MinB=buf2[i];
      } 
buf[0]=Bid;
buf2[0]=Ask;
for(i=0;i<b;i++)
   {
   ExtMapBuffer1[i]=buf[i];
   ExtMapBuffer3[i]=buf2[i];
   }
if(MathCeil(t/10)*10==t)
   {
   for(i=b;i<Bars;i++)
      {
      ExtMapBuffer1[i]=Bid;
      ExtMapBuffer3[i]=Ask;
      }
      ArrayInitialize(ExtMapBuffer2,Bid); 
      if(MaxB-Bid<width*Point)ExtMapBuffer2[0]=Bid+width*Point;
      if(Bid-MinB<width*Point)ExtMapBuffer2[1]=Bid-width*Point;
      //Print(MaxB,"+",Bid,"+",MinB);
   }   
for(i=0;i<Bars;i++)
{
ExtMapBuffer4[i]=(ExtMapBuffer1[i]+ExtMapBuffer1[i+1]+ExtMapBuffer1[i+2]+ExtMapBuffer1[i+3]+
 ExtMapBuffer1[i+4]+ExtMapBuffer1[i+5]+ExtMapBuffer1[i+6]+ExtMapBuffer1[i+7]+
 ExtMapBuffer1[i+8]+ExtMapBuffer1[i+9]+ExtMapBuffer1[i+10]+ExtMapBuffer1[i+11]+
 ExtMapBuffer1[i+12]+ExtMapBuffer1[i+13]+ExtMapBuffer1[i+14]+ExtMapBuffer1[i+15]+
 ExtMapBuffer1[i+16]+ExtMapBuffer1[i+17]+ExtMapBuffer1[i+18]+ExtMapBuffer1[i+19]+      
 ExtMapBuffer1[i+20]+ExtMapBuffer1[i+21]+ExtMapBuffer1[i+22]+ExtMapBuffer1[i+23]+ExtMapBuffer1[i+24])/25;
ExtMapBuffer5[i]=(ExtMapBuffer3[i]+ExtMapBuffer3[i+1]+ExtMapBuffer3[i+2]+ExtMapBuffer3[i+3]+
 ExtMapBuffer3[i+4]+ExtMapBuffer3[i+5]+ExtMapBuffer3[i+6]+ExtMapBuffer3[i+7]+
 ExtMapBuffer3[i+8]+ExtMapBuffer3[i+9]+ExtMapBuffer3[i+10]+ExtMapBuffer3[i+11]+
 ExtMapBuffer3[i+12]+ExtMapBuffer3[i+13]+ExtMapBuffer3[i+14]+ExtMapBuffer3[i+15]+
 ExtMapBuffer3[i+16]+ExtMapBuffer3[i+17]+ExtMapBuffer3[i+18]+ExtMapBuffer3[i+19]+      
 ExtMapBuffer3[i+20]+ExtMapBuffer3[i+21]+ExtMapBuffer3[i+22]+ExtMapBuffer3[i+23]+ExtMapBuffer3[i+24])/25;
}


//----
   return(0);
  }
//+------------------------------------------------------------------+