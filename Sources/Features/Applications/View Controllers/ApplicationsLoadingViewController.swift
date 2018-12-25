import Cocoa
import UserInterface

class ApplicationsLoadingViewController: NSViewController {
  override func loadView() { view = baseView }
  lazy var baseView = NSView()
  lazy var textField = NSTextField()
  lazy var progress = NSProgressIndicator()

  init(text: String) {
    super.init(nibName: nil, bundle: nil)
    self.textField.stringValue = text
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubviews(textField, progress)
    NSLayoutConstraint.constrain(
      textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
      textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
      progress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progress.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
      progress.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
      progress.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
      progress.heightAnchor.constraint(equalToConstant: 10)
    )
    textField.maximumNumberOfLines = -1
    textField.alignment = .center
    textField.isBezeled = false
    textField.isBordered = false
    textField.isEditable = false
    textField.isSelectable = false
    textField.drawsBackground = false
    textField.font = NSFont.systemFont(ofSize: 15)
    progress.canDrawConcurrently = true
    progress.isIndeterminate = false
//    progress.controlTint = NSControlTint.blueControlTint
    progress.style = .bar
    progress.doubleValue = 0.0
//    progress.isBezeled = true
  }

  func setText(_ text: String) {
    self.textField.stringValue = text
  }
}
