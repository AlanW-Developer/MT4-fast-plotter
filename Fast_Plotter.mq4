
//+------------------------------------------------------------------+
//|                                                   quick_text.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <KeyboardCodes.mqh>

// User Inputs

input string seperator1 = "--- Miscellaneous Settings ---";
input int font_size = 7;
input color text_color = clrBlack;
input color stop_color = clrRed;
input color price_tag_color = clrBlack;
input color fvg_color = clrNavajoWhite;
input color order_block_color = clrGainsboro;      
input int stop_width = 2;
input int price_tag_width = 1;
input bool current_time_frame_and_lower = True;
input int hours_adjust = 3; // GMT time minus 5 hours will be New York time

input string seperator2 = "--- Number Key Colors ---";
input color clr_1 = clrGreen;
input color clr_2 = clrRed;
input color clr_3 = clrOrange;
input color clr_4 = clrPurple;
input color clr_5 = clrBrown;
input color clr_6 = clrBlue;
input color clr_7 = clrGainsboro;
input color clr_8 = clrPink;
input color clr_9 = C'153,230,153';
input color clr_0 = clrPowderBlue;

input string seperator3= "--- Extend and Reduce ---";
input int amount_to_extend_lines = 3;
input int extend_reduce_speed = 400;

input string seperator4= "--- Time Zone Settings ---";
input int killzone_thickness = 6;
input color asian_range_color = clrDimGray;
input color london_range_color = clrMediumBlue;
input color ny_range_color = clrGreen;
input color eq_range_color = clrBlueViolet;
input color lc_range_color = clrRed;
input color ps_color = clrBlack;

input string seperator5= "--- Asian Session ---";
input color asian_range_top_bottom = clrRed;

input string seperator6= "--- Monthly/Weekly/Daily Opens ---";
input int weeks_to_display = 1;
input int days_to_display = 3;

// Co ordinate Variables
double my_price;
datetime my_datetime;
int selected_shift;
string selected_name;

// OHLC FVG 
double open_price;
double high_price;
double low_price;
double close_price;
double median_price;
double prev_candle_high;
double next_candle_low;
double prev_candle_low;
double next_candle_high;
double trend_date_1;    // Use for horizontal_line() to revert back to trend line
double trend_date_2;    // Use for horizontal_line() to revert back to trend line
color col;              // Use for horizontal_line() to revert back to trend line

//
int default_line_extender = 1000*Period()*amount_to_extend_lines;
datetime t0 = Time[0] + default_line_extender;

//OBJPROP_TIMEFRAME arguments. 

int time_frame_M1 =0x0001;
int time_frame_M5 = 0x0002;
int time_frame_M15 = 0x0004;
int time_frame_M30 = 0x0008;
int time_frame_H1 = 0x0010;
int time_frame_H4 = 0x0020; 
int time_frame_D1 = 0x0040;
int time_frame_W1 = 0x0080;
int time_frame_MN1= 0x0100;
int all_periods = 0x01ff;

int hour_in_secs = 3600;

//Variables for the different time frames to show, the highest timeframe and below
int MN1 = time_frame_MN1| time_frame_W1 | time_frame_D1 | time_frame_H4 | time_frame_H1 | time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int W1 = time_frame_W1 | time_frame_D1 | time_frame_H4 | time_frame_H1 | time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int D1 = time_frame_D1 | time_frame_H4 | time_frame_H1 | time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int H4 = time_frame_H4 | time_frame_H1 | time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int H1 = time_frame_H1 | time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int M30 = time_frame_M30 | time_frame_M15 | time_frame_M5 | time_frame_M1;
int M15 = time_frame_M15 | time_frame_M5 | time_frame_M1;
int M5 = time_frame_M5 | time_frame_M1;
int M1 = time_frame_M1;
//variable to determine which timeframes are shown
int time_frames_to_show;

//period separator variables
bool show_days;
bool show_AR;
int cnt;

// show trade levels
bool hide_active_trades;

// Fib Levels
int fib_type;
bool hide_fib_levels;
double max_price;
double min_price;
double fib_one_percent;
double hundred_level;
double seventy_nine_level;
double seventy_five_level;
double seventy_point_5_level;
double sixty_two_level;
double fifty_level;
double twenty_five_level;
double zero_level;

double hundred_twenty_seven;
double hundred_sixty_eight;
double two_hundred;

double RR1;
double RR2;
double RR3;
double RR4;
double RR5;
double RR6;
double RR7;
double RR8;
double RR9;
double RR10;

datetime fib_time0;
datetime fib_time1;
bool show_fib_levels = false;

// Monthly/Weekly/Daily Opens
bool show_quarterly_open = false;
bool show_monthly_open = false;
bool show_weekly_open = false;
bool show_daily_open = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    // Setting the time_frames_to_show variable depending on current chart time frame
    if(current_time_frame_and_lower){
        int period
         = Period();
        
        if(period == PERIOD_MN1){
            time_frames_to_show = MN1;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_W1){
            time_frames_to_show = W1;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_D1){
            time_frames_to_show = D1;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_H4){
            time_frames_to_show = H4;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_H1){
            time_frames_to_show = H1;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_M30){
            time_frames_to_show = M30;
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_M15){
            time_frames_to_show = M15;
          
            Print("Current Period: "+period);
        }

        else if(period == PERIOD_M5){
            time_frames_to_show = M5;
            Print("Current Period: "+period);
        }
    }
    else
    {
       time_frames_to_show = all_periods;
    } 

    // Period Separator
    show_days = false;
    show_AR = false;
    hide_active_trades = false;
    cnt = Bars;
    fib_type = 0;
    hide_fib_levels = true;
    delete_period_separators();
    show_asian_range();
    kill_zones();
}

void deinit(){
    delete_period_separators();
    delete_asian_range();
    delete_kill_zones();
}

void start()
{
   
}

string period_name(int period)
{
    string timeframe;
    if(period == 1){timeframe = "M1";} 
    else if(period == 5) {timeframe = "M5";}
    else if(period == 15) {timeframe = "M15";}
    else if(period == 60) {timeframe = "H1";}
    else if(period == 240) {timeframe = "H4";}
    else if(period == 1440) {timeframe = "Daily";}
    else if(period == 10080) {timeframe = "Weekly";}
    else if(period == 43200) {timeframe = "Monthly";}
    return timeframe;
}

