import Cocoa
import UserInterface

protocol ApplicationViewDelegate: class {
  func applicationView(_ view: ApplicationListView, didClickSegmentedControl segmentedControl: NSSegmentedControl)
}

class ApplicationListView: NSCollectionViewItem {
  weak var delegate: ApplicationViewDelegate?
  
  lazy var iconView: NSImageView = .init()
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
    view.addSubviews(line, iconView, label, toggle)
    let margin: CGFloat = 16
    
    NSLayoutConstraint.constrain(
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 36),
      iconView.heightAnchor.constraint(equalToConstant: 36),
      label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: margin),
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

