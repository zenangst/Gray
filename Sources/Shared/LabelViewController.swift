import Cocoa
import UserInterface

class LabelViewController: NSViewController {
  lazy var textField = NSTextField()

  init(text: String) {
    super.init(nibName: nil, bundle: nil)
    self.textField.stringValue = text
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    textField.isBezeled = false
    textField.isBordered = false
    textField.isEditable = false
    textField.isSelectable = false
    textField.drawsBackground = false
    textField.font = NSFont.boldSystemFont(ofSize: 18)
    view = NSView()
    view.addSubview(textField)
    NSLayoutConstraint.constrain(
      textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    )
  }
}
