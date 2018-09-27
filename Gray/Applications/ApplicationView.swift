import Cocoa
import UserInterface

class ApplicationView: NSCollectionViewItem {
  lazy var label: NSTextField = .init()
  lazy var toggle: NSSegmentedControl = NSSegmentedControl(labels: [
    "Light", "Dark"
    ], trackingMode: .selectOne, target: self, action: #selector(toggleAction))

  override func loadView() {
    self.view = NSView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let line = NSView()
    line.wantsLayer = true
    line.layer?.backgroundColor = NSColor.controlAlternatingRowBackgroundColors.last?.withAlphaComponent(1.0).cgColor

    label.backgroundColor = .clear
    label.isBezeled = false
    label.isEditable = false
    label.maximumNumberOfLines = 3
    view.addSubviews(line, label, toggle)
    let margin: CGFloat = 10
    
    NSLayoutConstraint.constrain(
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      label.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -margin),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      toggle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      toggle.leadingAnchor.constraint(equalTo: label.trailingAnchor),
      toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      line.heightAnchor.constraint(equalToConstant: 1)
    )
  }

  @objc func toggleAction() {

  }
}

