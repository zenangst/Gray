import Cocoa
import Vaccine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    Injection.load(then: loadApplication)
      .add(observer: self, with: #selector(injected(_:)))
  }

  @objc private func loadApplication() {
    self.window?.close()
    self.window = nil

    let contentViewController = ApplicationsViewController()
    let window = NSWindow(contentViewController: contentViewController)
    window.setFrameAutosaveName(NSWindow.FrameAutosaveName.init("MainApplicationWindow"))
    window.styleMask = [.closable, .miniaturizable, .resizable, .titled]
    if window.frame.size.width == 0 {
      window.setFrame(NSRect.init(origin: .zero, size: .init(width: 200, height: 200)),
                      display: false)
    }

    if let screen = NSScreen.main {
      let origin = NSPoint(x: screen.frame.width / 2 - window.frame.size.width / 2,
                           y: screen.frame.height / 2 - window.frame.size.height / 2)
      window.setFrameOrigin(origin)
    }

    window.makeKeyAndOrderFront(nil)
    self.window = window
  }

  @objc open func injected(_ notification: Notification) {
    loadApplication()
  }
}

