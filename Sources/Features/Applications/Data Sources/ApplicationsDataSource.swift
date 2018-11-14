import Cocoa
import Differific
import UserInterface

class ApplicationsDataSource: NSObject, NSCollectionViewDataSource {
  private(set) var models: [Application]
  let iconStore: IconStore

  // MARK: - Initializer

  init(iconStore: IconStore, models: [Application] = []) {
    self.iconStore = iconStore
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
    return collectionView.dequeue(ApplicationGridView.self, with: model(at: indexPath), for: indexPath) {
      view, model in
      self.iconStore.loadIcon(for: model, then: { image in
        view.iconView.image = image
      })
      view.titleLabel.stringValue = model.name
      view.update(with: model.appearance)

      switch model.appearance {
      case .dark:
        view.subtitleLabel.stringValue = "Dark appearance"
      case .light:
        view.subtitleLabel.stringValue = "Light appearance"
      case .system:
        view.subtitleLabel.stringValue = "System appearance"
      }

      if model.restricted {
        view.subtitleLabel.stringValue = "🔐 Locked"
      }
    }
  }
}
