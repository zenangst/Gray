import Cocoa
import Family

class MainContainerViewController: FamilyViewController,
  ApplicationsFeatureViewControllerDelegate,
  SystemPreferenceFeatureViewControllerDelegate,
  ToolbarSearchDelegate {
  lazy var systemLabelController = LabelViewController(text: "System preferences")
  lazy var applicationLabelController = LabelViewController(text: "Applications")
  lazy var loadingLabelController = ApplicationsLoadingViewController(text: "Loading...")
  let preferencesViewController: SystemPreferenceFeatureViewController
  let applicationsViewController: ApplicationsFeatureViewController
  let applicationLogicController = ApplicationsLogicController()

  init(iconStore: IconStore) {
    self.preferencesViewController = SystemPreferenceFeatureViewController(iconStore: iconStore)
    self.applicationsViewController = ApplicationsFeatureViewController(iconStore: iconStore)
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
    addChild(preferencesViewController)
    addChild(applicationLabelController, height: 60)
    addChild(loadingLabelController)
    addChild(applicationsViewController)

    loadingLabelController.view.frame.size.height = 60 + 120 + 120 + 20 + scrollView.contentInsets.top

    systemLabelController.view.enclosingScrollView?.drawsBackground = true
    applicationLabelController.view.enclosingScrollView?.drawsBackground = true
    loadingLabelController.view.enclosingScrollView?.drawsBackground = true
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    children.forEach { $0.viewDidAppear() }
  }

  private func performSearch(with string: String) {
    switch string.count > 0 {
    case false:
      systemLabelController.view.animator().alphaValue = 1.0
      preferencesViewController.component.collectionView.animator().alphaValue = 1.0
      applicationLabelController.setText("Applications")
      applicationsViewController.performSearch(with: string)
    case true:
      systemLabelController.view.animator().alphaValue = 0.0
      preferencesViewController.component.collectionView.animator().alphaValue = 0.0
      applicationLabelController.setText("Search results: \(string)")
      applicationsViewController.performSearch(with: string)
    }
  }

  // MARK: - ToolbarSearchDelegate

  func toolbar(_ toolbar: Toolbar, didSearchFor string: String) {
    performSearch(with: string)
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
