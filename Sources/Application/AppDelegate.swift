import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  weak var toolbar: Toolbar?
  weak var window: NSWindow?
  lazy var alertsController = AlertsController(versionController: versionController)
  lazy var versionController = VersionController()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    #if DEBUG
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection10.bundle")?.load()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(injected),
      name: NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION"),
      object: nil
    )
    #endif
    versionController.delegate = alertsController
    loadApplication()
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
    let windowSize = CGSize(width: 400, height: 640)
    let window = NSWindow(contentViewController: contentViewController)
    window.setFrameAutosaveName(NSWindow.FrameAutosaveName.init("MainApplicationWindow"))
    window.styleMask = [.closable, .miniaturizable, .resizable, .titled,
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
    window.resizeIncrements = .init(width: 120 + 10, height: 1)
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
        strongSelf.alertsController.showNewVersionDialog(version: version) { openGitHub in
          if openGitHub {
            let url = URL(string: "https://github.com/zenangst/Gray/releases/tag/\(version)")!
            NSWorkspace.shared.open(url)
          }
        }
      case false:
        if sender != nil {
          strongSelf.alertsController.showNoNewUpdates()
        }
      }
    }
  }
}

