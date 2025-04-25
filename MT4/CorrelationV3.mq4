//+------------------------------------------------------------------+
//|                                                  SimplePanel.mq4 |
//|                   Copyright 2009-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2009-2014, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

//#property indicator_separate_window
#property indicator_chart_window
//#property indicator_buffers             0

#resource "\\include\\Controls\\res\\CheckBoxOn.bmp "
#resource "\\include\\Controls\\res\\CheckBoxOff.bmp "
#include <Controls\ComboBox.mqh>

//References
//SQLite       https://www.mql5.com/en/articles/862
//Some Events  https://www.mql5.com/en/forum/162993
//             https://www.mql5.com/en/forum/298838

//------------------------------------------------------------------------------------------------------------------------------------
#include <Controls\Dialog.mqh>
#include <Controls\BmpButton.mqh>
//------------------------------------------------------------------------------------------------------------------------------------
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_4editlabel                   (30)

#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)

#define CONTROLS_GAP_X                      (10)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (10)      // gap by Y coordinate

#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate

#define EDIT_HEIGHT                         (30)      // size by Y coordinate

//Note
//When adding objects to Panel do:
//1. Create Private var in class dialogue
//2. Add func signiture to create the object in class dialogue
//3. Do same with events
//------------------------------------------------------------------------------------------------------------------------------------
class CPanelDialog : public CAppDialog
{
      private:
         int XCummulative;
         int YCummulative;
         CEdit m_edit;  // the display field object
         CBmpButton m_bmpButton;
         CComboBox m_combpBox1;
         
      public:
         CPanelDialog(void);
         ~CPanelDialog(void);

         virtual bool Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
         virtual bool OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

         
      protected:
         //--- create dependent controls
         bool CreateEdit(void);
         bool CreateGrpNmAdd(void);
         bool CreateCombo1(void);
         //--- internal event handlers
         virtual bool OnResize(void);
         bool OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam);
         bool OnClick_bmpButton1(void);
         void OnChange_combpBox1(void);   
};

EVENT_MAP_BEGIN(CPanelDialog)
ON_EVENT(ON_CLICK,m_bmpButton,OnClick_bmpButton1)
ON_EVENT(ON_CHANGE, m_combpBox1, OnChange_combpBox1)
ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppDialog)

CPanelDialog::CPanelDialog(void)
{
}

CPanelDialog::~CPanelDialog(void)
{
}

bool CPanelDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
{
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
      
  //--- create dependent controls
  //if(!CreateEdit())
  //   return(false);  

  //Commented out:  Good examlpe of how to reuse MT4's library
  //if(!CreateGrpNmAdd())
  //    return(false);
 
   if(!CreateCombo1())
   {
      return false;
   }
   //--- succeed
   return(true);
}

bool CPanelDialog::CreateEdit(void)
  {
  
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+YCummulative;
   int x2=ClientAreaWidth()-(INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X);
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit.Create(m_chart_id,m_name+"Edit",m_subwin,x1,y1,x2,y2))
      return(false);
   //if(!m_edit.ReadOnly(true))
      //return(false);
   if(!Add(m_edit))
      return(false);
   m_edit.Alignment(WND_ALIGN_WIDTH,INDENT_LEFT,0,INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X,0);
//--- succeed
   m_edit.Text("Enter a new group name here.");
//--- succeed
   return(true);
   
}

bool CPanelDialog::CreateGrpNmAdd(void){

   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+CONTROLS_GAP_X+YCummulative;
   int x2=ClientAreaWidth()-(INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X); 
   int y2=y1+EDIT_HEIGHT;
   if(!m_bmpButton.Create(m_chart_id,m_name+"AddGrpNm",m_subwin,x1,y1,x2,y2)){
      return false;
   }
   if(!Add(m_bmpButton))
   {
      return false;
   }
   if(!m_bmpButton.BmpOnName("\\include\\controls\\res\\CheckBoxOn"))
   {
      return false;
   };
   if(!m_bmpButton.BmpOffName("\\include\\controls\\res\\CheckBoxOff"))
   {
      return false;
   }
   if(!m_bmpButton.Activate())
   {
      return false;
   }
   if(!m_bmpButton.Enable())
   {
      return false;
   }
   return true;
}

bool CPanelDialog::CreateCombo1(void){

   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+CONTROLS_GAP_X;
   int x2=ClientAreaWidth()-(INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X); 
   int y2=y1+EDIT_HEIGHT;
   //m_combpBox1.Hide();
   if(!m_combpBox1.Create(m_chart_id,m_name+"AddGrpNm",m_subwin,x1,y1,x2,y2)){
      return false;
   }
   return true;
}

void CPanelDialog::OnChange_combpBox1(void){
   Print(__FUNCTION__);
}

//Events-----------------------------------------------------------------------------------------------------
bool CPanelDialog::OnResize(void)
{
   if(!CAppDialog::OnResize()) return(false);
 
   return(true);
}

bool CPanelDialog::OnDefault(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   //--- restore buttons' states after mouse move'n'click
   if(id==CHARTEVENT_CLICK){
      Print(__FUNCTION__+":Id"+(string)id+":lparam="+(string)lparam+":dparam="+(string)dparam+":sparam="+(string)sparam);
      
      //--- coordinates
      //int x=INDENT_LEFT*2;
      //int y=INDENT_TOP+CONTROLS_GAP_X+YCummulative;
      //int x2=ClientAreaWidth()-(INDENT_RIGHT+BUTTON_WIDTH+CONTROLS_GAP_X); 
      //int y2=y+EDIT_HEIGHT;
      //m_combpBox1.Show();
      //m_combpBox1.Move(x,y);
      //m_combpBox1.Width(x2);
      
      //--- let's handle event by parent
      return(false);
   }
   else{  
      //--- let's handle event by parent
      return(false);
   }

}

bool CPanelDialog::OnClick_bmpButton1(){
   m_edit.Text("Here");
   return true;
}

//+-
//------------------------------------------------------------------------------------------------------------------------------------
CPanelDialog ExtDialog;

//------------------------------------------------------------------------------------------------------------------------------------
int OnInit(void)
  {
  
   long height=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   long width=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   
   if(!ExtDialog.Create(0,"Correlation V3",0,0,0,(int)width,(int)height))

     return(INIT_FAILED);
   
//--- run application
   if(!ExtDialog.Run())
     return(INIT_FAILED);
   
//--- ok
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------------------------------------------------------------------------
void OnDeinit(const int reason)
  {
//--- destroy application dialog
   ExtDialog.Destroy(reason);
  }
//------------------------------------------------------------------------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
// do nothing
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//------------------------------------------------------------------------------------------------------------------------------------
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
