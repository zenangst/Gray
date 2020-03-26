import Blueprints
import Cocoa
import UserInterface

protocol ApplicationsFeatureViewControllerDelegate: class {
  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 finishedLoading: Bool)
  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 didLoad application: Application,
                                 offset: Int,
                                 total: Int)
  func applicationViewController(_ controller: ApplicationsFeatureViewController,
                                 toggleAppearance newAppearance: Application.Appearance,
                                 application: Application)
}

class ApplicationsFeatureViewController: NSViewController, NSCollectionViewDelegate,
ApplicationGridViewDelegate, ApplicationsLogicControllerDelegate, ApplicationListViewDelegate {
  enum Mode: String, CaseIterable {
    case grid = "Grid"
    case list = "List"

    var image: NSImage {
      switch self {
      case .grid:
        return NSImage.init(named: "Grid")!
      case .list:
        return NSImage.init(named: "List")!
      }
    }
  }

  enum State {
    case loading(application: Application, offset: Int, total: Int)
    case view([Application])
  }

  weak var delegate: ApplicationsFeatureViewControllerDelegate?
  let listComponent: ApplicationListViewController
  let gridComponent: ApplicationGridViewController
  let logicController = ApplicationsLogicController()
  let iconStore: IconStore
  var mode: Mode {
    didSet {
      switch mode {
      case .grid:
        self.component = gridComponent
      case .list:
        self.component = listComponent
      }
      self.view = component.view
      configureComponent()
    }
  }
  var component: Component
  var applicationCache = [Application]()
  var query: String = ""

  init(iconStore: IconStore, mode: Mode?, models: [Application] = []) {
    let layoutFactory = LayoutFactory()
    self.iconStore = iconStore
    self.mode = mode ?? .grid
    self.gridComponent = ApplicationGridViewController(title: "Applications".localized,
                                                       layout: layoutFactory.createGridLayout(),
                                                       iconStore: iconStore)
    self.listComponent = ApplicationListViewController(title: "Applications".localized,
                                                       layout: layoutFactory.createListLayout(),
                                                       iconStore: iconStore)

    switch self.mode {
    case .grid:
      self.component = gridComponent
    case .list:
      self.component = listComponent
    }

    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = component.view
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    logicController.delegate = self
    configureComponent()
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    logicController.load()
  }

  func configureComponent() {
    component.collectionView.delegate = self
    component.collectionView.isSelectable = true
    component.collectionView.allowsMultipleSelection = false
  }

  func toggle(_ newAppearance: Application.Appearance, for model: Application) {
    logicController.toggleAppearance(newAppearance, for: model)
  }

  func performSearch(with string: String) {
    query = string.lowercased()
    let filtered: [Application]
    switch string.count {
    case 0:
      filtered = applicationCache
    default:
      filtered = applicationCache.filter({
        return ($0.localizedName ?? $0.name).lowercased().contains(query)
      })
    }

    switch mode {
    case .grid:
      gridComponent.reload(with: gridModels(from: filtered))
    case .list:
      listComponent.reload(with: listModels(from: filtered))
    }
  }

  private func listModels(from applications: [Application]) -> [ApplicationListViewModel] {
    return applications.compactMap({
      ApplicationListViewModel(title: $0.name, subtitle: $0.metadata, application: $0)
    })
  }

  private func gridModels(from applications: [Application]) -> [ApplicationGridViewModel] {
    return applications.compactMap({
      ApplicationGridViewModel(title: $0.name, subtitle: $0.metadata, application: $0)
    })
  }

  private func render(_ newState: State) {
    switch newState {
    case .loading(let model, let offset, let total):
      delegate?.applicationViewController(self, didLoad: model, offset: offset, total: total)
    case .view(let applications):
      delegate?.applicationViewController(self, finishedLoading: true)
      applicationCache = applications

      let completion = { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.performSearch(with: strongSelf.query)
      }

      gridComponent.reload(with: gridModels(from: applications), completion: completion)
      listComponent.reload(with: listModels(from: applications), completion: completion)
    }
  }

  private func showPermissionsDialog(for application: Application, handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "Additional privileges needed".localized
    alert.informativeText = "To be able to change the appearance of apps like Mail, Messages, Safari and Home, you need to grant permission Full Disk Access.".localized
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open Security & Preferences".localized)
    alert.addButton(withTitle: "OK".localized)
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  // MARK: - ApplicationsLogicControllerDelegate

  func applicationsLogicController(_ controller: ApplicationsLogicController, didLoadApplication application: Application, offset: Int, total: Int) {
    render(.loading(application: application, offset: offset, total: total))
  }

  func applicationsLogicController(_ controller: ApplicationsLogicController, didLoadApplications applications: [Application]) {
    render(.view(applications))
  }

  // MARK: - ApplicationGridViewDelegate

  func applicationView(_ view: ApplicationGridView, didResetApplication currentAppearance: Application.Appearance?) {
    guard let indexPath = component.collectionView.indexPath(for: view) else { return }
    let model = gridComponent.model(at: indexPath)
    toggle(.system, for: model.application)
  }

  // MARK: - ApplicationListViewDelegate

  func applicationView(_ view: ApplicationListView, didResetApplication currentAppearance: Application.Appearance?) {
    guard let indexPath = component.collectionView.indexPath(for: view) else { return }
    let model = gridComponent.model(at: indexPath)
    toggle(.system, for: model.application)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    if let view = item as? ApplicationGridView {
      view.delegate = self
    }

    if let view = item as? ApplicationListView {
      view.delegate = self
    }
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first else { return }
    guard let item: NSCollectionViewItem = collectionView.item(at: indexPath) else { return }

    collectionView.deselectAll(nil)

    let restricted: Bool
    let application: Application
    let newAppearance: Application.Appearance

    if collectionView.item(at: indexPath) is ApplicationGridView {
      let model = gridComponent.model(at: indexPath)
      restricted = model.application.restricted
      application = model.application
      newAppearance = model.application.appearance == .light
        ? .dark
        : .light
    } else if collectionView.item(at: indexPath) is ApplicationListView {
      let model = listComponent.model(at: indexPath)
      restricted = model.application.restricted
      application = model.application
      newAppearance = model.application.appearance == .light
        ? .dark
        : .light
    } else { return }

    let duration: TimeInterval = 0.15

    NSAnimationContext.runAnimationGroup({ (context) in
      let scale: CGFloat = 0.8
      let scaleTransform = CGAffineTransform.init(scaleX: scale, y: scale)
      let (width, height) = (item.view.frame.width / 2, item.view.frame.height / 2)
      let moveTransform = CGAffineTransform.init(translationX: width - (width * scale),
                                                 y: height - (height * scale))
      let concatTransform = scaleTransform.concatenating(moveTransform)
      context.duration = duration
      context.allowsImplicitAnimation = true
      item.view.animator().layer?.setAffineTransform(concatTransform)
    }, completionHandler:{
      NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = duration
        context.allowsImplicitAnimation = true
        item.view.animator().layer?.setAffineTransform(.identity)
      }, completionHandler: {
        if restricted {
          self.showPermissionsDialog(for: application) { result in
            guard result else { return }
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
          }
        } else {
          (item as? AppearanceAware)?.update(with: newAppearance, duration: 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.applicationViewController(strongSelf,
                                                           toggleAppearance: newAppearance,
                                                           application: application)
          }
        }
      })
    })
  }
}
