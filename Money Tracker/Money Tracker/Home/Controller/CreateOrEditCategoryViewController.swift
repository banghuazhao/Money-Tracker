//
//  CreateOrEditCategoryViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class CreateOrEditCategoryViewController: UIViewController {
    var onSave: (() -> Void)?

    private let existing: UserCategory?
    private var selectedEmoji: String = "📱"
    private var selectedIncome: Bool

    // MARK: - Emoji data

    private let emojiSections: [(title: String, emojis: [String])] = [
        ("Objects", ["📱", "⌚", "💻", "🖥", "🖨", "⌨️", "📷", "📸", "📺", "📻", "📡", "🔭", "🔬", "🔋", "💡", "🔦", "🕯", "🧯", "🪛", "🔧", "🔨", "🪚", "⚙️", "🔑", "🗝", "🔐"]),
        ("Money & Finance", ["💰", "💴", "💵", "💶", "💷", "💸", "💳", "🪙", "💎", "🏧", "💹", "📈", "📉", "🏦", "🧾"]),
        ("Food & Drink", ["🍔", "🍕", "🌮", "🌯", "🥗", "🍜", "🍱", "🍣", "🍦", "🎂", "🍺", "☕", "🧃", "🥤", "🍷", "🧁", "🥐", "🍞", "🍎", "🛒"]),
        ("Shopping", ["🛍", "🏪", "🏬", "🏷", "🎁", "📦", "🧧"]),
        ("Fashion", ["👗", "👘", "👙", "👚", "👛", "👜", "👝", "🎒", "👒", "🧢", "👑", "💍", "💄", "👠", "👡", "👢", "👟", "👞", "🥾", "🧤", "🧣", "🧦", "🧥", "🥼", "👔", "👕", "👖", "🎽", "🩴"]),
        ("Transportation", ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🛻", "✈️", "🚂", "🚢", "🚲", "🛵", "🏍", "⛽", "🅿️", "🚦", "🛺"]),
        ("Home & Living", ["🏠", "🏡", "🛋", "🪑", "🛁", "🚿", "🪴", "🧹", "🪣", "🧺", "🪞", "🛏", "🔌", "🏗"]),
        ("Health & Beauty", ["💊", "💉", "🩺", "🏥", "🩹", "🧴", "💆", "💅", "🧖", "🌡", "👓", "🕶", "🧼", "🪥"]),
        ("Education & Work", ["📚", "📖", "✏️", "📝", "🖊", "📐", "📏", "🎓", "🏫", "💼", "📊", "📋", "🗂", "📌", "🔬"]),
        ("Entertainment", ["🎬", "🎭", "🎵", "🎸", "🎹", "🎮", "🎲", "🎯", "🎡", "🎢", "🎪", "📖", "🎙", "🎟"]),
        ("Sports & Fitness", ["⚽", "🏀", "🏈", "⚾", "🎾", "🏐", "🏋️", "🤸", "🚴", "⛷", "🏊", "🧗", "🏆", "🥇", "🎿"]),
        ("Travel", ["🗺", "🏖", "🏔", "🏕", "🏨", "🌴", "🗼", "🗽", "🌅", "✈️", "🏝", "🎡"]),
        ("Nature & Animals", ["🐶", "🐱", "🐹", "🐰", "🦊", "🐻", "🐼", "🌿", "🌹", "🌳", "🌈", "⭐", "🌙", "☀️", "🌊"]),
        ("Family & Kids", ["👶", "🧒", "🧸", "🍼", "🎠", "🎒", "🖍", "🪀", "🎡"]),
        ("Subscriptions", ["📺", "🎵", "📱", "🎮", "☁️", "🔔", "📧", "🌐"]),
    ]

    // MARK: - UI

    private lazy var nameField = UITextField().then { tf in
        tf.placeholder = "Category Name".localized()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17)
        tf.returnKeyType = .done
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
    }

    private lazy var typeSegment = UISegmentedControl(items: [
        "Expense".localized(), "Income".localized(),
    ]).then { sc in
        sc.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
    }

    private lazy var emojiPreview = UILabel().then { l in
        l.font = .systemFont(ofSize: 44)
        l.textAlignment = .center
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        cv.register(EmojiSectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "EmojiSectionHeader")
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .secondarySystemBackground
        return cv
    }()

    // MARK: - Init

    init(existing: UserCategory?, defaultIncome: Bool) {
        self.existing = existing
        self.selectedIncome = defaultIncome
        super.init(nibName: nil, bundle: nil)
        if let cat = existing {
            self.selectedEmoji = cat.iconName ?? "📱"
            self.selectedIncome = cat.isIncome
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = existing == nil ? "Create Category".localized() : "Edit Category".localized()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save".localized(), style: .done,
            target: self, action: #selector(tapSave)
        )

        setupViews()

        nameField.text = existing?.name
        typeSegment.selectedSegmentIndex = selectedIncome ? 1 : 0
        emojiPreview.text = selectedEmoji
        preselectCurrentEmoji()
    }

    private func setupViews() {
        let nameCard = UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }
        nameCard.addSubview(nameField)
        nameField.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)) }
        nameCard.snp.makeConstraints { $0.height.equalTo(52) }

        let previewCard = UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }
        previewCard.addSubview(emojiPreview)
        previewCard.addSubview(typeSegment)

        emojiPreview.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
        }
        typeSegment.snp.makeConstraints { make in
            make.top.equalTo(emojiPreview.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
        }

        view.addSubview(nameCard)
        view.addSubview(previewCard)
        view.addSubview(collectionView)

        nameCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        previewCard.snp.makeConstraints { make in
            make.top.equalTo(nameCard.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(previewCard.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Actions

    @objc private func typeChanged() {
        selectedIncome = typeSegment.selectedSegmentIndex == 1
    }

    @objc private func tapSave() {
        guard let name = nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showToast("Please enter category name".localized())
            return
        }
        if let cat = existing {
            cat.name = name
            cat.iconName = selectedEmoji
            cat.isIncome = selectedIncome
            CoreDataManager.shared.saveContext()
        } else {
            UserCategoryManager.shared.create(name: name, iconName: selectedEmoji, isIncome: selectedIncome)
        }
        onSave?()
        navigationController?.popViewController(animated: true)
    }

    private func showToast(_ message: String) {
        let toast = UILabel().then { l in
            l.text = message
            l.textAlignment = .center
            l.font = .systemFont(ofSize: 14, weight: .medium)
            l.textColor = .white
            l.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            l.layer.cornerRadius = 12
            l.layer.masksToBounds = true
            l.numberOfLines = 0
        }
        view.addSubview(toast)
        toast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.left.greaterThanOrEqualToSuperview().offset(32)
            make.right.lessThanOrEqualToSuperview().offset(-32)
            make.height.greaterThanOrEqualTo(36)
        }
        toast.layoutIfNeeded()
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) { toast.alpha = 1 } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5) { toast.alpha = 0 } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }

    private func preselectCurrentEmoji() {
        for (s, section) in emojiSections.enumerated() {
            if let row = section.emojis.firstIndex(of: selectedEmoji) {
                collectionView.scrollToItem(at: IndexPath(item: row, section: s), at: .centeredVertically, animated: false)
                collectionView.selectItem(at: IndexPath(item: row, section: s), animated: false, scrollPosition: [])
                return
            }
        }
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension CreateOrEditCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { emojiSections.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojiSections[section].emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(emoji: emojiSections[indexPath.section].emojis[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = emojiSections[indexPath.section].emojis[indexPath.item]
        emojiPreview.text = selectedEmoji
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "EmojiSectionHeader", for: indexPath
        ) as! EmojiSectionHeader
        header.configure(title: emojiSections[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = floor(collectionView.bounds.width / 5)
        return CGSize(width: side, height: side)
    }
}

// MARK: - UITextFieldDelegate

extension CreateOrEditCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - EmojiCell

private class EmojiCell: UICollectionViewCell {
    private let label = UILabel().then { l in
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(emoji: String) { label.text = emoji }

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected
                ? UIColor.systemBlue.withAlphaComponent(0.2)
                : .clear
            contentView.layer.cornerRadius = 10
            contentView.layer.cornerCurve = .continuous
        }
    }
}

// MARK: - EmojiSectionHeader

private class EmojiSectionHeader: UICollectionReusableView {
    private let label = UILabel().then { l in
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) { label.text = title.uppercased() }
}
