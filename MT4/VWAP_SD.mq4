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
#property indicator_buffers 12
#property indicator_plots 7
#property indicator_color1 clrWhite
#property indicator_color2 clrRed
#property indicator_color3 clrRed
#property indicator_color4 clrGreen
#property indicator_color5 clrGreen
#property indicator_color6 clrSkyBlue
#property indicator_color7 clrSkyBlue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_style1 0
#property indicator_style2 2
#property indicator_style3 2
#property indicator_style4 2
#property indicator_style5 2
#property indicator_style6 2
#property indicator_style7 2


input int N = 20; // Period of Volume Weight Average Price
input int Shift = 0;
input ENUM_APPLIED_PRICE Price_Type = PRICE_CLOSE; // Price Type
input double DeviationBand1 = 1; // Number of StdDevs for the 1st band
input double DeviationBand2 = 1.5; // Number of StdDevs for the 2nd band
input double DeviationBand3 = 2; // Number of StdDevs for the 3rd band
input int lastSDCandles=0;
// Indicator buffers
double ExtMapBuffer1[], UpperDev1[], LowerDev1[], UpperDev2[], LowerDev2[], UpperDev3[], LowerDev3[], ExtStdDevBuffer[];
double P1SD, P15SD,M1SD, M15SD;
string sIndiName=WindowExpertName();

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
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

   //SetIndexBuffer(0 , P1SD);
   //SetIndexBuffer(1 , P15SD);
   //SetIndexBuffer(3 , M1SD);
   //SetIndexBuffer(11 , M15SD);

   //In the chart window, histograms are drawn via pairs of buffers. If the first is higher than the second, it uses the first's color.
   //In separate window, histograms are drawn from the buffer value to zero. They are drawn from the first to the last. Of you want one to go the back, it must be the first buffer.
   
   //SetIndexStyle(0,DRAW_HISTOGRAM);
   //SetIndexStyle(1,DRAW_HISTOGRAM);
   //SetIndexStyle(2,DRAW_HISTOGRAM);  
   //SetIndexStyle(6,DRAW_HISTOGRAM);

   
	IndicatorShortName("VWAP Bands");
	
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int bar = Bars - IndicatorCounted() + N;
   if (bar >= Bars - N) bar = Bars - N - 1;

	for (int i = 0; i <= bar; i++)
	{
		double sum1 = 0, sum2 = 0;
		for (int ntmp = 0; ntmp <= N; ntmp++)
		{
		
		   
			switch(Price_Type)
			{
				case PRICE_CLOSE: 	sum1 += Close[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_OPEN: 		sum1 += Open[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_HIGH: 		sum1 += High[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_LOW: 		sum1 += Low[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_MEDIAN: 	sum1 += (High[i + ntmp] + Low[i + ntmp]) / 2 * Volume[i + ntmp]; break;
				case PRICE_TYPICAL:  sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp]) / 3 * Volume[i + ntmp]; break;
				case PRICE_WEIGHTED: sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp] + Close[i + ntmp]) / 4 * Volume[i + ntmp]; break;
			} 
			sum2 += (double)Volume[i + ntmp];
		}
		
		if (sum2 != 0) ExtMapBuffer1[i] = sum1 / sum2;
		else ExtMapBuffer1[i] = EMPTY_VALUE;
	   
	   
	
		if (ExtMapBuffer1[i] != EMPTY_VALUE && ((i<=lastSDCandles&&lastSDCandles!=0)||lastSDCandles==0))
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
	}
	return(0);
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
   
   ObjectDelete("time");
   return(0);
  } 
  