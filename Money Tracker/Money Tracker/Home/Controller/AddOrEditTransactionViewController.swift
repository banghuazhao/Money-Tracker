//
//  AddOrEditTransactionViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/5/20.
//

import CoreData
#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import Sheeeeeeeeet
import SnapKit
import SwiftDate
import Then
import UIKit

protocol AddOrEditTransactionViewControllerDelegate: AnyObject {
    func didAddUserTransaction()
    func didEditUserTransaction()
    func didDeleteUserTransaction()
}

class AddOrEditTransactionViewController: UIViewController {
    weak var delegate: AddOrEditTransactionViewControllerDelegate?

    var isAdd: Bool = true
    var selectedCategory: String = "Grocery"
    var selectedDate = Date()
    var enteredAmount: Double = 0.0

    var transaction: Transaction? {
        didSet {
            guard let transaction = transaction,
                  let category = transaction.category,
                  let date = transaction.date else { return }
            typeSegmentedControl.selectedSegmentIndex = transaction.amount < 0 ? 0 : 1
            updateAmountCardStyle()
            selectedCategory = category
            updateCategoryUI(name: category)
            selectedDate = date
            dateButton.setTitle(date.toFormat("yyyy-MM-dd"), for: .normal)
            enteredAmount = transaction.amount
            let absValue = fabs(enteredAmount)
            amountTextView.text = absValue > 0 ? absValue.cleanZero : ""
            updateAmountPlaceholder()
            saveButton.isEnabled = enteredAmount != 0
            descriptionTextField.text = transaction.title
        }
    }

    // MARK: - UI

    private lazy var scrollView = UIScrollView().then { sv in
        sv.keyboardDismissMode = .onDrag
        sv.alwaysBounceVertical = true
    }

    // Hero amount card — stored so we can update its tint color
    private lazy var amountCard = UIView().then { v in
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
    }

