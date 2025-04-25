//+------------------------------------------------------------------+
//|                                                  SQ9 (Price).mq4 |
//|                                  Copyright © 2006, Matt Trigwell |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Matt Trigwell"
#property link      "m.trigwell@gmail.com"

#property indicator_chart_window


extern double    the_High_or_Low_Price=95.77;
extern bool      is_this_the_LOW_price=true;
extern int       line_spacing_multiplier=10000;

extern int        levels__to=1440;
extern int        lines_every=90;
extern double     factorNumber=0.5;

extern color     line_Color=FireBrick;
extern int       line_Style_choose_from_0_to_4=0;
extern int       font_size=9;
extern string    UniqueID="SQ9";





int init()
{
   return(0);
}

int deinit()
{
   double AngleIndex=0;
   string AngleName="";


   for(AngleIndex=0;AngleIndex<=levels__to;AngleIndex=AngleIndex+lines_every)
   {
      AngleName = UniqueID+"Angle_" + AngleIndex;
      ObjectDelete(AngleName + " Label");
      ObjectDelete(AngleName + " Line");
   }

   
   return(0);
}

int start()
{
   double AngleIndex=0;
   string AngleName="";
   double FactorIndex=0;
   double AnglePriceLevel=0;
   int Index=0;
   string strLabel="";

   for(AngleIndex=0;AngleIndex<=levels__to;AngleIndex=AngleIndex+lines_every)
   {
      AnglePriceLevel = CalculateSquare(FactorIndex,the_High_or_Low_Price);
      
      //Trim Zero's
      if(Index==1)
      {
         strLabel = DoubleToStr(AngleIndex,1);
      }
      else
      {
         strLabel = DoubleToStr(AngleIndex,0);
      }
      
      AngleName = UniqueID+"Angle_" + AngleIndex;
      
      

      if(ObjectFind(AngleName + " Line") != 0)
      {
         ObjectCreate(AngleName + " Line", OBJ_HLINE, 0, Time[40], AnglePriceLevel);
         ObjectSet(AngleName + " Line", OBJPROP_STYLE, line_Style_choose_from_0_to_4);
         
         if(MathMod(Index,2) == 0)
         {
            ObjectSet(AngleName + " Line", OBJPROP_COLOR, line_Color);
         }
         else
         {
             ObjectSet(AngleName + " Line", OBJPROP_COLOR, line_Color);
         }
      }
      else
      {
         ObjectMove(AngleName + " Line", 0, Time[40], AnglePriceLevel);
      }
   
      if(ObjectFind(AngleName + " Label") != 0)
      {
         ObjectCreate(AngleName + " Label", OBJ_TEXT, 0, Time[20], AnglePriceLevel);
         
         if(MathMod(Index,2) == 0)
         {
            ObjectSetText(AngleName + " Label", strLabel + "°", font_size, "Arial", line_Color);
            
         }
         else
         {
             ObjectSetText(AngleName + " Label", strLabel + "°", font_size, "Arial", line_Color);
         }  

      }
      else
      {
         ObjectMove(AngleName + " Label", 0, Time[20], AnglePriceLevel);
      }
      
      FactorIndex = FactorIndex + factorNumber;
      Index = Index + 1;
   }

   return(0);
}






double CalculateSquare(double Factor, double Price)
{
   double AnglePrice=0;



  if(Price > 0)
   {
   
      if(StringFind(Symbol(),"JPY",0) == -1)
      {
         Price = Price * line_spacing_multiplier;
      }
      else
      {
         Price = Price * line_spacing_multiplier;
         Price = Price  / 100;
      }
            
      if(is_this_the_LOW_price==true)
      {
         AnglePrice = MathPow(MathSqrt(Price) + Factor,2);
      }
      else
      {
         AnglePrice = MathPow(MathSqrt(Price) - Factor,2);
      }
   
      if(StringFind(Symbol(),"JPY",0) == -1)
      {
         AnglePrice = AnglePrice / line_spacing_multiplier;
      }
      else
      {
         AnglePrice = AnglePrice / line_spacing_multiplier;
         AnglePrice = AnglePrice  * 100;
      }
   
   }
   
   return(AnglePrice);

 
} 