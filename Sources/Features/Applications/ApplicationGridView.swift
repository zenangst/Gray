import Cocoa
import UserInterface

protocol ApplicationGridViewDelegate: class {
  func applicationView(_ view: ApplicationGridView, didResetApplication currentAppearance: Application.Appearance?)
}

// sourcery: let application = Application
class ApplicationGridView: NSCollectionViewItem, CollectionViewItemComponent, AppearanceAware {
  lazy var baseView = OpaqueView()
  weak var delegate: ApplicationGridViewDelegate?

  // sourcery: currentAppearance = model.application.appearance
  var currentAppearance: Application.Appearance?

  // sourcery: $RawBinding = "iconStore.loadIcon(for: model.application) { image in view.iconView.image = image }"
  lazy var iconView = NSImageView()
  // sourcery: let title: String = "titleLabel.stringValue = model.application.localizedName ?? model.title"
  lazy var titleLabel = NSTextField()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel = NSTextField()

  override func loadView() {
    self.view = baseView
    baseView.wantsLayer = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Reset".localized, action: #selector(resetApplication), keyEquivalent: ""))
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
}

