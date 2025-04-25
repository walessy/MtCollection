//+------------------------------------------------------------------+
//|                                               LaguerreFilter.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
//mod +fir +mtf

#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
#property indicator_chart_window

#property  indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red

//---- input parameters
extern double    gamma      = 0.7;
extern int       Price_Type = 4; 
extern int     TimeFrame = 0;


extern string   note_price = "0C 1O 2H 3L 4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";
extern string  TimeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";

//---- buffers
double Filter[];
double Fir[];
double price[];
double L0[];
double L1[];
double L2[];
double L3[];
string IndicatorFileName;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(7);
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexDrawBegin(0, 1);
	SetIndexLabel(0, "LaguerreFilter");
	SetIndexLabel(1, "FIR");
	SetIndexBuffer(0, Filter);
	SetIndexBuffer(1, Fir);
	SetIndexBuffer(2, price);
   SetIndexBuffer(3, L0);
   SetIndexBuffer(4, L1);
   SetIndexBuffer(5, L2);
   SetIndexBuffer(6, L3);
//----
   if(TimeFrame < Period()) TimeFrame = Period();

   string short_name="LaguerreFilter(" + DoubleToStr(gamma, 2) + ") "+TimeFrame;
   IndicatorShortName(short_name);
   IndicatorFileName = WindowExpertName();
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	int    limit;
	int    counted_bars = IndicatorCounted();
	double CU, CD;
	//---- last counted bar will be recounted
	if (counted_bars>0)
		counted_bars--;
	else
		counted_bars = 1;
	limit = Bars - counted_bars;
   if (TimeFrame != Period())
      {
         limit = MathMax(limit,TimeFrame/Period());

            for (int i=limit; i>= 0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);	


               Filter[i] = iCustom(NULL,TimeFrame,IndicatorFileName,gamma,Price_Type,0,y);
               Fir[i]    = iCustom(NULL,TimeFrame,IndicatorFileName,gamma,Price_Type,1,y);
            
            }

         return(0);         

      }



	for ( i=limit; i>=0; i--)
	{
		price[i]=iMA(NULL,0,1,0,0,Price_Type,i);
		
		L0[i] = (1.0 - gamma)*price[i] + gamma*L0[i+1];
		L1[i] = -gamma*L0[i] + L0[i+1] + gamma*L1[i+1];
		L2[i] = -gamma*L1[i] + L1[i+1] + gamma*L2[i+1];
		L3[i] = -gamma*L2[i] + L2[i+1] + gamma*L3[i+1];
		
		CU = 0;
		CD = 0;
		if (L0[i] >= L1[i])
			CU = L0[i] - L1[i];
		else
			CD = L1[i] - L0[i];
		if (L1[i] >= L2[i])
			CU = CU + L1[i] - L2[i];
		else
			CD = CD + L2[i] - L1[i];
		if (L2[i] >= L3[i])
			CU = CU + L2[i] - L3[i];
		else
			CD = CD + L3[i] - L2[i];

		if (CU + CD != 0)

			Filter[i] = (L0[i] + 2 * L1[i] + 2 * L2[i] + L3[i]) / 6.0;

         Fir[i]   = (price[i]+2.0*price[i+1]+2.0*price[i+2]+price[i+3]) / 6.0;



	}
   return(0);
}
//+------------------------------------------------------------------+