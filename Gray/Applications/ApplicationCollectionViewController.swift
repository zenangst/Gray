import Blueprints
import Cocoa
import UserInterface

class ApplicationCollectionViewController: NSViewController {
  let dataSource: ApplicationsDataSource
  lazy var layout = VerticalBlueprintLayout(itemsPerRow: 1, itemSize: .init(width: 100, height: 60))
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
    view.addSubview(collectionView, pin: true)
  }
}
