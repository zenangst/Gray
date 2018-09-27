import Cocoa
import UserInterface

class ApplicationsDataSource: NSObject, NSCollectionViewDataSource {
  weak var collectionView: NSCollectionView?
  private(set) var models: [Application]

  // MARK: - Initializer

  init(models: [Application] = []) {
    self.models = models
    super.init()
  }

  // MARK: - Public API

  func reload(with models: [Application],
              then handler: (() -> Void)? = nil) {
    self.models = models
    collectionView?.reloadData()
    handler?()
  }

  func model(at indexPath: IndexPath) -> Application {
    return models[indexPath.item]
  }

  // MARK: - UICollectionViewDataSource

  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return models.count
  }

  func collectionView(_ collectionView: NSCollectionView,
                      itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    return collectionView.dequeue(ApplicationView.self, with: model(at: indexPath), for: indexPath) {
      view, model in
      view.label.stringValue = model.name
    }
  }
}
