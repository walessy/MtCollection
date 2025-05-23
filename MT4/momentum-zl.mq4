//+------------------------------------------------------------------+
//|                                                     Momentum.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http: //www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property indicator_level1 0.0
#property indicator_levelcolor Red
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID

//---- input parameters
extern int MomPeriod = 10;

//---- buffers
double MomBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
    string short_name;
//---- indicator line
    SetIndexStyle( 0, DRAW_LINE );
    SetIndexBuffer( 0, MomBuffer );
//---- name for DataWindow and indicator subwindow label
    short_name = "Momentum-ZL(" + MomPeriod + ")";
    IndicatorShortName( short_name );
    SetIndexLabel( 0, short_name );
//----
    SetIndexDrawBegin( 0, MomPeriod );
//----
    return( 0 );
}

//+------------------------------------------------------------------+
//| Momentum                                                         |
//+------------------------------------------------------------------+
int start() {
    int i, counted_bars = IndicatorCounted();

//----
    if ( Bars <= MomPeriod ) {
        return( 0 );
    }

//---- initial zero
    if ( counted_bars < 1 ) {
        for ( i = 1; i <= MomPeriod; i++ ) {
            MomBuffer[Bars - i] = 0.0;
        }
    }
//----
    i = Bars - MomPeriod - 1;

    if ( counted_bars >= MomPeriod ) {
        i = Bars - counted_bars - 1;
    }

    while ( i >= 0 ) {
        MomBuffer[i] = iMomentum( NULL, 0, MomPeriod, PRICE_CLOSE, i ) - 100.0;
        i--;
    }
    return( 0 );
}

//+------------------------------------------------------------------+