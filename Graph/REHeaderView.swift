//------------------------------------------------------------------------------
//  REHeaderView.swift
//------------------------------------------------------------------------------
import Cocoa
class REHeaderView: NSView {
    var textOfDate:String = "" //見出し年月
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {return true}
    }
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
        textOfDate.draw(at: CGPoint(x:18, y:7), withAttributes:
            UATextAttribute.makeAttributes(size: 18))
        "日付".draw(at: CGPoint(x:20, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12))
        "曜日".draw(at: CGPoint(x:55, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12))
        "最低".draw(at: CGPoint(x:90, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12))
        "最高".draw(at: CGPoint(x:135, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12))
        String(lowerNormal).draw(at: CGPoint(x:290, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12, color: NSColor.blue))
        String(upperNormal).draw(at: CGPoint(x:363, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12, color: NSColor.red))
        "200".draw(at: CGPoint(x:458, y:30), withAttributes:
            UATextAttribute.makeAttributes(size: 12))
    }
}
