import Blueprints
import Cocoa
import UserInterface

protocol SystemPreferenceFeatureViewControllerDelegate: class {
  func systemPreferenceViewController(_ controller: SystemPreferenceFeatureViewController,
                                      toggleSystemPreference model: SystemPreferenceViewModel)
}

class SystemPreferenceFeatureViewController: NSViewController, NSCollectionViewDelegate, SystemLogicControllerDelegate {
  weak var delegate: SystemPreferenceFeatureViewControllerDelegate?
  let logicController = SystemLogicController()
  let iconStore: IconStore
  let component: SystemPreferenceViewController

  init(iconStore: IconStore) {
    let layoutFactory = LayoutFactory()
    self.iconStore = iconStore
    self.component = SystemPreferenceViewController(title: "Preferences".localized,
                                                    layout: layoutFactory.createGridLayout(),
                                                    iconStore: iconStore)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = component.view
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    logicController.delegate = self
    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    backgroundView.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
    component.collectionView.backgroundView = backgroundView
    component.collectionView.delegate = self
    component.collectionView.isSelectable = true
    component.collectionView.allowsMultipleSelection = false
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    logicController.load()
  }

  func toggle(_ systemPreference: SystemPreference) {
    logicController.toggleSystemPreference(systemPreference)
  }

  // MARK: - SystemLogicControllerDelegate

  func systemLogicController(_ controller: SystemLogicController, didLoadPreferences preferences: [SystemPreferenceViewModel]) {
    component.reload(with: preferences)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }

    collectionView.deselectAll(nil)
    delegate?.systemPreferenceViewController(self, toggleSystemPreference: component.model(at: indexPath))
  }
}
