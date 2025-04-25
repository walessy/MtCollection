// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Synchronise timeframes, autoscroll, position and chart type with active chart's timeframe
// timginter @ ForexFactory
//
// version 2.1
// ber_tdf @ ForexFactory
//
// https://www.forexfactory.com/thread/895344-synchronise-timeframes-on-multiple-charts
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#property description "Synchronise timeframe, autoscroll, position and chart type with those of the active chart (chart window with focus)"
#property indicator_chart_window

extern bool         SyncChartMove = true;
extern bool         SyncChartType = false;
extern bool         SyncChartZoom = false;
extern bool       SyncChartSymbol = true;
extern bool       SyncChartPeriod = true;
extern string               info0 = "------- ------- -------";
extern bool       UpdateOnlyOnTick = false;
extern string GlobalVariablePrefix = "chartSync";
extern int        TimerMsNotMoving = 250;
extern int           TimerMsMoving = 50;

string availableSymbols[70];

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

string globalVarPeriod = GlobalVariablePrefix + "_Period";
string globalVarType   = GlobalVariablePrefix + "_Type";
string globalVarZoom   = GlobalVariablePrefix + "_Zoom";
string globalVarMove   = GlobalVariablePrefix + "_Move";
string globalVarFVB    = GlobalVariablePrefix + "_FVB";
string globalVarSymbol = GlobalVariablePrefix + "_Symbol";

