import Cocoa
import Vaccine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, VersionControllerDelegate {
  let versionController = VersionController()
  var window: NSWindow?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    Injection.load(then: loadApplication)
      .add(observer: self, with: #selector(injected(_:)))
    versionController.delegate = self
    checkForNewVersion(nil)
  }

  @objc private func loadApplication() {
    self.window?.close()
    self.window = nil

    let contentViewController = ApplicationsViewController()
    let window = NSWindow(contentViewController: contentViewController)
    window.setFrameAutosaveName(NSWindow.FrameAutosaveName.init("MainApplicationWindow"))
    window.styleMask = [.closable, .miniaturizable, .resizable, .titled,
                        .fullSizeContentView, .unifiedTitleAndToolbar]
    window.titleVisibility = .hidden
    window.toolbar = NSToolbar()
    if window.frame.size.width == 0 {
      window.setFrame(NSRect.init(origin: .zero, size: .init(width: 200, height: 200)),
                      display: false)
    }

    if let screen = NSScreen.main, window.frame.origin == .zero {
      let origin = NSPoint(x: screen.frame.width / 2 - window.frame.size.width / 2,
                           y: screen.frame.height / 2 - window.frame.size.height / 2)
      window.setFrameOrigin(origin)
    }

    window.minSize = .init(width: 320, height: 320)
    window.makeKeyAndOrderFront(nil)
    self.window = window
  }

  // MARK: - Injection

  @objc open func injected(_ notification: Notification) {
    loadApplication()
  }

  @IBAction func checkForNewVersion(_ sender: Any?) {
    versionController.checkForNewVersion { [weak self] foundNewVersion in
      guard let strongSelf = self else { return }
      switch foundNewVersion {
      case true:
        let version = strongSelf.versionController.currentVersion()
        strongSelf.showNewVersionDialog(version: version) { openGitHub in
          if openGitHub {
            let url = URL(string: "https://github.com/zenangst/Gray/releases/tag/\(version)")!
            NSWorkspace.shared.open(url)
          }
        }
      case false:
        if sender != nil {
          strongSelf.showNoNewUpdates()
        }
      }
    }
  }

  private func showNewVersionDialog(version: String, handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "A new version is available."
    alert.informativeText = "Version \(version) is available for download on GitHub."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open GitHub")
    alert.addButton(withTitle: "OK")
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  private func showNoNewUpdates() {
    let alert = NSAlert()
    alert.messageText = "You’re up-to-date!"
    alert.informativeText = "Gray \(versionController.currentVersion()) is currently the newest version available."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }

  // MARK: - VersionControllerDelegate

  func versionController(_ controller: VersionController, foundNewVersion version: String) {
    showNewVersionDialog(version: version) { openGitHub in
      if openGitHub {
        let url = URL(string: "https://github.com/zenangst/Gray/releases/tag/\(version)")!
        NSWorkspace.shared.open(url)
      }
    }
  }
}

