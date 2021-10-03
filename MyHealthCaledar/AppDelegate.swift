//------------------------------------------------------------------------------
//  AppDelegate.swift
//------------------------------------------------------------------------------
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var window: NSWindow!
    let uaView:UAView
    override init(){
        let point = NSMakePoint(30, 30)
        uaView = UAView.init(point: point)
        super.init()
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
            window.contentView?.addSubview(uaView)
    }
    //Docのアイコンをクリックしたらウィンドウを再表示する
    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows flag: Bool) -> Bool{
        if !flag{
            for openWindow in sender.windows{
                if openWindow == self.window{
                    openWindow.makeKeyAndOrderFront(self)
                }
            }
        }
        return true
    }
    //一覧表ウィンドウを閉じる
    func windowWillClose(_ notification: Notification){
        uaView.resultControl.window?.close()
    }

}

