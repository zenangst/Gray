import Cocoa
import UserInterface

protocol ApplicationGridViewDelegate: class {
  func applicationView(_ view: ApplicationGridView, didClickSegmentedControl segmentedControl: NSSegmentedControl)
}

class ApplicationGridView: NSCollectionViewItem {
  weak var delegate: ApplicationGridViewDelegate?

  lazy var iconView: NSImageView = .init()
  lazy var titleLabel: NSTextField = .init()
  lazy var subtitleLabel: NSTextField = .init()

  override func loadView() {
    let view = NSView()
    view.wantsLayer = true
    self.view = view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.layer?.backgroundColor = NSColor.white.cgColor
    view.layer?.cornerRadius = 28
    view.layer?.masksToBounds = true

    titleLabel.backgroundColor = .clear
    titleLabel.isBezeled = false
    titleLabel.isEditable = false
    titleLabel.maximumNumberOfLines = 1
    titleLabel.font = NSFont.boldSystemFont(ofSize: 18)

    subtitleLabel.backgroundColor = .clear
    subtitleLabel.isBezeled = false
    subtitleLabel.isEditable = false
    subtitleLabel.maximumNumberOfLines = 1

    view.addSubviews(iconView, titleLabel, subtitleLabel)

    let margin: CGFloat = 20

    NSLayoutConstraint.constrain(
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
      iconView.widthAnchor.constraint(equalToConstant: 50),
      iconView.heightAnchor.constraint(equalToConstant: 50),

      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -12),

      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
    )
  }

  func update(with appearance: Application.Appearance, duration: TimeInterval = 0, then handler: (() -> Void)? = nil) {
    if duration > 0 {
      NSAnimationContext.current.allowsImplicitAnimation = true
      NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = 1.0
        switch appearance {
        case .dark:
          view.animator().layer?.backgroundColor = .black
          titleLabel.animator().textColor = .white
          subtitleLabel.animator().textColor = .lightGray
          subtitleLabel.animator().stringValue = "Dark mode"
        case .light:
          view.animator().layer?.backgroundColor = .white
          titleLabel.animator().textColor = .black
          subtitleLabel.animator().textColor = .darkGray
          subtitleLabel.animator().stringValue = "Light mode"
        }
      }, completionHandler:{
        handler?()
      })
    } else {
      switch appearance {
      case .dark:
        view.layer?.backgroundColor = .black
        titleLabel.animator().textColor = .white
        subtitleLabel.textColor = .lightGray
        subtitleLabel.stringValue = "Dark mode"
      case .light:
        view.layer?.backgroundColor = .white
        titleLabel.textColor = .black
        subtitleLabel.textColor = .darkGray
        subtitleLabel.stringValue = "Light mode"
      }
    }
  }
}

