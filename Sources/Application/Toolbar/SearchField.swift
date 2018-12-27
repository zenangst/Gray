import Cocoa

class CustomTextFieldCell: NSSearchFieldCell {
  private static let padding = CGSize(width: 5.0, height: 5.0)

  override init(textCell string: String) {
    super.init(textCell: string)
    isEditable = true
    isBezeled = false
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
    let insetRect = rect.insetBy(dx: -CustomTextFieldCell.padding.width,
                                 dy: CustomTextFieldCell.padding.height)
    return super.searchButtonRect(forBounds: insetRect)
  }

  override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
    let insetRect = rect.insetBy(dx: CustomTextFieldCell.padding.width,
                                 dy: CustomTextFieldCell.padding.height)
    super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
  }

  override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
    let insetRect = rect.insetBy(dx: 20,
                                 dy: CustomTextFieldCell.padding.height)
    super.select(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
  }

  override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
    let insetRect = cellFrame.insetBy(dx: CustomTextFieldCell.padding.width,
                                      dy: CustomTextFieldCell.padding.height)
    super.drawInterior(withFrame: insetRect, in: controlView)
  }
}

class SearchField: NSSearchField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    font = NSFont.systemFont(ofSize: 15)
    drawsBackground = true
    cell = CustomTextFieldCell(textCell: "")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
