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

class ApplicationsFeatureViewController: NSViewController, NSCollectionViewDelegate, ApplicationGridViewDelegate {
  enum State {
    case loading(application: ApplicationGridViewModel, offset: Int, total: Int)
    case view([ApplicationGridViewModel])
  }

  weak var delegate: ApplicationsFeatureViewControllerDelegate?
  let component: ApplicationGridViewController
  let logicController = ApplicationsLogicController()
  let iconStore: IconStore
  var applicationCache = [ApplicationGridViewModel]()
  var query: String = ""

  init(iconStore: IconStore, models: [Application] = []) {
    let layoutFactory = LayoutFactory()
    self.iconStore = iconStore
    self.component = ApplicationGridViewController(title: "Applications", layout: layoutFactory.createGridLayout())
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
    component.collectionView.delegate = self
    component.collectionView.isSelectable = true
    component.collectionView.allowsMultipleSelection = false
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    logicController.load(then: render)
  }

  func toggle(_ newAppearance: Application.Appearance, for application: Application) {
    logicController.toggleAppearance(newAppearance, for: application, then: render)
  }

  func performSearch(with string: String) {
    query = string
    switch string.count {
    case 0:
      component.reload(with: applicationCache)
    default:
      // This can be improved!
      let results = applicationCache.filter({ $0.application.name.contains(query) })
      component.reload(with: results)
    }
  }

  private func render(_ newState: State) {
    switch newState {
    case .loading(let model, let offset, let total):
      delegate?.applicationViewController(self, didLoad: model.application, offset: offset, total: total)
    case .view(let applications):
      delegate?.applicationViewController(self, finishedLoading: true)
      applicationCache = applications
      component.reload(with: applications) { [weak self] in
        guard let strongSelf = self else { return }
        strongSelf.performSearch(with: strongSelf.query)
      }
    }
  }

  private func showPermissionsDialog(for application: Application, handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "Additional privileges needed"
    alert.informativeText = """
    To be able to change the appearance of apps like Mail, Messages, Safari and Home, you need to grant permission Full Disk Access.

    """
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open Security & Preferences")
    alert.addButton(withTitle: "OK")
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  // MARK: - ApplicationGridViewDelegate

  func applicationView(_ view: ApplicationGridView, didResetApplication currentAppearance: Application.Appearance?) {
    guard let indexPath = component.indexPath(for: view) else { return }

    let model = component.model(at: indexPath)
    toggle(.system, for: model.application)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    if let view = item as? ApplicationGridView {
      view.delegate = self
      iconStore.loadIcon(for: component.model(at: indexPath).application) { image in view.iconView.image = image }
    }
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first,
      let item = collectionView.item(at: indexPath) as? ApplicationGridView else {
        return
    }

    collectionView.deselectAll(nil)

    let model = component.model(at: indexPath)
    let newAppearance: Application.Appearance = model.application.appearance == .light
      ? .dark
      : .light
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
        if model.application.restricted {
          self.showPermissionsDialog(for: model.application) { result in
            guard result else { return }
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
          }
        } else {
          item.update(with: newAppearance, duration: 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.applicationViewController(strongSelf,
                                                           toggleAppearance: newAppearance,
                                                           application: model.application)
          }
        }
      })
    })
  }
}
