//------------------------------------------------------------------------------
//  BPValueView.swift：血圧の入力フィールド
//------------------------------------------------------------------------------
import Cocoa
//プロトコル宣言
protocol BPValueViewDelegate: class {
    func changeView(_ fromView:BPValueView)
}
class BPValueView: NSView {
    var _value:Int = 0               //値
    var _preValue:Int = 0            //更新前の値
    var aString = NSMutableAttributedString(string:"") //値（文字列）
    var initialInput:Bool = true    //初期入力フラグ
    weak var delegate: BPValueViewDelegate?  = nil  //デリゲート変数
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    //ビューの再表示
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //血圧値の表示
        let x = (dirtyRect.size.width / 2) - (aString.size().width / 2)
        let y = (dirtyRect.size.height / 2) - (aString.size().height / 2)
        aString.draw(at: CGPoint(x:x, y:y))
        if self.window?.firstResponder == self{
            self.selectedColor()
        }else{
            self.defaultColor()
        }
    }
    //--------------------------------------------------------------------------
    //ファーストレスポンダーを受け入れる
    //--------------------------------------------------------------------------
    override var acceptsFirstResponder:Bool {
        get {
            return true
        }
    }
    //--------------------------------------------------------------------------
    //ファーストレスポンダーになった
    //--------------------------------------------------------------------------
    override func becomeFirstResponder()->Bool {
        initialInput = true
        self.selectedColor()
        return true
    }
    //--------------------------------------------------------------------------
    //ファーストレスポンダーを放棄する
    //--------------------------------------------------------------------------
    override func resignFirstResponder()->Bool {
        _preValue = _value
        self.defaultColor()
        return true
    }
    //--------------------------------------------------------------------------
    //アクセッサー
    //--------------------------------------------------------------------------
    var value:Int{
        get{
            return _value
        }
        set(inValue){
            _value = inValue
            let strValue = String(format:"%ld",inValue)
            aString = UATextAttribute.makeAttributedString(string: strValue, size: 19)
        }
    }
    //--------------------------------------------------------------------------
    //キーボードのキーを押した
    //--------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        //print("keyDown \(event.keyCode)")
        if event.keyCode == 48{
            delegate?.changeView(self)
        }else{
            super.keyDown(with: event)
        }
    }
    //--------------------------------------------------------------------------
    //選択中の色にする
    //--------------------------------------------------------------------------
    private func selectedColor(){
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.black.cgColor
        self.layer?.backgroundColor = NSColor.yellow.cgColor
    }
    //--------------------------------------------------------------------------
    //非選択中の色にする
    //--------------------------------------------------------------------------
    private func defaultColor(){
        self.layer?.borderWidth = 1
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
}
