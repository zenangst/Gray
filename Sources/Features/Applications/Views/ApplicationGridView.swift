import Cocoa
import UserInterface

protocol ApplicationGridViewDelegate: class {
  func applicationView(_ view: ApplicationGridView, didResetApplication currentAppearance: Application.Appearance?)
}

class ApplicationGridView: NSCollectionViewItem {
  lazy var baseView = NSView()
  weak var delegate: ApplicationGridViewDelegate?

  var currentAppearance: Application.Appearance?

  lazy var iconView: NSImageView = .init()
  lazy var titleLabel: NSTextField = .init()
  lazy var subtitleLabel: NSTextField = .init()

  override func loadView() {
    self.view = baseView
    self.view.wantsLayer = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Reset", action: #selector(resetApplication), keyEquivalent: ""))
    view.menu = menu

    view.layer?.backgroundColor = NSColor.white.cgColor
    view.layer?.cornerRadius = 20
    view.layer?.masksToBounds = true

    titleLabel.backgroundColor = .clear
    titleLabel.isBezeled = false
    titleLabel.isEditable = false
    titleLabel.maximumNumberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.backgroundColor = .clear
    subtitleLabel.isBezeled = false
    subtitleLabel.isEditable = false
    subtitleLabel.maximumNumberOfLines = 1
    subtitleLabel.font = NSFont.boldSystemFont(ofSize: 9)

    view.addSubviews(iconView, titleLabel, subtitleLabel)

    let margin: CGFloat = 14

    NSLayoutConstraint.constrain(
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
      iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
      iconView.widthAnchor.constraint(equalToConstant: 28),
      iconView.heightAnchor.constraint(equalToConstant: 28),

      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: 0),

      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
    )
  }

  override func viewDidLayout() {
    super.viewDidLayout()

    guard let currentAppearance = currentAppearance else { return }
    update(with: currentAppearance)
  }

  @objc func resetApplication() {
    delegate?.applicationView(self, didResetApplication: currentAppearance)
  }

  func update(with appearance: Application.Appearance, duration: TimeInterval = 0, then handler: (() -> Void)? = nil) {
    currentAppearance = appearance

    if duration > 0 {
      NSAnimationContext.current.allowsImplicitAnimation = true
      NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = duration
        switch appearance {
        case .dark:
          view.animator().layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
          titleLabel.animator().textColor = .white
          subtitleLabel.animator().textColor = .controlAccentColor
          view.layer?.borderWidth = 0.0
        case .system:
          view.animator().layer?.backgroundColor = NSColor.gray.cgColor
          titleLabel.animator().textColor = .white
          subtitleLabel.animator().textColor = .lightGray
          view.layer?.borderWidth = 0.0
        case .light:
          view.animator().layer?.backgroundColor = .white
          titleLabel.animator().textColor = .black
          subtitleLabel.animator().textColor = .controlAccentColor
          view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
          view.layer?.borderWidth = 0
        }
      }, completionHandler:{
        handler?()
      })
    } else {
      switch appearance {
      case .dark:
        view.layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
        titleLabel.textColor = .white
        subtitleLabel.textColor = .controlAccentColor
        view.layer?.borderWidth = 0.0
      case .light:
        view.layer?.backgroundColor = NSColor(named: "Light")?.cgColor
        titleLabel.textColor = .black
        subtitleLabel.textColor = .controlAccentColor
        view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
        view.layer?.borderWidth = 1.0
      case .system:
        switch view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
        case .darkAqua?:
          view.layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
          titleLabel.textColor = .white
          subtitleLabel.textColor = .lightGray
          view.layer?.borderWidth = 0.0
        case .aqua?:
          view.layer?.backgroundColor = NSColor(named: "Light")?.cgColor
          titleLabel.textColor = .black
          subtitleLabel.textColor = .controlAccentColor
          view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
          view.layer?.borderWidth = 1.0
        default:
          break
        }
      }
    }
  }
}

