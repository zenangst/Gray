import Blueprints
import Cocoa
import UserInterface

protocol SystemPreferenceFeatureViewControllerDelegate: class {
  func systemPreferenceViewController(_ controller: SystemPreferenceFeatureViewController,
                                      toggleSystemPreference model: SystemPreferenceViewModel)
}

class SystemPreferenceFeatureViewController: NSViewController, NSCollectionViewDelegate {
  enum State {
    case view([SystemPreferenceViewModel])
  }

  weak var delegate: SystemPreferenceFeatureViewControllerDelegate?
  let logicController = SystemLogicController()
  let iconStore: IconStore
  let component: SystemPreferenceViewController

  init(iconStore: IconStore) {
    let layoutFactory = LayoutFactory()
    self.iconStore = iconStore
    self.component = SystemPreferenceViewController(layout: layoutFactory.createGridLayout())
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
    logicController.load(then: render)
  }

  func toggle(_ systemPreference: SystemPreference) {
    logicController.toggleSystemPreference(systemPreference, then: render)
  }

  private func render(_ state: State) {
    switch state {
    case .view(let preferences):
      component.reload(with: preferences)
    }
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }

    collectionView.deselectAll(nil)
    delegate?.systemPreferenceViewController(self, toggleSystemPreference: component.model(at: indexPath))
  }
}
