//+------------------------------------------------------------------+
//|                                       Laguerre_RSI_v2.1m_mtf.mq4 |
//|LaGuerre RSI v1.01 smz mtf                                 mladen |
//+------------------------------------------------------------------+
//mod
#property copyright "mladen"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_color1  clrDarkGray
#property indicator_color2  clrLime
#property indicator_color3  clrRed

//
//
// Alternative: Gama = 0.55,levels 0.75,0.45,0.15
//
//

extern ENUM_TIMEFRAMES TimeFrame     = PERIOD_CURRENT;        // Time frame
extern double          Gama          = 0.75;
extern ENUM_APPLIED_PRICE PriceType  = PRICE_CLOSE;
extern int             Smooth        = 1;           // smz: 1...3; if>3 smz=3
extern bool            SmoothPrice   = false;
extern double          Level1        = 0.975;
extern double          Level2        = 0.50;
extern double          Level3        = 0.025;
extern bool            ShowLevels    = true; 
extern bool            ShowLevelSig  = true; 
extern bool            ShowCrossings = true; 
input bool             ArrowOnFirst  = false;
extern bool            alertsOn      = false;
extern bool            alertsMessage = true;
extern bool            alertsSound   = false;
extern bool            alertsEmail   = false;
extern color           LevelsColor   = C'30,33,36';
extern string          UniqueID      = "Laguerre rsi1";
input bool             Interpolate   = true;             // Interpolate in mtf mode?

//
//
//
//
//

double MainBuffer[];
double CUpBuffer[];
double CDnBuffer[];
double L0[];
double L1[];
double L2[];
double L3[];
double L4[],count[];
string indicatorFileName;
string ShortName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Gama,PriceType,Smooth,SmoothPrice,Level1,Level2,Level3,ShowLevels,ShowLevelSig,ShowCrossings,ArrowOnFirst,alertsOn,alertsMessage,alertsSound,alertsEmail,LevelsColor,UniqueID,_buff,_ind)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(9);
   SetIndexBuffer(0, MainBuffer);SetIndexLabel(0,"Laguerre RSI");
   SetIndexBuffer(1, CUpBuffer); SetIndexStyle(1,(ShowCrossings||ShowLevelSig) ? DRAW_ARROW : DRAW_NONE); SetIndexArrow(1,159);
   SetIndexBuffer(2, CDnBuffer); SetIndexStyle(2,(ShowCrossings||ShowLevelSig) ? DRAW_ARROW : DRAW_NONE); SetIndexArrow(2,159);
   SetIndexBuffer(3, L0);
   SetIndexBuffer(4, L1);
   SetIndexBuffer(5, L2);
   SetIndexBuffer(6, L3);
   SetIndexBuffer(7, L4);
   SetIndexBuffer(8, count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   
   ShortName=UniqueID+" : "+timeFrameToString(TimeFrame)+" ("+DoubleToStr(Gama,2)+")";
   IndicatorShortName(ShortName); 
return(0);
}

int deinit(){   DeleteBounds(); return(0);}

//+------------------------------------------------------------------+
//|                                                                  |
//+---------------------------------------------

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(8,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  int x = y;
                  if (ArrowOnFirst)
                        {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
                  else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
                     MainBuffer[i] = _mtfCall(0,y);
                     CUpBuffer[i]  = EMPTY_VALUE;
                     CDnBuffer[i]  = EMPTY_VALUE;
                     if (x!=y)
                     {
                       CUpBuffer[i] = _mtfCall(1, y);
                       CDnBuffer[i] = _mtfCall(2,y);
                     }
                 
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)  _interpolate(MainBuffer);  
               }
   return(0);
   }

   //
   //
   //
   
   for(i = limit; i >= 0 ; i--) MainBuffer[i] = LaGuerre(Gama,i,PriceType);
   for(i = limit; i >= 0 ; i--)
   {
      CUpBuffer[i]  = EMPTY_VALUE;
      CDnBuffer[i]  = EMPTY_VALUE;
 
      if (ShowCrossings) 
      {

         if (MainBuffer[i] > Level1 && MainBuffer[i+1] < Level1) CUpBuffer[i] = Level1;
         if (MainBuffer[i] < Level1 && MainBuffer[i+1] > Level1) CDnBuffer[i] = Level1;
         if (MainBuffer[i] > Level3 && MainBuffer[i+1] < Level3) CUpBuffer[i] = Level3;
         if (MainBuffer[i] < Level3 && MainBuffer[i+1] > Level3) CDnBuffer[i] = Level3;
      }
      if (ShowLevelSig)
      { 
         if (MainBuffer[i] > Level1 ) CUpBuffer[i] = Level1;
         if (MainBuffer[i] < Level3 ) CDnBuffer[i] = Level3;
      }
   }            
   if (ShowLevels) UpdateBounds();
   if (alertsOn) CheckCrossings();
