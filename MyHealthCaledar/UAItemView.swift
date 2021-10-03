//------------------------------------------------------------------------------
//  UAItemView.swift
//------------------------------------------------------------------------------
import Cocoa

enum MoveTYpe: Int{
    case THIS = 0
    case RIGHT = 1
    case LEFT = 2
    case DOWN = 3
    case UP = 4
}
//プロトコル宣言
protocol UAItemViewDelegate: class  {
    func moveDate(index: Int, to:MoveTYpe)
    func clickOpen()
}
class UAItemView: NSView {
    var index: NSInteger = 0                                //インデックス
    var aString: NSAttributedString?                        //表示文字列
    var myBackgroundColor: CGColor?                         //背景色
    var myBorderWidth: CGFloat = 0.5                        //枠線の太さ
    var myBorderColor: CGColor = NSColor.lightGray.cgColor  //枠線の色
    weak var delegate: UAItemViewDelegate?  = nil           //デリゲート
    var upper: Int = 0;                                     //最高血圧
    var lower: Int = 0;                                     //最低血圧
    var confirm: Bool = false                               //確定フラグ
    //--------------------------------------------------------------------------
    //ビューの再表示
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if aString == nil{ return }
        if (index < 0){
            //月末一週間を非表示
            self.isHidden = true;
            return;
        }
        //初期値
        let path1 = NSBezierPath.init()
        path1.appendRect(CGRect(x:0, y:0,
                                width:self.frame.size.width,
                                height:self.frame.size.height))
        NSColor.white.set()
        path1.stroke()
        //日付の表示
        self.isHidden = false;
        let x = (self.frame.size.width/2)-(aString!.size().width/2)
        let y = (self.frame.size.height/2)-(aString!.size().height/2)
        aString?.draw(at: NSMakePoint(x, y)) //? is Optional Chaining
        //形状の属性
        self.layer?.borderWidth = myBorderWidth
        self.layer?.borderColor = myBorderColor
        self.layer?.backgroundColor = myBackgroundColor
        //血圧入力済みの印
        if confirm{
            let path2 = NSBezierPath.init()
            path2.appendOval(in: NSMakeRect((self.frame.size.width/2-17),
                                            (self.frame.size.height/2-17), 34, 34))
            NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).set()
            path2.stroke()
        }
    }
    //--------------------------------------------------------------------------
    // ファーストレスポンダーになった
    //--------------------------------------------------------------------------
    override func becomeFirstResponder() -> Bool {
        myBorderWidth = 2.5
        myBorderColor = NSColor.blue.cgColor
        self.needsDisplay = true
        return true
    }
    //--------------------------------------------------------------------------
    // ファーストレスポンダーを外れた
    //--------------------------------------------------------------------------
    override func resignFirstResponder() -> Bool {
        myBorderWidth = 0.5
        myBorderColor = NSColor.lightGray.cgColor
        self.needsDisplay = true
        return true
    }
    //--------------------------------------------------------------------------
    //日付をクリックして日付を移動する：デリゲートする
    //--------------------------------------------------------------------------
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2{
            delegate?.clickOpen()
        }else{
            delegate?.moveDate(index: self.index, to: .THIS)
        }
    }
    //--------------------------------------------------------------------------
    //キーを押して日付を移動する：デリゲートする
    //--------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:                   //left
            delegate?.moveDate(index: self.index, to: .LEFT)
        case 124, 48:               //right, tab
            delegate?.moveDate(index: self.index, to: .RIGHT)
        case 125:                   //down
            delegate?.moveDate(index: self.index, to: .DOWN)
        case 126:                   //up
            delegate?.moveDate(index: self.index, to: .UP)
        case 36:                    //return
            delegate?.clickOpen()
        default:
            super.keyDown(with: event)
        }
    }
}

