//------------------------------------------------------------------------------
//  BPAcceptButton.swift：確定フラグ
//------------------------------------------------------------------------------
import Cocoa
//プロトコル宣言
protocol BPAcceptButtonDelegate: class {
    func changeCheck(_ event:NSEvent)
}
class BPAcceptButton: NSButton {
    weak var delegate: BPAcceptButtonDelegate?  = nil  //デリゲート変数
    //--------------------------------------------------------------------------
    //ファーストレスポンダーを受け入れる
    //--------------------------------------------------------------------------
    override var acceptsFirstResponder:Bool {
        get {
            return true
        }
    }
    //--------------------------------------------------------------------------
    //タブキーによるファーストレスポンダの移動 及びリターンキーによるon/offの変更
    //--------------------------------------------------------------------------
    override func keyDown(with event: NSEvent) {
        //print("keyDown \(event.keyCode)")
        if event.keyCode == 48 || event.keyCode == 36{
            delegate?.changeCheck(event)
        }else{
            super.keyDown(with: event)
        }
    }
}
