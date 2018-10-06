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
  lazy var systemPreferencesCollectionViewController = SystemPreferenceCollectionViewController()
  lazy var applicationsCollectionViewController = ApplicationsCollectionViewController()
  var query: String = ""
  var applicationCache = [Application]()

  override func viewWillAppear() {
    super.viewWillAppear()
    applicationsLogicController.load(then: render)
    systemPreferenceLogicController.load(then: render)
    title = "Gray"
    applicationsCollectionViewController.delegate = self
    systemPreferencesCollectionViewController.delegate = self
    addChild(systemPreferencesCollectionViewController, view: { $0.collectionView })
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
    query = string
    switch string.count {
    case 0:
      systemPreferencesCollectionViewController.collectionView.animator().alphaValue = 1.0
      applicationsCollectionViewController.dataSource.reload(applicationsCollectionViewController.collectionView,
                                                             with: applicationCache)
      scrollView.layoutViews(withDuration: 0.15, excludeOffscreenViews: false)
    case 1:
      systemPreferencesCollectionViewController.collectionView.animator().alphaValue = 0.0
      scrollView.layoutViews(withDuration: 0.15, excludeOffscreenViews: false)
      fallthrough
    default:
      let filtered = applicationCache.filter({ $0.name.lowercased().contains(string.lowercased()) })
      applicationsCollectionViewController.dataSource.reload(applicationsCollectionViewController.collectionView,
                                                             with: filtered, then: {
                                                              self.scrollView.layout()
      })
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
