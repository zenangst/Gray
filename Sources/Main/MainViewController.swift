import Cocoa
import Family

class MainViewController: FamilyViewController,
  ApplicationsCollectionViewControllerDelegate,
  SystemPreferenceCollectionViewControllerDelegate,
  ToolbarSearchDelegate {

  enum State {
    case viewApplications([Application])
    case viewPreferences([SystemPreference])
  }
  let applicationsLogicController = ApplicationsLogicController()
  let systemPreferenceLogicController = SystemLogicController()
  lazy var systemLabelController = LabelViewController(text: "System preferences")
  lazy var systemPreferencesCollectionViewController = SystemPreferenceCollectionViewController()
  lazy var applicationsCollectionViewController = ApplicationsCollectionViewController()
  var query: String = ""
  var applicationCache = [Application]()

  override func viewWillAppear() {
    super.viewWillAppear()
    title = "Gray"
    applicationsLogicController.load(then: render)
    systemPreferenceLogicController.load(then: render)

    applicationsCollectionViewController.delegate = self
    systemPreferencesCollectionViewController.delegate = self
    systemLabelController.view.wantsLayer = true
    systemLabelController.view.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor

    addChild(systemLabelController, height: 60)
    addChild(systemPreferencesCollectionViewController, view: { $0.collectionView })
    addChild(LabelViewController(text: "Applications"), height: 60)
    addChild(applicationsCollectionViewController, view: { $0.collectionView })
  }

  private func render(_ state: State) {
    switch state {
    case .viewPreferences(let preferences):
      systemPreferencesCollectionViewController.dataSource.reload(systemPreferencesCollectionViewController.collectionView,
                                                                  with: preferences)
    case .viewApplications(let applications):
      applicationCache = applications
      applicationsCollectionViewController.dataSource.reload(applicationsCollectionViewController.collectionView,
                                                             with: applications) { [weak self] in
                                                              guard let strongSelf = self else { return }
                                                              strongSelf.performSearch(with: strongSelf.query)
      }
    }
  }

  private func performSearch(with string: String) {
    let collectionView = applicationsCollectionViewController.collectionView
    query = string
    switch string.count {
    case 0:
      systemLabelController.view.animator().alphaValue = 1.0
      systemPreferencesCollectionViewController.collectionView.animator().alphaValue = 1.0
      applicationsCollectionViewController.dataSource.reload(collectionView,
                                                             with: applicationCache)
      scrollView.layoutViews(withDuration: 0.15, excludeOffscreenViews: false)
    case 1:
      systemLabelController.view.animator().alphaValue = 0.0
      systemPreferencesCollectionViewController.collectionView.animator().alphaValue = 0.0
      fallthrough
    default:
      let filtered = applicationCache.filter({ $0.name.lowercased().contains(string.lowercased()) })
      applicationsCollectionViewController.dataSource.reload(collectionView,
                                                             with: filtered)
      scrollView.layoutViews(withDuration: 0.15, excludeOffscreenViews: false)
    }
  }

  // MARK: - ToolbarSearchDelegate

  func toolbar(_ toolbar: Toolbar, didSearchFor string: String) {
    performSearch(with: string)
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationCollectionViewController(_ controller: ApplicationsCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application) {
    applicationsLogicController.toggleAppearance(for: application,
                                                 newAppearance: newAppearance,
                                                 then: render)
  }

  // MARK: - SystemPreferenceCollectionViewControllerDelegate

  func systemPreferenceCollectionViewController(_ controller: SystemPreferenceCollectionViewController,
                                                toggleSystemPreference preference: SystemPreference) {
    systemPreferenceLogicController.toggleSystemPreference(preference, then: render)
  }
}
