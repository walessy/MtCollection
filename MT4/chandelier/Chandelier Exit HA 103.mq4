//------------------------------------------------------------------
#property copyright "Copyright 2022 IonOne"
#property link      "https://forex-station.com"
#property version   "1.03"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrOrange
#property indicator_width3 2
#property indicator_width4 2

#property strict

extern int bars = 10000;
           
extern int             length      = 22;             
extern double          multiplier  = 3.0;            
extern bool            useClose = true;  
        
enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
//extern enPrices        Price           = pr_close;         // Price to use 

extern string s16 = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";//_
extern string s17 = "           Arrows Parameters";//_
extern string s18 = "////////////////////////////////";//_
extern bool arrows = true;//Main Chart Arrows
extern int arrowBuyCode = 233;
extern int arrowSellCode = 234;
extern int arrowBuySize = 2;
extern int arrowSellSize = 2;
extern color arrowColorBuy = clrGreen;
extern color arrowColorSell = clrRed;
extern double ArrowDistanceBuy = 2;
extern double ArrowDistanceSell = 2;
extern int ArrowRef = 1234;
  
extern string s6 = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";//_
extern string s7 = "           Alerts Parameters";//_
extern string s8 = "////////////////////////////////";//_
bool AlertOnClose = true;//Alert On Close Only ?
extern bool AudioAlert = true;
extern string sound = "alert2.wav";
extern bool AlertAlert = true;//Alert
extern bool EmailAlert = false;
extern bool PushAlert = false;

string indicatorFileName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
double longStop_[],longStop[];
double shortStop_[],shortStop[];
int OnInit()
{

  
      SetIndexBuffer(0,up_arr);
      SetIndexStyle(0,DRAW_ARROW,EMPTY,arrowBuySize,arrowColorBuy);
      SetIndexArrow(0,arrowBuyCode);
      SetIndexLabel(0,"UP arrow");
      
      SetIndexBuffer(1,dn_arr);
      SetIndexStyle(1,DRAW_ARROW,EMPTY,arrowSellSize,arrowColorSell);
      SetIndexArrow(1,arrowSellCode);
      SetIndexLabel(1,"DOWN arrow");
      
      
      SetIndexBuffer(2, longStop);
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2); 
      SetIndexBuffer(3, shortStop);
      SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2); 
       
      SetIndexBuffer(4, longStop_);
      SetIndexStyle(4,DRAW_NONE); 
      SetIndexBuffer(5, shortStop_);
      SetIndexStyle(5,DRAW_NONE); 
      
      
      
   
      
      
      indicatorFileName = WindowExpertName();
   return(0);
}
 double up_arr[];//!
 double dn_arr[];//!


