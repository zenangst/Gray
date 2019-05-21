import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let exportController = ExportController()
  let importController = ImportController()
  weak var toolbar: Toolbar?
  weak var window: NSWindow?
  weak var mainContainerViewController: MainContainerViewController?
  lazy var alertsController = AlertsController(versionController: versionController)
  lazy var versionController = VersionController()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    #if DEBUG
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")?.load()
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
    let previousFrame = self.window?.frame
    self.window?.close()
    self.window = nil

    let dependencyContainer = DependencyContainer()
    let contentViewController = MainContainerViewController(iconStore: dependencyContainer)
    let toolbar = Toolbar(identifier: .init("MainApplicationWindowToolbar"))
    toolbar.toolbarDelegate = contentViewController
    let windowSize = CGSize(width: 400, height: 640)
    let window = NSWindow(contentViewController: contentViewController)
    window.setFrameAutosaveName(NSWindow.FrameAutosaveName.init("MainApplicationWindow"))
    window.styleMask = [.closable, .miniaturizable, .resizable, .titled,
                        .fullSizeContentView, .unifiedTitleAndToolbar]
    window.titleVisibility = .hidden
    window.toolbar = toolbar
    window.minSize = windowSize
    window.maxSize = CGSize(width: 790 * 2, height: 1280)

    if window.frame.size.width < windowSize.width || window.frame.size.width > window.maxSize.width {
      window.setFrame(NSRect.init(origin: .zero, size: windowSize),
                      display: false)
    }

    if let previousFrame = previousFrame {
      window.setFrame(previousFrame, display: true)
    }

    window.resizeIncrements = .init(width: 120 + 10, height: 1)
    window.makeKeyAndOrderFront(nil)
    self.window = window
    self.toolbar = toolbar

    mainContainerViewController = contentViewController
  }

  // MARK: - Injection

  @objc func injected() {
    loadApplication()
  }

  // MARK: - Actions

  @IBAction func switchToGrid(_ sender: Any?) {
    guard let toolbar = window?.toolbar as? Toolbar else { return }
    (window?.contentViewController as? MainContainerViewController)?.toolbar(toolbar,
                                                                             didChangeMode: ApplicationsFeatureViewController.Mode.grid.rawValue)
    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "featureViewControllerMode"), object: nil)
  }

  @IBAction func switchToList(_ sender: Any?) {
    guard let toolbar = window?.toolbar as? Toolbar else { return }
    (window?.contentViewController as? MainContainerViewController)?.toolbar(toolbar,
                                                                             didChangeMode: ApplicationsFeatureViewController.Mode.list.rawValue)
    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "featureViewControllerMode"), object: nil)
  }

  @IBAction func exportAction(_ sender: Any?) {
    exportController.openDialog()
  }

  @IBAction func importAction(_ sender: Any?) {
    importController.delegate = mainContainerViewController
    importController.openDialog()
  }

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

