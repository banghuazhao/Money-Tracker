//
//  AddOrEditTransactionViewController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/5/20.
//

import CoreData
import DatePickerDialog
#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import Sheeeeeeeeet
import SwiftDate
import UIKit

protocol AddOrEditTransactionViewControllerDelegate: class {
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
    let datePickerDialog = DatePickerDialog()
    var transaction: Transaction? {
        didSet {
            guard let transaction = transaction, let category = transaction.category, let date = transaction.date else { return }
            if categoryExpenses.contains(category) {
                typeSegmentedControl.selectedSegmentIndex = 0
            } else {
                typeSegmentedControl.selectedSegmentIndex = 1
            }
            selectedCategory = category
            categoryButton.setAttributedTitle(NSAttributedString(
                string: category.localized(),
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                ]), for: .normal)
            selectedDate = date
            dateButton.setAttributedTitle(NSAttributedString(
                string: date.toFormat("yyyy-MM-dd"),
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                ]), for: .normal)
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
    }

    lazy var categoryButton = UIButton().then { button in
        button.addTarget(self, action: #selector(tapCategoryButton(_:)), for: .touchUpInside)
        button.setAttributedTitle(NSAttributedString(
            string: "Grocery".localized(),
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
            ]), for: .normal)
    }

    lazy var dateLabel = UILabel().then { label in
        label.text = "Date".localized()
    }

    lazy var dateButton = UIButton().then { button in
        let date = Date()
        button.setAttributedTitle(NSAttributedString(
            string: date.toFormat("yyyy-MM-dd"),
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
            ]), for: .normal)
        button.addTarget(self, action: #selector(tapDateButton(_:)), for: .touchUpInside)
    }

    lazy var amountLabel = UILabel().then { label in
        label.text = "Amount".localized() + " (-)"
    }

    lazy var amountTextView = UITextView().then { textView in
        textView.layer.cornerRadius = 24
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.textAlignment = .center
        textView.keyboardType = .decimalPad
        textView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        textView.text = "0"
        textView.backgroundColor = UIColor(hex: "#C2EEF5").alpha(0.4)
        textView.delegate = self
    }

    lazy var descriptionTextField = UITextFieldPadding().then { textField in
        textField.layer.cornerRadius = 24
        textField.placeholder = "Transaction Description".localized()
        textField.backgroundColor = UIColor(hex: "#C2EEF5").alpha(0.4)
    }

    lazy var saveButton = UIButton(type: .custom).then { button in
        button.setImage(UIImage(named: "save_button"), for: .normal)
        button.addTarget(self, action: #selector(tapSaveButton(_:)), for: .touchUpInside)
    }

    lazy var deleteButton = UIButton(type: .custom).then { button in
        button.setImage(UIImage(named: "delete_button"), for: .normal)
        button.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
    }

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
        view.backgroundColor = .systemBackground
        if isAdd {
            title = "Add Transaction".localized()
        } else {
            title = "Edit Transaction".localized()
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

        scrollView.addSubview(typeSegmentedControl)
        scrollView.addSubview(typeLabel)
        scrollView.addSubview(categoryButton)
        scrollView.addSubview(categoryLabel)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(dateButton)
        scrollView.addSubview(amountTextView)
        scrollView.addSubview(amountLabel)
        scrollView.addSubview(descriptionTextField)
        scrollView.addSubview(saveButton)

        typeSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(160)
            make.height.equalTo(48)
        }

        typeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-88)
            make.centerY.equalTo(typeSegmentedControl)
        }

        categoryButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.top.equalTo(typeSegmentedControl.snp.bottom).offset(24)
            make.width.equalTo(160)
            make.height.equalTo(48)
        }

        categoryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-88)
            make.centerY.equalTo(categoryButton)
        }

        dateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.top.equalTo(categoryButton.snp.bottom).offset(24)
            make.width.equalTo(160)
            make.height.equalTo(48)
        }

        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-88)
            make.centerY.equalTo(dateButton)
        }

        amountTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(80)
            make.top.equalTo(dateButton.snp.bottom).offset(24)
            make.width.equalTo(160)
            make.height.equalTo(48)
        }

        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-88)
            make.centerY.equalTo(amountTextView)
        }

        descriptionTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(amountTextView.snp.bottom).offset(24)
            make.width.equalTo(312)
            make.height.equalTo(48)
        }

        #if !targetEnvironment(macCatalyst)
            scrollView.addSubview(bannerView)
        #endif

        if isAdd {
            saveButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(descriptionTextField.snp.bottom).offset(24)
                make.width.equalTo(312)
                make.height.equalTo(54)
                make.bottom.equalToSuperview().offset(-80 - 300)
            }
            #if !targetEnvironment(macCatalyst)
                bannerView.snp.makeConstraints { make in
                    make.top.equalTo(saveButton.snp.bottom).offset(24)
                    make.width.equalToSuperview().offset(-32)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(280)
                }
            #endif
        } else {
            saveButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(descriptionTextField.snp.bottom).offset(24)
                make.width.equalTo(312)
                make.height.equalTo(54)
            }
            scrollView.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(saveButton.snp.bottom).offset(24)
                make.width.equalTo(312)
                make.height.equalTo(54)
                make.bottom.equalToSuperview().offset(-80 - 300)
            }
            #if !targetEnvironment(macCatalyst)
                bannerView.snp.makeConstraints { make in
                    make.top.equalTo(deleteButton.snp.bottom).offset(24)
                    make.width.equalToSuperview().offset(-32)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(280)
                }
            #endif
        }
    }
}

