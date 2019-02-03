// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa
import Differific

class ApplicationGridViewController: NSViewController {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationGridDataSource
  let collectionView: NSCollectionView

  init(layout: NSCollectionViewFlowLayout,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationGridDataSource()
    if let collectionView = collectionView {
      self.collectionView = collectionView
    } else {
      self.collectionView = NSCollectionView()
    }
    self.collectionView.collectionViewLayout = layout
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func loadView() {
    self.view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = dataSource
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationGridView")
    collectionView.register(ApplicationGridView.self, forItemWithIdentifier: identifier)
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationGridViewModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationGridViewModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationGridDataSource: NSObject, NSCollectionViewDataSource {

  private var models = [ApplicationGridViewModel]()

  init(models: [ApplicationGridViewModel] = []) {
    self.models = models
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationGridViewModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationGridViewModel],
              then handler: (() -> Void)? = nil) {
    let manager = DiffManager()
    let changes = manager.diff(self.models, models)
    collectionView.reload(with: changes,
                          updateDataSource: { self.models = models },
                          completion: handler)
  }

  // MARK: - NSCollectionViewDataSource

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationGridView")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationGridView {
          view.currentAppearance = model.application.appearance
          view.titleLabel.stringValue = model.title
          view.subtitleLabel.stringValue = model.subtitle
    }

    return item
  }
}

struct ApplicationGridViewModel: Hashable {
  let title: String
  let subtitle: String
  let application: Application
}
