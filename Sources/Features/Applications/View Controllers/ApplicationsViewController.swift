import Blueprints
import Cocoa
import UserInterface

protocol ApplicationsViewControllerDelegate: class {
  func applicationViewController(_ controller: ApplicationsViewController,
                                 toggleAppearance newAppearance: Application.Appearance,
                                 application: Application)
}

class ApplicationsViewController: NSViewController, NSCollectionViewDelegate, ApplicationGridViewDelegate {
  enum State {
    case view([Application])
  }

  weak var delegate: ApplicationsViewControllerDelegate?
  let dataSource: ApplicationsDataSource
  let logicController = ApplicationsLogicController()
  lazy var layoutFactory = LayoutFactory()
  lazy var collectionView = NSCollectionView(layout: layoutFactory.createGridLayout(),
                                             register: ApplicationGridView.self)
  var applicationCache = [Application]()
  var query: String = ""

  init(models: [Application] = []) {
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
    collectionView.isSelectable = true
    collectionView.allowsMultipleSelection = false
    view.addSubview(collectionView, pin: true)
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
      dataSource.reload(collectionView, with: applicationCache)
    default:
      let filtered = applicationCache.filter({ $0.name.lowercased().contains(string.lowercased()) })
      dataSource.reload(collectionView, with: filtered)
    }
  }

  private func render(_ newState: State) {
    switch newState {
    case .view(let applications):
      applicationCache = applications
      dataSource.reload(collectionView,
                        with: applications) { [weak self] in
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
    guard let indexPath = collectionView.indexPath(for: view) else { return }

    let application = dataSource.model(at: indexPath)
    toggle(.system, for: application)
  }

  // MARK: - NSCollectionViewDelegate

  func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    (item as? ApplicationGridView)?.delegate = self
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first,
      let item = collectionView.item(at: indexPath) as? ApplicationGridView else {
        return
    }

    collectionView.deselectAll(nil)

    let application = dataSource.model(at: indexPath)
    let newAppearance: Application.Appearance = application.appearance == .light
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
        if application.restricted {
          self.showPermissionsDialog(for: application) { result in
            guard result else { return }
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
            NSWorkspace.shared.open(url)
          }
        } else {
          item.update(with: newAppearance, duration: 0.5) { [weak self] in
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