string day_of_week(int day_of_week)
{
    string the_day;
    if(day_of_week == 0){the_day = "Sunday";} 
    else if(day_of_week == 1) {the_day = "Monday";}
    else if(day_of_week == 2) {the_day = "Tuesday";}
    else if(day_of_week == 3) {the_day = "Wednesday";}
    else if(day_of_week == 4) {the_day = "Thursday";}
    else if(day_of_week == 5) {the_day = "Friday";}
    else if(day_of_week == 6) {the_day = "Saturday";}
    else if(day_of_week == 7) {the_day = "Saturday";}
    return the_day;
}

void open_line()
{   
    string name = period_name(Period()) + " Open: " + open_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, open_price, t0, open_price);
        ObjectSet(name, OBJPROP_COLOR, clrBlack);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void high_line()
{
    string name = period_name(Period()) + " High: " + high_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, high_price, t0, high_price);
        ObjectSet(name, OBJPROP_COLOR, clrBlack);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void low_line()
{
    string name = period_name(Period()) + " Low: " + low_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, low_price, t0, low_price);
        ObjectSet(name, OBJPROP_COLOR, clrBlack);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void close_line()
{
    string name = period_name(Period()) + " Close: " + close_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, close_price, t0, close_price);
        ObjectSet(name, OBJPROP_COLOR, clrBlack);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void median_line()
{
    string name = period_name(Period()) + " Mean Threshold: " + median_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, median_price, t0, median_price);
        ObjectSet(name, OBJPROP_COLOR, clrRed);
        ObjectSet(name, OBJPROP_BACK, true);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void horizontal_line() 
{
    if(ObjectType(selected_name) == OBJ_TREND)
    {
        double price = ObjectGet(selected_name, OBJPROP_PRICE1);
        trend_date_1 = ObjectGet(selected_name, OBJPROP_TIME1);
        trend_date_2 = ObjectGet(selected_name, OBJPROP_TIME2);
        col = ObjectGet(selected_name, OBJPROP_COLOR);

        ObjectDelete(selected_name);
        ObjectCreate(selected_name, OBJ_HLINE, 0, 0, price);
        ObjectSet(selected_name, OBJPROP_COLOR, col);
    }

    else if(ObjectType(selected_name) == OBJ_HLINE)
    {
        price = ObjectGet(selected_name, OBJPROP_PRICE1);
        col = ObjectGet(selected_name, OBJPROP_COLOR);
        ObjectDelete(selected_name);
        ObjectCreate(selected_name, OBJ_TREND, 0, trend_date_1, price, trend_date_2, price);
        ObjectSet(selected_name, OBJPROP_COLOR, col);
    }
}

void miscellaneous_line()
{   
    string name = period_name(Period()) + " Misc line: " + open_price;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_TREND, 0, my_datetime, my_price, my_datetime+(24*hour_in_secs), my_price);
        ObjectSet(name, OBJPROP_COLOR, clrRed);
        ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}


void FVG()
{
    string name = period_name(Period()) + " Fair Value Gap: " + my_datetime;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        if(open_price < close_price)
        {
            ObjectCreate(name, OBJ_RECTANGLE, 0, my_datetime, prev_candle_high, t0, next_candle_low);
            ObjectSet(name, OBJPROP_COLOR, fvg_color);
            ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
            selected_name = name;
        }
        else
        {
            ObjectCreate(name, OBJ_RECTANGLE, 0, my_datetime, prev_candle_low, t0, next_candle_high);
            ObjectSet(name, OBJPROP_COLOR, fvg_color);
            ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
            selected_name = name;
        }
    }
}

void equal_highs_rectangle()
{
    string name = period_name(Period()) + " Equal Highs: " + my_datetime;
    if(name == selected_name)
    {
        ObjectDelete(name);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_RECTANGLE, 0, my_datetime, my_price, my_datetime+(24*hour_in_secs), my_price*1.1);
        ObjectSet(name, OBJPROP_COLOR, clrPink);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

void order_block()
{
    string name = period_name(Period()) + " Order Block: " + TimeToStr(my_datetime);
    if(name == selected_name)
    {
        ObjectDelete(name);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = "";
    }
    else
    {
        ObjectCreate(name, OBJ_RECTANGLE, 0, my_datetime - 4000, high_price, my_datetime + 4000, low_price);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name;
    }
}

int num_candles_M_W_D(string period)
{
    int num_candles;
    // Weekly 5 Days worth
    if(period == "weekly")
    {
        if(Period() == 240){num_candles = 33;}
        if(Period() == 60){num_candles = 130;}
        if(Period() == 30){num_candles = 260;}
        if(Period() == 15){num_candles = 520;}
        if(Period() == 5){num_candles = 1560;}
        if(Period() == 1){num_candles = 7800;}
    }

    // Daily
    if(period == "daily")
    {
        if(Period() == 240){num_candles = 6;}
        if(Period() == 60){num_candles = 24;}
        if(Period() == 30){num_candles = 48;}
        if(Period() == 15){num_candles = 96;}
        if(Period() == 5){num_candles = 288;}
        if(Period() == 1){num_candles = 1440;}
    }
    return num_candles;
}

void quarterly_open()
{
    int num_candles = num_candles_M_W_D("monthly");
    int num_candles_in_months = weeks_to_display * num_candles; 
    for(int i=0; i<cnt; i++)
    {   
        string name = "Quarterly Open "+TimeToStr(Time[i], TIME_DATE);

        if(((TimeMonth(Time[i]) == 1 || TimeMonth(Time[i]) == 4 || TimeMonth(Time[i]) == 7 || TimeMonth(Time[i]) == 10) && TimeDay(Time[i]) == 1))
        {
            open_price = iOpen(NULL, 0, i);
            ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(2080*hour_in_secs), open_price);
            ObjectSet(name, OBJPROP_TIMEFRAMES, D1);
            ObjectSet(name, OBJPROP_COLOR, clrPurple);
            ObjectSet(name, OBJPROP_RAY, false);
            ObjectSet(name, OBJPROP_WIDTH, 2);
            // ObjectSet(name, OBJPROP_SELECTABLE, false);
        }
    }
}

