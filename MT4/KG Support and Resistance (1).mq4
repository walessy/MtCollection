//+------------------------------------------------------------------+
//|                                      KG Support & Resistance.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Kang_Gun  @  http://www.free-knowledge.com"
#property link      "https://forexsystemsru.com/threads/indikatory-sobranie-sochinenij-tankk.86203/"  ////https://forexsystemsru.com/forums/indikatory-foreks.41/
//--- //#property version   "2.11"  
#property indicator_chart_window
#property indicator_buffers 8
//#property indicator_color1 Yellow
//#property indicator_color2 Yellow
//#property indicator_color3 LimeGreen
//#property indicator_color4 LimeGreen
//#property indicator_color5 Blue
//#property indicator_color6 Blue
//#property indicator_color7 Red
//#property indicator_color8 Red
//---- enum parameters
enum calcPRC { HighLow, OpenClose };  
//---- input parameters
extern calcPRC       CalcPrices  =  HighLow;
extern ENUM_TIMEFRAMES  Period1  =  PERIOD_M15,
                        Period2  =  PERIOD_H1,
                        Period3  =  PERIOD_H4,
                        Period4  =  PERIOD_D1;
extern calcPRC       DrawPrices  =  HighLow;
extern color             color1  =  clrYellow,
                         color2  =  clrLimeGreen,
                         color3  =  clrDeepSkyBlue,  //DodgerBlue,
                         color4  =  clrMagenta;
extern int              SRcode1  =  158,
                        SRcode2  =  167,
                        SRcode3  =  115,
                        SRcode4  =  171,
                        SRsize1  =  2,
                        SRsize2  =  2,
                        SRsize3  =  3,
                        SRsize4  =  3;
//---- buffers
double Ress1[], Supp1[];
double Ress2[], Supp2[];
double Ress3[], Supp3[];
double Ress4[], Supp4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   Period1 = fmax(Period1,_Period);    
   Period2 = fmax(Period2,_Period);    
   Period3 = fmax(Period3,_Period);    
   Period4 = fmax(Period4,_Period);    
//---- indicators
   IndicatorBuffers(8);    IndicatorDigits(Digits);  //(Digits-Digits%2);   //if (Digits%2==1) IndicatorDigits(Digits-1);
   //---
   SetIndexBuffer(0,Ress1);
   SetIndexStyle(0,DRAW_ARROW,EMPTY,SRsize1,color1);   SetIndexArrow(0, SRcode1);
   SetIndexDrawBegin(0,Period1);                       SetIndexLabel(0,stringMTF(Period1)+": Resistance1");  //"Resistance M15");
   //---
   SetIndexBuffer(1,Supp1);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,SRsize1,color1);   SetIndexArrow(1, SRcode1);
   SetIndexDrawBegin(1,Period1);                       SetIndexLabel(1,stringMTF(Period1)+": Support1");  //"Support M15");
   //---
   SetIndexBuffer(2,Ress2);
   SetIndexStyle(2,DRAW_ARROW,EMPTY,SRsize2,color2);   SetIndexArrow(2, SRcode2);
   SetIndexDrawBegin(2,Period1);                       SetIndexLabel(2,stringMTF(Period2)+": Resistance2");  //"Resistance H1");
   //---
   SetIndexBuffer(3,Supp2);
   SetIndexStyle(3,DRAW_ARROW,EMPTY,SRsize2,color2);   SetIndexArrow(3, SRcode2);
   SetIndexDrawBegin(3,Period1);                       SetIndexLabel(3,stringMTF(Period2)+": Support2");  //"Support H1");
   //---
   SetIndexBuffer(4,Ress3);
   SetIndexStyle(4,DRAW_ARROW,EMPTY,SRsize3,color3);   SetIndexArrow(4, SRcode3);
   SetIndexDrawBegin(4,Period1);                       SetIndexLabel(4,stringMTF(Period3)+": Resistance3");  //"Resistance H4");
   //---
   SetIndexBuffer(5,Supp3);
   SetIndexStyle(5,DRAW_ARROW,EMPTY,SRsize3,color3);   SetIndexArrow(5, SRcode3);
   SetIndexDrawBegin(5,Period1);                       SetIndexLabel(5,stringMTF(Period3)+": Support3");  //"Support H4");
   //---
   SetIndexBuffer(6,Ress4);
   SetIndexStyle(6,DRAW_ARROW,EMPTY,SRsize4,color4);   SetIndexArrow(6, SRcode4);
   SetIndexDrawBegin(6,Period1);                       SetIndexLabel(6,stringMTF(Period4)+": Resistance4");  //Resistance D1");
   //---
   SetIndexBuffer(7,Supp4);
   SetIndexStyle(7,DRAW_ARROW,EMPTY,SRsize4,color4);   SetIndexArrow(7, SRcode4);
   SetIndexDrawBegin(7,Period1);                       SetIndexLabel(7,stringMTF(Period4)+": Support4");  //"Support D1");
   //---
   IndicatorShortName( WindowExpertName() +": "+ stringMTF(Period1)+" > "+stringMTF(Period2)+" > "+stringMTF(Period3)+" > "+stringMTF(Period4) );   //": CCI MTF TT ["+(string)CCIPeriod+">"+(string)Signal+"] ");
