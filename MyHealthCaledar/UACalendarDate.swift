//------------------------------------------------------------------------------
//  UACalendarDate.swift
//------------------------------------------------------------------------------
import Cocoa
//日のタイプ
enum DayType{
    case Weekday       //平日
    case Saturday      //土曜日
    case Sunday        //日曜日
}
//月のタイプ
enum MonthType{
    case PreMonth       //前月
    case ThisMonth      //当月
    case NextMonth      //翌月
}
class UACalendarDate: NSObject{
    var year:Int                    //年
    var month:Int                   //月
    var day:Int                     //日
    var dayOfWeek:Int               //曜日コード
    var strYobi:String              //曜日名
    var dayType:DayType             //日のタイプ
    var monthType:MonthType         //月のタイプ
    var isToday:Bool = false        //当日フラグ
    var integerYearMonthDay:Int     //年月日（YYYYMMDD）整数
    var isHolida:Bool = false       //休日フラグ
    var holidayName:String = ""     //休日名
    var isFirstday:Bool = false     //初日フラグ
    var isLastday:Bool = false      //末日フラグ
    //var nsdate:Date                 //日付オブジェクト（Foundation）
    static let calendar = Calendar(identifier: .gregorian) //カレンダーオブジェクト
    static let youbis = ["日","月","火","水","木","金","土"]   //曜日名テーブル
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init(_ date:Date){
        //引数の日付オブジエクトから日付要素を取得する
        let dateComp = UACalendarDate.calendar.dateComponents(
            [.year, .month, .day, .weekday], from: date)
        //アンラップ
        guard let year_ = dateComp.year,
              let month_ = dateComp.month,
              let day_ = dateComp.day,
              let dayOfWeek_ = dateComp.weekday else {
            print("Error dateComponents in UAdate")
            abort()
        }
        //プロパティに設定
        year = year_
        month = month_
        day = day_
        dayOfWeek = dayOfWeek_
        //曜日名
        strYobi = UACalendarDate.youbis[dayOfWeek-1]
        //曜日タイプ
        dayType = DayType.Weekday
        if dayOfWeek == 7 {dayType = DayType.Saturday}
        if dayOfWeek == 1 {dayType = DayType.Sunday}
        //月タイプ：初期値＝当月
        monthType = MonthType.ThisMonth
        //年月日整数（yyyymmdd）
        integerYearMonthDay = year * 10000 + month * 100 + day
        //日付オブジェクト
        //nsdate = date
        //スーパークラスの初期化
        super.init()
    }
}



