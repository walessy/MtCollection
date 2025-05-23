// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Synchronise timeframes, autoscroll, position and chart type with active chart's timeframe
// timginter @ ForexFactory
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#property description "Synchronise timeframe, autoscroll, position and chart type with those of the active chart (chart window with focus)"
#property indicator_chart_window

extern bool SyncChartType = true;
extern bool SyncChartZoom = true;
extern bool SyncChartMove = true;
extern string info0 = "------- ------- -------";
extern bool UpdateOnlyOnTick = false;
extern string GlobalVariablePrefix = "chartSync";
extern int TimerMsNotMoving = 250;
extern int TimerMsMoving = 50;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

string globalVarPeriod = GlobalVariablePrefix + "_Period";
string globalVarType = GlobalVariablePrefix + "_Type";
string globalVarZoom = GlobalVariablePrefix + "_Zoom";
string globalVarMove = GlobalVariablePrefix + "_Move";
string globalVarFVB = GlobalVariablePrefix + "_FVB";

void init() 
{
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
       !GlobalVariableCheck(globalVarFVB)
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
      }
      
      // return to avoid getting values of non-existing global variables
      return;
   }
 
   // timeframe doesn't match the global variable
   int syncPeriod = GlobalVariableGet(globalVarPeriod);
   if (ChartPeriod(0) != syncPeriod)
   {
      // save global variable if has focus
      // apply from global variable if doesn't have focus
      if (hasFocus) GlobalVariableSet(globalVarPeriod, ChartPeriod(0));
      else ChartSetSymbolPeriod(0, NULL, syncPeriod);
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