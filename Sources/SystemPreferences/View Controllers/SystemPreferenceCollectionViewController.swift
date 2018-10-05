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
  lazy var gridLayout = VerticalBlueprintLayout(
    itemSize: .init(width: 157, height: 157),
    minimumInteritemSpacing: 28,
    minimumLineSpacing: 28,
    sectionInset: .init(top: 28, left: 28, bottom: 28, right: 28))

  lazy var collectionView = NSCollectionView(layout: gridLayout,
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
    collectionView.backgroundColors = [NSColor.quaternaryLabelColor.withAlphaComponent(0.0)]
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    view.addSubview(collectionView, pin: true)
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }

    collectionView.deselectAll(nil)
    let model = dataSource.model(at: indexPath)
    delegate?.systemPreferenceCollectionViewController(self, toggleSystemPreference: model)
  }
}
