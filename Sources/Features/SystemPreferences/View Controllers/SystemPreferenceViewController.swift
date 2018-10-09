import Blueprints
import Cocoa
import UserInterface

protocol SystemPreferenceViewControllerDelegate: class {
  func systemPreferenceViewController(_ controller: SystemPreferenceViewController,
                                      toggleSystemPreference preference: SystemPreference)
}

class SystemPreferenceViewController: NSViewController, NSCollectionViewDelegate {
  enum State {
    case view([SystemPreference])
  }

  weak var delegate: SystemPreferenceViewControllerDelegate?
  lazy var layoutFactory = LayoutFactory()
  lazy var collectionView = NSCollectionView(layout: layoutFactory.createGridLayout(),
                                             register: SystemPreferenceView.self)
  let dataSource: SystemPreferenceDataSource
  let logicController = SystemLogicController()

  init(models: [SystemPreference] = []) {
    self.dataSource = SystemPreferenceDataSource(models: models)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let backgroundView = NSView()
    backgroundView.wantsLayer = true
    backgroundView.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
    collectionView.backgroundView = backgroundView
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    view.addSubview(collectionView, pin: true)
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
      dataSource.reload(collectionView, with: preferences)
    }
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }

    collectionView.deselectAll(nil)
    let model = dataSource.model(at: indexPath)
    delegate?.systemPreferenceViewController(self, toggleSystemPreference: model)
  }
}