void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
bool nb = false;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int limit;
   int CountedBars=IndicatorCounted();
   if(CountedBars>Bars-1) CountedBars=Bars-1;
   if(CountedBars<0) return(-1);
   if(CountedBars>0) CountedBars--;
   if(CountedBars<100) CountedBars = 100;
   limit=Bars-1-CountedBars;
   
   if (limit > bars)
   {
      limit = bars;
   }
   for(int i=limit; i>=AlertOnClose; i--) 
   {
        if (tim != iTime(NULL,0,1))
        {
            tim = iTime(NULL,0,1);
            nb = true;
            
            //up_arr[i] = 0;
            //dn_arr[i] = 0;
        }
               /*
         length = 1
         mult = 1.4
         showLabels = true
         useClose =false
         highlightState = true
         
         atr = mult * atr(length)*/
         double atr = multiplier * iATR(NULL,0,length,i);
         
         /*
         
         longStop = (useClose ? highest(close, length) : highest(length)) - atr
         longStopPrev = nz(longStop[1], longStop) 
         longStop := close[1] > longStopPrev ? max(longStop, longStopPrev) : longStop
         */
         
            int hh;
            if (useClose)
            {
               double max = 0;
               for (int j = 0; j < length; j++)
               {
                  double m = getPrice(pr_haclose,Open,Close,High,Low,i+j,Bars);
                  if (m > max)
                  {
                     max = m;
                     hh = i+j;
                  }
               }
            }
            else
            {
               double max = 0;
               for (int j = 0; j < length; j++)
               {
                  double m = getPrice(pr_hahigh,Open,Close,High,Low,i+j,Bars);
                  if (m > max)
                  {
                     max = m;
                     hh = i+j;
                  }
               }
            }
            
            if (useClose)
            {
               longStop_[i] = getPrice(pr_haclose,Open,Close,High,Low,hh,Bars) - atr;
            }
            else longStop_[i] = getPrice(pr_hahigh,Open,Close,High,Low,hh,Bars) - atr;
            
            longStop_[i] = getPrice(pr_haclose,Open,Close,High,Low,i+1,Bars) > longStop_[i+1] ? MathMax(longStop_[i], longStop_[i+1]) : longStop_[i];
            
            
         
         /*
         shortStop = (useClose ? lowest(close, length) : lowest(length)) + atr
         shortStopPrev = nz(shortStop[1], shortStop)
         shortStop := close[1] < shortStopPrev ? min(shortStop, shortStopPrev) : shortStop
         */
            int ll;
            if (useClose)
            {
               double min = EMPTY_VALUE;
               for (int j = 0; j < length; j++)
               {
                  double m = getPrice(pr_haclose,Open,Close,High,Low,i+j,Bars);
                  if (m < min)
                  {
                     min = m;
                     ll = i+j;
                  }
               }
            }
            else
            {
               double min = EMPTY_VALUE;
               for (int j = 0; j < length; j++)
               {
                  double m = getPrice(pr_halow,Open,Close,High,Low,i+j,Bars);
                  if (m < min)
                  {
                     min = m;
                     ll = i+j;
                  }
               }
            }
            
            if (useClose)
            {
               shortStop_[i] = getPrice(pr_haclose,Open,Close,High,Low,ll,Bars) + atr;
            }
            else shortStop_[i] = getPrice(pr_halow,Open,Close,High,Low,ll,Bars) + atr;
         
            shortStop_[i] = getPrice(pr_haclose,Open,Close,High,Low,i+1,Bars) < shortStop_[i+1] ? MathMin(shortStop_[i], shortStop_[i+1]) : shortStop_[i];
        
         
         
         static int prevdir ;
         
         /*
         var int dir = 1
         dir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : dir
         */
         static int dir = 1;
         dir = (getPrice(pr_haclose,Open,Close,High,Low,i,Bars) > shortStop_[i+1]) ? 1 : (getPrice(pr_haclose,Open,Close,High,Low,i,Bars) < longStop_[i+1] ? -1 : dir);
                     
            
         if (dir == 1)
         {
            longStop[i] = longStop_[i];
            shortStop[i] = EMPTY_VALUE;
            if (prevdir == -1)
            {
               longStop[i+1] = shortStop[i+1];
               up_arr[i] = iLow(NULL,0,i) - iATR(NULL,0,20,i)*ArrowDistanceBuy;         
            }
               
         }
         else if (dir == -1)
         {
            shortStop[i] = shortStop_[i];
            longStop[i] = EMPTY_VALUE;
            if (prevdir == 1)
            {
               shortStop[i+1] = longStop[i+1];
               dn_arr[i] = iHigh(NULL,0,i) + iATR(NULL,0,20,i)*(ArrowDistanceSell+1);           
            } 
         }   
         
         if (i == AlertOnClose && up_arr[i+AlertOnClose] > 0 && up_arr[i+AlertOnClose] < EMPTY_VALUE)
             AlertBuy();
         if (i == AlertOnClose && dn_arr[i+AlertOnClose] > 0 && dn_arr[i+AlertOnClose] < EMPTY_VALUE)
             AlertSell();         
            
               
         prevdir = dir;
         /*
         var color longColor = color.green
         var color shortColor = color.red
         
         longStopPlot = plot(dir == 1 ? longStop : na, title="Long Stop", style=plot.style_linebr, linewidth=2, color=longColor)
         buySignal = dir == 1 and dir[1] == -1
         plotshape(buySignal ? longStop : na, title="Long Stop Start", location=location.absolute, style=shape.circle, size=size.tiny, color=longColor, transp=0)
         plotshape(buySignal and showLabels ? longStop : na, title="Buy Label", text="Buy", location=location.absolute, style=shape.labelup, size=size.tiny, color=longColor, textcolor=color.white, transp=0)
         */
            }
   return(rates_total);
   }               
       
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//


void AlertBuy()
{
   if (nb)
   {  
      string text = "";
      
      text = "Chandelier Exit : Open BUY order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";
          
      SetAlert(text);
      nb = false;
   }
}  
void AlertSell()
{
   if (nb)
   {  
      string text = "";
      
      text = "Chandelier Exit : Open SELL order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";
          
      SetAlert(text);
      nb = false;

   }
} 

void SetAlert(string s)
{     
   if (AudioAlert)
   {
      PlaySound(sound);
   }
   if (AlertAlert)
   {
      Alert(s);
   }
   if (EmailAlert)
   {
       SendMail(s, "Alert from indicator : ");
   }
   if (PushAlert)
   {
       SendNotification(s);
   }
   
}     
datetime tim;

int TFNumber(int tf)
{
   switch (tf)
   {
      case PERIOD_M1 : return 0; break;
      case PERIOD_M5 : return 1; break;
      case PERIOD_M15 : return 2; break;
      case PERIOD_M30 : return 3; break;
      case PERIOD_H1 : return 4; break;
      case PERIOD_H4 : return 5; break;
      case PERIOD_D1 : return 6; break;
      case PERIOD_W1 : return 7; break;
      case PERIOD_MN1 : return 8; break;
   }
   return -1;
}
string GetNameTF(int ctTF)
{
   switch (ctTF)
   {
      case 0 : return "M1"; break;
      case 1 : return "M5"; break;
      case 2 : return "M15"; break;
      case 3 : return "M30"; break;
      case 4 : return "H1"; break;
      case 5 : return "H4"; break;
      case 6 : return "D1"; break;
      case 7 : return "W1"; break;
      case 8 : return "MN1"; break;
   }
   
   return "";
}  
  
  
#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
return(0);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
 
//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}


