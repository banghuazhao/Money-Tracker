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
            guard let transaction = transaction, let category = transaction.category, let date = transaction.date else { return }
            if categoryExpenses.contains(category) {
                typeSegmentedControl.selectedSegmentIndex = 0
            } else {
                typeSegmentedControl.selectedSegmentIndex = 1
            }
            selectedCategory = category
            categoryButton.setTitle(category.localized(), for: .normal)
            selectedDate = date
            dateButton.setTitle(date.toFormat("yyyy-MM-dd"), for: .normal)
            enteredAmount = transaction.amount
            amountTextView.text = fabs(enteredAmount).cleanZero
            descriptionTextField.text = transaction.title
        }
    }

    // MARK: - UI related

    lazy var scrollView = UIScrollView()
    lazy var typeLabel = UILabel().then { label in
        label.text = "Type".localized()
    }

    lazy var typeSegmentedControl = UISegmentedControl(items: ["Expense".localized(), "Income".localized()]).then { sc in
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(tapTypeSegmentedControl(_:)), for: .valueChanged)
    }

    lazy var categoryLabel = UILabel().then { label in
        label.text = "Category".localized()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
    }

    lazy var categoryButton = UIButton().then { button in
        button.addTarget(self, action: #selector(tapCategoryButton(_:)), for: .touchUpInside)
        button.setTitle("Grocery".localized(), for: .normal)
        button.setTitleColor(.themeColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.contentHorizontalAlignment = .right
    }

    lazy var dateLabel = UILabel().then { label in
        label.text = "Date".localized()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
    }

    lazy var dateButton = UIButton().then { button in
        button.setTitle(Date().toFormat("yyyy-MM-dd"), for: .normal)
        button.setTitleColor(.themeColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(tapDateButton(_:)), for: .touchUpInside)
    }

    lazy var amountLabel = UILabel().then { label in
        label.text = "Amount".localized() + " (-)"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
    }

    lazy var amountTextView = UITextView().then { textView in
        textView.layer.cornerRadius = 14
        textView.layer.cornerCurve = .continuous
        textView.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        textView.textAlignment = .center
        textView.keyboardType = .decimalPad
        textView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        textView.text = "0"
        textView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        textView.delegate = self
    }

    lazy var descriptionTextField = UITextFieldPadding().then { textField in
        textField.layer.cornerRadius = 14
        textField.layer.cornerCurve = .continuous
        textField.placeholder = "Transaction Description".localized()
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.clearButtonMode = .whileEditing
    }

    lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.image = UIImage(systemName: "checkmark")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .themeColor
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tapSaveButton(_:)), for: .touchUpInside)
        return button
    }()

    lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Delete Transaction".localized()
        config.cornerStyle = .large
        config.image = UIImage(systemName: "trash")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .expenseRed
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        return button
    }()

    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        if isAdd {
            title = "Add Transaction".localized()
            var config = saveButton.configuration
            config?.title = "Save Transaction".localized()
            saveButton.configuration = config
        } else {
            title = "Edit Transaction".localized()
            var config = saveButton.configuration
            config?.title = "Update Transaction".localized()
            saveButton.configuration = config
        }
        hideKeyboardWhenTappedAround()
        setupView()
    }
}

// MARK: - private funcitons

extension AddOrEditTransactionViewController {
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Card container for form rows
        let formCard = UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 16
            v.layer.cornerCurve = .continuous
        }

        // Dividers between rows
        let divider1 = makeDivider()
        let divider2 = makeDivider()
        let divider3 = makeDivider()

        formCard.addSubview(typeLabel)
        formCard.addSubview(typeSegmentedControl)
        formCard.addSubview(divider1)
        formCard.addSubview(categoryLabel)
        formCard.addSubview(categoryButton)
        formCard.addSubview(divider2)
        formCard.addSubview(dateLabel)
        formCard.addSubview(dateButton)
        formCard.addSubview(divider3)
        formCard.addSubview(amountLabel)
        formCard.addSubview(amountTextView)

        scrollView.addSubview(formCard)
        scrollView.addSubview(descriptionTextField)
        scrollView.addSubview(saveButton)

        // -- formCard layout --
        formCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }

        let rowH: CGFloat = 54
        let inset: CGFloat = 16

        typeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalTo(typeSegmentedControl)
        }
        typeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(inset)
            make.height.equalTo(36)
            make.width.equalTo(180)
            make.left.greaterThanOrEqualTo(typeLabel.snp.right).offset(8)
        }

        divider1.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentedControl.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        categoryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalTo(categoryButton)
        }
        categoryButton.snp.makeConstraints { make in
            make.top.equalTo(divider1.snp.bottom)
            make.right.equalToSuperview().inset(inset)
            make.height.equalTo(rowH)
            make.width.lessThanOrEqualTo(200)
            make.left.greaterThanOrEqualTo(categoryLabel.snp.right).offset(8)
        }

        divider2.snp.makeConstraints { make in
            make.top.equalTo(categoryButton.snp.bottom)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalTo(dateButton)
        }
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(divider2.snp.bottom)
            make.right.equalToSuperview().inset(inset)
            make.height.equalTo(rowH)
            make.width.lessThanOrEqualTo(200)
            make.left.greaterThanOrEqualTo(dateLabel.snp.right).offset(8)
        }

        divider3.snp.makeConstraints { make in
            make.top.equalTo(dateButton.snp.bottom)
            make.left.equalToSuperview().offset(inset)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        amountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(inset)
            make.centerY.equalTo(amountTextView)
        }
        amountTextView.snp.makeConstraints { make in
            make.top.equalTo(divider3.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(inset)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.width.equalTo(140)
            make.left.greaterThanOrEqualTo(amountLabel.snp.right).offset(8)
        }

        // -- items below the card --
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(formCard.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.height.equalTo(50)
        }

        #if !targetEnvironment(macCatalyst)
            scrollView.addSubview(bannerView)
        #endif

        if isAdd {
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(descriptionTextField.snp.bottom).offset(24)
                make.left.equalTo(view).offset(16)
                make.right.equalTo(view).offset(-16)
                make.height.equalTo(54)
                make.bottom.equalToSuperview().offset(-40)
            }
            #if !targetEnvironment(macCatalyst)
                bannerView.snp.makeConstraints { make in
                    make.top.equalTo(saveButton.snp.bottom).offset(20)
                    make.left.equalTo(view).offset(16)
                    make.right.equalTo(view).offset(-16)
                    make.height.equalTo(60)
                    make.bottom.equalToSuperview().offset(-20)
                }
            #endif
        } else {
            scrollView.addSubview(deleteButton)
            saveButton.snp.makeConstraints { make in
                make.top.equalTo(descriptionTextField.snp.bottom).offset(24)
                make.left.equalTo(view).offset(16)
                make.right.equalTo(view).offset(-16)
                make.height.equalTo(54)
            }
            deleteButton.snp.makeConstraints { make in
                make.top.equalTo(saveButton.snp.bottom).offset(12)
                make.left.equalTo(view).offset(16)
                make.right.equalTo(view).offset(-16)
                make.height.equalTo(54)
                make.bottom.equalToSuperview().offset(-40)
            }
            #if !targetEnvironment(macCatalyst)
                bannerView.snp.makeConstraints { make in
                    make.top.equalTo(deleteButton.snp.bottom).offset(20)
                    make.left.equalTo(view).offset(16)
                    make.right.equalTo(view).offset(-16)
                    make.height.equalTo(60)
                    make.bottom.equalToSuperview().offset(-20)
                }
            #endif
        }
    }

    private func makeDivider() -> UIView {
        UIView().then { v in
            v.backgroundColor = UIColor.separator
        }
    }
}

