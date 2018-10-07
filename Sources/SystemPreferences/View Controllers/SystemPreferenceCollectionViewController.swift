import Blueprints
import Cocoa
import UserInterface

protocol SystemPreferenceCollectionViewControllerDelegate: class {
  func systemPreferenceCollectionViewController(_ controller: SystemPreferenceCollectionViewController,
                                                toggleSystemPreference preference: SystemPreference)
}

class SystemPreferenceCollectionViewController: NSViewController, NSCollectionViewDelegate {
  weak var delegate: SystemPreferenceCollectionViewControllerDelegate?
  let dataSource: SystemPreferenceDataSource
  lazy var layoutFactory = LayoutFactory()
  lazy var collectionView = NSCollectionView(layout: layoutFactory.createGridLayout(),
                                             register: SystemPreferenceView.self)

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

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }

    collectionView.deselectAll(nil)
    let model = dataSource.model(at: indexPath)
    delegate?.systemPreferenceCollectionViewController(self, toggleSystemPreference: model)
  }
}
