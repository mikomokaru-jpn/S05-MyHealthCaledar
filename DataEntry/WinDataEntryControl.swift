//------------------------------------------------------------------------------
//  WinDataEntryControl.swift
//------------------------------------------------------------------------------
import Cocoa
//定数
let upperNormal = 135
let lowerNormal = 85
//プロトコル宣言
protocol WinDataEntryControlDelegate: class  {
    func putDateToIemView()
}
class WinDataEntryControl: NSWindowController,
                           BPButtonDelegate,
                           BPValueViewDelegate,
                           BPAcceptButtonDelegate{
    //プロパティ
    var thisDate:UACalendarDate?        //対象日
    var btns:[BPButton] = []            //数値ボタン配列
    var dateLabel:BPLabel               //日付ラベル
    var upperView:BPValueView           //最高血圧入力エリア
    var lowerView:BPValueView           //最低血圧入力エリア
    var confirmCheck:BPAcceptButton     //確定チェックボックス
    var saveLowerValue:Int = 0          //最高血圧
    var saveUpperValue:Int = 0          //最低血圧
    var saveConfirmFlg = NSControl.StateValue.off   //確定フラグ
    var messageField:BPLabel            //メッセージ領域
    weak var delegate:WinDataEntryControlDelegate?  //デリゲート変数
    //xibファイル名の設定が必要
    //The name of the nib file that stores the window associated with the receiver. だそうだ
    override var windowNibName:NSNib.Name?  {
        return "WinDataEntry"
    }
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init(){
        dateLabel = BPLabel.init(point: CGPoint(x:15, y:15), fontSize: 22)
        upperView = BPValueView.init(frame: CGRect(x:17, y:70 ,width:50 ,height:30))
        lowerView = BPValueView.init(frame: CGRect(x:17, y:130 ,width:50 ,height:30))
        confirmCheck = BPAcceptButton.init(frame: CGRect(x:15, y:180 ,width:60 ,height:18))
        messageField = BPLabel.init(point: CGPoint(x:15, y:245), fontSize:12, color:NSColor.red)
        super.init(window: nil)
        //独自の初期処理
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    // Windowコントーラロード時
    //--------------------------------------------------------------------------
    override func windowDidLoad() {
        super.windowDidLoad()
        //背景色
        self.window?.contentView?.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    //--------------------------------------------------------------------------
    //初期設定
    //--------------------------------------------------------------------------
    private func _init(){
        let xPos:CGFloat = 83
        let yPos:CGFloat = 50;
        //数値ボタンの作成
        for i in 0..<10{
            let btn = BPButton.init(rect:CGRect(x:0, y:0, width:40, height:40),
                                    num: i, delegate: self)
            btns += [btn]
            self.window?.contentView?.addSubview(btn)
        }
        //数値ボタンの配置場所
        let span:CGFloat = 39;
        btns[7].frame.origin = CGPoint(x:xPos, y:yPos)
        btns[8].frame.origin = CGPoint(x:xPos+span, y:yPos)
        btns[9].frame.origin = CGPoint(x:xPos+span*2, y:yPos)
        btns[4].frame.origin = CGPoint(x:xPos, y:yPos+span)
        btns[5].frame.origin = CGPoint(x:xPos+span, y:yPos+span)
        btns[6].frame.origin = CGPoint(x:xPos+span*2, y:yPos+span)
        btns[1].frame.origin = CGPoint(x:xPos, y:yPos+span*2)
        btns[2].frame.origin = CGPoint(x:xPos+span, y:yPos+span*2)
        btns[3].frame.origin = CGPoint(x:xPos+span*2, y:yPos+span*2)
        btns[0].frame.origin = CGPoint(x:xPos, y:yPos+span*3)
        //クリアボタンの作成
        let rect = CGRect(x:xPos+span, y:yPos+span*3, width:79, height:40)
        let btnClear = BPButton.init(rect:rect, num: -1, delegate: self)
        self.window?.contentView?.addSubview(btnClear)
        //閉じるボタンの作成
        let btnClose = NSButton.init(title: "登録",
                                    target: self,
                                    action: #selector(self.formClose))
        btnClose.frame = CGRect(x:110, y:210, width:90, height:40)
        btnClose.setButtonType(NSButton.ButtonType.momentaryPushIn)
        btnClose.bezelStyle = NSButton.BezelStyle.rounded
        self.window?.contentView?.addSubview(btnClose)
        //キャンセルボタンの作成
        let btnCancel = NSButton.init(title: "キャンセル",
                                     target: self,
                                     action: #selector(self.formCancel))
        btnCancel.frame = CGRect(x:15, y:210, width:90, height:40)
        btnCancel.setButtonType(NSButton.ButtonType.momentaryPushIn)
        btnCancel.bezelStyle = NSButton.BezelStyle.rounded
        self.window?.contentView?.addSubview(btnCancel)
        //日付ラベルの追加
        dateLabel.text = ""
        self.window?.contentView?.addSubview(dateLabel)
        //最高血圧ラベルの追加
        let upperLabel = BPLabel.init(point: CGPoint(x:15, y:50), fontSize: 12)
        upperLabel.text = "最高血圧"
        self.window?.contentView?.addSubview(upperLabel)
        //最高血圧入力エリア
        upperView.delegate = self
        self.window?.contentView?.addSubview(upperView)
        //最低血圧ラベルの追加
        let lowerLabel = BPLabel.init(point: CGPoint(x:15, y:110), fontSize: 12)
        lowerLabel.text = "最低血圧"
        self.window?.contentView?.addSubview(lowerLabel)
        //最低血圧入力エリア
        lowerView.delegate = self
        self.window?.contentView?.addSubview(lowerView)
        //確定フラグ
        confirmCheck.setButtonType(NSButton.ButtonType.switch)
        confirmCheck.title = "確定"
        confirmCheck.delegate = self
        self.window?.contentView?.addSubview(confirmCheck)
        //メッセージ領域
        messageField.text = " " //1文字の空白が必要
        self.window?.contentView?.addSubview(messageField)
    }
    //--------------------------------------------------------------------------
    //血圧を更新してフォームを閉じる
    //--------------------------------------------------------------------------
    @objc private func formClose(){
        if saveLowerValue == lowerView.value &&
           saveUpperValue == upperView.value &&
           saveConfirmFlg == confirmCheck.state{
            //値の変更がないので何もしない（DB読み込み時と値が同じ）
        }else{
            //入力チェック
            if lowerView.value > upperView.value{
                messageField.text = "値が不正です。最低≧最高"
                messageField.needsDisplay = true
                return
            }
            //DB更新
            //let cmd = "http://192.168.11.3:5000/sql_w10"
            let cmd = "http://localhost:5000/sql_w10"
            //let cmd = "http://192.168.11.3/doc_health_calendar/php/sql_w10.php"
            //let cmd = "http://localhost/doc_health_calendar/php/sql_w10.php"
            let param = String(format:"id=%ld&date=%ld&lower=%ld&upper=%ld&confirm=%ld",
                               500 ,thisDate!.integerYearMonthDay,
                               lowerView.value, upperView.value, confirmCheck.state.rawValue)
            //DBレコードの取得
            let list = UAServerRequest.postSync(urlString:cmd, param:param)
            //受信データのキャスト  [Int]
            guard let records = list as? [Int] else{
                print("cast error")
                return
            }
            //戻り値のチェック
            if records[0] != 1 {
                print ("DB update error")
                return
            }
            //カレンダービューの再表示
            if delegate != nil{
                delegate?.putDateToIemView()
            }
        }
        //シートを閉じる
        self.window?.sheetParent?.endSheet(self.window!,
                                           returnCode: NSApplication.ModalResponse.cancel)
    }
    //--------------------------------------------------------------------------
    //フォームを閉じる
    //--------------------------------------------------------------------------
    @objc private func formCancel(){
        self.window?.sheetParent?.endSheet(self.window!,
                                           returnCode: NSApplication.ModalResponse.cancel)
    }
    //--------------------------------------------------------------------------
    //キーを押した
    //--------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51{
            self.updateNumber(num: -1)
            return
        }
        //数値の判定：正規表現パターンの定義
        guard let regex = try? NSRegularExpression.init(pattern:"[0-9]",
                                                        options:[]) else{
            return
        }
        guard let ch = event.characters else{
            return
        }
        let result = regex.matches(in: ch, options: [], range: NSMakeRange(0, ch.count))
        if result.count > 0{
            //0から9の数字である
            self.updateNumber(num: Int(ch)!)
        }else if ch.caseInsensitiveCompare("c") == .orderedSame{
            self.updateNumber(num: -1)
        }
    }
    //--------------------------------------------------------------------------
    //キャンセル処理 escキー押下時に呼ばれるNSResponderのcancel:アクションを実装する。
    //--------------------------------------------------------------------------
    @objc func cancel(_ sender: Any?) {
        close()
    }
    //--------------------------------------------------------------------------
    // 血圧データの取得
    //--------------------------------------------------------------------------
    func getData(date:UACalendarDate){
        thisDate = date //対象日
        //let cmd = "http://192.168.11.3:5000/sql_r20"
        let cmd = "http://localhost:5000/sql_r20"
        //let cmd = "http://192.168.11.3/doc_health_calendar/php/sql_r20.php"
        //let cmd = "http://localhost/doc_health_calendar/php/sql_r20.php"

        let param = String(format:"id=%ld&date=%ld",500 ,date.integerYearMonthDay)
        //DBレコードの取得
        let list = UAServerRequest.postSync(urlString:cmd, param:param)
        //受信データのキャスト  Any -> [[String:Int]]
        guard let records = list as? [[String:Int]] else{
            print("cast error")
            return
        }
        if records.count < 1{
            upperView.value = 0
            lowerView.value = 0
            confirmCheck.state =  NSControl.StateValue(rawValue: 0) //これ面倒
        }else{
            //辞書の要素のアンンラップ（冗長だな）
            guard let upper = records[0]["upper"],
                let lower = records[0]["lower"],
                let confirm = records[0]["confirm"] else{
                    print("error upper or lower is nill")
                    return
            }
            upperView.value = upper
            lowerView.value = lower
            confirmCheck.state =  NSControl.StateValue(rawValue: confirm) //これ面倒
        }
        //変更前の値を保存
        saveLowerValue = lowerView.value
        saveUpperValue = upperView.value
        saveConfirmFlg = confirmCheck.state
        //日付ラベル
        dateLabel.text = String(format:"%ld年%ld月%ld日(%@)",
                                       date.year, date.month, date.day, date.strYobi)
        //ビューの再表示
        dateLabel.needsDisplay = true
        upperView.needsDisplay = true
        lowerView.needsDisplay = true
        messageField.text = " "
        messageField.needsDisplay = true
        //カーソルの初期位置
        self.window?.makeFirstResponder(upperView)
    }
    //--------------------------------------------------------------------------
    // BtnCalc Delegate 数字ボタンをクリックした
    //--------------------------------------------------------------------------
    func clickNumber(_ btn : BPButton) {
        self.updateNumber(num: btn.number)
    }
    //--------------------------------------------------------------------------
    // 数値の入力
    //--------------------------------------------------------------------------
    private func updateNumber(num: Int){
        let responder:NSObject? = self.window?.firstResponder
        guard let res = responder else {
            return
        }
        //クラスの判定
        if type(of:res) == BPValueView.self{
            let valueView = responder as! BPValueView
            if valueView.initialInput == true{
                //カーソルが移った直後に値を入力したときは、初期入力とする。
                valueView.value = 0
                valueView.initialInput = false
            }
            //入力値の判定
            if num == -1{
               //Clearボタン
                valueView.value = 0
            }else{
                //値の追加。最大桁数は3桁
                valueView.value = valueView.value * 10 + num
                if valueView.value > 99{
                    //3桁以上の入力は次の値入力ビューに移る
                    self.changeView(valueView)
                }
            }
            valueView.needsDisplay = true
        }else{
            print("aaaaaa")
        }
    }
    //--------------------------------------------------------------------------
    // タブキーによるファーストレスポンダの移動（BPValueViewDelegate）
    //--------------------------------------------------------------------------
    func changeView(_ fromView:BPValueView){
        if fromView == upperView{
            self.window?.makeFirstResponder(lowerView)
        }else if fromView == lowerView{
            self.window?.makeFirstResponder(confirmCheck)
        }
    }
    //--------------------------------------------------------------------------
    //確定チェックボックスの反転（BPAcceptButtonDelegate）
    //--------------------------------------------------------------------------
    func changeCheck(_ event:NSEvent){
        if event.keyCode == 48{ //tab
            self.window?.makeFirstResponder(upperView)
        }else if event.keyCode == 36{ //return
            if confirmCheck.state == NSControl.StateValue.on{
                confirmCheck.state = NSControl.StateValue.off
            }else{
                confirmCheck.state = NSControl.StateValue.on
            }
        }
    }
    
    
  
}
