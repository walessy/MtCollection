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
//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
double ExtBufferVWAP[];
double __ohlcvTotal,
   __volumeTotal;
datetime __sessionStartTime;

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
   SetIndexBuffer( 0, ExtBufferVWAP );

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
