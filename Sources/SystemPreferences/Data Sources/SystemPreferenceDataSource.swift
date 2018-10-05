import Cocoa
import Differific
import UserInterface

class SystemPreferenceDataSource: NSObject, NSCollectionViewDataSource {
  private(set) var models: [SystemPreference]
  let iconController = IconController()

  // MARK: - Initializer

  init(models: [SystemPreference] = []) {
    self.models = models
    super.init()
  }

  // MARK: - Public API

  func reload(_ collectionView: NSCollectionView,
              with models: [SystemPreference],
              then handler: (() -> Void)? = nil) {
    self.models = models
    collectionView.reloadData()
  }

  func model(at indexPath: IndexPath) -> SystemPreference {
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
    return collectionView.dequeue(SystemPreferenceView.self, with: model(at: indexPath), for: indexPath) {
      item, model in
      item.iconView.image = model.icon
      item.titleLabel.stringValue = model.name
      item.subtitleLabel.stringValue = item.view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        ? "Dark apperance" : "Light apperance"
    }
  }
}
