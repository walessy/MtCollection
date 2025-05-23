//+------------------------------------------------------------------+
//|                                               ModChartWindow.mq4 |
//|                                                 Copyright © 2011 |
//|                               http://www.forexfactory.com/xaphod |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Xaphod"
#property link      "http://www.forexfactory.com/xaphod"
#property indicator_chart_window

#import "user32.dll"
  int SetWindowLongA(int hWnd,int nIndex, int dwNewLong);
  int GetWindowLongA(int hWnd,int nIndex);
  int SetWindowPos(int hWnd, int hWndInsertAfter,int X, int Y, int cx, int cy, int uFlags);
  int GetParent(int hWnd);
  int PostMessageA(int hWnd,int Msg,int wParam,int lParam);
  int RegisterWindowMessageA(string MessageName);
#import

#define GWL_STYLE         -16 
#define WS_CAPTION        0x00C00000 
#define WS_BORDER         0x00800000
#define WS_SIZEBOX        0x00040000
#define WS_DLGFRAME       0x00400000
#define SWP_NOSIZE        0x0001
#define SWP_NOMOVE        0x0002
#define SWP_NOZORDER      0x0004
#define SWP_NOACTIVATE    0x0010
#define SWP_FRAMECHANGED  0x0020

// Parameters
extern bool HideCaption=True;
extern bool HideBorder=False;

// Global vars
int iChartParent;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  iChartParent=0;
  PostTick();
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int iNewStyle;
  
  if (iChartParent==0) {
    iChartParent=GetParent(WindowHandle(Symbol(),0));
    
    if (HideCaption==True && HideBorder==True)
      iNewStyle = GetWindowLongA(iChartParent, GWL_STYLE) & (~(WS_BORDER | WS_DLGFRAME | WS_SIZEBOX));    
    else if (HideCaption==True && HideBorder==False)
      iNewStyle = GetWindowLongA(iChartParent, GWL_STYLE) | WS_SIZEBOX & (~WS_CAPTION); 
    else if (HideCaption==False && HideBorder==True)
      iNewStyle = GetWindowLongA(iChartParent, GWL_STYLE) & (~WS_SIZEBOX);    
    else 
      iNewStyle = GetWindowLongA(iChartParent, GWL_STYLE) | WS_CAPTION; 
    
    if (iChartParent>0 && iNewStyle>0) {
      SetWindowLongA(iChartParent, GWL_STYLE, iNewStyle);
      SetWindowPos(iChartParent,0, 0, 0, 0, 0, SWP_NOZORDER | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE| SWP_FRAMECHANGED);
    }
  }
  return(0);
  }
//+------------------------------------------------------------------+

//-----------------------------------------------------------------------------
// function: PostTick()
// Description: Post a tick to metatrader
//-----------------------------------------------------------------------------
void PostTick() {
  int hWnd = WindowHandle(Symbol(), Period());
  int iMsg = RegisterWindowMessageA("MetaTrader4_Internal_Message");
  if (hWnd!=0)
    PostMessageA(hWnd, iMsg, 2, 1);
 // return(0);
}