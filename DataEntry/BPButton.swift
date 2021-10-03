//------------------------------------------------------------------------------
//  BPButton.swift
//------------------------------------------------------------------------------
import Cocoa
protocol BPButtonDelegate: class { //プロトコル宣言
    func clickNumber(_ btn:BPButton)
}
class BPButton: NSButton {
    var number: Int //数値
    weak var delegate: BPButtonDelegate?  = nil  //デリゲート変数
    //--------------------------------------------------------------------------
    //イニシャライザ
    //--------------------------------------------------------------------------
    init(rect:NSRect, num:Int, delegate:BPButtonDelegate){
        number = num
        super.init(frame: rect) //指定イニシャライザ
        //ボタンの種類とスタイル
        self.setButtonType(ButtonType.momentaryPushIn)
        self.bezelStyle = BezelStyle.texturedSquare
        self.isBordered = false
        self.delegate = delegate
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    //--------------------------------------------------------------------------
    //ビューの再表示
    //--------------------------------------------------------------------------
    override func draw(_ dirtyRect: NSRect) {
        //タイトル（数字）のセット
        if self.number == -1{
            self.title = "C"
        }else{
            self.title = String(format:"%ld", self.number)
        }
        //外見の設定
        self.font =  NSFont.init(name:"Arial", size:22) ?? NSFont.systemFont(ofSize: 12)
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.gray.cgColor
        self.layer?.backgroundColor = NSColor.white.cgColor
        super.draw(dirtyRect) //最後に行う
    }
    //--------------------------------------------------------------------------
    // クリックした（mouseDown）
    //--------------------------------------------------------------------------
    override func mouseDown(with event: NSEvent) {
        //クリックした数字を入力フィールドに追加する。自オブジェクトを引数とする
        delegate?.clickNumber(self)
        self.layer?.backgroundColor = NSColor.yellow.cgColor
    }
    //--------------------------------------------------------------------------
    // クリックした（mouseUp）
    //--------------------------------------------------------------------------
    override func mouseUp(with event: NSEvent) {
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
}
