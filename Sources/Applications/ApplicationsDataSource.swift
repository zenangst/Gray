import Cocoa
import Differific
import UserInterface

class ApplicationsDataSource: NSObject, NSCollectionViewDataSource {
  private(set) var models: [Application]

  // MARK: - Initializer

  init(models: [Application] = []) {
    self.models = models
    super.init()
  }

  // MARK: - Public API

  func reload(_ collectionView: NSCollectionView,
              with models: [Application],
              then handler: (() -> Void)? = nil) {
    let manager = DiffManager()
    let changes = manager.diff(self.models, models)
    collectionView.reload(with: changes,
                           updateDataSource: { self.models = models },
                           completion: handler)
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
      view.toggle.setSelected(model.appearance == .light, forSegment: 0)
      view.toggle.setSelected(model.appearance == .dark, forSegment: 1)
    }
  }
}
