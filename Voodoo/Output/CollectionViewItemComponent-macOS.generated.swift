// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa
import Differific

class ApplicationGridViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationGridDataSource
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconStore: IconStore,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationGridDataSource(title: title, iconStore: iconStore)
    if let collectionView = collectionView {
      self.collectionView = collectionView
    } else {
      self.collectionView = NSCollectionView()
    }
    self.collectionView.collectionViewLayout = layout
    super.init(nibName: nil, bundle: nil)
    self.title = title
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
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationGridViewHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationGridView")
    collectionView.register(ApplicationGridView.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 60
    }
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

  private var title: String?
  private var models = [ApplicationGridViewModel]()
  private let iconStore: IconStore

  init(title: String? = nil,
       models: [ApplicationGridViewModel] = [],
       iconStore: IconStore) {
    self.title = title
    self.models = models
    self.iconStore = iconStore
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

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationGridViewHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationGridView")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationGridView {
      view.currentAppearance = model.application.appearance
      iconStore.loadIcon(for: model.application) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.application.localizedName ?? model.title
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

class ApplicationListViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: ApplicationListDataSource
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconStore: IconStore,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = ApplicationListDataSource(title: title, iconStore: iconStore)
    if let collectionView = collectionView {
      self.collectionView = collectionView
    } else {
      self.collectionView = NSCollectionView()
    }
    self.collectionView.collectionViewLayout = layout
    super.init(nibName: nil, bundle: nil)
    self.title = title
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
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationListViewHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("ApplicationListView")
    collectionView.register(ApplicationListView.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 60
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> ApplicationListViewModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [ApplicationListViewModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class ApplicationListDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [ApplicationListViewModel]()
  private let iconStore: IconStore

  init(title: String? = nil,
       models: [ApplicationListViewModel] = [],
       iconStore: IconStore) {
    self.title = title
    self.models = models
    self.iconStore = iconStore
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> ApplicationListViewModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [ApplicationListViewModel],
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

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationListViewHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("ApplicationListView")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? ApplicationListView {
      view.currentAppearance = model.application.appearance
      iconStore.loadIcon(for: model.application) { image in view.iconView.image = image }
      view.titleLabel.stringValue = model.application.localizedName ?? model.title
      view.subtitleLabel.stringValue = model.subtitle
    }

    return item
  }
}

struct ApplicationListViewModel: Hashable {
  let title: String
  let subtitle: String
  let application: Application
}

class SystemPreferenceViewController: NSViewController, Component {
  private let layout: NSCollectionViewFlowLayout
  private let dataSource: SystemPreferenceDataSource
  let collectionView: NSCollectionView

  init(title: String? = nil,
       layout: NSCollectionViewFlowLayout,
       iconStore: IconStore,
       collectionView: NSCollectionView? = nil) {
    self.layout = layout
    self.dataSource = SystemPreferenceDataSource(title: title, iconStore: iconStore)
    if let collectionView = collectionView {
      self.collectionView = collectionView
    } else {
      self.collectionView = NSCollectionView()
    }
    self.collectionView.collectionViewLayout = layout
    super.init(nibName: nil, bundle: nil)
    self.title = title
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
    let headerIdentifier = NSUserInterfaceItemIdentifier.init("SystemPreferenceViewHeader")
    collectionView.register(CollectionViewHeader.self,
                            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
                            withIdentifier: headerIdentifier)
    let itemIdentifier = NSUserInterfaceItemIdentifier.init("SystemPreferenceView")
    collectionView.register(SystemPreferenceView.self, forItemWithIdentifier: itemIdentifier)

    if title != nil {
      layout.headerReferenceSize.height = 60
    }
  }

  // MARK: - Public API

  func indexPath(for item: NSCollectionViewItem) -> IndexPath? {
    return collectionView.indexPath(for: item)
  }

  func model(at indexPath: IndexPath) -> SystemPreferenceViewModel {
    return dataSource.model(at: indexPath)
  }

  func reload(with models: [SystemPreferenceViewModel], completion: (() -> Void)? = nil) {
    dataSource.reload(collectionView, with: models, then: completion)
  }
}

class SystemPreferenceDataSource: NSObject, NSCollectionViewDataSource {

  private var title: String?
  private var models = [SystemPreferenceViewModel]()
  private let iconStore: IconStore

  init(title: String? = nil,
       models: [SystemPreferenceViewModel] = [],
       iconStore: IconStore) {
    self.title = title
    self.models = models
    self.iconStore = iconStore
    super.init()
  }

  // MARK: - Public API

  func model(at indexPath: IndexPath) -> SystemPreferenceViewModel {
    return models[indexPath.item]
  }

  func reload(_ collectionView: NSCollectionView,
              with models: [SystemPreferenceViewModel],
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

  func collectionView(_ collectionView: NSCollectionView,
                      viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                      at indexPath: IndexPath) -> NSView {
    let identifier = NSUserInterfaceItemIdentifier.init("SystemPreferenceViewHeader")
    let item = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader,
                                                    withIdentifier: identifier, for: indexPath)

    if let title = title, let header = item as? CollectionViewHeader {
      header.setText(title)
    }

    return item
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let identifier = NSUserInterfaceItemIdentifier.init("SystemPreferenceView")
    let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
    let model = self.model(at: indexPath)

    if let view = item as? SystemPreferenceView {
      view.iconView.image = model.icon
      view.titleLabel.stringValue = model.title
      view.subtitleLabel.stringValue = model.subtitle
    }

    return item
  }
}

struct SystemPreferenceViewModel: Hashable {
  let icon: NSImage
  let title: String
  let subtitle: String
  let preference: SystemPreference
}

