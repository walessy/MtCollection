//+------------------------------------------------------------------+
//|                                                   ADX Wilder.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"
/* written by Rosh*/
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 MediumSeaGreen
#property indicator_color2 DodgerBlue
#property indicator_color3 Coral
#property indicator_color4 Brown

//---- input parameters
extern int       Period_ADX=14;
//---- buffers
double ADXBuffer[];
double PlusDiBuffer[];
double MinusDiBuffer[];
double ADXR_Buffer[];

double DX_Buffer[];
double Plus_DMBuffer[];
double Minus_DMBuffer[];
double TR_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ADXBuffer);
   SetIndexDrawBegin(0,2*Period_ADX);
   SetIndexLabel(0,"ADX");
   SetIndexEmptyValue(0,EMPTY_VALUE);
   
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,PlusDiBuffer);
   SetIndexDrawBegin(1,Period_ADX);
   SetIndexLabel(1,"+DI");
   SetIndexEmptyValue(1,EMPTY_VALUE);

   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,MinusDiBuffer);
   SetIndexDrawBegin(2,Period_ADX);
   SetIndexLabel(2,"-DI");
   SetIndexEmptyValue(2,EMPTY_VALUE);

   SetIndexStyle(3,DRAW_LINE,STYLE_DASH);
   SetIndexBuffer(3,ADXR_Buffer);
   SetIndexDrawBegin(3,3*Period_ADX);
   SetIndexLabel(3,"ADXR");
   SetIndexEmptyValue(3,EMPTY_VALUE);

   SetIndexBuffer(4,DX_Buffer);
   SetIndexBuffer(5,Plus_DMBuffer);
   SetIndexBuffer(6,Minus_DMBuffer);
   SetIndexBuffer(7,TR_Buffer);

   IndicatorDigits(0);
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
   int   i,counted_bars=IndicatorCounted();
   int   limit1,limit2,limit3,limit4;
   double dm_plus, dm_minus,tr,TR14;
   double num1,num2,num3,summ;
   
   int counter1,counter2,counter3,counter4;
//----
   if (counted_bars==0)
      {
      limit1=Bars-2;
      limit2=Bars-1-Period_ADX;
      limit3=limit2-Period_ADX;
      limit4=limit3-Period_ADX;
      ArrayInitialize(Plus_DMBuffer,0);
      ArrayInitialize(Minus_DMBuffer,0);
      ArrayInitialize(TR_Buffer,0);
      ArrayInitialize(PlusDiBuffer,0);
      ArrayInitialize(MinusDiBuffer,0);
      ArrayInitialize(DX_Buffer,0);

      }   

   if (counted_bars>0)
      {
      limit1=Bars-counted_bars-1;
      limit2=limit1;
      limit3=limit1;
      limit4=limit1;
      }   
   for (i=limit1;i>=0;i--)
      {
      if (High[i]>High[i+1])  dm_plus=High[i]-High[i+1]; else dm_plus=0;
      if (Low[i+1]>Low[i])  dm_minus=Low[i+1]-Low[i]; else dm_minus=0;
      if (dm_plus==dm_minus)
         {
         dm_plus=0;
         dm_minus=0;
         }
      num1=MathAbs(High[i]-Low[i]);
      num2=MathAbs(High[i]-Close[i+1]);
      num3=MathAbs(Low[i]-Close[i+1]);
      tr=MathMax(num1,num2);
      tr=MathMax(tr,num3);
      Plus_DMBuffer[i]=dm_plus;
      Minus_DMBuffer[i]=dm_minus;
      TR_Buffer[i]=tr;
      
      //if (counter1<5*Period_ADX) Print(Bars-1-i,"   ",DoubleToStr(Plus_DMBuffer[i],Digits),"  ",DoubleToStr(Minus_DMBuffer[i],Digits),"  ",DoubleToStr(TR_Buffer[i],Digits));
      counter1++;
      }
   for (i=limit2;i>=0;i--)
      {
      TR14=iMAOnArray(TR_Buffer,0,Period_ADX,0,MODE_SMMA,i);
      //if (counter2<5*Period_ADX) Print(Bars-1-i,"   ",DoubleToStr(iMAOnArray(Plus_DMBuffer,0,Period_ADX,0,MODE_SMA,i),Digits),"  ",DoubleToStr(iMAOnArray(Plus_DMBuffer,0,Period_ADX,0,MODE_SMMA,i),Digits));
      if (TR14!=0)
         {
         PlusDiBuffer[i]=iMAOnArray(Plus_DMBuffer,0,Period_ADX,0,MODE_SMMA,i)/TR14*100.0;
         MinusDiBuffer[i]=iMAOnArray(Minus_DMBuffer,0,Period_ADX,0,MODE_SMMA,i)/TR14*100.0;
         }
      else
         {
         PlusDiBuffer[i]=0.0;
         MinusDiBuffer[i]=0.0;
         }
      summ=PlusDiBuffer[i]+MinusDiBuffer[i];   
      if (summ!=0)DX_Buffer[i]=MathAbs(PlusDiBuffer[i]-MinusDiBuffer[i])/summ*100.0; else DX_Buffer[i]=0;

      if (counter2<5*Period_ADX) Print(Bars-1-i,"   ",DoubleToStr(PlusDiBuffer[i],Digits),"  ",DoubleToStr(MinusDiBuffer[i],Digits),"  ",DoubleToStr(TR14,Digits));
      counter2++;
      }
   for (i=limit3;i>=0;i--)  ADXBuffer[i]=iMAOnArray(DX_Buffer,0,Period_ADX,0,MODE_SMMA,i);
   for (i=limit4;i>=0;i--)  ADXR_Buffer[i]=(ADXBuffer[i]+ADXBuffer[i+Period_ADX])/2.0;
//----
   return(0);
  }
//+------------------------------------------------------------------+