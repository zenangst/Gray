import Cocoa
import Family

class ApplicationsViewController: FamilyViewController, ApplicationCollectionViewControllerDelegate {
  enum State { case list([Application]) }
  let logicController = ApplicationsLogicController()
  var collectionViewController: ApplicationCollectionViewController?

  override func viewWillAppear() {
    super.viewWillAppear()
    logicController.load(then: render)
    title = "Gray"
  }

  private func render(_ state: State) {
    switch state {
    case .list(let applications):
      children.forEach {
        $0.removeFromParent()
        $0.view.removeFromSuperview()
      }

      let collectionViewController = ApplicationCollectionViewController(models: applications)
      collectionViewController.delegate = self
      addChild(collectionViewController, view: { $0.collectionView })
      self.collectionViewController = collectionViewController
    }
  }

  // MARK: - ApplicationCollectionViewControllerDelegate

  func applicationCollectionViewController(_ controller: ApplicationCollectionViewController,
                                           toggleAppearance newAppearance: Application.Appearance,
                                           application: Application) {
    logicController.toggleAppearance(for: application, newAppearance: newAppearance, then: { _ in
    })
  }
}
