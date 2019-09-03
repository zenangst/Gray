import Cocoa

class OpaqueView: NSView {
  override var isOpaque: Bool { return true }
}
