//------------------------------------------------------------------------------
//  REMainView.swift
//------------------------------------------------------------------------------
import Cocoa
class REMainView: NSView {
    var square1:CAShapeLayer
    var square2:CAShapeLayer
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init(frame:CGRect, graphWidth:CGFloat){
        //補助線を引く
        square1 = CAShapeLayer.init() //適正最低血圧の上限 85
        square2 = CAShapeLayer.init() //適正最高血圧の上限 135
        
        super.init(frame: frame)
        let base = frame.size.width - graphWidth
        let height = frame.size.height
        let left = ((CGFloat)(lowerNormal) / 200) * graphWidth + base
        let right = ((CGFloat)(upperNormal) / 200) * graphWidth + base
        //適正最低血圧の上限の補助線
        let path1 = NSBezierPath.init()
        path1.appendRect(CGRect(x:left, y:0, width:1, height:height))
        square1.path = path1.cgPath
        square1.position = CGPoint.zero
        square1.fillColor = NSColor.blue.cgColor
        square1.opacity = 1
        //適正最高血圧の上限の補助線
        let path2 = NSBezierPath.init()
        path2.appendRect(CGRect(x:right, y:0, width:1, height:height))
        square2.path = path2.cgPath
        square2.position = CGPoint.zero
        square2.fillColor = NSColor.red.cgColor
        square2.opacity = 1
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {return true}
    }
    //--------------------------------------------------------------------------
    //ビューの再表示
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.addSublayer(square1)
        self.layer?.addSublayer(square2)
    }
}



