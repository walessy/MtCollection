/*------------------------------------------------------------------+
//| dayHL_Average.mq4 |
//+------------------------------------------------------------------+
/*
Name := dayHL_Average
Author := KCBT
Link := http://www.kcbt.ru/forum/index.php?
*/
//edited by nickw
#import "user32.dll"
   int FindWindowA(string lpClassName, string lpWindowName);
   int GetAncestor(int hWnd, int gaFlags);
   bool FlashWindowEx(int hwnd, int dwFlags, int uCount, int dwTimeout);
#import


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color3 Blue
//---- input parameters5
extern int show_comment=0; // comments on the chart (0 - no, 1 - yes)
extern int how_long=1000; // bars to be counted (-1 - all the bars)
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];


#define GA_ROOT 2
#define FLASHW_STOP        0
#define FLASHW_CAPTION     1
#define FLASHW_TRAY        2
#define FLASHW_ALL         (FLASHW_CAPTION | FLASHW_TRAY)
#define FLASHW_TIMER       4
#define FLASHW_TIMERNOFG   12

struct FLASHWINFO
{
   int  cbSize;
   int  hwnd;
   int  dwFlags;
   int  uCount;
   int  dwTimeout;
};
 

// Function to flash the chart window title bar
void FlashChartTitleBar()
{
   // Get the handle to the chart window
   string chartTitle = "MetaTrader";  // Replace with actual chart window title if necessary
   
   // Get handle to the MetaTrader 4 window (or specific chart window)
   int hChartWindow = FindWindowA(0, chartTitle);
   
   if(hChartWindow != 0)
   {
      // Get the root window handle
      int rootWindow = GetAncestor(hChartWindow, GA_ROOT);
      
      // Prepare FLASHWINFO structure
      FLASHWINFO fw;
      fw.cbSize = sizeof(fw);
      fw.hwnd = rootWindow;
      fw.dwFlags = FLASHW_ALL;
      fw.uCount = 5;  // Number of flashes
      fw.dwTimeout = 0;  // Default cursor blink rate
      
      // Flash the title bar
      FlashWindowEx(rootWindow, fw.dwFlags, fw.uCount, fw.dwTimeout);
   }
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
SetIndexBuffer(0, ExtMapBuffer1);
SetIndexStyle(0, DRAW_LINE);
SetIndexBuffer(1, ExtMapBuffer2);
SetIndexStyle(1, DRAW_LINE);
SetIndexBuffer(2, ExtMapBuffer3);
SetIndexStyle(2, DRAW_LINE);
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
Comment("");
return(0);
}

int start()
{
int cnt=0; // ñ÷åò÷èê áàðîâ
int begin_bar=0; // áàð, ñ êîòîðîãî íà÷èíàåò ðàáîòó èíäèêàòîð
int prev_day, cur_day; // èäåíòèôèêàòîðû òåêóùåãî è ïðåäûäóùåãî äíÿ
double day_high=0; // äíåâíîé high
double day_low=0; // äíåâíîé low
double yesterday_high=0; // íàèáîëüøàÿ öåíà ïðåäûäóùåãî äíÿ
double yesterday_low=0; // íàèìåíüøàÿ öåíà ïðåäûäóùåãî äíÿ
double yesterday_close=0; // öåíà çàêðûòèÿ ïðåäûäóùåãî äíÿ
double P, S, R;

// ïðàâèëüíûå òàéìôðåìû äëÿ íàøåãî èíäèêàòîðà - âñå, ÷òî ìåíüøå D1
if (Period() >= PERIOD_D1) {
Comment("WARNING: Invalid timeframe! Valid value < D1.");
return(0);
}

// ðåøàåì ñ êàêîãî áàðà ìû íà÷íåì ñ÷èòàòü íàø èíäèêàòîð
if (how_long == -1) {
begin_bar = Bars;
} else {
begin_bar = how_long;
}

// îáõîäèì áàðû ñëåâà íàïðàâî (0-é áàð òîæå èñïîëüçóåì, ò.ê. èç íåãî ìû áåð¸ì òîëüêî high è low)
for (cnt = begin_bar; cnt >= 0; cnt--) {
cur_day = TimeDay(Time[cnt]);
if (prev_day != cur_day) {
yesterday_close = Close[cnt+1];
yesterday_high = day_high;
yesterday_low = day_low;
P = (yesterday_high + yesterday_low ) / 2;
R = yesterday_high;
S = yesterday_low;

// ò.ê. íà÷àëñÿ íîâûé äåíü, òî èíèöèèðóåì ìàêñ. è ìèí. òåêóùåãî (óæå) äíÿ
day_high = High[cnt];
day_low = Low[cnt];

// çàïîìíèì äàííûé äåíü, êàê òåêóùèé
prev_day = cur_day;
}

// ïðîäîëæàåì íàêàïëèâàòü äàííûå
day_high = MathMax(day_high, High[cnt]);
day_low = MathMin(day_low, Low[cnt]);

// ðèñóåì pivot-ëèíèþ ïî çíà÷åíèþ, âû÷èñëåííîìó ïî ïàðàìåòðàì â÷åðàøíåãî äíÿ
//ExtMapBuffer2[cnt] = P;
// ðèñóåì ëèíèè ñîïðîòèâëåíèÿ è ïîääåðæêè óðîâíÿ 1,2 èëè 3
ExtMapBuffer1[cnt] = R; // ñîïðîòèâëåíèå
ExtMapBuffer3[cnt] = S; // ïîääåðæêà
}

if (show_comment == 1) {
P = (yesterday_high + yesterday_low ) / 2;
R = yesterday_high;
S = yesterday_low;

Comment(Symbol()+" Current H=", R, ", L=", S, ", HL/2=", P, ", H-L=", (R-S)/Point );
 FlashChartTitleBar();
}
return(0);
}
//+------------------------------------------------------------------+