    private lazy var typeSegmentedControl = UISegmentedControl(items: ["Expense".localized(), "Income".localized()]).then { sc in
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(tapTypeSegmentedControl(_:)), for: .valueChanged)
    }

    private lazy var amountTextView = UITextView().then { tv in
        tv.font = UIFont.monospacedDigitSystemFont(ofSize: 44, weight: .regular)
        tv.textAlignment = .center
        tv.keyboardType = .decimalPad
        tv.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        tv.text = ""
        tv.backgroundColor = .clear
        tv.inputAccessoryView = makeKeyboardToolbar()
        tv.delegate = self
    }

    private lazy var amountPlaceholderLabel = UILabel().then { l in
        l.text = "0.00"
        l.font = UIFont.monospacedDigitSystemFont(ofSize: 44, weight: .regular)
        l.textAlignment = .center
        l.isUserInteractionEnabled = false
    }

    private lazy var categoryLabel = UILabel().then { l in
        l.text = "Category".localized()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .label
    }

    private lazy var categoryButton = UIButton().then { b in
        b.addTarget(self, action: #selector(tapCategoryButton(_:)), for: .touchUpInside)
        b.setTitle("Grocery".localized(), for: .normal)
        b.setTitleColor(.themeColor, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.contentHorizontalAlignment = .right
    }

    private lazy var categoryIconView = UIImageView().then { iv in
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 8
        iv.layer.cornerCurve = .continuous
        iv.clipsToBounds = true
    }

    private lazy var categoryChevron = makeChevron()

    private lazy var dateLabel = UILabel().then { l in
        l.text = "Date".localized()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .label
    }

    private lazy var dateButton = UIButton().then { b in
        b.setTitle(Date().toFormat("yyyy-MM-dd"), for: .normal)
        b.setTitleColor(.themeColor, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.contentHorizontalAlignment = .right
        b.addTarget(self, action: #selector(tapDateButton(_:)), for: .touchUpInside)
    }

    private lazy var dateChevron = makeChevron()

    private lazy var descriptionTextField = UITextFieldPadding().then { tf in
        tf.placeholder = "Transaction Description".localized()
        tf.backgroundColor = .clear
        tf.font = .systemFont(ofSize: 15)
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.delegate = self
    }

    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.image = UIImage(systemName: "checkmark")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .themeColor
        let b = UIButton(configuration: config)
        b.addTarget(self, action: #selector(tapSaveButton(_:)), for: .touchUpInside)
        return b
    }()

    private lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Delete Transaction".localized()
        config.cornerStyle = .large
        config.image = UIImage(systemName: "trash")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .expenseRed
        let b = UIButton(configuration: config)
        b.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        return b
    }()

    #if !targetEnvironment(macCatalyst)
        private lazy var bannerView: GADBannerView = {
            let bv = GADBannerView()
            bv.adUnitID = Constants.bannerViewAdUnitID
            bv.rootViewController = self
            bv.load(GADRequest())
            return bv
        }()
        private var showsBanner: Bool { !IAPManager.shared.adsRemoved }
    #endif

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        var saveCfg = saveButton.configuration
        saveCfg?.title = isAdd ? "Save Transaction".localized() : "Update Transaction".localized()
        saveButton.configuration = saveCfg
        title = isAdd ? "Add Transaction".localized() : "Edit Transaction".localized()

        setupView()
        updateCategoryUI(name: selectedCategory)
        updateAmountCardStyle()
        saveButton.isEnabled = false
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }

    private var hasAppeared = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isAdd && !hasAppeared {
            amountTextView.becomeFirstResponder()
        }
        hasAppeared = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Layout

extension AddOrEditTransactionViewController {
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let inset: CGFloat = 16
        let rowH: CGFloat = 54

        // ── Amount hero card ──────────────────────────────────
        amountCard.addSubview(typeSegmentedControl)
        amountCard.addSubview(amountTextView)
        amountCard.addSubview(amountPlaceholderLabel)

        typeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview().offset(-inset)
        }
        amountTextView.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentedControl.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview().offset(-inset)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        amountPlaceholderLabel.snp.makeConstraints { $0.edges.equalTo(amountTextView) }
        updateAmountPlaceholder()

        // ── Details card ─────────────────────────────────────
        let detailsCard = UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 22
            v.layer.cornerCurve = .continuous
        }

        // Category row
        let categoryRow = UIView()
        let categoryTapOverlay = UIButton()
        categoryTapOverlay.addTarget(self, action: #selector(tapCategoryButton(_:)), for: .touchUpInside)
        categoryRow.addSubview(categoryLabel)
        categoryRow.addSubview(categoryIconView)
        categoryRow.addSubview(categoryButton)
        categoryRow.addSubview(categoryChevron)
        categoryRow.addSubview(categoryTapOverlay)

        categoryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalToSuperview()
        }
        categoryChevron.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(inset)
            make.centerY.equalToSuperview()
        }
        categoryIconView.snp.makeConstraints { make in
            make.right.equalTo(categoryButton.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        categoryButton.snp.makeConstraints { make in
            make.right.equalTo(categoryChevron.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(categoryLabel.snp.right).offset(8)
        }
        categoryTapOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        let div1 = makeDivider()

        // Date row
        let dateRow = UIView()
        let dateTapOverlay = UIButton()
        dateTapOverlay.addTarget(self, action: #selector(tapDateButton(_:)), for: .touchUpInside)
        dateRow.addSubview(dateLabel)
        dateRow.addSubview(dateButton)
        dateRow.addSubview(dateChevron)
        dateRow.addSubview(dateTapOverlay)

        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalToSuperview()
        }
        dateChevron.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(inset)
            make.centerY.equalToSuperview()
        }
        dateButton.snp.makeConstraints { make in
            make.right.equalTo(dateChevron.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(dateLabel.snp.right).offset(8)
        }
        dateTapOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        let div2 = makeDivider()

        // Description row (inside card, no border)
        let descriptionRow = UIView()
        descriptionRow.addSubview(descriptionTextField)
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.left.equalToSuperview().offset(inset - 8) // UITextFieldPadding adds 8
            make.right.equalToSuperview().offset(-inset + 8)
        }

        detailsCard.addSubview(categoryRow)
        detailsCard.addSubview(div1)
        detailsCard.addSubview(dateRow)
        detailsCard.addSubview(div2)
        detailsCard.addSubview(descriptionRow)

        categoryRow.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(rowH)
        }
        div1.snp.makeConstraints { make in
            make.top.equalTo(categoryRow.snp.bottom)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        dateRow.snp.makeConstraints { make in
            make.top.equalTo(div1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(rowH)
        }
        div2.snp.makeConstraints { make in
            make.top.equalTo(dateRow.snp.bottom)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        descriptionRow.snp.makeConstraints { make in
            make.top.equalTo(div2.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(rowH)
        }

        // ── Assemble in scroll view ───────────────────────────
        scrollView.addSubview(amountCard)
        scrollView.addSubview(detailsCard)
        scrollView.addSubview(saveButton)

        amountCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(inset)
            make.right.equalTo(view).offset(-inset)
        }
        detailsCard.snp.makeConstraints { make in
            make.top.equalTo(amountCard.snp.bottom).offset(16)
            make.left.equalTo(view).offset(inset)
            make.right.equalTo(view).offset(-inset)
        }

        #if !targetEnvironment(macCatalyst)
            if showsBanner { scrollView.addSubview(bannerView) }
        #endif

        let lastAnchor: ConstraintItem
        if !isAdd {
            scrollView.addSubview(deleteButton)
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(detailsCard.snp.bottom).offset(24)
                make.left.equalTo(view).offset(inset)
                make.right.equalTo(view).offset(-inset)
                make.height.equalTo(54)
            }
            deleteButton.snp.makeConstraints { make in
                make.top.equalTo(saveButton.snp.bottom).offset(12)
                make.left.equalTo(view).offset(inset)
                make.right.equalTo(view).offset(-inset)
                make.height.equalTo(54)
            }
            lastAnchor = deleteButton.snp.bottom
        } else {
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(detailsCard.snp.bottom).offset(24)
                make.left.equalTo(view).offset(inset)
                make.right.equalTo(view).offset(-inset)
                make.height.equalTo(54)
            }
            lastAnchor = saveButton.snp.bottom
        }

        #if !targetEnvironment(macCatalyst)
            if showsBanner {
                bannerView.snp.makeConstraints { make in
                    make.top.equalTo(lastAnchor).offset(20)
                    make.left.equalTo(view).offset(inset)
                    make.right.equalTo(view).offset(-inset)
                    make.height.equalTo(60)
                    make.bottom.equalToSuperview().offset(-20)
                }
            } else {
                scrollView.snp.makeConstraints { $0.bottom.equalTo(lastAnchor).offset(40) }
            }
        #else
            scrollView.snp.makeConstraints { $0.bottom.equalTo(lastAnchor).offset(40) }
        #endif
    }

    private func makeDivider() -> UIView {
        UIView().then { $0.backgroundColor = .separator }
    }

    private func makeChevron() -> UILabel {
        UILabel().then { l in
            l.text = "›"
            l.font = .systemFont(ofSize: 18, weight: .medium)
            l.textColor = .tertiaryLabel
            l.isUserInteractionEnabled = false
        }
    }

    private func makeKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flex, done]
        return toolbar
    }

    func updateAmountPlaceholder() {
        amountPlaceholderLabel.isHidden = !(amountTextView.text?.isEmpty ?? true)
    }

    private func updateAmountCardStyle() {
        let isExpense = typeSegmentedControl.selectedSegmentIndex == 0
        let color: UIColor = isExpense ? .expenseRed : .incomeGreen
        UIView.animate(withDuration: 0.25) {
            self.amountCard.backgroundColor = color.withAlphaComponent(0.08)
        }
        amountTextView.textColor = color
        amountPlaceholderLabel.textColor = color.withAlphaComponent(0.30)
    }

    private func updateCategoryUI(name: String) {
        let isUser = UserCategoryManager.shared.category(forName: name) != nil
        categoryButton.setTitle(isUser ? name : name.localized(), for: .normal)
        if let userCat = UserCategoryManager.shared.category(forName: name),
           let emoji = userCat.iconName {
            categoryIconView.image = UIImage.emoji(emoji, size: 36)
        } else {
            categoryIconView.image = UIImage.categoryIcon(for: name)
        }
    }
}

