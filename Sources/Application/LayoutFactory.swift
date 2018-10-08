import Blueprints
import Cocoa

class LayoutFactory {
  func createGridLayout() -> VerticalBlueprintLayout {
    let layout = VerticalBlueprintLayout(
      itemSize: .init(width: 120, height: 120),
      minimumInteritemSpacing: 12,
      minimumLineSpacing: 12,
      sectionInset: .init(top: 0, left: 18, bottom: 20, right: 18),
      animator: DefaultLayoutAnimator(animation: .fade))
    return layout
  }
}
