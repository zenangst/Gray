import Cocoa
import Family

class MainContainerViewController: FamilyViewController,
  ApplicationsFeatureViewControllerDelegate,
  SystemPreferenceFeatureViewControllerDelegate,
  ToolbarDelegate,
  ImportControllerDelegate {

    lazy var loadingLabelController = ApplicationsLoadingViewController(text: "Loading...".localized)
    lazy var importLabelController = ApplicationsLoadingViewController(text: "Importing...".localized)
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

    body {
      add(importLabelController)
      add(loadingLabelController)
      add(preferencesViewController)
      add(applicationsViewController)
      loadingLabelController.view.frame.size.height = 120
    }

    loadingLabelController.view.enclosingScrollView?.drawsBackground = true
  }

  private func performSearch(with string: String) {
    let header = applicationsViewController.component.collectionView.supplementaryView(forElementKind: NSCollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? CollectionViewHeader

    body {
      switch string.count > 0 {
      case false:
        preferencesViewController.component.collectionView.animator().alphaValue = 1.0
        applicationsViewController.performSearch(with: string)
        header?.setText("Applications".localized)
      case true:
        preferencesViewController.component.collectionView.animator().alphaValue = 0.0
        applicationsViewController.performSearch(with: string)
        header?.setText("Search results:".localized + " \(string)")
      }
    }
  }

  // MARK: - ImportControllerDelegate

  func importController(_ controller: ImportController, didStartImport: Bool, settingsCount: Int) {
    importLabelController.view.alphaValue = 0.0
    body {
      importLabelController.view.frame.size.height = 75
      importLabelController.view.animator().alphaValue = 1.0
    }
  }

  func importController(_ controller: ImportController,
                        offset: Int,
                        importProgress progress: Double,
                        settingsCount: Int) {
    importLabelController.progress.animator().doubleValue = floor(progress)
    importLabelController.textField.stringValue = "Importing".localized + " (\(offset)/\(settingsCount)) " + "settings.".localized
  }

  func importController(_ controller: ImportController, didFinishImport: Bool, settingsCount: Int) {
    body {
      importLabelController.view.animator().alphaValue = 0.0
    }
    applicationsViewController.logicController.load()
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
    add(applicationsViewController)
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationViewController(_ controller: ApplicationsFeatureViewController, finishedLoading: Bool) {
    loadingLabelController.view.alphaValue = 0.0
  }

  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 didLoad application: Application, offset: Int, total: Int) {
    let progress = Double(offset + 1) / Double(total) * Double(100)
    loadingLabelController.progress.doubleValue = floor(progress)
    loadingLabelController.textField.stringValue = "Loading".localized + " (\(offset)/\(total)): \(application.name)"
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
