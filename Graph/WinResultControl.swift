//------------------------------------------------------------------------------
//  WinResultControl.swift
//------------------------------------------------------------------------------
import Cocoa


class WinResultControl: NSWindowController, NSWindowDelegate {
    var matrix: [[REElementView]] = []      //要素ビューのリスト
    private var _recordList:[RERecord] = [] //月間データ
    var header: String = ""                 //年月見出し
    var headerView: REHeaderView            //年月見出しビュー
    //外形寸法
    let window_height:CGFloat = 720         //ウィンドウの高さ
    let header_height:CGFloat = 50          //ヘッダビューの高さ
    let cell_height:CGFloat = 20            //明細行の高さ
    let scroll_width:CGFloat = 480          //スクロールビューの幅
    let main_width:CGFloat = 460            //メインビューの幅
    let graph_width:CGFloat = 299           //グラフ領域の幅
    //--------------------------------------------------------------------------
    //xibファイル名の設定
    //--------------------------------------------------------------------------
    override var windowNibName:NSNib.Name?  {
        return "WinResult"
    }
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init() {
        headerView = REHeaderView.init(frame: CGRect.zero)
        super.init(window: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    //レコードリスト
    //--------------------------------------------------------------------------
    var recordList:[RERecord]{
        get {
            return _recordList
        }
        set(newRecordList){
            _recordList = newRecordList
        }
    }
    //--------------------------------------------------------------------------
    //明細行の高さの合計
    //--------------------------------------------------------------------------
    var main_height:CGFloat{
        get {return cell_height * 31 + 1}
    }
    //--------------------------------------------------------------------------
    //ウィンドウロード時
    //--------------------------------------------------------------------------
    override func windowDidLoad() {
        super.windowDidLoad()
        //ウィンドウの高さ
        guard let winRect = self.window?.frame else {
            return
        }
        let newWinRect = CGRect(x:winRect.origin.x, y:winRect.origin.y,
                             width: winRect.size.width, height: window_height)
        self.window?.setFrame(newWinRect, display: true)
        
        self.window?.contentView?.layer?.backgroundColor = NSColor.white.cgColor
        //ヘッダビューの追加
        guard let viewRect = self.window?.contentView?.frame else {
            return
        }
        headerView.frame = CGRect(x:0, y:0, width:viewRect.width, height:viewRect.height)
        self.window?.contentView?.addSubview(headerView)
        //スクロールビューの追加
        let scrollView = NSScrollView.init(frame: CGRect(x:10, y:header_height,
                                                         width:scroll_width, height:main_height + 20 ))
        self.window?.contentView?.addSubview(scrollView)
        scrollView.borderType = NSBorderType.noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.maxXMargin, .height] //16(0b10000) + 4(0b100)
        //メインビューの追加
        let mainView = REMainView.init(
            frame: CGRect(x:0, y:0, width:main_width, height:main_height), graphWidth: 299)
        scrollView.documentView = mainView //注目！
        //アイテムビューの生成とメインビューへの格納
        for _ in 0..<31{
            var rows:[REElementView] = []
            for _ in 0..<7{
                let aView = REElementView.init(frame: CGRect.zero)
                mainView.addSubview(aView)
                rows.append(aView)
            }
            matrix.append(rows)
        }
        mainView.scroll(CGPoint.zero) //スクロールの位置指定
    }
    //--------------------------------------------------------------------------
    //キャンセル処理 escキー押下時に呼ばれるNSResponderのcancel:アクションを実装する。
    //--------------------------------------------------------------------------
    @objc func cancel(_ sender: Any?) {
        close()
    }
    //--------------------------------------------------------------------------
    //アイテムビューにデータをセットする
    //--------------------------------------------------------------------------
    func arrangeData(){
        var cellWidthList: [CGFloat] = [40, 30, 45, 45, 0, 0, 0]
        var yPos: CGFloat = 0
        var index = 0
        //年月見出し
        headerView.textOfDate = header
        headerView.needsDisplay = true
        //1ヶ月分の血圧データ
        for record in recordList{
            cellWidthList[4] = (CGFloat)(record.lowerValue) / 200.0 * graph_width
            cellWidthList[5] = (CGFloat)(record.upperValue) / 200.0 * graph_width
                                - cellWidthList[4]
            cellWidthList[6] = graph_width - cellWidthList[4] - cellWidthList[5]
            let elements = matrix[index]
            var xPos: CGFloat = 0
            //要素の位置の決定
            for i in 0..<7{
                elements[i].frame = CGRect(x:xPos, y:yPos,
                                           width:cellWidthList[i] + 1.0, height:cell_height + 1.0)
                xPos += cellWidthList[i]
            }
            //日付のセット
            if record.day == 0{
                elements[0].text = ""
            }else{
                elements[0].text = String(format:"%ld", record.day)
            }
            elements[0].align = .right
            elements[0].attribute = UATextAttribute.makeAttributes(size: 12)
            //曜日のセット
            elements[1].text = record.yobi
            elements[1].align = .center
            if record.isHoliday || record.dayType == .Sunday{
                elements[1].attribute =
                    UATextAttribute.makeAttributes(size: 12, color: NSColor.red)
            }else if record.dayType == .Saturday {
                elements[1].attribute =
                    UATextAttribute.makeAttributes(size: 12, color: NSColor.blue)
            }else{
                elements[1].attribute =
                    UATextAttribute.makeAttributes(size: 12)
            }
            //最低血圧のセット
            if record.lowerValue == 0{
                elements[2].text = ""
            }else{
                elements[2].text = String(format:"%ld", record.lowerValue)
                if record.lowerValue > lowerNormal{
                    elements[2].attribute = UATextAttribute.makeAttributes(color: NSColor.red)
                }else{
                    elements[2].attribute = UATextAttribute.makeAttributes(color: NSColor.black)
                }
            }
            elements[2].align = .right
            //最高血圧のセット
            if record.upperValue == 0{
                elements[3].text = ""
            }else{
                elements[3].text = String(format:"%ld", record.upperValue)
                if record.upperValue > upperNormal{
                    elements[3].attribute = UATextAttribute.makeAttributes(color: NSColor.red)
                }else{
                    elements[3].attribute = UATextAttribute.makeAttributes(color: NSColor.black)
                }
            }
            elements[3].align = .right
            //棒グラフの色
            if record.lowerValue > lowerNormal{
                //下が高い
                elements[4].backgroundColor =
                    NSColor.init(calibratedRed: 1.0, green: 0.4, blue: 0.4, alpha: 0.6)
            }else{
                //下の正常
                elements[4].backgroundColor =
                    NSColor.init(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 0.2)
            }
            if record.upperValue > upperNormal{
                //上が高い
                elements[5].backgroundColor =
                    NSColor.init(calibratedRed: 1.0, green: 0.4, blue: 0.4, alpha: 0.9)
            }else{
                //上の正常
                elements[5].backgroundColor =
                    NSColor.init(calibratedRed: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
            }
            yPos = cell_height * (CGFloat)(index + 1)
            //再描画
            for element in elements{
                element.needsDisplay = true
            }
            index += 1
        }
    }
    //--------------------------------------------------------------------------
    //ウィンドウの大きさを固定する
    //--------------------------------------------------------------------------
    func windowWillResize(_ sender: NSWindow,
                          to frameSize: NSSize) -> NSSize{
        var theSize = frameSize
        if frameSize.width != 500{
            theSize.width = 500
        }
        if frameSize.height < 120{
            theSize.height = 120;
        }else if frameSize.height > window_height {
            theSize.height = window_height
        }
        return theSize;
    }
}
