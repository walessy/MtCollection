//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_width5  3
#property indicator_width6  3
#property strict

//
//
//
//
//

#define _disBar 1
#define _disLin 2
enum enDisplayType
{
   dis_01=_disLin,                // Display chandelier stops line
   dis_02=_disBar,                // Display chandelier stops bars
   dis_04=_disLin+_disBar,        // Display chandelier stops line and bars
   dis_07=_disLin+_disBar,        // Display all
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;  // Time frame
input int              AtrPeriod       = 22;              // Atr period
input double           AtrMultiplier   = 3.0;             // Atr multiplier
input int              LookBackPeriod  = 22;              // Look-back period
input bool             useClose        = false;           // Use close price calculations
input bool             alertsOn        = false;           // Turn alerts on/off?
input bool             alertsOnCurrent = false;           // Alerts on open bar on/off?
input bool             alertsMessage   = true;            // Alerts message on/off?
input bool             alertsSound     = false;           // Alerts sound on/off?
input bool             alertsNotify    = false;           // Alerts phone notification on/off?
input bool             alertsEmail     = false;           // Alerts email on/off?
input string           soundFile       = "alert2.wav";    // Sound file
input enDisplayType    DisplayWhat     = _disLin+_disBar; // Display type
input color            ColorUp         = clrLimeGreen;    // Up color
input color            ColorDn         = clrOrangeRed;    // Down color
input color            ColorNe         = clrDarkGray;     // Neutral color
input bool             Interpolate     = true;            // Interpolate on/off?
//
//
//
//
//

double upb[],dnb[],upa[],dna[],histou[],histod[],smin[],smax[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AtrPeriod,AtrMultiplier,LookBackPeriod,useClose,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,DisplayWhat,ColorUp,ColorDn,ColorNe,_buff,_y)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   int chup = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorUp;
   int chdn = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorDn;
   int clup = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorUp;
   int cldn = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorDn;
   int arst = ((DisplayWhat&_disLin)==0) ? DRAW_LINE : DRAW_ARROW;
   IndicatorBuffers(10);
   SetIndexBuffer(0, histou); SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,chup);
   SetIndexBuffer(1, histod); SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,EMPTY,chdn);
   SetIndexBuffer(2, upb);    SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,clup);
   SetIndexBuffer(3, dnb);    SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,cldn);
   SetIndexBuffer(4, upa);    SetIndexStyle(4,arst,EMPTY,EMPTY,clup); SetIndexArrow(4,159);
   SetIndexBuffer(5, dna);    SetIndexStyle(5,arst,EMPTY,EMPTY,cldn); SetIndexArrow(5,159);
   SetIndexBuffer(6, smax);
   SetIndexBuffer(7, smin);
   SetIndexBuffer(8, trend);
   SetIndexBuffer(9, count);
         
      
      //
      //
      //
      //
      //
     
        indicatorFileName = WindowExpertName();
        TimeFrame         = fmax(TimeFrame,_Period);  
      IndicatorShortName(timeFrameToString(TimeFrame)+" Chandelier stops");
return(INIT_SUCCEEDED);
}  
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{

   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit=fmin(rates_total-counted_bars,rates_total-1); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(9,0)*TimeFrame/_Period));
               for (int i=limit;i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,btime[i]);
                     smax[i]  = _mtfCall(6,y);
                     smin[i]  = _mtfCall(7,y);
                     trend[i] = _mtfCall(8,y);
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,btime[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<rates_total && btime[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                        {
                           _interpolate(smax);
                           _interpolate(smin);
                        }                  
               }
               for (int i=limit;i>=0; i--)
               {
                   upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
                   if (trend[i] ==  1) { upb[i] = smin[i]; histou[i] = high[i]; histod[i] = low[i]; }
                   if (trend[i] == -1) { dnb[i] = smax[i]; histod[i] = high[i]; histou[i] = low[i]; }
                   upa[i] = (i<rates_total-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
                   dna[i] = (i<rates_total-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
               }         
   return(rates_total);
   }               

   //
   //
   //

   for(int i=limit; i>=0; i--)
   {
      double atr = 0; for(int k=1; k<=AtrPeriod && (i+k+1)<rates_total; k++) atr += fmax(high[i+k],close[fmax(i+k+1,0)])-fmin(low[i+k],close[fmax(i+k+1,0)]); atr/=(double)AtrPeriod;
      double max = (!useClose) ? high[ArrayMaximum(high,LookBackPeriod,i)] : close[ArrayMaximum(close,LookBackPeriod,i)];
      double min = (!useClose) ? low [ArrayMinimum(low ,LookBackPeriod,i)] : close[ArrayMinimum(close,LookBackPeriod,i)];
      smax[i]  = min+AtrMultiplier*atr;
      smin[i]  = max-AtrMultiplier*atr;
      trend[i] = (i<rates_total-1) ? (close[i]>smax[i+1]) ? 1 : (close[i]<smin[i+1]) ? -1 : trend[i+1] : 0;
              if (i<rates_total-1)
              {
                if (trend[i]==-1 && smax[i]>smax[i+1]) smax[i] = smax[i+1];
                if (trend[i]== 1 && smin[i]<smin[i+1]) smin[i] = smin[i+1];
              }                  
      upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
      if (trend[i] ==  1) { upb[i] = smin[i]; histou[i] = high[i]; histod[i] = low[i]; }
      if (trend[i] == -1) { dnb[i] = smax[i]; histod[i] = high[i]; histou[i] = low[i]; }
      upa[i] = (i<rates_total-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
      dna[i] = (i<rates_total-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
   }
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(" up");
         if (trend[whichBar] ==-1) doAlert(" down");       
      }         
    }              
return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Chandelier stops state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" BB stops ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
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

