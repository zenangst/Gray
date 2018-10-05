import Cocoa
import Family

class MainViewController: FamilyViewController,
  ApplicationsCollectionViewControllerDelegate,
SystemPreferenceCollectionViewControllerDelegate {
  enum State {
    case viewApplications([Application])
    case viewPreferences([SystemPreference])
  }
  let applicationsLogicController = ApplicationsLogicController()
  let systemPreferenceLogicController = SystemLogicController()
  lazy var systemPreferencesCollectionViewController = SystemPreferenceCollectionViewController()
  lazy var applicationsCollectionViewController = ApplicationsCollectionViewController()

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
      applicationsCollectionViewController.dataSource.reload(applicationsCollectionViewController.collectionView,
                                                             with: applications)
    }
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
