import Blueprints
import Cocoa
import UserInterface

protocol ApplicationsCollectionViewControllerDelegate: class {
  func applicationCollectionViewController(_ controller: ApplicationsCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application)
}

class ApplicationsCollectionViewController: NSViewController, NSCollectionViewDelegate {
  weak var delegate: ApplicationsCollectionViewControllerDelegate?
  let dataSource: ApplicationsDataSource
  lazy var layoutFactory = LayoutFactory()
  lazy var collectionView = NSCollectionView(layout: layoutFactory.createGridLayout(),
                                             register: ApplicationGridView.self)

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

  // MARK: - NSCollectionViewDelegate

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
            strongSelf.delegate?.applicationCollectionViewController(strongSelf,
                                                                     toggleAppearance: newAppearance,
                                                                     application: application)
          }
        }
      })
    })
  }
}