void init()
{

   getAvailableSymbols();

   // set sync timer
   if (!UpdateOnlyOnTick )
   {
      EventSetMillisecondTimer(TimerMsNotMoving);
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
void CheckTimeFrames()
{
   // check if chart has focus (is top-most)
   bool hasFocus = ChartGetInteger(0, CHART_BRING_TO_TOP, 0) == 1;

   // check if any of the global variables doesn't exist
   if (!GlobalVariableCheck(globalVarPeriod) ||
       !GlobalVariableCheck(globalVarType) ||
       !GlobalVariableCheck(globalVarZoom) ||
       !GlobalVariableCheck(globalVarMove) ||
       !GlobalVariableCheck(globalVarFVB)  ||
       !GlobalVariableCheck(globalVarSymbol)
      )
   {
      // save properties of the chart with focus
      if (hasFocus)
      {
         GlobalVariableSet(globalVarPeriod, ChartPeriod(0));
         GlobalVariableSet(globalVarType, ChartGetInteger(0, CHART_MODE));
         GlobalVariableSet(globalVarZoom, ChartGetInteger(0, CHART_SCALE));
         GlobalVariableSet(globalVarMove, ChartGetInteger(0, CHART_AUTOSCROLL, 0));
         GlobalVariableSet(globalVarFVB, ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
         GlobalVariableSet(globalVarSymbol, GetSymbolIndi(_Symbol));
      }

      // return to avoid getting values of non-existing global variables
      return;
   }

   // type doesn't match global variable
   int syncType = GlobalVariableGet(globalVarType);
   if( SyncChartType && ChartGetInteger(0, CHART_MODE) != syncType)
   {
      // save global variable if has focus
      // apply from global variable if doesn't have focus
      if (hasFocus) GlobalVariableSet(globalVarType, ChartGetInteger(0, CHART_MODE));
      else ChartSetInteger(0, CHART_MODE, syncType);
   }

   // zoom doesn't match the global variable
   int syncZoom = GlobalVariableGet(globalVarZoom);
   if (SyncChartZoom && ChartGetInteger(0, CHART_SCALE) != syncZoom)
   {
      // save global variable if has focus
      // apply from global variable if doesn't have focus
      if (hasFocus) GlobalVariableSet(globalVarZoom, ChartGetInteger(0, CHART_SCALE));
      else ChartSetInteger(0, CHART_SCALE, syncZoom);
   }

   // autoscroll doesn't match global variable
   int syncMove = GlobalVariableGet(globalVarMove);
   if (SyncChartMove && ChartGetInteger(0, CHART_AUTOSCROLL, 0) != syncMove)
   {
      // save global variable if has focus
      // apply from global variable if doesn't have focus
      if (hasFocus) GlobalVariableSet(globalVarMove, ChartGetInteger(0, CHART_AUTOSCROLL, 0));
      else ChartSetInteger(0, CHART_AUTOSCROLL, syncMove);

      // adjust timer delay
      if (!UpdateOnlyOnTick)
      {
         if (syncMove)
         {
            EventSetMillisecondTimer(TimerMsNotMoving);
         }
         else
         {
            EventSetMillisecondTimer(TimerMsMoving);
         }
      }
   }

   // move chart only if autoscroll disabled and if last bar doesn't match the chart with focus
   if (SyncChartMove && ChartGetInteger(0, CHART_AUTOSCROLL, 0) == 0)
   {
      // check if current First Visible Bar matches global variable
      int currentFVBar = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int syncVBar = GlobalVariableGet(globalVarFVB);
      if (currentFVBar != syncVBar)
      {
         // save global variable if has focus
         // move chart by bar diff if doesn't have focus
         if (hasFocus)
         {
            GlobalVariableSet(globalVarFVB, ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR));
         }
         else
         {
            int barDiff = currentFVBar - syncVBar;
            ChartNavigate(0, CHART_CURRENT_POS, barDiff);
         }
      }
   }

   // change symbol or period if autosymbol true or autoperiod true
   int syncSymbol = GlobalVariableGet(globalVarSymbol);
   int syncPeriod = GlobalVariableGet(globalVarPeriod);
   int currentSymbol = GetSymbolIndi(_Symbol);
   int currentPeriod = _Period;
   string nameSymbol = availableSymbols[syncSymbol];
   if ((SyncChartSymbol && currentSymbol != -1 && currentSymbol != syncSymbol) || (SyncChartPeriod && currentPeriod != syncPeriod))
   {
      // save global variable if has focus
      // change chart symbol if doesn't have focus
      if (hasFocus)
      {
         GlobalVariableSet(globalVarSymbol, GetSymbolIndi(_Symbol));
         GlobalVariableSet(globalVarPeriod, ChartPeriod(0));
      }
      else
      {
         int newPeriod = (SyncChartPeriod && currentPeriod != syncPeriod ? syncPeriod : 0);
         if (nameSymbol != "") ChartSetSymbolPeriod(0, availableSymbols[syncSymbol], newPeriod);

      }
   }

}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
void start()
{
   if( UpdateOnlyOnTick )
   {
      CheckTimeFrames();
   }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
void deinit()
{
   // sanity check - kill sync timer
   EventKillTimer();
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
void OnTimer()
{
   CheckTimeFrames();
}

#define EURUSD 0
#define USDCHF 1
#define USDJPY 2
#define GBPUSD 3

#define EURJPY 4
#define GBPJPY 5
#define NZDUSD 6
#define AUDUSD 7
#define USDCAD 8

#define USDCNH 9
#define USDCZK 10
#define USDDKK 11
#define USDHKD 12
#define USDHUF 13
#define USDMXN 14
#define USDNOK 15
#define USDPLN 16
#define USDRUB 17
#define USDSEK 18
#define USDSGD 19
#define USDTRY 20
#define USDZAR 21

#define EURCHF 22
#define EURAUD 23
#define EURGBP 24
#define EURCAD 25
#define EURNZD 26
#define EURCZK 27
#define EURDKK 28
#define EURHKD 29
#define EURHUF 30
#define EURMXN 31
#define EURNOK 32
#define EURPLN 33
#define EURSEK 34
#define EURSGD 35
#define EURTRY 36
#define EURZAR 37

#define GBPCHF 38
#define GBPAUD 39
#define GBPCAD 40
#define GBPNZD 41
#define GBPCZK 42
#define GBPDKK 43
#define GBPHKD 44
#define GBPHUF 45
#define GBPNOK 46
#define GBPPLN 47
#define GBPSEK 48
#define GBPTRY 49
#define GBPZAR 50

#define AUDNZD 51
#define AUDJPY 52
#define AUDCAD 53
#define AUDCHF 54

#define NZDCHF 55
#define NZDCAD 56
#define NZDJPY 57
#define NZDSGD 58

#define CADJPY 59
#define CADCHF 60
#define CHFJPY 61

#define BRENT  62
#define XTIUSD 63

#define BTCUSD 64
#define ETHUSD 65
#define LTCUSD 66

#define XAGUSD 67
#define XAUUSD 68

int GetSymbolIndi(string sSymbol) {

   if (StringFind(sSymbol,"EURUSD") != -1)      return(EURUSD);
   else if (StringFind(sSymbol,"USDCHF") != -1) return(USDCHF);
   else if (StringFind(sSymbol,"USDJPY") != -1) return(USDJPY);
   else if (StringFind(sSymbol,"GBPUSD") != -1) return(GBPUSD);

   else if (StringFind(sSymbol,"EURJPY") != -1) return(EURJPY);
   else if (StringFind(sSymbol,"GBPJPY") != -1) return(GBPJPY);
   else if (StringFind(sSymbol,"NZDUSD") != -1) return(NZDUSD);
   else if (StringFind(sSymbol,"AUDUSD") != -1) return(AUDUSD);
   else if (StringFind(sSymbol,"USDCAD") != -1) return(USDCAD);

   else if (StringFind(sSymbol,"USDCNH") != -1) return(USDCNH);
   else if (StringFind(sSymbol,"USDCZK") != -1) return(USDCZK);
   else if (StringFind(sSymbol,"USDDKK") != -1) return(USDDKK);
   else if (StringFind(sSymbol,"USDHKD") != -1) return(USDHKD);
   else if (StringFind(sSymbol,"USDHUF") != -1) return(USDHUF);
   else if (StringFind(sSymbol,"USDMXN") != -1) return(USDMXN);
   else if (StringFind(sSymbol,"USDNOK") != -1) return(USDNOK);
   else if (StringFind(sSymbol,"USDPLN") != -1) return(USDPLN);
   else if (StringFind(sSymbol,"USDRUB") != -1) return(USDRUB);
   else if (StringFind(sSymbol,"USDSEK") != -1) return(USDSEK);
   else if (StringFind(sSymbol,"USDSGD") != -1) return(USDSGD);
   else if (StringFind(sSymbol,"USDTRY") != -1) return(USDTRY);
   else if (StringFind(sSymbol,"USDZAR") != -1) return(USDZAR);

   else if (StringFind(sSymbol,"EURCHF") != -1) return(EURCHF);
   else if (StringFind(sSymbol,"EURAUD") != -1) return(EURAUD);
   else if (StringFind(sSymbol,"EURGBP") != -1) return(EURGBP);
   else if (StringFind(sSymbol,"EURCAD") != -1) return(EURCAD);
   else if (StringFind(sSymbol,"EURNZD") != -1) return(EURNZD);
   else if (StringFind(sSymbol,"EURCZK") != -1) return(EURCZK);
   else if (StringFind(sSymbol,"EURDKK") != -1) return(EURDKK);
   else if (StringFind(sSymbol,"EURHKD") != -1) return(EURHKD);
   else if (StringFind(sSymbol,"EURHUF") != -1) return(EURHUF);
   else if (StringFind(sSymbol,"EURMXN") != -1) return(EURMXN);
   else if (StringFind(sSymbol,"EURNOK") != -1) return(EURNOK);
   else if (StringFind(sSymbol,"EURPLN") != -1) return(EURPLN);
   else if (StringFind(sSymbol,"EURSEK") != -1) return(EURSEK);
   else if (StringFind(sSymbol,"EURSGD") != -1) return(EURSGD);
   else if (StringFind(sSymbol,"EURTRY") != -1) return(EURTRY);
   else if (StringFind(sSymbol,"EURZAR") != -1) return(EURZAR);

   else if (StringFind(sSymbol,"GBPCHF") != -1) return(GBPCHF);
   else if (StringFind(sSymbol,"GBPAUD") != -1) return(GBPAUD);
   else if (StringFind(sSymbol,"GBPCAD") != -1) return(GBPCAD);
   else if (StringFind(sSymbol,"GBPNZD") != -1) return(GBPNZD);
   else if (StringFind(sSymbol,"GBPCZK") != -1) return(GBPCZK);
   else if (StringFind(sSymbol,"GBPDKK") != -1) return(GBPDKK);
   else if (StringFind(sSymbol,"GBPHKD") != -1) return(GBPHKD);
   else if (StringFind(sSymbol,"GBPHUF") != -1) return(GBPHUF);
   else if (StringFind(sSymbol,"GBPNOK") != -1) return(GBPNOK);
   else if (StringFind(sSymbol,"GBPPLN") != -1) return(GBPPLN);
   else if (StringFind(sSymbol,"GBPSEK") != -1) return(GBPSEK);
   else if (StringFind(sSymbol,"GBPTRY") != -1) return(GBPTRY);
   else if (StringFind(sSymbol,"GBPZAR") != -1) return(GBPZAR);

   else if (StringFind(sSymbol,"AUDNZD") != -1) return(AUDNZD);
   else if (StringFind(sSymbol,"AUDJPY") != -1) return(AUDJPY);
   else if (StringFind(sSymbol,"AUDCAD") != -1) return(AUDCAD);
   else if (StringFind(sSymbol,"AUDCHF") != -1) return(AUDCHF);

   else if (StringFind(sSymbol,"NZDCHF") != -1) return(NZDCHF);
   else if (StringFind(sSymbol,"NZDCAD") != -1) return(NZDCAD);
   else if (StringFind(sSymbol,"NZDJPY") != -1) return(NZDJPY);
   else if (StringFind(sSymbol,"NZDSGD") != -1) return(NZDSGD);

   else if (StringFind(sSymbol,"CADJPY") != -1) return(CADJPY);
   else if (StringFind(sSymbol,"CADCHF") != -1) return(CADCHF);
   else if (StringFind(sSymbol,"CHFJPY") != -1) return(CHFJPY);

   else if (StringFind(sSymbol,"BRENT")  != -1) return(BRENT);
   else if (StringFind(sSymbol,"XTIUSD") != -1) return(XTIUSD);

   else if (StringFind(sSymbol,"BTCUSD") != -1) return(BTCUSD);
   else if (StringFind(sSymbol,"ETHUSD") != -1) return(ETHUSD);
   else if (StringFind(sSymbol,"LTCUSD") != -1) return(LTCUSD);

   else if (StringFind(sSymbol,"XAGUSD") != -1) return(XAGUSD);
   else if (StringFind(sSymbol,"XAUUSD") != -1) return(XAUUSD);

   return (-1);
}

void getAvailableSymbols()
{
   int symbolsCount = SymbolsTotal(false);
   for(int j = 0; j < symbolsCount; j++)
   {
      string sSymbol = SymbolName(j, false);
      int    iSymbol = GetSymbolIndi(sSymbol);
      if (iSymbol != -1) availableSymbols[iSymbol] = sSymbol;
   }
}