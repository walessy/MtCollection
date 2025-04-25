//+------------------------------------------------------------------+
//|                                                    nPipLines.mq4 |
//|                                                        Cubesteak |
//|                                                www.cubesteak.net |
//+------------------------------------------------------------------+
#property copyright "Cubesteak"
#property link      "www.cubesteak.net"

#property indicator_chart_window
//---- input parameters
extern int       nLines=1000;
extern int       nPipGap=50;
extern color     LineColor=FireBrick;
extern int       LineSize = 0; // Integer value to set/get object line width. Can be from 1 to 5. 
extern int       LineStyle = STYLE_SOLID ; // STYLE_SOLID, STYLE_DASH, STYLE_DOT, STYLE_DASHDOT, STYLE_DASHDOTDOT constants to set/get object line style. 
extern bool      ContinuousUpdate = false;

int DidIt = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

for (int x = nLines;x>=0;x--)
{
   DeleteLine(x);
}
DidIt = 0;
DrawLines();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
for (int x = nLines;x>=0;x--)
{
   DeleteLine(x);
}

   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   if (ContinuousUpdate) DrawLines();
   else if (DidIt == 0 ) { DrawLines(); DidIt = 1;}
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void MakeLine(double ThisPrice, int Unique)
{
   string ThisLine = StringConcatenate("nPipLine",Unique);
   bool foo = ObjectCreate(ThisLine, OBJ_HLINE, 0,0,0);
   ObjectSet(ThisLine,OBJPROP_PRICE1,ThisPrice);
   ObjectSet(ThisLine,OBJPROP_COLOR,LineColor);
   ObjectSet(ThisLine,OBJPROP_WIDTH,LineSize);
   ObjectSet(ThisLine,OBJPROP_STYLE,LineStyle);
}

void DeleteLine(int Unique)
{
   string ThisLine = StringConcatenate("nPipLine",Unique);
   ObjectDelete(ThisLine);
}


void DrawLines()
{
   double CurPrice = Open[0];
   //Print("curprice",CurPrice);

   int Ord = CurPrice;
   //Print("ord",Ord);

   double AftDec = CurPrice - Ord;

   //Print ("aftdec:",AftDec);

   int PlacesToMove = Digits - 2;

   //Print ("places to move:",PlacesToMove);

   int MultValue = MathPow(10,PlacesToMove);

   //Print ("MultValue:",MultValue);

   double PartValue = AftDec * MultValue;

   //Print ("PartValue:",PartValue);
 
   int PlaceValue = MathRound(PartValue);
 
   //Print ("PlaceValue:",PlaceValue);

   int StartValue = AftDec * MultValue;

   //Print ("StartValue:",StartValue);

   double NewAftDec = StartValue / ((MultValue*0.1)/(0.1));

   //Print ("NewAftDec:",NewAftDec);

   if (PlaceValue > StartValue) double StartPrice = Ord + NewAftDec + (5/(MathPow(10,PlacesToMove+1)));
   else StartPrice = Ord + NewAftDec;

   //Print("StartPrice:",StartPrice);

   double LinePrice = NormalizeDouble(StartPrice,Digits);

   //Print("LinePrice:",LinePrice);

   double dPipGap = (nPipGap * Point) - (0.1*Point) ;

   //Print("dPipGap:",dPipGap);

   int half = nLines / 2;

   //Print("half:",half);


   for (int x = 0;x<=half;x++)
   {
      MakeLine(LinePrice, x);
      LinePrice += dPipGap;
   }

   LinePrice = NormalizeDouble(StartPrice,Digits);

   for (x = nLines;x>half;x--)
   {
      MakeLine(LinePrice, x);
      LinePrice -= dPipGap;
   }

}