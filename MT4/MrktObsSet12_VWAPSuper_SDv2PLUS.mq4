//+------------------------------------------------------------------+
//                                              		VWAP Bands.mq4 |
//|                             		 Copyright © 2016, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#include <ere\include1v2.mqh>

#property copyright "Copyright © 2016, EarnForex.com"
#property link      "https://www.earnforex.com/forum/threads/can-somebody-please-help-upgrading-this-indicator.22300/"
#property version   "1.00"
#property strict

#property description "VWAP refers to Volume Weight Average Price."
#property description "Bands are created based on standard deviation of price from VWAP."
#property description "You can use up to 3 bands."

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots 7
#property indicator_color1 clrWhite
#property indicator_color2 clrRed
#property indicator_color3 clrRed
#property indicator_color4 clrGreen
#property indicator_color5 clrGreen
#property indicator_color6 clrSkyBlue
#property indicator_color7 clrSkyBlue
#property indicator_color8 clrNONE;
#property indicator_color9 clrNONE;
#property indicator_color10 clrNONE;

#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 0
#property indicator_width9 0
#property indicator_width10 0
 
input int N = 20; // Period of Volume Weight Average Price
input int Shift = 0;
input ENUM_APPLIED_PRICE Price_Type = PRICE_CLOSE; // Price Type
input double DeviationBand1 = 1; // Number of StdDevs for the 1st band
input double DeviationBand2 = 1.5; // Number of StdDevs for the 2nd band
input double DeviationBand3 = 2; // Number of StdDevs for the 3rd band

// Indicator buffers
double ExtMapBuffer1[], UpperDev1[], LowerDev1[], UpperDev2[], LowerDev2[], UpperDev3[], LowerDev3[], ExtStdDevBuffer[];
//double BarOpen[], BarClose[];
string sIndiName=WindowExpertName();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   CleanChart();
   ArrayFree(ExtStdDevBuffer);
   IndiGlobalIsLoaded(true);
   if (N < 1)
   {
   	Alert("Period must be >= 1.");
   	return(INIT_FAILED);
   }
   IndicatorDigits(Digits);

   SetIndexBuffer(0 , ExtMapBuffer1);
   SetIndexShift(0, Shift);
   SetIndexBuffer(1, UpperDev1);
   SetIndexShift(1, Shift);
   SetIndexBuffer(2, LowerDev1);
   SetIndexShift(2, Shift);   
   SetIndexBuffer(3, UpperDev2);
   SetIndexShift(3, Shift);
   SetIndexBuffer(4, LowerDev2);
   SetIndexShift(4, Shift); 
   SetIndexBuffer(5, UpperDev3);
   SetIndexShift(5, Shift);
   SetIndexBuffer(6, LowerDev3);
   SetIndexShift(6, Shift);       
   SetIndexBuffer(7, ExtStdDevBuffer);
   //SetIndexBuffer(8, BarOpen);
   //SetIndexBuffer(9, BarClose);
   
	IndicatorShortName("VWAP Super (" + IntegerToString(N) + ")");
	
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   CleanChart();
   int bar = Bars - IndicatorCounted() + N;
   if (bar >= Bars - N) bar = Bars - N;
   int cndleInx=0;
   double sum1 = 0, sum2 = 0;
            
   //Cached past bars
   //This calculates for all bars   
   for (int i = 1; i <= bar; i++)
   //THIS ONLY CALCLATES for current period
   //for (int i = 0; i <= (N+N); i++)
   {  
      
      if(MathMod(i,N)==0){
	      //;
	      sum1=0; 
	      sum2=0;
	   }
		if(i>=N){
		   cndleInx=i-N;
		   //Print(i);
			switch(Price_Type)
			{
				case PRICE_CLOSE: 	sum1 += Close[cndleInx] * Volume[cndleInx]; break;
				case PRICE_OPEN: 		sum1 += Open[cndleInx] * Volume[cndleInx]; break;
				case PRICE_HIGH: 		sum1 += High[cndleInx] * Volume[cndleInx]; break;
				case PRICE_LOW: 		sum1 += Low[cndleInx] * Volume[cndleInx]; break;
				case PRICE_MEDIAN: 	sum1 += (High[cndleInx] + Low[cndleInx]) / 2 * Volume[cndleInx]; break;
				case PRICE_TYPICAL:  sum1 += (High[cndleInx] + Low[cndleInx] + Close[cndleInx]) / 3 * Volume[cndleInx]; break;
				case PRICE_WEIGHTED: sum1 += (High[cndleInx] + Low[cndleInx] + Close[cndleInx] + Close[cndleInx]) / 4 * Volume[cndleInx]; break;
			} 
			sum2 += (double)Volume[cndleInx];
		}

		if (sum2 != 0) ExtMapBuffer1[cndleInx] = sum1/sum2;
		else ExtMapBuffer1[cndleInx] = EMPTY_VALUE;	  
		
	   //Print(cndleInx);
	  
		if (ExtMapBuffer1[i] != EMPTY_VALUE)// && i<N)
		{
			ExtStdDevBuffer[i] = StdDev_Func(i, ExtMapBuffer1, N);
			if (DeviationBand1 > 0)
			{
				UpperDev1[i] = ExtMapBuffer1[i] + DeviationBand1 * ExtStdDevBuffer[i];
				LowerDev1[i] = ExtMapBuffer1[i] - DeviationBand1 * ExtStdDevBuffer[i]; 
			}  
			if (DeviationBand2 > 0)
			{
				UpperDev2[i] = ExtMapBuffer1[i] + DeviationBand2 * ExtStdDevBuffer[i];
				LowerDev2[i] = ExtMapBuffer1[i] - DeviationBand2 * ExtStdDevBuffer[i]; 
			} 
			if (DeviationBand3 > 0)
			{            
				UpperDev3[i] = ExtMapBuffer1[i] + DeviationBand3 * ExtStdDevBuffer[i];
				LowerDev3[i] = ExtMapBuffer1[i] - DeviationBand3 * ExtStdDevBuffer[i];            
			} 
		} 
		//BarOpen[i]=Open[i];
		//BarClose[i]=Close[i];
		
	}
	
	return(0);
}
double barCalc(double sum1, double sum2){
   return sum1/sum2;
}
// Calculates standard deviation for price and its average.
double StdDev_Func(const int position, const double &MAprice[], int period)
{
	double StdDev_dTmp = 0, price = 0;
	for (int i = 0; i < period; i++)
	{
		switch(Price_Type)
		{
			case PRICE_CLOSE: 	price = Close[position + i]; break;
			case PRICE_OPEN: 		price = Open[position + i]; break;
			case PRICE_HIGH: 		price = High[position + i]; break;
			case PRICE_LOW: 		price = Low[position + i]; break;
			case PRICE_MEDIAN: 	price = (High[position + i] + Low[position + i]) / 2; break;
			case PRICE_TYPICAL: 	price = (High[position + i] + Low[position + i] + Close[position + i]) / 3; break;
			case PRICE_WEIGHTED: price = (High[position + i] + Low[position + i] + Close[position + i] + Close[position + i]) / 4; break;
		} 
		StdDev_dTmp += MathPow(price - MAprice[position], 2);
	}       
	StdDev_dTmp = MathSqrt(StdDev_dTmp / period);
	return(StdDev_dTmp);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() 
  {
   IndiGlobalIsLoaded(false);
   CleanChart();
   ObjectDelete("time");
   return(0);
  } 
  