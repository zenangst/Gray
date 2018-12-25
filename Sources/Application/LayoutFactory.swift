import Blueprints
import Cocoa

class LayoutFactory {
  func createGridLayout() -> VerticalBlueprintLayout {
    let layout = VerticalBlueprintLayout(
      itemSize: .init(width: 120, height: 120),
      minimumInteritemSpacing: 10,
      minimumLineSpacing: 10,
      sectionInset: .init(top: 0, left: 10, bottom: 20, right: 10),
      animator: DefaultLayoutAnimator(animation: .fade))
    return layout
  }
}