void delete_quarterly_open()
{
    for(int i=0; i<cnt; i++)
    {   
        if((TimeDay(Time[i]) == 1))
        {
            string name = "Quarterly Open "+TimeToStr(Time[i], TIME_DATE);
            ObjectDelete(name);
        }
    }
}

void monthly_open()
{
    int num_candles = num_candles_M_W_D("monthly");
    int num_candles_in_months = weeks_to_display * num_candles; 
    for(int i=0; i<cnt; i++)
    {   
        string name = "Monthly Open "+TimeToStr(Time[i], TIME_DATE);

        // Sundays candle
        // if((TimeHour(Time[i]) == 0 )  && (TimeDayOfWeek(Time[i]) == 0) && (TimeMinute(Time[i]) == 0) )
        // {
        //     double open_price = iOpen(NULL, 0, i);
        //     ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(96*hour_in_secs), open_price);
        //     ObjectSet(name, OBJPROP_TIMEFRAMES, D1);
        //     ObjectSet(name, OBJPROP_COLOR, clrGreen);
        //     ObjectSet(name, OBJPROP_RAY, false);
        //     ObjectSet(name, OBJPROP_SELECTABLE, false);

        // }

        // Mondays Candle
        if((TimeDay(Time[i]) == 1))
        {
            open_price = iOpen(NULL, 0, i);
            ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(520*hour_in_secs), open_price);
            ObjectSet(name, OBJPROP_TIMEFRAMES, D1);
            ObjectSet(name, OBJPROP_COLOR, clrRed);
            ObjectSet(name, OBJPROP_RAY, false);
            ObjectSet(name, OBJPROP_WIDTH, 2);
            // ObjectSet(name, OBJPROP_SELECTABLE, false);
        }
    }
}

void delete_monthly_open()
{
    for(int i=0; i<cnt; i++)
    {   
        if((TimeDay(Time[i]) == 1))
        {
            string name = "Monthly Open "+TimeToStr(Time[i], TIME_DATE);
            ObjectDelete(name);
        }
    }
}

void weekly_open()
{
    int num_candles = num_candles_M_W_D("weekly");
    int num_candles_in_weeks = weeks_to_display * num_candles; 
    for(int i=0; i<cnt; i++)
    {   
        string name = "Weekly Open "+TimeToStr(Time[i], TIME_DATE);

        // Sundays candle
        // if((TimeHour(Time[i]) == 0 )  && (TimeDayOfWeek(Time[i]) == 0) && (TimeMinute(Time[i]) == 0) )
        // {
        //     double open_price = iOpen(NULL, 0, i);
        //     ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(96*hour_in_secs), open_price);
        //     ObjectSet(name, OBJPROP_TIMEFRAMES, D1);
        //     ObjectSet(name, OBJPROP_COLOR, clrGreen);
        //     ObjectSet(name, OBJPROP_RAY, false);
        //     ObjectSet(name, OBJPROP_SELECTABLE, false);

        // }

        // Mondays Candle
        if((TimeHour(Time[i]) == 0 )  && (TimeDayOfWeek(Time[i]) == 1) && (TimeMinute(Time[i]) == 0))
        {
            open_price = iOpen(NULL, 0, i);
            ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(130*hour_in_secs), open_price);
            ObjectSet(name, OBJPROP_TIMEFRAMES, D1);
            ObjectSet(name, OBJPROP_COLOR, clrGreen);
            ObjectSet(name, OBJPROP_RAY, false);
            ObjectSet(name, OBJPROP_WIDTH, 2);
            // ObjectSet(name, OBJPROP_SELECTABLE, false);
        }
    }
}

void delete_weekly_open()
{
    for(int i=0; i<cnt; i++)
    {   
        if((TimeHour(Time[i]) == 0 )  && (TimeDayOfWeek(Time[i]) == 1) && (TimeMinute(Time[i]) == 0))
        {
            string name = "Weekly Open "+TimeToStr(Time[i], TIME_DATE);
            ObjectDelete(name);
        }
    }
}

void daily_open()
{
    int num_candles = num_candles_M_W_D("daily");
    int num_candles_in_days = days_to_display * num_candles;
    int ny_midnight = 4;
    for(int i=0; i<num_candles_in_days; i++)
    {   
        string name = "Daily Open "+TimeToStr(Time[i], TIME_DATE);

        // Sundays candle
        if((TimeHour(Time[i]) == ny_midnight + hours_adjust) && (TimeMinute(Time[i]) == 0))
        {
            double open_price = iOpen(NULL, 0, i);
            ObjectCreate(name, OBJ_TREND, 0, Time[i], open_price, Time[i]+(24*hour_in_secs), open_price);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, clrBlue);
            ObjectSet(name, OBJPROP_RAY, false);
            ObjectSet(name, OBJPROP_WIDTH, 2);
            // ObjectSet(name, OBJPROP_SELECTABLE, false);
        }
    }
}

void delete_daily_open()
{
    int num_candles = num_candles_M_W_D("weekly");
    int num_candles_in_days = days_to_display * num_candles;
    int ny_midnight = 4;
    for(int i=0; i<cnt; i++)
    {   
        if((TimeHour(Time[i]) == ny_midnight + hours_adjust) && (TimeMinute(Time[i]) == 0))
        {
            string name = "Daily Open "+TimeToStr(Time[i], TIME_DATE);
            ObjectDelete(name);
        }
    }
}

void text()
{
    string name = "Text @ "+IntegerToString(Period()) + " @ " + DoubleToStr(my_price, 4);
    ObjectCreate(name, OBJ_TEXT, 0, my_datetime, my_price, 0, 0);
    ObjectSetText(name, "Hello World", font_size, NULL, text_color);
    ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
    selected_name = name;
}

void stop_sign()
{
    string name = "Stop @ "+IntegerToString(Period()) + " @ " + DoubleToStr(my_price, 4);
    ObjectCreate(name, OBJ_ARROW_STOP, 0, my_datetime, my_price, 0, 0);
    ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
    ObjectSet(name, OBJPROP_COLOR, stop_color);
    ObjectSet(name, OBJPROP_WIDTH, stop_width);
    ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
    selected_name = name;
}

