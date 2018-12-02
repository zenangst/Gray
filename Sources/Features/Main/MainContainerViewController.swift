import Cocoa
import Family

class MainContainerViewController: FamilyViewController,
  ApplicationsViewControllerDelegate,
  SystemPreferenceViewControllerDelegate,
  ToolbarSearchDelegate {

  lazy var systemLabelController = LabelViewController(text: "System preferences")
  let preferencesViewController: SystemPreferenceViewController
  let applicationsViewController: ApplicationsViewController

  init(iconStore: IconStore) {
    self.preferencesViewController = SystemPreferenceViewController(iconStore: iconStore)
    self.applicationsViewController = ApplicationsViewController(iconStore: iconStore)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    children.forEach { $0.removeFromParent(); $0.view.removeFromSuperview() }
    title = "Gray"
    applicationsViewController.delegate = self
    preferencesViewController.delegate = self
    systemLabelController.view.wantsLayer = true
    systemLabelController.view.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor

    addChild(systemLabelController, height: 60)
    addChild(preferencesViewController, view: { $0.collectionView })
    addChild(LabelViewController(text: "Applications"), height: 60)
    addChild(applicationsViewController, view: { $0.collectionView })
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    children.forEach { $0.viewDidAppear() }
  }

  private func performSearch(with string: String) {
    switch string.count {
    case 0:
      systemLabelController.view.animator().alphaValue = 1.0
      preferencesViewController.collectionView.animator().alphaValue = 1.0
      applicationsViewController.performSearch(with: string)
    case 1:
      systemLabelController.view.animator().alphaValue = 0.0
      preferencesViewController.collectionView.animator().alphaValue = 0.0
      fallthrough
    default:
      applicationsViewController.performSearch(with: string)
    }
  }

  // MARK: - ToolbarSearchDelegate

  func toolbar(_ toolbar: Toolbar, didSearchFor string: String) {
    performSearch(with: string)
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationViewController(_ controller: ApplicationsViewController,
                                 toggleAppearance newAppearance: Application.Appearance,
                                 application: Application) {
    applicationsViewController.toggle(newAppearance, for: application)
  }

  // MARK: - SystemPreferenceCollectionViewControllerDelegate

  func systemPreferenceViewController(_ controller: SystemPreferenceViewController,
                                      toggleSystemPreference preference: SystemPreference) {
    preferencesViewController.toggle(preference)
  }
}