// MARK: - actions

extension AddOrEditTransactionViewController {
    @objc private func tapTypeSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedCategory = "Grocery"
            categoryButton.setTitle("Grocery".localized(), for: .normal)
            amountLabel.text = "Amount".localized() + " (-)"
            enteredAmount = -fabs(enteredAmount)
        } else {
            selectedCategory = "Salary"
            categoryButton.setTitle("Salary".localized(), for: .normal)
            amountLabel.text = "Amount".localized() + " (+)"
            enteredAmount = fabs(enteredAmount)
        }
    }

    @objc private func tapCategoryButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        var items: [MenuItem] = []
        if typeSegmentedControl.selectedSegmentIndex == 0 {
            for tempCategory in categoryExpenses {
                let item = SingleSelectItem(title: tempCategory.localized(), isSelected: tempCategory == selectedCategory, image: UIImage.categoryIcon(for: tempCategory))
                items.append(item)
            }
        } else {
            for tempCategory in categoryIncomes {
                let item = SingleSelectItem(title: tempCategory.localized(), isSelected: tempCategory == selectedCategory, image: UIImage.categoryIcon(for: tempCategory))
                items.append(item)
            }
        }

        let cancelButton = CancelButton(title: "Cancel".localized())
        items.append(cancelButton)
        let menu = Menu(title: "Select a Category".localized(), items: items)

        let sheet = menu.toActionSheet { [weak self] _, item in
            guard let self = self else { return }
            guard item.title != "Cancel".localized() && item.title != "Select a Category".localized() else { return }
            let title = item.title
            let index = items.firstIndex { (item) -> Bool in
                item.title == title
            }
            if self.typeSegmentedControl.selectedSegmentIndex == 0 {
                if let index = index {
                    self.selectedCategory = categoryExpenses[index]
                }
            } else {
                if let index = index {
                    self.selectedCategory = categoryIncomes[index]
                }
            }
            self.categoryButton.setTitle(title, for: .normal)
        }
        sheet.present(in: self, from: sender)
    }

    @objc private func tapDateButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
            guard let self = self else { return }
            sender.setTitle(datePicker.date.toFormat("yyyy-MM-dd"), for: .normal)
            self.selectedDate = datePicker.date
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    @objc private func tapSaveButton(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let context = CoreDataManager.shared.persistentContainer.viewContext
        if isAdd {
            // The user's first real entry replaces the first-run sample data so
            // their records never get mixed up with the examples.
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSampleData) {
                CoreDataManager.shared.deleteAllTransactions()
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.hasSampleData)
            }
            let newTransaction = Transaction(context: context)
            newTransaction.category = selectedCategory
            newTransaction.date = selectedDate
            newTransaction.amount = enteredAmount
            newTransaction.title = descriptionTextField.text
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
            guard let self = self, let transaction = self.transaction else { return }
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
    func textViewDidEndEditing(_ textView: UITextView) {
        if let value = Double(textView.text) {
            if typeSegmentedControl.selectedSegmentIndex == 0 {
                enteredAmount = -value
            } else {
                enteredAmount = value
            }
        } else if textView.text == "" {
            enteredAmount = 0.0
        }
        textView.text = fabs(enteredAmount).cleanZero
    }

    func textViewDidChange(_ textView: UITextView) {
        if let value = Double(textView.text) {
            if typeSegmentedControl.selectedSegmentIndex == 0 {
                enteredAmount = -value
            } else {
                enteredAmount = value
            }
        } else if textView.text == "" {
        } else {
            textView.text = fabs(enteredAmount).cleanZero
        }
    }
}