void left_price_tag()
{
     string name = "Price @" + DoubleToStr(my_price, 4);
     ObjectCreate(name, OBJ_ARROW_LEFT_PRICE, 0, my_datetime, my_price, 0, 0);
     ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
     ObjectSet(name, OBJPROP_COLOR, price_tag_color);
     ObjectSet(name, OBJPROP_WIDTH, price_tag_width);
     ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
     selected_name = name;
}

void right_price_tag()
{
    string name = "Price @" + DoubleToStr(my_price, 4);
    ObjectCreate(name, OBJ_ARROW_RIGHT_PRICE, 0, my_datetime, my_price, 0, 0);
    ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
    ObjectSet(name, OBJPROP_COLOR, price_tag_color);
    ObjectSet(name, OBJPROP_WIDTH, price_tag_width);
    ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
    selected_name = name;
}

void up_arrow()
{
    string name = "Up Arrow: "+ DoubleToStr(my_price, 4);
    if(selected_name == name)
    {
        ObjectDelete(selected_name);
    }
    else
    {
        ObjectCreate(name, OBJ_ARROW_UP, 0, my_datetime, my_price, 0, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_COLOR, clrRed);
        ObjectSet(name, OBJPROP_WIDTH, 3);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name; 
    }
    
}

void down_arrow()
{
    string name = "Down Arrow: "+ DoubleToStr(my_price, 4);
    if(selected_name == name)
    {
        ObjectDelete(selected_name);
    }
    else
    {
        ObjectCreate(name, OBJ_ARROW_DOWN, 0, my_datetime, my_price, 0, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_COLOR, clrRed);
        ObjectSet(name, OBJPROP_WIDTH, 3);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        selected_name = name; 
    }
}
void style_change()
{   
    int style = ObjectGet(selected_name, OBJPROP_STYLE);

    if(style < 5)
    {
        ObjectSet(selected_name, OBJPROP_STYLE, style + 1);
    }
    else
    {
        ObjectSet(selected_name, OBJPROP_STYLE, 0);
    }
    
}
void size_increase()
{   
    if(ObjectType(selected_name)==OBJ_TEXT)
    {
        int obj_font_size = ObjectGet(selected_name, OBJPROP_FONTSIZE);
        ObjectSet(selected_name, OBJPROP_FONTSIZE, obj_font_size + 1);
    }
    else
    {
        int obj_size = ObjectGet(selected_name, OBJPROP_WIDTH);
        if(obj_size == 5)
        {
            ObjectSet(selected_name, OBJPROP_WIDTH, 1);
        }
        else
        {
            ObjectSet(selected_name, OBJPROP_WIDTH, obj_size + 1);
        }
    }
}

void increase_price()
{
    double pip;

    if(MarketInfo(Symbol(), MODE_DIGITS)==4||MarketInfo(Symbol(), MODE_DIGITS)==5){
      pip = 0.0001;
    }
    else {
      pip = 0.01;
    } 

    double price = ObjectGet(selected_name, OBJPROP_PRICE1);

    ObjectSet(selected_name, OBJPROP_PRICE1, price + pip);
    ObjectSet(selected_name, OBJPROP_PRICE2, price + pip);
}

void decrease_price()
{
    double pip;

    if(MarketInfo(Symbol(), MODE_DIGITS)==4||MarketInfo(Symbol(), MODE_DIGITS)==5){
      pip = 0.0001;
    }
    else {
      pip = 0.01;
    } 

    double price = ObjectGet(selected_name, OBJPROP_PRICE1);

    ObjectSet(selected_name, OBJPROP_PRICE1, price - pip);
    ObjectSet(selected_name, OBJPROP_PRICE2, price - pip);
}

void extend()
{
    if(ObjectType(selected_name) == OBJ_FIBO)
    {
        datetime time1 = ObjectGet(selected_name, OBJPROP_TIME1);
        datetime time2 = ObjectGet(selected_name, OBJPROP_TIME2);
        ObjectSet(selected_name, OBJPROP_TIME1, time1 + (extend_reduce_speed*Period())/3);
        ObjectSet(selected_name, OBJPROP_TIME2, time2 + (extend_reduce_speed*Period())/3);
    }
    else
    {   
        time2 = ObjectGet(selected_name, OBJPROP_TIME2);
        ObjectSet(selected_name, OBJPROP_TIME2, time2 + (extend_reduce_speed*Period())/3);
    }
}

void reduce()
{

    if(ObjectType(selected_name) == OBJ_FIBO)
    {
        datetime time1 = ObjectGet(selected_name, OBJPROP_TIME1);
        datetime time2 = ObjectGet(selected_name, OBJPROP_TIME2);
        ObjectSet(selected_name, OBJPROP_TIME1, time1 - (extend_reduce_speed*Period())/3);
        ObjectSet(selected_name, OBJPROP_TIME2, time2 - (extend_reduce_speed*Period())/3);
    }
    else
    {   
        time2 = ObjectGet(selected_name, OBJPROP_TIME2);
        ObjectSet(selected_name, OBJPROP_TIME2, time2 - (extend_reduce_speed*Period())/3);
    }
}

void set_color(color the_color)
{
   ObjectSet(selected_name, OBJPROP_COLOR, the_color);
}

void decrease_tf()
{   
    int period = Period();
    switch(period)
    {
        case PERIOD_MN1: period = PERIOD_W1; break;
        case PERIOD_W1: period = PERIOD_D1; break;
        case PERIOD_D1: period = PERIOD_H4; break;
        case PERIOD_H4: period = PERIOD_H1; break;
        case PERIOD_H1: period = PERIOD_M30; break;
        case PERIOD_M30: period = PERIOD_M15; break;
        case PERIOD_M15: period = PERIOD_M5; break;
        case PERIOD_M5: period = PERIOD_M1; break;
        case PERIOD_M1: period = PERIOD_MN1; break;
    }
    
    ChartSetSymbolPeriod(0, NULL, period);
}

void increase_tf()
{   
    int period = Period();
    switch(period)
    {
        case PERIOD_MN1: period = PERIOD_M1; break;
        case PERIOD_W1: period = PERIOD_MN1; break;
        case PERIOD_D1: period = PERIOD_W1; break;
        case PERIOD_H4: period = PERIOD_D1; break;
        case PERIOD_H1: period = PERIOD_H4; break;
        case PERIOD_M30: period = PERIOD_H1; break;
        case PERIOD_M15: period = PERIOD_M30; break;
        case PERIOD_M5: period = PERIOD_M15; break;
        case PERIOD_M1: period = PERIOD_M5; break;
    }
    
    ChartSetSymbolPeriod(0, NULL, period);
}