//---//---//
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()  {  Comment("");  return(0);  }
//+------------------------------------------------------------------+
//| Custom indicator Fractal function                                |
//+------------------------------------------------------------------+
bool Fractal (string M, int P, int shift)
  {
   if (_Period>P) return(false);
   P=P/_Period*2+MathCeil(P/_Period/2);                  
   //---
   if (shift<P) return(false);
   if (shift>Bars-P) return(false); 
   //---
   for (int i=1; i<=P; i++)   //enum calcPRC { HighLow, OpenClose };  
     {
      if (M=="U")
        {
         if (CalcPrices==0)
          {
           if (High[shift+i] > High[shift]) return(false);
           if (High[shift-i] >= High[shift]) return(false);    
          }
         //---
         if (CalcPrices==1)
          {
           if ( fmax(Open[shift+i],Close[shift+i]) > fmax(Open[shift],Close[shift]) ) return(false);
           if ( fmax(Open[shift-i],Close[shift-i]) >= fmax(Open[shift],Close[shift]) ) return(false);    
          }
        }
      //---
      if (M=="L")
        {
         if (CalcPrices==0)
          {
           if (Low[shift+i] < Low[shift]) return(false);
           if (Low[shift-i] <= Low[shift]) return(false);
          }
         //---
         if (CalcPrices==1)
          {
           if ( fmin(Open[shift+i],Close[shift+i]) < fmin(Open[shift],Close[shift]) ) return(false);
           if ( fmin(Open[shift-i],Close[shift-i]) <= fmin(Open[shift],Close[shift]) ) return(false);    
          }
        }        
     }
   return(true);   
  }  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int M15=Period1, H1=Period2, H4=Period3, D1=Period4;    ///int D1=1440, H4=240, H1=60, M15=15;
   //---
   int i=Bars;
     //---
     while (i>=0)
      {
       if (Fractal("U",M15,i)) Ress1[i] = DrawPrices==0 ? High[i] : fmax(Open[i],Close[i]);
       else Ress1[i] = Ress1[i+1];
       //---
       if (Fractal("L",M15,i)) Supp1[i] = DrawPrices==0 ? Low[i] : fmin(Open[i],Close[i]);
       else Supp1[i] = Supp1[i+1];
       //---
       if (Period2>Period1) 
        {
         if (Fractal("U",H1,i)) Ress2[i] = DrawPrices==0 ? High[i] : fmax(Open[i],Close[i]);
         else Ress2[i] = Ress2[i+1];
         //---
         if (Fractal("L",H1,i)) Supp2[i] = DrawPrices==0 ? Low[i] : fmin(Open[i],Close[i]);
         else Supp2[i] = Supp2[i+1];
        }
       //---
       if (Period3>Period1 && Period3!=Period2) 
        {
         if (Fractal("U",H4,i)) Ress3[i] = DrawPrices==0 ? High[i] : fmax(Open[i],Close[i]);
         else Ress3[i] = Ress3[i+1];
         //---
         if (Fractal("L",H4,i)) Supp3[i] = DrawPrices==0 ? Low[i] : fmin(Open[i],Close[i]);
         else Supp3[i] = Supp3[i+1];
        }
       //---
       if (Period4>Period1 && Period4!=Period3 && Period4!=Period2) 
        {
         if (Fractal("U",D1,i)) Ress4[i] = DrawPrices==0 ? High[i] : fmax(Open[i],Close[i]);
         else Ress4[i] = Ress4[i+1];
         //---
         if (Fractal("L",D1,i)) Supp4[i] = DrawPrices==0 ? Low[i] : fmin(Open[i],Close[i]);
         else Supp4[i] = Supp4[i+1];
        }
       //---
       i--;
      }
//---//---//
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string stringMTF(int perMTF)
{  
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Period error!");  //("Ошибка периода");
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+