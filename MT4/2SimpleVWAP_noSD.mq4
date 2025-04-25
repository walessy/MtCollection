//+------------------------------------------------------------------+
//|                                                         VWAP.mq4 |
//|                                                          mwfx108 |
//|                                                mwfx108@gmail.com |
//|                       Like my stuff? Made some profits using it? |
//|          Donate ETH @ 0xeDC0D4Dd8abcB106FEdC17Ce07Cc68a6571a038e |
//+------------------------------------------------------------------+
#property copyright "mwfx108"
#property link      "mwfx108@gmail.com"
#property version   "1.00"
#property strict
#property indicator_buffers 1
#property indicator_chart_window
#property indicator_color1 Red



//input ENUM_APPLIED_PRICE Price_Type = PRICE_CLOSE; // Price Type
//input double DeviationBand1 = 1; // Number of StdDevs for the 1st band
//input double DeviationBand2 = 1.5; // Number of StdDevs for the 2nd band
//input double DeviationBand3 = 2; // Number of StdDevs for the 3rd band
//input int lastSDCandles=1;
//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
double ExtBufferVWAP[];
double __ohlcvTotal,
   __volumeTotal;
datetime __sessionStartTime;
double  UpperDev1[], LowerDev1[], UpperDev2[], LowerDev2[], UpperDev3[], LowerDev3[], ExtStdDevBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   
   __volumeTotal = 0;
   __ohlcvTotal = 0;
   __sessionStartTime = 0;
   
   IndicatorShortName( "VWAP" );
   IndicatorDigits( _Digits );
   
   //--- Drawing settings
   SetIndexStyle( 0, DRAW_LINE );
   
   //--- Indicator buffers mapping
   //SetIndexBuffer( 0, ExtBufferVWAP );
   SetIndexBuffer(0 , ExtBufferVWAP);
   SetIndexBuffer(2, UpperDev1);
   SetIndexBuffer(3, LowerDev1);
   SetIndexBuffer(4, UpperDev2);
   SetIndexBuffer(5, LowerDev2);
   SetIndexBuffer(6, UpperDev3);
   SetIndexBuffer(7, LowerDev3);
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   
   // An "Intraday" indicator makes no sense anymore above H1
   if ( Period() >= PERIOD_H4 )
   {
      return ( rates_total - 1 );
   }
   
   int startIndex = MathMax( 0, rates_total - prev_calculated - 1 );
   
   // Only calculate up until the previous bar. We don't want to calculate the current bar.
   if ( startIndex > 0 )
   {
      for ( int i = startIndex; i >= 1; i-- )
      {
         double
            ohlcAvg = ( open[ i ] + high[ i ] + low[ i ] + close[ i ] ) / 4,
            vol = ( double ) tick_volume[ i ];

         // Reset values when session changed
         if ( TimeDay( time[ i ] ) != TimeDay ( __sessionStartTime ) )
         {
            __sessionStartTime = time[ i ];
            __ohlcvTotal = 0;
            __volumeTotal = 0;
         }
            
         __ohlcvTotal += ohlcAvg * vol;
         __volumeTotal += vol;
         
         ExtBufferVWAP[ i ] = NormalizeDouble( __ohlcvTotal / __volumeTotal, _Digits );
      }
   }
   
   return( rates_total - 1 );
}
//+------------------------------------------------------------------+


// Calculates standard deviation for price and its average.
double StdDev_Func(const int position, const double &MAprice[], int period)
{
	double StdDev_dTmp = 0, price = 0;
	for (int i = 0; i < period; i++)
	{

			price = Close[position + i]; break;

		StdDev_dTmp += MathPow(price - MAprice[position], 2);
	}       
	StdDev_dTmp = MathSqrt(StdDev_dTmp / period);
	return(StdDev_dTmp);
}