void kill_zones()
{
    double bottom_of_chart = WindowPriceMin(0);

    for(int i=0; i<cnt; i++)
    {   
        datetime asian_start = Time[i];
        datetime asian_end = Time[i] + (4*hour_in_secs);
        datetime london_start = Time[i] + (5*hour_in_secs);
        datetime london_end = Time[i] + (9*hour_in_secs);
        datetime ny_start = Time[i] + (11*hour_in_secs);
        datetime ny_end = Time[i] + (14*hour_in_secs);
        datetime eq_start = Time[i] + (13.5*hour_in_secs);
        datetime eq_end = Time[i] + (14*hour_in_secs);
        datetime lc_start = Time[i] + (14*hour_in_secs); 
        datetime lc_end = Time[i] + (16*hour_in_secs);

        if(TimeHour(Time[i]) == hours_adjust && TimeMinute(Time[i])==0)
        { 
            // Asian Range
            string name = "Asian Range "+i;

            ObjectCreate(name, OBJ_TREND, 0, asian_start, bottom_of_chart, asian_end, bottom_of_chart);
            ObjectSet(name, OBJPROP_WIDTH, killzone_thickness);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, asian_range_color);
            ObjectSet(name, OBJPROP_YDISTANCE, 500);

            // London Range

            name = "London Range "+i;
            ObjectCreate(name, OBJ_TREND, 0, london_start, bottom_of_chart, london_end, bottom_of_chart);
            ObjectSet(name, OBJPROP_WIDTH, killzone_thickness);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, london_range_color);

            // NY Range
            name = "NY Range "+i;
            ObjectCreate(name, OBJ_TREND, 0, ny_start, bottom_of_chart, ny_end, bottom_of_chart);
            ObjectSet(name, OBJPROP_WIDTH, killzone_thickness);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, ny_range_color);

            // Equities Open
            name = "EQ Range "+i;
            ObjectCreate(name, OBJ_TREND, 0, eq_start, bottom_of_chart, eq_end, bottom_of_chart);
            ObjectSet(name, OBJPROP_WIDTH, killzone_thickness);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, eq_range_color);

            // London Close
            name = "LC Range "+i;
            ObjectCreate(name, OBJ_TREND, 0, lc_start, bottom_of_chart, lc_end, bottom_of_chart);
            ObjectSet(name, OBJPROP_WIDTH, killzone_thickness);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_COLOR, lc_range_color);
        }

    

    
    }

}

void delete_kill_zones()
{
    double bottom_of_chart = WindowPriceMin(0);

    for(int i=0; i<cnt; i++)
    {
        ObjectDelete("Asian Range "+i);
        ObjectDelete("London Range "+i);
        ObjectDelete("NY Range "+i);
        ObjectDelete("EQ Range "+i);
        ObjectDelete("LC Range "+i);
    }
}

void period_separators() {
  int P = Period();
  if (P > PERIOD_D1) return;
  
  string name = "";
  
  for (int i=0; i < cnt; i++)
  {
        
       if(TimeHour(Time[i])== hours_adjust && TimeMinute(Time[i])==0)
       {
         datetime ny_midnight = Time[i] + (4*hour_in_secs);
         name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight;
         
         if(TimeDayOfWeek(ny_midnight) == 1)
         {
            name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight+" End";
            ObjectCreate(name, OBJ_VLINE, 0, ny_midnight, 0, 0);
            ObjectSet(name, OBJPROP_COLOR, ps_color);
            ObjectSet(name, OBJPROP_BACK, true);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);

            name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight+" Begin";
            ObjectCreate(name, OBJ_VLINE, 0, ny_midnight-(7*hour_in_secs), 0, 0);
            ObjectSet(name, OBJPROP_COLOR, ps_color);
            ObjectSet(name, OBJPROP_BACK, true);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
         }
         else
         {
            ObjectCreate(name, OBJ_VLINE, 0, ny_midnight, 0, 0);
            ObjectSet(name, OBJPROP_COLOR, ps_color);
            ObjectSet(name, OBJPROP_BACK, true);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
         }
       }
  } 
}    

void delete_period_separators() {
  int P = Period();
  if (P > PERIOD_D1) return;
  
  for (int i=0; i < cnt; i++){

    if (TimeHour(Time[i]) == hours_adjust && TimeMinute(Time[i])==0)
    {
      datetime ny_midnight = Time[i] + (4*hour_in_secs);  
      string name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight;
      ObjectDelete(name);
      
      if(TimeDayOfWeek(ny_midnight) == 1){
        name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight+" End";
        ObjectDelete(name);
        name = day_of_week(TimeDayOfWeek(ny_midnight)) +" "+ny_midnight+" Begin";
        ObjectDelete(name);
      }
    }
  }
}

void show_asian_range(){
   for (int i=0; i < cnt; i++)
     {
          if(TimeHour(Time[i])== hours_adjust && TimeMinute(Time[i])==0)
          {
            string asian_range = Time[i] + (4*hour_in_secs);
            string asian_range_end = "Asian Range End "+TimeDayOfWeek(Time[i])+" "+TimeToStr(Time[i]);
            int hour_candle_shift = iBarShift(NULL, PERIOD_H1, asian_range);
            int asian_range_high = iHighest(NULL, PERIOD_H1, MODE_HIGH, 4, hour_candle_shift);
            int asian_range_low = iLowest(NULL, PERIOD_H1, MODE_LOW, 4, hour_candle_shift);
            double high_price = iHigh(NULL, PERIOD_H1, asian_range_high);
            double low_price = iLow(NULL, PERIOD_H1, asian_range_low);
            
            string name = "AR Top "+day_of_week(TimeDayOfWeek(Time[i]))+" "+ TimeToStr(Time[i], TIME_DATE);
            
            ObjectCreate(name, OBJ_TREND, 0, Time[i], high_price, asian_range, high_price);
            ObjectSet(name, OBJPROP_COLOR, asian_range_color);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
            
  
            name = "AR Bottom "+day_of_week(TimeDayOfWeek(Time[i]))+" "+ TimeToStr(Time[i], TIME_DATE);
            
            ObjectCreate(name, OBJ_TREND, 0, Time[i], low_price, asian_range, low_price);
            ObjectSet(name, OBJPROP_COLOR, asian_range_color);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_RAY, 0);
            ObjectSet(name, OBJPROP_TIMEFRAMES, H1);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
          }
     }
}

