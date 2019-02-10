import Cocoa
import Family

class MainContainerViewController: FamilyViewController,
  ApplicationsFeatureViewControllerDelegate,
  SystemPreferenceFeatureViewControllerDelegate,
ToolbarDelegate {
  lazy var loadingLabelController = ApplicationsLoadingViewController(text: "Loading...")
  let preferencesViewController: SystemPreferenceFeatureViewController
  let applicationsViewController: ApplicationsFeatureViewController
  let applicationLogicController = ApplicationsLogicController()

  init(iconStore: IconStore) {
    self.preferencesViewController = SystemPreferenceFeatureViewController(iconStore: iconStore)
    self.applicationsViewController = ApplicationsFeatureViewController(iconStore: iconStore,
                                                                        mode: UserDefaults.standard.featureViewControllerMode)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    children.forEach { $0.removeFromParent() }
    title = "Gray"

    applicationsViewController.delegate = self
    preferencesViewController.delegate = self

    addChild(preferencesViewController)
    addChild(loadingLabelController)
    addChild(applicationsViewController)

    loadingLabelController.view.frame.size.height = 60 + 120 + 120 + 20 + scrollView.contentInsets.top
    loadingLabelController.view.enclosingScrollView?.drawsBackground = true
  }

  private func performSearch(with string: String) {
    let header = applicationsViewController.component.collectionView.supplementaryView(forElementKind: NSCollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? CollectionViewHeader

    performBatchUpdates({ controller in
      switch string.count > 0 {
      case false:
        preferencesViewController.component.collectionView.animator().alphaValue = 1.0
        applicationsViewController.performSearch(with: string)
        header?.setText("Applications")
      case true:
        preferencesViewController.component.collectionView.animator().alphaValue = 0.0
        applicationsViewController.performSearch(with: string)
        header?.setText("Search results: \(string)")
      }
    }, completion: nil)
  }

  // MARK: - ToolbarSearchDelegate

  func toolbar(_ toolbar: Toolbar, didSearchFor string: String) {
    performSearch(with: string)
  }

  func toolbar(_ toolbar: Toolbar, didChangeMode mode: String) {
    guard let mode = ApplicationsFeatureViewController.Mode.init(rawValue: mode) else {
      return
    }
    UserDefaults.standard.featureViewControllerMode = mode
    applicationsViewController.mode = mode
    applicationsViewController.removeFromParent()
    addChild(applicationsViewController)
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationViewController(_ controller: ApplicationsFeatureViewController, finishedLoading: Bool) {
    loadingLabelController.view.alphaValue = 0.0
  }

  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 didLoad application: Application, offset: Int, total: Int) {
    let progress = Double(offset + 1) / Double(total) * Double(100)
    loadingLabelController.progress.doubleValue = floor(progress)
    loadingLabelController.textField.stringValue = "Loading (\(offset)/\(total)): \(application.name)"
  }

  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 toggleAppearance newAppearance: Application.Appearance,
                                 application: Application) {
    applicationsViewController.toggle(newAppearance, for: application)
  }

  // MARK: - SystemPreferenceCollectionViewControllerDelegate

  func systemPreferenceViewController(_ controller: SystemPreferenceFeatureViewController,
                                      toggleSystemPreference model: SystemPreferenceViewModel) {
    preferencesViewController.toggle(model.preference)
  }
}
