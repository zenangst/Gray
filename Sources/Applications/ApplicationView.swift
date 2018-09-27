import Cocoa
import UserInterface

protocol ApplicationViewDelegate: class {
  func applicationView(_ view: ApplicationView, didClickSegmentedControl segmentedControl: NSSegmentedControl)
}

class ApplicationView: NSCollectionViewItem {
  weak var delegate: ApplicationViewDelegate?
  lazy var label: NSTextField = .init()
  lazy var toggle = NSSegmentedControl(labels: Application.Appearance.allCases.compactMap({ $0.rawValue }),
                                       trackingMode: .selectOne,
                                       target: self,
                                       action: #selector(toggleAction))

  override var isSelected: Bool {
    willSet { updateState(isSelected) }
  }

  override func loadView() {
    let view = NSView()
    view.wantsLayer = true
    self.view = view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let line = NSView()
    line.wantsLayer = true
    line.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.2).cgColor

    label.backgroundColor = .clear
    label.isBezeled = false
    label.isEditable = false
    label.maximumNumberOfLines = 3
    view.addSubviews(line, label, toggle)
    let margin: CGFloat = 16
    
    NSLayoutConstraint.constrain(
      label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      label.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -margin),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      toggle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      toggle.widthAnchor.constraint(equalToConstant: 150),
      toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      line.heightAnchor.constraint(equalToConstant: 1)
    )
  }

  func updateState(_ isSelected: Bool) {
    switch isSelected {
    case true:
      view.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.cgColor
    case false:
      view.layer?.backgroundColor = NSColor.clear.cgColor
    }
  }

  @objc func toggleAction() {
    delegate?.applicationView(self, didClickSegmentedControl: toggle)
  }
}

