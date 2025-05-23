//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//#include <EasyAndFastGUI\Controls\WndEvents.mqh>
#include <ere\Controls\WndEvents.mqh>
//--- Enumeration of the modes of setting a window
enum ENUM_WINDOW_MODE
  {
   LEFT  =0,
   RIGHT =1,
   FULL  =2
  };
//--- External parameters
input ENUM_WINDOW_MODE WindowMode=LEFT;
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
protected:
   //--- Window
   CWindow           m_window;
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/uninitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Creates a trading panel
   bool              CreateTradePanel(void);
   //---
protected:
   bool              CreateWindow(const string text);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
   //--- Deleting an interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      //--- If the mode of the form for the whole width of the chart is selected
      if(WindowMode==FULL)
         m_window.ChangeWindowWidth(m_chart.WidthInPixels()-2);
      //--- If the mode of setting the form on the right is selected
      else if(WindowMode==RIGHT)
         m_window.X(m_chart.WidthInPixels()-(m_window.XSize()+1));
     }
  }
//+------------------------------------------------------------------+
//| Creates a trading panel                                          |
//+------------------------------------------------------------------+
bool CProgram::CreateTradePanel(void)
  {
//--- Creating a panel
   if(!CreateWindow("INDICATOR PANEL"))
      return(false);
//--- Creating controls
// ...
//---
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
//--- Add a window pointer to the window array
   CWndContainer::AddWindow(m_window);
//--- Sizes
   int x_size=(WindowMode!=FULL)? 200 : m_chart.WidthInPixels()-2;
   int y_size=200;
//--- Coordinates
   int x=(WindowMode!=RIGHT)? 1 : m_chart.WidthInPixels()-(x_size+1);
   int y=1;
//--- Properties
   m_window.XSize(x_size);
   m_window.YSize(y_size);
   m_window.RollUpSubwindowMode(false,true);
//--- Creating a form
   if(!m_window.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
