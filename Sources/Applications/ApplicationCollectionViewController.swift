import Blueprints
import Cocoa
import UserInterface

protocol ApplicationCollectionViewControllerDelegate: class {
  func applicationCollectionViewController(_ controller: ApplicationCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application)
}

class ApplicationCollectionViewController: NSViewController, ApplicationViewDelegate, NSCollectionViewDelegate {
  weak var delegate: ApplicationCollectionViewControllerDelegate?
  let dataSource: ApplicationsDataSource
  lazy var layout = VerticalBlueprintLayout(
    itemsPerRow: 1,
    itemSize: .init(width: 100, height: 70),
    minimumLineSpacing: 0)
  lazy var collectionView = NSCollectionView(layout: layout,
                                             register: ApplicationView.self)

  init(models: [Application]) {
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
    collectionView.allowsEmptySelection = false
    view.addSubview(collectionView, pin: true)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView,
                      willDisplay item: NSCollectionViewItem,
                      forRepresentedObjectAt indexPath: IndexPath) {
    (item as? ApplicationView)?.delegate = self
  }

  // MARK: - ApplicationViewDelegate

  func applicationView(_ view: ApplicationView, didClickSegmentedControl segmentedControl: NSSegmentedControl) {
    guard let indexPath = collectionView.indexPath(for: view),
      let appearance = segmentedControl.label(forSegment: segmentedControl.selectedSegment),
      let newAppearance = Application.Appearance.init(rawValue: appearance) else { return }

    let application = dataSource.model(at: indexPath)
    delegate?.applicationCollectionViewController(self,
                                                  toggleAppearance: newAppearance,
                                                  application: application)
  }
}