// MARK: - actions

extension AddOrEditTransactionViewController {
    @objc private func tapTypeSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedCategory = "Grocery"
            categoryButton.setAttributedTitle(NSAttributedString(
                string: "Grocery".localized(),
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                ]), for: .normal)
            amountLabel.text = "Amount".localized() + " (-)"
            enteredAmount = -fabs(enteredAmount)
        } else {
            selectedCategory = "Salary"
            categoryButton.setAttributedTitle(NSAttributedString(
                string: "Salary".localized(),
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                ]), for: .normal)
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
                let item = SingleSelectItem(title: tempCategory.localized(), isSelected: tempCategory == selectedCategory, image: UIImage(named: tempCategory))
                items.append(item)
            }
        } else {
            for tempCategory in categoryIncomes {
                let item = SingleSelectItem(title: tempCategory.localized(), isSelected: tempCategory == selectedCategory, image: UIImage(named: tempCategory))
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
            self.categoryButton.setAttributedTitle(NSAttributedString(
                string: title,
                attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                ]), for: .normal)
        }
        sheet.present(in: self, from: sender)
    }

    @objc private func tapDateButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if #available(iOS 13.4, *) {
            datePickerDialog.datePicker.preferredDatePickerStyle = .wheels
        }
        print(selectedDate)
        datePickerDialog.show("Pick Date".localized(),
                              doneButtonTitle: "Done".localized(),
                              cancelButtonTitle: "Cancel".localized(),
                              defaultDate: selectedDate,
                              minimumDate: Date() - 100.years,
                              maximumDate: Date() + 100.years,
                              datePickerMode: .date) { [weak self]
            (date) -> Void in
            if let date = date, let self = self {
                sender.setAttributedTitle(NSAttributedString(
                    string: date.toFormat("yyyy-MM-dd"),
                    attributes: [
                        NSAttributedString.Key.foregroundColor: UIColor(hex: "#4A90E2"),
                    ]), for: .normal)
                self.selectedDate = date
            }
        }
    }

    @objc private func tapSaveButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if isAdd {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            let newTransaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: context) as! Transaction

            newTransaction.category = selectedCategory

            newTransaction.date = selectedDate

            newTransaction.amount = enteredAmount

            newTransaction.title = descriptionTextField.text

            do {
                try context.save()

                delegate?.didAddUserTransaction()
            } catch let saveErr {
                print("Failed to save Event:", saveErr)
            }
        } else {
            transaction?.category = selectedCategory

            transaction?.date = selectedDate

            transaction?.amount = enteredAmount

            transaction?.title = descriptionTextField.text

            let context = CoreDataManager.shared.persistentContainer.viewContext
            do {
                try context.save()

                delegate?.didEditUserTransaction()
            } catch let saveErr {
                print("Failed to save user Event:", saveErr)
            }
        }

        navigationController?.popViewController(animated: true)
    }

    @objc private func tapDeleteButton(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let alterController = UIAlertController(title: "Do you want to delete this transaction?".localized(), message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            let context = CoreDataManager.shared.persistentContainer.viewContext

            context.delete(self.transaction!)

            do {
                try context.save()

                self.delegate?.didDeleteUserTransaction()
                self.navigationController?.popViewController(animated: true)
            } catch let saveErr {
                print("Failed to save Event:", saveErr)
            }
        }

        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alterController.addAction(action1)
        alterController.addAction(cancel)
        present(alterController, animated: true, completion: nil)
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