void delete_asian_range()
{
   for (int i=0; i < cnt; i++)
      if(TimeHour(Time[i])== hours_adjust && TimeMinute(Time[i])==0){
         
         string asian_range_top_border = "AR Top "+day_of_week(TimeDayOfWeek(Time[i]))+" "+ TimeToStr(Time[i], TIME_DATE);
         string asian_range_bottom_border = "AR Bottom "+day_of_week(TimeDayOfWeek(Time[i]))+" "+ TimeToStr(Time[i], TIME_DATE);
         ObjectDelete(asian_range_top_border);
         ObjectDelete(asian_range_bottom_border);
      }
}

void show_trade_levels()
{
    ChartSetInteger(ChartID(), CHART_SHOW_TRADE_LEVELS, true);
}

void hide_trade_levels()
{
    ChartSetInteger(ChartID(), CHART_SHOW_TRADE_LEVELS, false);
}

void fib_levels()
{
    if(ObjectType(selected_name) == OBJ_FIBO)
    {
        switch(fib_type)
        {
            case 1:
            {
                 ObjectSetInteger(0,selected_name,OBJPROP_FIBOLEVELS,9);
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+0,0.0);  ObjectSetFiboDescription(selected_name,0,"0%%   :: %$");
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+1,0.50); ObjectSetFiboDescription(selected_name,1,"50%%   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+2,0.62); ObjectSetFiboDescription(selected_name,2,"OTE 62%%   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+3,0.705); ObjectSetFiboDescription(selected_name,3,"Sweet Spot 70.5%%   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+4,0.79); ObjectSetFiboDescription(selected_name,4,"OTE 79%%   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+5,1.0); ObjectSetFiboDescription(selected_name,5,"100%%   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+6,1.27); ObjectSetFiboDescription(selected_name,6,"127%%  Short Term   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+7,1.68); ObjectSetFiboDescription(selected_name,7,"168%%   :: %$");
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+8,2.00); ObjectSetFiboDescription(selected_name,8,"200%%   :: %$");
                 ObjectSet(selected_name, OBJPROP_TIMEFRAMES, time_frames_to_show);
            }
            break;
            case 2:
            {
                 ObjectSetInteger(0,selected_name,OBJPROP_FIBOLEVELS,12);
                 // if(max_price<min_price)
                 // {
                    ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+0,0.0);  ObjectSetFiboDescription(selected_name,0,"Stop Loss   :: %$");
                    ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+1,1.0); ObjectSetFiboDescription(selected_name,1,"Entry   :: %$"); 
                 // }
                 // else
                 // {
                 //    ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+0,0.0);  ObjectSetFiboDescription(selected_name,0,"Entry   :: %$");
                 //    ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+1,1.0); ObjectSetFiboDescription(selected_name,1,"Stop Loss   :: %$"); 
                 // }
                 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+2,2.0); ObjectSetFiboDescription(selected_name,2,"Take Profit 1R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+3,3.0); ObjectSetFiboDescription(selected_name,3,"Take Profit 2R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+4,4.0); ObjectSetFiboDescription(selected_name,4,"Take Profit 3R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+5,5.0); ObjectSetFiboDescription(selected_name,5,"Take Profit 4R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+6,6.0); ObjectSetFiboDescription(selected_name,6,"Take Profit 5R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+7,7.0); ObjectSetFiboDescription(selected_name,7,"Take Profit 6R:R   :: %$"); 
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+8,8.0); ObjectSetFiboDescription(selected_name,8,"Take Profit 7R:R   :: %$");
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+9,9.0); ObjectSetFiboDescription(selected_name,9,"Take Profit 8R:R   :: %$");
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+10,10.0); ObjectSetFiboDescription(selected_name,10,"Take Profit 9R:R   :: %$");
                 ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+11,11.0); ObjectSetFiboDescription(selected_name,11,"Take Profit 10R:R   :: %$");
                 ObjectSet(selected_name, OBJPROP_TIMEFRAMES, time_frames_to_show);
            }
            break;
            case 3:
            {
                ObjectSetInteger(0,selected_name,OBJPROP_FIBOLEVELS,5);
                ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+0,0.0);  ObjectSetFiboDescription(selected_name,0,"0%   :: %$");
                ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+1,0.25); ObjectSetFiboDescription(selected_name,1,"25%   :: %$"); 
                ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+2,0.50); ObjectSetFiboDescription(selected_name,2,"50%   :: %$"); 
                ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+3,0.75); ObjectSetFiboDescription(selected_name,3,"75%   :: %$"); 
                ObjectSet(selected_name,OBJPROP_FIRSTLEVEL+4,1.0); ObjectSetFiboDescription(selected_name,4,"100%   :: %$");
                ObjectSet(selected_name, OBJPROP_TIMEFRAMES, time_frames_to_show);
            }
            break;
        } 
    }
}