// MARK: - Keyboard

extension AddOrEditTransactionViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - Actions

extension AddOrEditTransactionViewController {
    @objc private func tapTypeSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedCategory = "Grocery"
            updateCategoryUI(name: "Grocery")
        } else {
            selectedCategory = "Salary"
            updateCategoryUI(name: "Salary")
        }
        updateAmountCardStyle()
        // Flip sign of any already-entered amount
        if enteredAmount != 0 {
            enteredAmount = sender.selectedSegmentIndex == 0 ? -fabs(enteredAmount) : fabs(enteredAmount)
        }
    }

    @objc private func tapCategoryButton(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let isIncome = typeSegmentedControl.selectedSegmentIndex == 1
        let vc = CategoryListViewController(isSelectMode: true, filterIncome: isIncome)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func tapDateButton(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let alert = UIAlertController(title: "Pick Date".localized(), message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.date = selectedDate
        datePicker.minimumDate = Date() - 100.years
        datePicker.maximumDate = Date() + 100.years
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
        ])
        alert.addAction(UIAlertAction(title: "Done".localized(), style: .default) { [weak self] _ in
            guard let self else { return }
            self.dateButton.setTitle(datePicker.date.toFormat("yyyy-MM-dd"), for: .normal)
            self.selectedDate = datePicker.date
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    @objc private func tapSaveButton(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        guard enteredAmount != 0.0 else {
            let alert = UIAlertController(
                title: "Amount Required".localized(),
                message: "Please enter an amount for this transaction.".localized(),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel) { [weak self] _ in
                self?.amountTextView.becomeFirstResponder()
            })
            present(alert, animated: true)
            return
        }

        view.endEditing(true)
        let context = CoreDataManager.shared.persistentContainer.viewContext

        if isAdd {
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSampleData) {
                CoreDataManager.shared.deleteAllTransactions()
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasSampleData)
            }
            let t = Transaction(context: context)
            t.category = selectedCategory
            t.date = selectedDate
            t.amount = enteredAmount
            t.title = descriptionTextField.text
        } else {
            transaction?.category = selectedCategory
            transaction?.date = selectedDate
            transaction?.amount = enteredAmount
            transaction?.title = descriptionTextField.text
        }

        do {
            try context.save()
            if isAdd { delegate?.didAddUserTransaction() } else { delegate?.didEditUserTransaction() }
        } catch {
            print("Failed to save transaction:", error)
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func tapDeleteButton(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController(
            title: "Delete Transaction".localized(),
            message: "Do you want to delete this transaction?".localized(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { [weak self] _ in
            guard let self, let transaction = self.transaction else { return }
            let context = CoreDataManager.shared.persistentContainer.viewContext
            context.delete(transaction)
            do {
                try context.save()
                self.delegate?.didDeleteUserTransaction()
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("Failed to delete transaction:", error)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension AddOrEditTransactionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        amountPlaceholderLabel.isHidden = true
    }

    func textViewDidChange(_ textView: UITextView) {
        if let value = Double(textView.text), value > 0 {
            enteredAmount = typeSegmentedControl.selectedSegmentIndex == 0 ? -value : value
        } else if textView.text.isEmpty {
            enteredAmount = 0.0
        } else if textView.text != "." {
            // reject non-numeric input by reverting
            let abs = fabs(enteredAmount)
            textView.text = abs > 0 ? abs.cleanZero : ""
        }
        saveButton.isEnabled = enteredAmount != 0
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if let value = Double(textView.text), value > 0 {
            enteredAmount = typeSegmentedControl.selectedSegmentIndex == 0 ? -value : value
            textView.text = value.cleanZero
        } else {
            enteredAmount = 0.0
            textView.text = ""
        }
        updateAmountPlaceholder()
        saveButton.isEnabled = enteredAmount != 0
    }
}

// MARK: - CategoryListViewControllerDelegate

extension AddOrEditTransactionViewController: CategoryListViewControllerDelegate {
    func categoryList(_ vc: CategoryListViewController, didSelect name: String) {
        selectedCategory = name
        updateCategoryUI(name: name)
        saveButton.isEnabled = enteredAmount != 0
    }
}

// MARK: - UITextFieldDelegate

extension AddOrEditTransactionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
