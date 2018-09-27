import Cocoa
import Family

class ApplicationsViewController: FamilyViewController {
  enum State { case list([Application]) }
  let logicController = ApplicationsLogicController()

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
      addChild(collectionViewController, view: { $0.collectionView })
    }
  }
}
