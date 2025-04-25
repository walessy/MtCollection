
//+------------------------------------------------------------------+
//|                                                   Stochs4.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 DarkSeaGreen
#property indicator_color2 Red
#property indicator_color3 PaleGreen
#property indicator_color4 Red
#property indicator_color5 LightSeaGreen
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Red

#property indicator_level1 80
#property indicator_level2 20
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_levelcolor LightSteelBlue
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//---- input parameters
extern int KPeriod1=14;
extern int DPeriod1=1;
extern int Slowing1=1;

extern int KPeriod2=28;
extern int DPeriod2=1;
extern int Slowing2=1;

extern int KPeriod3=56;
extern int DPeriod3=1;
extern int Slowing3=1;

extern int KPeriod4=112;
extern int DPeriod4=1;
extern int Slowing4=1;

extern int MAMethod=0; // 0=sma, 1=ema, 2=smma, 3=lwma, 4=lsma
extern int PriceField=0; //  0 - Low/High or 1 - Close/Close.

double ExtMapBuffer1[], ExtMapBuffer2[], ExtMapBuffer3[], ExtMapBuffer4[], ExtMapBuffer5[], ExtMapBuffer6[], ExtMapBuffer7[], ExtMapBuffer8[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(8);
   string short_name = "Stochs4("+KPeriod1+","+KPeriod2+","+KPeriod3+","+KPeriod4+")";
   IndicatorShortName(short_name);
//   int draw_begin1=0;
//   int draw_begin2=0;
   int draw_begin1=KPeriod4+Slowing4;
   int draw_begin2=draw_begin1+DPeriod4;

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_NONE) ; 
//   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexLabel(0," main("+KPeriod1+","+DPeriod1+","+Slowing1+")");
   SetIndexDrawBegin(0,draw_begin1);

   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_NONE) ; 
//   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexLabel(1," signal("+KPeriod1+","+DPeriod1+","+Slowing1+")");
   SetIndexDrawBegin(1,draw_begin2);

   SetIndexBuffer(2,ExtMapBuffer1);
   SetIndexStyle(2,DRAW_NONE) ; 
//   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   SetIndexLabel(2," main("+KPeriod2+","+DPeriod2+","+Slowing2+")");
   SetIndexDrawBegin(2,draw_begin1);

   SetIndexBuffer(3,ExtMapBuffer2);
   SetIndexStyle(3,DRAW_NONE) ; 
//   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexLabel(3," signal("+KPeriod2+","+DPeriod2+","+Slowing2+")");
   SetIndexDrawBegin(3,draw_begin2);

   SetIndexBuffer(4,ExtMapBuffer1);
   SetIndexStyle(4,DRAW_NONE) ; 
//   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1);
   SetIndexLabel(4," main("+KPeriod3+","+DPeriod3+","+Slowing3+")");
   SetIndexDrawBegin(4,draw_begin1);

   SetIndexBuffer(5,ExtMapBuffer2);
   SetIndexStyle(5,DRAW_NONE) ; 
//   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexLabel(5," signal("+KPeriod3+","+DPeriod3+","+Slowing3+")");
   SetIndexDrawBegin(5,draw_begin2);

   SetIndexBuffer(6,ExtMapBuffer1);
   SetIndexStyle(6,DRAW_NONE) ; 
//   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1);
   SetIndexLabel(6," main("+KPeriod4+","+DPeriod4+","+Slowing4+")");
   SetIndexDrawBegin(6,draw_begin1);

   SetIndexBuffer(7,ExtMapBuffer2);
   SetIndexStyle(7,DRAW_NONE) ; 
//   SetIndexStyle(7,DRAW_LINE,STYLE_DOT);
   SetIndexLabel(7," signal("+KPeriod4+","+DPeriod4+","+Slowing4+")");
   SetIndexDrawBegin(7,draw_begin2);

   return(0);
  }

int start()
  {
   int    i, limit, counted_bars=IndicatorCounted();
   limit=Bars-counted_bars ;

   for(i=0 ; i<limit ; i++)
   {
   ExtMapBuffer1[i]=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod,PriceField,MODE_MAIN,i);
    ExtMapBuffer2[i]=iStochastic(NULL,0,KPeriod1,DPeriod1,Slowing1,MAMethod,PriceField,MODE_SIGNAL,i);
   ExtMapBuffer3[i]=iStochastic(NULL,0,KPeriod2,DPeriod2,Slowing2,MAMethod,PriceField,MODE_MAIN,i);
    ExtMapBuffer4[i]=iStochastic(NULL,0,KPeriod2,DPeriod2,Slowing2,MAMethod,PriceField,MODE_SIGNAL,i);
   ExtMapBuffer5[i]=iStochastic(NULL,0,KPeriod3,DPeriod3,Slowing3,MAMethod,PriceField,MODE_MAIN,i);
    ExtMapBuffer6[i]=iStochastic(NULL,0,KPeriod3,DPeriod3,Slowing3,MAMethod,PriceField,MODE_SIGNAL,i);
   ExtMapBuffer7[i]=iStochastic(NULL,0,KPeriod4,DPeriod4,Slowing4,MAMethod,PriceField,MODE_MAIN,i);
    ExtMapBuffer8[i]=iStochastic(NULL,0,KPeriod4,DPeriod4,Slowing4,MAMethod,PriceField,MODE_SIGNAL,i);
   }  
   return(0);
  }
// result:  it's showing only one line wh visibly is the KPeriod1 14 (red but not dotted) 
// in the data window only buffers 7 & 8 have a value 
// while in the indi window it's the ExtMapBuffer1 value shown 
// commenting out all but 1st line, results the same 
// it was lacking the IndicatorBuffers(8); line - but that made no drc 