void draw_fib_levels()
{   
     string name;
     if(fib_type == 3)
     {
         name = period_name(Period())+" 100% Range";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, max_price, fib_time1, max_price);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 75% Range";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, seventy_five_level, fib_time1, seventy_five_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 50% Range";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, fifty_level, fib_time1, fifty_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 25% Range";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, twenty_five_level, fib_time1, twenty_five_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 0% Range";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, zero_level, fib_time1, zero_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
     }
     else if(fib_type == 1)
     {
         name = period_name(Period())+" 100% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, max_price, fib_time1, max_price);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name = period_name(Period())+" 79% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, seventy_nine_level, fib_time1, seventy_nine_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name = period_name(Period())+" 70.5% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, seventy_point_5_level, fib_time1, seventy_point_5_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name = period_name(Period())+" 62% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, sixty_two_level, fib_time1, sixty_two_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 50% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, fifty_level, fib_time1, fifty_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 0% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, zero_level, fib_time1, zero_level);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 127% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, hundred_twenty_seven, fib_time1, hundred_twenty_seven);
         ObjectSet(name, OBJPROP_COLOR, clrGreen);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 168% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, hundred_sixty_eight, fib_time1, hundred_sixty_eight);
         ObjectSet(name, OBJPROP_COLOR, clrGreen);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);

         name= period_name(Period())+" 200% Fib Level";
         ObjectCreate(name, OBJ_TREND, 0, fib_time0, two_hundred, fib_time1, two_hundred);
         ObjectSet(name, OBJPROP_COLOR, clrGreen);
         ObjectSet(name, OBJPROP_RAY, 0);
         ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
     }

     else if(fib_type = 2)
     {
        name="Stop Loss";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, zero_level, fib_time1, zero_level);
        ObjectSet(name, OBJPROP_COLOR, clrRed);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "Entry";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, hundred_level, fib_time1, hundred_level);
        ObjectSet(name, OBJPROP_COLOR, clrBlue);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "1R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR1, fib_time1, RR1);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "2R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR2, fib_time1, RR2);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "3R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR3, fib_time1, RR3);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "4R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR4, fib_time1, RR4);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "5R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR5, fib_time1, RR5);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "6R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR6, fib_time1, RR6);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "7R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR7, fib_time1, RR7);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "8R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR8, fib_time1, RR8);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "9R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR9, fib_time1, RR9);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);

        name = "10R";
        ObjectCreate(name, OBJ_TREND, 0, fib_time0, RR10, fib_time1, RR10);
        ObjectSet(name, OBJPROP_COLOR, clrGreen);
        ObjectSet(name, OBJPROP_RAY, 0);
        ObjectSet(name, OBJPROP_TIMEFRAMES, time_frames_to_show);
        ObjectSet(name, OBJPROP_WIDTH, 4);
     }
}

