//------------------------------------------------------------------------------
//  RERecord.swift：表示用血圧データ
//------------------------------------------------------------------------------
import Cocoa

class RERecord: NSObject {
    var ID:Int = 0                      //個人ID
    var upperValue: Int = 0             //最高血圧
    var lowerValue: Int = 0             //最低血圧
    var confirm: Bool = false           //確定フラグ
    var integerYearMonthDay: Int = 0    //年月日
    var day: Int = 0                    //日
    var yobi: String = ""               //曜日
    var dayType: DayType = .Weekday     //日タイプ
    var isHoliday: Bool = false         //休日フラグ
}
