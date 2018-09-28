import Blueprints
import Cocoa
import UserInterface

protocol ApplicationCollectionViewControllerDelegate: class {
  func applicationCollectionViewController(_ controller: ApplicationCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application)
}

class ApplicationCollectionViewController: NSViewController, ApplicationListViewDelegate, NSCollectionViewDelegate {
  weak var delegate: ApplicationCollectionViewControllerDelegate?
  let dataSource: ApplicationsDataSource
  lazy var listLayout = VerticalBlueprintLayout(
    itemsPerRow: 1,
    itemSize: .init(width: 100, height: 70),
    minimumLineSpacing: 0)

  lazy var gridLayout = VerticalBlueprintLayout(
    itemSize: .init(width: 157, height: 157),
    minimumInteritemSpacing: 28,
    minimumLineSpacing: 28,
    sectionInset: .init(top: 28, left: 28, bottom: 28, right: 28))

  lazy var collectionView = NSCollectionView(layout: gridLayout,
                                             register: ApplicationListView.self, ApplicationGridView.self)

  init(models: [Application] = []) {
    self.dataSource = ApplicationsDataSource(models: models)
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
    collectionView.dataSource = dataSource
    collectionView.delegate = self
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    view.addSubview(collectionView, pin: true)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView,
                      willDisplay item: NSCollectionViewItem,
                      forRepresentedObjectAt indexPath: IndexPath) {
    (item as? ApplicationListView)?.delegate = self
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first,
      let view = collectionView.item(at: indexPath) as? ApplicationGridView else {
        return
    }

    collectionView.deselectAll(nil)

    let application = dataSource.model(at: indexPath)
    let newAppearance: Application.Appearance = application.appearance == .light
      ? .dark
      : .light

    view.update(with: newAppearance, duration: 0.75) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.applicationCollectionViewController(strongSelf,
                                                               toggleAppearance: newAppearance,
                                                               application: application)
    }
  }

  // MARK: - ApplicationViewDelegate

  func applicationView(_ view: ApplicationListView, didClickSegmentedControl segmentedControl: NSSegmentedControl) {
    guard let indexPath = collectionView.indexPath(for: view),
      let appearance = segmentedControl.label(forSegment: segmentedControl.selectedSegment),
      let newAppearance = Application.Appearance.init(rawValue: appearance) else { return }

    let application = dataSource.model(at: indexPath)
    delegate?.applicationCollectionViewController(self,
                                                  toggleAppearance: newAppearance,
                                                  application: application)
  }
}
