//------------------------------------------------------------------------------
//  REElementView.swift
//------------------------------------------------------------------------------
import Cocoa
//文字位置揃え
enum AlignType{
    case left
    case center
    case right
}
class REElementView: NSView {
    var text: String = ""                           //表示文字列
    var backgroundColor: NSColor = NSColor.white    //背景色
    var borderWidth: CGFloat = 1.0                  //枠線の太さ
    var borderColor: NSColor =
        NSColor.init(calibratedRed: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) //枠線の色
    var opacity: Float = 1.0                        //透明度
    var align: AlignType = .left                    //文字列揃え
    var attribute: [NSAttributedString.Key:Any] =
        UATextAttribute.makeAttributes(size: 14)    //文字列装飾
    //--------------------------------------------------------------------------
    //ビューの再表示
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.opacity = opacity
        self.layer?.backgroundColor = backgroundColor.cgColor
        self.layer?.borderWidth = borderWidth
        self.layer?.borderColor = borderColor.cgColor
        let textSize = text.size(withAttributes: attribute)
        let newPont: CGPoint
        let wpad:CGFloat = 5    //横padding
        let hpad:CGFloat = 2    //縦padding
        if align == .right{
            //右揃え
            newPont = CGPoint(x:dirtyRect.size.width - textSize.width - wpad,
                              y:dirtyRect.size.height - textSize.height - hpad)
        }else if align == .center{
            //中右揃え
            newPont = CGPoint(x:(dirtyRect.size.width / 2) - (textSize.width / 2),
                              y:dirtyRect.size.height - textSize.height - hpad)
        }else{
            //左揃え
            newPont = CGPoint(x:wpad,
                              y:dirtyRect.size.height - textSize.height - hpad)
        }
        //文字列の描画
        text.draw(at: newPont, withAttributes:attribute)
    }
}
