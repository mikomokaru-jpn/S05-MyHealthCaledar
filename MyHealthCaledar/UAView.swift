//------------------------------------------------------------------------------
//  UAView.swift aa
//------------------------------------------------------------------------------
import Cocoa

extension Int {
    var boolValue: Bool { return self != 0 }
}
class UAView: NSView, UAItemViewDelegate, WinDataEntryControlDelegate {
    //プロパティ
    var currentDate:Date                            //現在日
    var thisFirstDate:Date                          //当月初日
    var dtUtil:UADateUtil                           //日付操作ユーティリティオブジェクト
    var fontStandard: NSFont?                       //日付フォント（標準）
    var fontSmall: NSFont?                          //日付フォント（小）
    var itemViewList = [UAItemView]()               //日付ビューリスト
    var calendar: UACalendar =  UACalendar.init()   //カレンダーオブジェクト
    var headerView: BPLabel                         //年月見出し
    var selectedItemIndex:Int = 0                   //選択中の日付ビュー
    var openButton: NSButton                        //血圧入力フォームを開く
    var displayButton: NSButton                     //一覧表示フォームを開く
    var dataEntryControl: WinDataEntryControl       //血圧入力フォーム
    var resultControl: WinResultControl             //一覧表示フォーム
    //定数
    let HEIGHT:CGFloat = 330.0;
    let YofButtton:CGFloat = 282.0;
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {return true}
    }
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init(point: NSPoint){
        //プロパティの初期化
        dtUtil = UADateUtil.dateManager
        currentDate = Date() //現在日
        thisFirstDate = dtUtil.firstDate(date: currentDate) //当月初日
        //見出し
        headerView = BPLabel.init(point:NSMakePoint(50,10), fontSize:22);
        //入力ボタン
        openButton = NSButton.init()
        //一覧表示ボタン
        displayButton = NSButton.init()
        //血圧入力フォームオブジェクトの作成
        dataEntryControl = WinDataEntryControl()
        //一覧表示フォームオブジェクトの作成
        resultControl = WinResultControl ()
        //**** super classオブジェクトの作成 ****
        let myFrame = NSMakeRect(point.x, point.y, 300, 0)
        super.init(frame: myFrame)
        //当月カレンダーの作成（現在日を元に）
        calendar = UACalendar()
        //サブビュー（コントロール、日付ビュー）の作成と配置
        self.arrangeControlViews()
        //日付ビューに日付をセットする
        self.putDateToIemView()
        selectedItemIndex = calendar.currentDateIndex
        //血圧入力フォームオブジェクトのデリゲート設定
        dataEntryControl.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    // カレンダービューの再描画
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        window?.makeFirstResponder(itemViewList[selectedItemIndex])
    }
    //--------------------------------------------------------------------------
    //前月へボタン
    //--------------------------------------------------------------------------
    @objc func clickPreButton(){
        calendar.createCalender(addMonth: -1)
        self.putDateToIemView()
        selectedItemIndex = calendar.lastDayIndex
        self.needsDisplay = true
    }
    //--------------------------------------------------------------------------
    //翌月へボタン
    //--------------------------------------------------------------------------
    @objc func clickNextButton(){
        calendar.createCalender(addMonth: 1)
        self.putDateToIemView()
        selectedItemIndex = calendar.firstDayIndex
        self.needsDisplay = true
    }
    //--------------------------------------------------------------------------
    //キーを押して日付を移動する
    //--------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 43: //<
                if event.modifierFlags.contains(.shift){
                    self.clickPreButton() //前月
                }
            case 47: //>
                if event.modifierFlags.contains(.shift){
                    self.clickNextButton() //翌月
                }
            default: break
        }
    }
    //--------------------------------------------------------------------------
    //血圧入力シートを開く
    //--------------------------------------------------------------------------
    @objc func clickOpen(){
        //descriptionを表示する
        print("a \(window?.description ?? "window is nil")")
        print("b \(String(describing: dataEntryControl.window))")
        //データを取得する
        dataEntryControl.getData(date:calendar.dateList[selectedItemIndex])
        //シートを開く
        window?.beginSheet(dataEntryControl.window!, completionHandler:{(response) in
            //コールバック処理を記述する
        })
    }
    //--------------------------------------------------------------------------
    //一覧表示シートを開く
    //--------------------------------------------------------------------------
    @objc func clickDisplay(){
        
        let calendarRect = window?.frame
        let chartPoint = CGPoint(x:(calendarRect?.origin.x)! + (calendarRect?.size.width)!,
                                 y:(calendarRect?.origin.y)! + (calendarRect?.size.height)!)
        //ウィンドウの表示
        resultControl.showWindow(self)
        resultControl.window?.setFrameOrigin(chartPoint)
        //ウィンドウコントローラのプロパティを設定する
        resultControl.recordList = self.makeChartList() //月間データ
        resultControl.header = headerView.text
        resultControl.arrangeData()
    }
    //--------------------------------------------------------------------------
    //サブビュー（コントロール、日付ビュー）の作成と配置
    //--------------------------------------------------------------------------
    func arrangeControlViews(){
        //super classのプロパティの参照はここから
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.addSubview(headerView)
        //前月へボタン
        let preButton: NSButton = NSButton.init(title: "<",
                                       target: self,
                                       action: #selector(self.clickPreButton))
        preButton.frame = NSMakeRect(5,8,30,35)
        preButton.setButtonType(.momentaryPushIn)
        preButton.bezelStyle = .texturedSquare
        self.addSubview(preButton)
        //翌月へボタン
        let nextButton: NSButton = NSButton.init(title: ">",
                                        target: self,
                                        action: #selector(self.clickNextButton))
        nextButton.frame = NSMakeRect(265,8,30,35)
        nextButton.setButtonType(.momentaryPushIn)
        nextButton.bezelStyle = .texturedSquare
        self.addSubview(nextButton)
        //曜日見出し
        let youbis = ["月","火","水","木","金","土","日"]
        for i in 0..<youbis.count {
            let youbiView = BPLabel.init(point:NSMakePoint(CGFloat(21+(40*i)),48), fontSize:16)
            youbiView.text = youbis[i]
            self.addSubview(youbiView)
        }
        //日付ビューのグリッド(6行×7列)を作成してカレンダービューへ追加する
        let CELL_WIDTH: CGFloat = 40.0
        let CELL_HEIGHT: CGFloat = 40.0
        var index = 0
        for i in 1...6{
            for j in 1...7{
                let x = CGFloat((j-1) % 7) * CELL_WIDTH + 10
                let y = 70 + (CGFloat(i-1) * CELL_HEIGHT)
                let rect = NSMakeRect(x, y, CELL_WIDTH, CELL_HEIGHT)
                let item = UAItemView.init(frame: rect)
                item.delegate = self
                itemViewList.append(item)
                self.addSubview(item)
                index += 1
            }
        }
        //入力ボタン
        openButton.title = "入力（⌘o）"
        openButton.target = self
        openButton.action = #selector(self.clickOpen)
        openButton.frame = NSMakeRect(10,282,130,35)
        openButton.setButtonType(.momentaryPushIn)
        openButton.bezelStyle = .texturedSquare
        openButton.keyEquivalentModifierMask = .command
        openButton.keyEquivalent = "o"
        self.addSubview(openButton)
        //一覧表示ボタン
        displayButton.title = "一覧表示（⌘d）"
        displayButton.target = self
        displayButton.action = #selector(self.clickDisplay)
        displayButton.frame = NSMakeRect(158,282,130,35)
        displayButton.setButtonType(.momentaryPushIn)
        displayButton.bezelStyle = .texturedSquare
        displayButton.keyEquivalentModifierMask = .command
        displayButton.keyEquivalent = "d"
        self.addSubview(displayButton)
    }
    //--------------------------------------------------------------------------
    //日付ビューに日付をセットする（イニシャライザ、または前月/翌月の移動処理から呼ばれる）
    //--------------------------------------------------------------------------
    func putDateToIemView(){
        let currentDaycolor:CGColor =
            NSColor.init(red: 200/255, green: 220/255, blue: 240/255, alpha: 1).cgColor
        let wareki:Array = calendar.yearOfWareki
        headerView.text = String(format: "%ld年%ld月(%@%@)",
                          calendar.year, calendar.month, wareki[0], wareki[1])
        headerView.needsDisplay = true
        //血圧データの取得
        //let cmd = "http://192.168.11.3:5000/sql_r10" //node.js 
        //let cmd = "http://localhost:5000/sql_r10"
        let cmd = "http://192.168.11.3/doc_health_calendar/php/sql_r10.php"
        //let cmd = "http://localhost/doc_health_calendar/php/sql_r10.php"
        let param = String(format:"id=%ld&from_date=%ld&to_date=%ld",
                           500, calendar.startOfCalendar, calendar.endOfCalendar)
        let list = UAServerRequest.postSync(urlString:cmd, param:param)
        //受信データのキャスト  Any -> [[String:Int]]
        guard let bloodPressureList = list as? [[String:Int]] else{
            print("cast error")
            return
        }
        //日付のセット
        for i in 0..<itemViewList.count{
            let item = itemViewList[i]; //日付ビュー
            if i < calendar.daysOfCalender{
                item.index = i
                item.aString = self.attributedDay(index: i)
                if i == calendar.currentDateIndex{
                    item.myBackgroundColor = currentDaycolor
                }else{
                    item.myBackgroundColor = NSColor.white.cgColor
                }
                item.upper = 0
                item.lower = 0
                item.confirm = false
                for record in bloodPressureList {
                    if calendar.dateList[i].integerYearMonthDay == record["date"]{
                        //辞書の要素のアンンラップ
                        guard let upper = record["upper"],
                              let lower = record["lower"],
                              let confirm = record["confirm"] else{
                            print("error upper or lower is nill")
                            return
                        }
                        item.upper = upper
                        item.lower = lower
                        item.confirm = confirm.boolValue
                        break
                    }
                }
            }else{
                item.index = -1 //hidden
                item.isHidden = true
            }
            item.needsDisplay = true
        }
        //ビューの大きさを変える
        if (calendar.daysOfCalender > 35){
            //6週
            self.frame.size.height = HEIGHT + 40.0
            openButton.frame.origin.y = YofButtton + 40.0
            displayButton.frame.origin.y = YofButtton + 40.0

        }else{
            //5週
            self.frame.size.height = HEIGHT
            openButton.frame.origin.y = YofButtton
            displayButton.frame.origin.y = YofButtton
        }
    }
    //--------------------------------------------------------------------------
    //文字列・日の作成
    //--------------------------------------------------------------------------
    private func attributedDay(index: Int)->NSAttributedString{
        let fontName = "Arial"
        var size: CGFloat = 0
        let attributes: [NSAttributedString.Key : Any]
        if calendar.thisMonthFlag(index: index){
            size = 24
        }else{
            size = 16
        }
        if calendar.weekday(index: index) == 1 ||
            calendar.holidayFlag(index: index){
            //日曜日・休日
            attributes = UATextAttribute.makeAttributes(name: fontName,
                                                        size: size, color: NSColor.red)
        }else if calendar.weekday(index: index) == 7{
            //土曜日
            attributes = UATextAttribute.makeAttributes(name: fontName,
                                                        size: size, color: NSColor.blue)
        }else{
            //平日
            attributes = UATextAttribute.makeAttributes(name: fontName,
                                                            size: size, color: NSColor.black)
        }
        //属性付き文字列の作成
        let day = String(format:"%ld", calendar.day(index: index))
        let atrDay = NSAttributedString.init(string: day, attributes: attributes)
        return atrDay
    }
    //--------------------------------------------------------------------------
    //デリゲートメソッド：日付ビューの移動
    //--------------------------------------------------------------------------
    func moveDate(index: Int, to:MoveTYpe){
        switch to {
        case .LEFT:
            if selectedItemIndex > 0{
                //前日へ
                selectedItemIndex -= 1
            }else{
                var addition = 0
                //前月へ
                //カーソルの位置
                if !calendar.thisMonthFlag(index: selectedItemIndex){
                    addition = 7;
                }
                calendar.createCalender(addMonth: -1)   //前月のカレンダーの作成
                self.putDateToIemView()                 //日付ビューに日付をセットする
                selectedItemIndex = calendar.daysOfCalender - 1 - addition
            }
        case .RIGHT:
            if selectedItemIndex < calendar.daysOfCalender - 1 {
                //翌日へ
                selectedItemIndex += 1
            }else{
                var addition = 0
                //翌月へ
                //カーソルの位置
                if !calendar.thisMonthFlag(index: selectedItemIndex){
                    addition = 7;
                }
                calendar.createCalender(addMonth: 1)   //翌月のカレンダーの作成
                self.putDateToIemView()                //日付ビューに日付をセットする
                selectedItemIndex = addition
            }
        case .DOWN:
            if selectedItemIndex < calendar.daysOfCalender - 7{
                selectedItemIndex += 7
            }
        case .UP:
            if selectedItemIndex >= 7{
                selectedItemIndex -= 7
            }
        default:
            selectedItemIndex = index
        }
        self.needsDisplay = true
    }
    //--------------------------------------------------------------------------
    //1ヶ月の血圧レコードを作成する。
    //--------------------------------------------------------------------------
    func makeChartList()->[RERecord]{
        var recordList: [RERecord] = []      //血圧レコードのリスト
        for itemView in itemViewList{
            if itemView.isHidden{
                continue     //非表示の日付とき
            }
            //日付オブジェクトの取得
            let date:UACalendarDate = calendar.dateList[itemView.index]
            if date.monthType == .ThisMonth {
                //当月
                let record = RERecord.init()
                record.ID = 500
                record.integerYearMonthDay = date.integerYearMonthDay
                record.day = date.day
                record.yobi = date.strYobi
                record.dayType = date.dayType
                record.isHoliday = date.isHolida
                if itemView.confirm{
                    record.lowerValue = itemView.lower
                    record.upperValue = itemView.upper
                }else{
                    record.lowerValue = 0
                    record.upperValue = 0
                }
                record.confirm = itemView.confirm
                recordList.append(record)
            }
        }
        return recordList
    }
}
