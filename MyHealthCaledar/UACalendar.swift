//------------------------------------------------------------------------------
//  UACalendar.swift
//------------------------------------------------------------------------------
import Cocoa
class UACalendar: NSObject {
    var dateList = [UACalendarDate]()               //日付オブジェクトの配列
    private(set) var daysOfCalender: Int = 0        //日数 35 or 42
    private(set) var currentDateIndex: Int = 0      //現在日の添え字
    private(set) var firstDayIndex: Int = 0         //1日の添え字
    private(set) var lastDayIndex: Int = 0          //末日の添え字
    private var holidays: Dictionary = [String: String]()  //休日辞書
    private let dtUtil:UADateUtil = UADateUtil.dateManager  //日付操作ユーティリティ
    private var firstDateOfThisMonth:Date           //当月の1日

    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    override init() {
        firstDateOfThisMonth = dtUtil.firstDate(date: Date()) //当月の1日
        //スーパークラスの初期化
        super.init()
        //休日ファイルを読み込む
        if let path = Bundle.main.path(forResource: "holiday", ofType: "json"){
            do {
                let url:URL = URL.init(fileURLWithPath: path)
                let data = try Data.init(contentsOf: url)
                let jsonData = try JSONSerialization.jsonObject(with: data)
                if let dictionary = jsonData as? Dictionary<String, String>{
                    holidays = dictionary
                    /*
                     for (key, value) in holidays{
                     print(String(format: "%@:%@", key, value))
                     }
                     */
                }else{
                    print("休日ファイルを読み込めません cast error")
                    return
                }
            }catch{
                print("休日ファイルを読み込めません JSONSerialization error cought")
            }
        }
        //当月のカレンダーを作成する
        self.createDateList()
    }
    //--------------------------------------------------------------------------
    //　月を移動してカレンダーを作成する：UAViewクラスから呼ばれる
    //--------------------------------------------------------------------------
    func createCalender(addMonth:Int){
        firstDateOfThisMonth = dtUtil.date(date: firstDateOfThisMonth, addMonths: addMonth)
        self.createDateList()
    }
    //--------------------------------------------------------------------------
    //当年を返す
    //--------------------------------------------------------------------------
    var year:Int{
        get{
            return dtUtil.intYear(date: firstDateOfThisMonth)
        }
    }
    //--------------------------------------------------------------------------
    //当年（和暦）を返す
    //--------------------------------------------------------------------------
    var yearOfWareki:Array<String> {
        get{
            return dtUtil.yearOfWareki(date: firstDateOfThisMonth)
        }
    }
    //--------------------------------------------------------------------------
    //当月を返す
    //--------------------------------------------------------------------------
    var month:Int{
        get{
            return dtUtil.intMonth(date: firstDateOfThisMonth)
        }
    }
    //--------------------------------------------------------------------------
    //カレンダーの最初の日
    //--------------------------------------------------------------------------
    var startOfCalendar:Int{
        get{
            return dateList[0].integerYearMonthDay
        }
    }
    //--------------------------------------------------------------------------
    //カレンダーの最後の日
    //--------------------------------------------------------------------------
    var endOfCalendar:Int{
        get{
            return dateList[dateList.count-1].integerYearMonthDay
        }
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付の年を返す
    //--------------------------------------------------------------------------
    func year(index: Int) -> Int {
        return dateList[index].year
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付の月を返す
    //--------------------------------------------------------------------------
    func month(index: Int) -> Int {
        return dateList[index].month
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付のを返す
    //--------------------------------------------------------------------------
    func day(index: Int) -> Int {
        return dateList[index].day
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付の曜日（コード）を返す
    //--------------------------------------------------------------------------
    func weekday(index: Int) -> Int {
        return dateList[index].dayOfWeek
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付が当日か否か
    //--------------------------------------------------------------------------
    func thisMonthFlag(index: Int) -> Bool {
        if dateList[index].monthType == MonthType.ThisMonth{
            return true
        }
        return false
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付が休日か否か
    //--------------------------------------------------------------------------
    func holidayFlag(index: Int) -> Bool {
        return dateList[index].isHolida
    }
    //--------------------------------------------------------------------------
    //指定のインデックスの日付の月タイプを返す
    //--------------------------------------------------------------------------
    func monthType(index: Int) -> MonthType {
        return dateList[index].monthType
    }
    //--------------------------------------------------------------------------
    // 日付の設定
    //--------------------------------------------------------------------------
    private func createDateList(){
        let format = DateFormatter()
        format.dateStyle = .medium
        
        dateList = [UACalendarDate]()
        let tableCnv = [7,1,2,3,4,5,6]
        //前月処理
        let weekOf1st = dtUtil.intWeekday(date: firstDateOfThisMonth)
        let preDays = tableCnv[weekOf1st - 1] - 1
        let preDate = dtUtil.date(date: firstDateOfThisMonth, addDays: -preDays)
        for i:Int in 0 ..< preDays{
            //日付オブジェクトの作成
            let udt = self.makeDate(date:dtUtil.date(date: preDate, addDays: i))
            udt.monthType = MonthType.PreMonth
            dateList.append(udt)
        }
        //当月処理
        let daysOfThisMonth = dtUtil.daysOfMonth(date: firstDateOfThisMonth)
        for i:Int in 0 ..< daysOfThisMonth{
            //日付オブジェクトの作成
            let udt = self.makeDate(date:dtUtil.date(date: firstDateOfThisMonth, addDays: i))
            udt.monthType = MonthType.ThisMonth
            if i == 0 {udt.isFirstday = true}
            if i == daysOfThisMonth-1 {udt.isLastday = true}
            dateList.append(udt)
        }
        //翌月処理
        let firstDateNext = dtUtil.date(date: firstDateOfThisMonth, addMonths: 1)
        let nextDays = (7 - (dateList.count % 7)) % 7
        for i:Int in 0 ..< nextDays{
            let udt = self.makeDate(date:dtUtil.date(date: firstDateNext, addDays: i))
            udt.monthType = MonthType.NextMonth
            dateList.append(udt)
        }
        //各インデックスを求める
        currentDateIndex = -1;
        daysOfCalender = dateList.count
        for i:Int in 0 ..< daysOfCalender{
            if dateList[i].isToday{
                //当日の位置
                currentDateIndex = i
            }
            if dateList[i].isFirstday{
                //月初日の位置
                firstDayIndex = i
            }
            if dateList[i].isLastday{
                //月末日の位置
                lastDayIndex = i
            }
        }
    }
    //--------------------------------------------------------------------------
    //日付オブジェクトを作成する
    //--------------------------------------------------------------------------
    func makeDate(date: Date)->UACalendarDate{
        let udt = UACalendarDate(date)
        //現在日の判定
        if dtUtil.isEqualDate(date1: date, date2: Date()){
            udt.isToday = true
        }else{
            udt.isToday = false
        }
        //休日の判定
        udt.isHolida = false
        let strYMD = String(format:"%d", udt.year*10000 + udt.month*100 + udt.day)
        let holidayName : String? = holidays[strYMD]
        if holidayName != nil{
            udt.isHolida = true
        }
        return udt
    }
}
