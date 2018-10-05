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
  lazy var listLayout = VerticalBlueprintLayout(
    itemsPerRow: 1,
    itemSize: .init(width: 100, height: 70),
    minimumLineSpacing: 0)

  lazy var gridLayout = VerticalBlueprintLayout(
    itemSize: .init(width: 157, height: 157),
    minimumInteritemSpacing: 28,
    minimumLineSpacing: 28,
    sectionInset: .init(top: 28, left: 28, bottom: 28, right: 28))

  lazy var collectionView = NSCollectionView(layout: gridLayout,
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
        item.update(with: newAppearance, duration: 0.5) { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.delegate?.applicationCollectionViewController(strongSelf,
                                                                   toggleAppearance: newAppearance,
                                                                   application: application)
        }
      })
    })
  }
}
