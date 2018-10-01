import Cocoa
import Family

class ApplicationsViewController: FamilyViewController, ApplicationsCollectionViewControllerDelegate {
  enum State { case list([Application]) }
  let logicController = ApplicationsLogicController()
  lazy var collectionViewController = ApplicationsCollectionViewController()

  override func viewWillAppear() {
    super.viewWillAppear()
    logicController.load(then: render)
    title = "Gray"
    collectionViewController.delegate = self
    addChild(collectionViewController, view: { $0.collectionView })
  }

  private func render(_ state: State) {
    switch state {
    case .list(let applications):
      collectionViewController.dataSource.reload(collectionViewController.collectionView, with: applications)
    }
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationCollectionViewController(_ controller: ApplicationsCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application) {
    logicController.toggleAppearance(for: application, newAppearance: newAppearance, then: render)
  }
}