return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double LaGuerre(double gamma, int i, int priceType)
{
	double Price = iMA(NULL,0,1,0,MODE_SMA,priceType,i);
	double RSI   = 0.00;
	double CU    = 0.00;
	double CD    = 0.00;


   if (SmoothPrice)
   {
      	L4[i] = Price;
      	Price = smooth(L4,i);
   }
   L0[i] = (1.0 - gamma)*Price + gamma*L0[i+1];
	L1[i] = -gamma*L0[i] + L0[i+1]     + gamma*L1[i+1];
	L2[i] = -gamma*L1[i] + L1[i+1]     + gamma*L2[i+1];
	L3[i] = -gamma*L2[i] + L2[i+1]     + gamma*L3[i+1];

   //
   //
   //
   //
   //
   
	if (L0[i] >= L1[i])
   			CU = L0[i] - L1[i];
	else	   CD = L1[i] - L0[i];
	if (L1[i] >= L2[i])
   			CU = CU + L1[i] - L2[i];
	else	   CD = CD + L2[i] - L1[i];
	if (L2[i] >= L3[i])
			   CU = CU + L2[i] - L3[i];
	else	   CD = CD + L3[i] - L2[i];

   //
   //
   //
   //
   //

   if (CU + CD != 0) RSI = CU / (CU + CD) ;
   if (!SmoothPrice)
   {
      L4[i] = RSI;
      RSI   = smooth(L4,i);
   }
   return(RSI);
}

//
//
//
//
//

double smooth(double& array[],int i)
{
   double result;
      if (Smooth <= 0) result = (array[i]);
      if (Smooth == 1) result = (array[i] +   array[i+1] +   array[i+2])/3 ;
      if (Smooth == 2) result = (array[i] + 2*array[i+1] + 2*array[i+2] +   array[i+3])/6 ;
      if (Smooth >= 3) result = (array[i] + 2*array[i+1] + 3*array[i+2] + 3*array[i+3] + 2*array[i+4] + array[i+5])/12 ;
   return(result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CheckCrossings()
{
   if (CUpBuffer[0] == Level1) doAlert("level "+DoubleToStr(Level1,2)+" crossed up");
   if (CDnBuffer[0] == Level1) doAlert("level "+DoubleToStr(Level1,2)+" crossed down");
   if (CUpBuffer[0] == Level3) doAlert("level "+DoubleToStr(Level3,2)+" crossed up");
   if (CDnBuffer[0] == Level3) doAlert("level "+DoubleToStr(Level3,2)+" crossed down");
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Laguerre "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(_Symbol+" Laguerre ",message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void DeleteBounds()
{
   ObjectDelete(ShortName+"-1");
   ObjectDelete(ShortName+"-2");
   ObjectDelete(ShortName+"-3");
}

//
//
//
//
//

void UpdateBounds()
{
   if (Level1 > 0) SetUpBound(ShortName+"-1",1.0000     ,Level1);
   if (Level2 > 0) SetUpBound(ShortName+"-2",Level2*1.01,Level2*0.99);
   if (Level3 > 0) SetUpBound(ShortName+"-3",Level3     ,     0.0000);
}

//
//
//
//
//

void SetUpBound(string name, double up, double down,int objType=OBJ_RECTANGLE)
{
   if (ObjectFind(name) == -1)
      {
         ObjectCreate(name,objType,WindowFind(ShortName),0,0);
         ObjectSet(name,OBJPROP_PRICE1,up);
         ObjectSet(name,OBJPROP_PRICE2,down);
         ObjectSet(name,OBJPROP_COLOR,LevelsColor);
         ObjectSet(name,OBJPROP_BACK,true);
      }
      ObjectSet(name,OBJPROP_TIME1,Time[Bars-1]);
      ObjectSet(name,OBJPROP_TIME2,Time[     0]);
}