void delete_fib_levels()
{
    if(fib_type == 1)
    {
        ObjectDelete(period_name(Period())+" 100% Fib Level");
        ObjectDelete(period_name(Period())+" 79% Fib Level");
        ObjectDelete(period_name(Period())+" 70.5% Fib Level");
        ObjectDelete(period_name(Period())+" 62% Fib Level");
        ObjectDelete(period_name(Period())+" 50% Fib Level");
        ObjectDelete(period_name(Period())+" 0% Fib Level");
        ObjectDelete(period_name(Period())+" 127% Fib Level");
        ObjectDelete(period_name(Period())+" 168% Fib Level");
        ObjectDelete(period_name(Period())+" 200% Fib Level");
    }

    else if(fib_type == 3)
    {
        ObjectDelete(period_name(Period())+" 100% Range");
        ObjectDelete(period_name(Period())+" 75% Range");
        ObjectDelete(period_name(Period())+" 50% Range");
        ObjectDelete(period_name(Period())+" 25% Range");
        ObjectDelete(period_name(Period())+" 0% Range");
    }

    else if(fib_type == 2)
    {
        ObjectDelete("Stop Loss");
        ObjectDelete("Entry");
        ObjectDelete("1R");
        ObjectDelete("2R");
        ObjectDelete("3R");
        ObjectDelete("4R");
        ObjectDelete("5R");
        ObjectDelete("6R");
        ObjectDelete("7R");
        ObjectDelete("8R");
        ObjectDelete("9R");
        ObjectDelete("10R");
    }
    
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
    // Comment(__FUNCTION__,": id=",id," lparam=",lparam," dparam=",dparam," sparam=",sparam);
    // Toggle Tab event for IPDA Data ranges
    if(id==CHARTEVENT_CLICK){

        int      x     =(int)lparam;
        int      y     =(int)dparam;
        datetime dt    =0;
        double   price =0;
        int      window=0;
        
        if(ChartXYToTimePrice(0,x,y, window, dt, price)){
            my_price = price;
            my_datetime = dt;
            selected_shift = iBarShift(NULL, 0, my_datetime);
            open_price = iOpen(NULL, 0, selected_shift);
            high_price = iHigh(NULL, 0, selected_shift);
            low_price = iLow(NULL, 0, selected_shift);
            close_price = iClose(NULL, 0, selected_shift);

            double range;
            if(open_price > close_price)
            {
                range = (open_price - close_price)/2;
                median_price = close_price + range;
                prev_candle_low = iLow(NULL, 0, selected_shift + 1);
                next_candle_high = iHigh(NULL, 0, selected_shift - 1);
            }
            else
            {   
                range = (close_price - open_price)/2;
                median_price = open_price + range;

                prev_candle_high = iHigh(NULL, 0, selected_shift + 1);
                next_candle_low = iLow(NULL, 0, selected_shift - 1);
            }
        };
    }
    
    if(id==CHARTEVENT_OBJECT_CLICK)
    
     {
      selected_name = sparam;
      if(ObjectType(selected_name) == OBJ_FIBO)
      {
        //
        // Calculations for all the Levels on the Fib
        //
         double  price0 = ObjectGetDouble(0,selected_name,OBJPROP_PRICE,0);
         double  price1 = ObjectGetDouble(0,selected_name,OBJPROP_PRICE,1);
         fib_time0 = ObjectGet(selected_name, OBJPROP_TIME1);
         fib_time1 = ObjectGet(selected_name, OBJPROP_TIME2);

         if(price0 > price1)
         {
            max_price = price0;
            min_price = price1;
            hundred_level = price0;
            zero_level = price1;
         } 
         else if(price0 < price1) 
         {
            max_price = price1;
            min_price = price0;
            hundred_level = price0;
            zero_level = price1;
         }

         // Fib Retracement Levels
         fib_one_percent = (max_price - min_price)/100;
         // hundred_level = max_price;
         seventy_nine_level = (fib_one_percent * 79) + min_price;
         seventy_five_level = (fib_one_percent * 75) + min_price;
         seventy_point_5_level = (fib_one_percent * 70.5) + min_price;
         sixty_two_level = (fib_one_percent * 62) + min_price;
         fifty_level = (fib_one_percent * 50) + min_price;
         twenty_five_level = (fib_one_percent * 25) + min_price;
         // zero_level = min_price;

         // Fib extension Levels
         hundred_twenty_seven = (fib_one_percent * 127) + min_price;
         hundred_sixty_eight = (fib_one_percent * 168) + min_price;
         two_hundred = (fib_one_percent * 200) + min_price;

         // RR levels
         if(price1 < price0) {
            RR1 = 2*(max_price - min_price) + min_price;
            RR2 = 3*(max_price - min_price) + min_price;
            RR3 = 4*(max_price - min_price) + min_price;
            RR4 = 5*(max_price - min_price) + min_price;
            RR5 = 6*(max_price - min_price) + min_price;
            RR6 = 7*(max_price - min_price) + min_price;
            RR7 = 8*(max_price - min_price) + min_price;
            RR8 = 9*(max_price - min_price) + min_price;
            RR9 = 10*(max_price - min_price) + min_price;
            RR10 = 11*(max_price - min_price) + min_price;
         } 
         else {
            RR1 = -2*(max_price - min_price) + max_price;
            RR2 = -3*(max_price - min_price) + max_price;
            RR3 = -4*(max_price - min_price) + max_price;
            RR4 = -5*(max_price - min_price) + max_price;
            RR5 = -6*(max_price - min_price) + max_price;
            RR6 = -7*(max_price - min_price) + max_price;
            RR7 = -8*(max_price - min_price) + max_price;
            RR8 = -9*(max_price - min_price) + max_price;
            RR9 = -10*(max_price - min_price) + max_price;
            RR10 = -11*(max_price - min_price) + max_price;
         }
      }
     }
     
    if(id==CHARTEVENT_CHART_CHANGE){
       delete_kill_zones();
       kill_zones();
    }

    if(id==CHARTEVENT_KEYDOWN)
    {
        if(lparam == KEY_Y)
        {
            text();
        }
            
        else if(lparam == KEY_G)
        {
            stop_sign();
        }

        else if(lparam == KEY_LEFT_ARROW)
        {   
            left_price_tag();
        }
        
        else if(lparam == KEY_U)
        {
            right_price_tag();
        }

        else if(lparam == KEY_W)
        {
            size_increase();
        }

        else if(lparam == KEY_E)
        {
            extend();
        }

        else if(lparam == KEY_R)
        {
            reduce();
        }

        else if(lparam == KEY_O)
        {
            open_line();
        }

        else if(lparam == KEY_H)
        {
            high_line();
        }

        else if(lparam == KEY_L)
        {
            low_line();
        }

        else if(lparam == KEY_C)
        {
            close_line();
        }

        else if(lparam == KEY_M)
        {
            median_line();
        }

        else if(lparam == KEY_T)
        {
            horizontal_line();
        }
        
        else if(lparam == KEY_V)
        {
            FVG();
        }

        else if(lparam == KEY_B)
        {
            order_block();
        }

        else if(lparam == KEY_S)
        {
            style_change();
        }

        else if(lparam == KEY_TAB)
        {
            decrease_tf();
        }

        else if(lparam == KEY_Q)
        {
            increase_tf();
        }
        
        else if(lparam == KEY_K)
        {
          show_days = !show_days;
          if(show_days == True){
             period_separators();
          }
          else{
             delete_period_separators();
          }
        }

        else if(lparam == KEY_A)
        {
            increase_price();
        }

        else if(lparam == KEY_Z)
        {
            decrease_price();
        }

        else if(lparam == KEY_D)
        {   
            hide_active_trades = !hide_active_trades;
            if(hide_active_trades == true)
            {
                hide_trade_levels();
            }
            else
            {
                show_trade_levels();
            }
        }

        else if(lparam == KEY_F)
        {
            if(fib_type < 3)
            {
                fib_type++;
            }
            else
            {
                fib_type=1;
            }
            Print("Fib Type: " + fib_type);
            fib_levels(); 
        }

        else if(lparam == KEY_J)
        {
            show_fib_levels =! show_fib_levels;
            if(show_fib_levels)
            {
                draw_fib_levels();
            }
            else
            {
                delete_fib_levels();
            }

            
        }

        else if(lparam == KEY_N)
        {
            delete_fib_levels();
        }

        else if(lparam == KEY_I)
        {
           miscellaneous_line();
        }

        else if(lparam == KEY_P)
        {
            equal_highs_rectangle();
        }

        else if(lparam == KEY_OPEN_BRACKET)
        {
            show_monthly_open =! show_monthly_open;
            if(show_monthly_open)
            {
                quarterly_open();
            }
            else if(!show_monthly_open)
            {
                delete_quarterly_open();
            }
        }

        else if(lparam == KEY_CLOSE_BRACKET)
        {
            show_monthly_open =! show_monthly_open;
            if(show_monthly_open)
            {
                Print("Monthly Open has been pressed");
                monthly_open();
            }
            else if(!show_monthly_open)
            {
                delete_monthly_open();
            }
        }

        else if(lparam == KEY_SEMI_COLON)
        {
            show_weekly_open =! show_weekly_open;
            if(show_weekly_open)
            {
                weekly_open();
            }
            else if(!show_weekly_open)
            {
                delete_weekly_open();
            }
            
        }

        else if(lparam == KEY_COMMA)
        {
            show_daily_open =! show_daily_open;
            if(show_daily_open)
            {
                daily_open();
            }
            else if(!show_daily_open)
            {
                delete_daily_open();
            }
        }


        else if(lparam == KEY_UP_ARROW)
        {
            Print(lparam);
            up_arrow();
        }
        else if(lparam == KEY_DOWN_ARROW)
        {
            down_arrow();
        }
        
        else if(lparam == KEY_1 || KEY_2 || KEY_3 || KEY_4 || KEY_5 || KEY_6 || KEY_7 || KEY_8 || KEY_9 || KEY_0)
        {
            switch(lparam)
            {
                case KEY_1 : set_color(clr_1); break;
                case KEY_2 : set_color(clr_2); break;
                case KEY_3 : set_color(clr_3); break;
                case KEY_4 : set_color(clr_4); break;
                case KEY_5 : set_color(clr_5); break;
                case KEY_6 : set_color(clr_6); break;
                case KEY_7 : set_color(clr_7); break;
                case KEY_8 : set_color(clr_8); break;
                case KEY_9 : set_color(clr_9); break;
                case KEY_0 : set_color(clr_0); break;
            }
        }
    }
}

