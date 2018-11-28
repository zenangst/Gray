import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, VersionControllerDelegate {
  let versionController = VersionController()
  weak var toolbar: Toolbar?
  weak var window: NSWindow?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    #if DEBUG
      Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection10.bundle")?.load()
    #endif
    loadApplication()
    versionController.delegate = self
    checkForNewVersion(nil)
  }

  func applicationDidBecomeActive(_ notification: Notification) {
    guard window == nil else { return }
    loadApplication()
  }

  @objc private func loadApplication() {
    self.window?.close()
    self.window = nil

    let dependencyContainer = DependencyContainer()
    let contentViewController = MainContainerViewController(iconStore: dependencyContainer)
    let toolbar = Toolbar(identifier: .init("MainApplicationWindowToolbar"))
    toolbar.searchDelegate = contentViewController
    let windowSize = CGSize(width: 420, height: 640)
    let window = NSWindow(contentViewController: contentViewController)
    window.setFrameAutosaveName(NSWindow.FrameAutosaveName.init("MainApplicationWindow"))
    window.styleMask = [.closable, .miniaturizable, .titled,
                        .fullSizeContentView, .unifiedTitleAndToolbar]
    window.titleVisibility = .hidden
    window.toolbar = toolbar
    if window.frame.size.width == 0 {
      window.setFrame(NSRect.init(origin: .zero, size: .init(width: 200, height: 200)),
                      display: false)
    }

    if let screen = NSScreen.main, window.frame.origin == .zero {
      let origin = NSPoint(x: screen.frame.width / 2 - window.frame.size.width / 2,
                           y: screen.frame.height / 2 - window.frame.size.height / 2)
      window.setFrame(NSRect.init(origin: origin, size: windowSize),
                      display: true)
    }

    window.minSize = windowSize
    window.maxSize = windowSize
    window.setFrame(NSRect.init(origin: window.frame.origin, size: windowSize), display: true)
    window.makeKeyAndOrderFront(nil)
    self.window = window
    self.toolbar = toolbar
  }

  // MARK: - Injection

  @objc func injected() {
    loadApplication()
  }

  // MARK: - Actions

  @IBAction func search(_ sender: Any?) {
    toolbar?.searchField?.becomeFirstResponder()
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

