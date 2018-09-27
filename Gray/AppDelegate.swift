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

    if window.frame.size == .zero {
      window.setFrame(NSRect.init(origin: .zero, size: .init(width: 200, height: 200)),
                      display: true)
    }

    window.makeKeyAndOrderFront(nil)
    self.window = window
  }

  @objc open func injected(_ notification: Notification) {
//    guard Injection.objectWasInjected(self, in: notification) else { return }
    loadApplication()
  }
}

