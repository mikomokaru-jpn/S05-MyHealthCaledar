//------------------------------------------------------------------------------
//  BPLabel.swift
//------------------------------------------------------------------------------
import Cocoa
class BPLabel: NSView {
    var _text = NSMutableAttributedString.init(string: " ")  //表示テキスト
    var fontSize: CGFloat = 12.0                             //フォントサイズ
    var color: NSColor = NSColor.black                       //テキスト色
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {return true}
    }
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    convenience init(point: NSPoint, fontSize: CGFloat) {  //接頭辞convenienceを忘れない
        self.init(point: point, fontSize: fontSize, color: NSColor.black)
    }
    init(point: NSPoint, fontSize: CGFloat, color: NSColor) {
        let frame = CGRect(x:point.x, y:point.y, width:1, height:1)  //width, heigt は 0は不可
        super.init(frame: frame)
        self.fontSize = fontSize
        self.color = color
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    //アクセッサー
    //--------------------------------------------------------------------------
    var text:String{
        get{
            return _text.string
        }
        set(inText){
            _text = UATextAttribute.makeAttributedString(
                string:inText, size:fontSize, color:color)
        }
    }
    //--------------------------------------------------------------------------
    //ビューの再描画（左揃え）
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.frame.size.width = _text.size().width
        self.frame.size.height = _text.size().height
        _text.draw(at: NSMakePoint(0, 0))
    }
}
