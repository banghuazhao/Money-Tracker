//
//  TipCalculatorViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit

class TipCalculatorViewController: UIViewController {
    // MARK: - Input fields

    private lazy var billField = makeTextField(placeholder: "60", keyboard: .decimalPad)
    private lazy var peopleField = makeTextField(placeholder: "2", keyboard: .numberPad)

    // Tip percentage: 10 / 15 / 18 / 20 / 25
    private let tipOptions = [10, 15, 18, 20, 25]
    private lazy var tipSegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: tipOptions.map { "\($0)%" })
        sc.selectedSegmentIndex = 3 // 20%
        sc.addTarget(self, action: #selector(recalculate), for: .valueChanged)
        return sc
    }()

    // MARK: - Result labels

    private lazy var tipAmountLabel = makeResultValue(color: .themeColor)
    private lazy var totalLabel = makeResultValue(color: .label)
    private lazy var perPersonLabel = makeResultValue(color: .incomeGreen)

    private lazy var shareButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)),
        style: .plain, target: self, action: #selector(tapShare))

    private lazy var clearButton = UIBarButtonItem(
        image: UIImage(systemName: "arrow.counterclockwise"),
        style: .plain, target: self, action: #selector(clearAll))

    private lazy var resultCard: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 20
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tip Calculator".localized()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        hideKeyboardWhenTappedAround()
        navigationItem.rightBarButtonItems = [shareButton, clearButton]
        setupViews()

        billField.text = "60"
        peopleField.text = "2"
        [billField, peopleField].forEach {
            $0.addTarget(self, action: #selector(recalculate), for: .editingChanged)
        }
        recalculate()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // Tip percentage card
        let tipCard = makeCard()
        let tipTitle = UILabel().then { l in
            l.text = "Tip Percentage".localized()
            l.font = UIFont.systemFont(ofSize: 16)
        }
        tipCard.addSubview(tipTitle)
        tipCard.addSubview(tipSegment)
        tipTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        tipSegment.snp.makeConstraints { make in
            make.top.equalTo(tipTitle.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
        }

        // Input card
        let inputCard = makeCard()
        let r1 = makeInputRow(title: "Bill Amount".localized(), field: billField, unit: "$")
        let d1 = makeDivider()
        let r2 = makeInputRow(title: "Split Between".localized(), field: peopleField, unit: "👥")

        for sub in [r1, d1, r2] { inputCard.addSubview(sub) }
        r1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        d1.snp.makeConstraints { make in
            make.top.equalTo(r1.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        r2.snp.makeConstraints { make in
            make.top.equalTo(d1.snp.bottom); make.left.right.bottom.equalToSuperview(); make.height.equalTo(54)
        }

        // Result card
        let rr1 = makePrimaryResultRow(title: "Tip Amount".localized(), value: tipAmountLabel)
        let rd1 = makeDivider()
        let rr2 = makeResultRow(title: "Total".localized(), value: totalLabel)
        let rd2 = makeDivider()
        let rr3 = makeResultRow(title: "Per Person".localized(), value: perPersonLabel)

        for sub in [rr1, rd1, rr2, rd2, rr3] { resultCard.addSubview(sub) }
        rr1.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview(); make.height.equalTo(92)
        }
        rd1.snp.makeConstraints { make in
            make.top.equalTo(rr1.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        rr2.snp.makeConstraints { make in
            make.top.equalTo(rd1.snp.bottom); make.left.right.equalToSuperview(); make.height.equalTo(54)
        }
        rd2.snp.makeConstraints { make in
            make.top.equalTo(rr2.snp.bottom); make.left.equalToSuperview().offset(16); make.right.equalToSuperview(); make.height.equalTo(0.5)
        }
        rr3.snp.makeConstraints { make in
            make.top.equalTo(rd2.snp.bottom); make.left.right.bottom.equalToSuperview(); make.height.equalTo(54)
        }

        // Assemble
        contentView.addSubview(tipCard)
        contentView.addSubview(inputCard)
        contentView.addSubview(resultCard)

        tipCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        inputCard.snp.makeConstraints { make in
            make.top.equalTo(tipCard.snp.bottom).offset(16)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
        }
        resultCard.snp.makeConstraints { make in
            make.top.equalTo(inputCard.snp.bottom).offset(20)
            make.left.equalTo(view).offset(16)
            make.right.equalTo(view).offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - Actions

    @objc private func recalculate() {
        guard
            let bText = billField.text, let bill = Double(bText), bill > 0
        else {
            [tipAmountLabel, totalLabel, perPersonLabel].forEach { $0.text = "—" }
            shareButton.isEnabled = false
            return
        }

        let people = max(Double(peopleField.text ?? "") ?? 1, 1)
        let tipPercent = Double(tipOptions[tipSegment.selectedSegmentIndex])

        let tip = bill * tipPercent / 100.0
        let total = bill + tip
        let perPerson = total / people

        tipAmountLabel.text = convertDoubleToCurrency(amount: tip)
        totalLabel.text = convertDoubleToCurrency(amount: total)
        perPersonLabel.text = convertDoubleToCurrency(amount: perPerson)
        shareButton.isEnabled = true
    }

    @objc private func clearAll() {
        billField.text = "60"
        peopleField.text = "2"
        tipSegment.selectedSegmentIndex = 3
        recalculate()
    }

    @objc private func tapShare() {
        let bill = convertDoubleToCurrency(amount: Double(billField.text ?? "") ?? 0)
        let tipPct = "\(tipOptions[tipSegment.selectedSegmentIndex])%"
        let people = peopleField.text.flatMap { Int($0) }.map { "\($0)" } ?? "1"
        let text = """
        \("Tip Calculator".localized())

        \("Bill Amount".localized()): \(bill)
        \("Tip Percentage".localized()): \(tipPct)
        \("Split Between".localized()): \(people)

        \("Tip Amount".localized()): \(tipAmountLabel.text ?? "")
        \("Total".localized()): \(totalLabel.text ?? "")
        \("Per Person".localized()): \(perPersonLabel.text ?? "")

        via Money Tracker
        """
        let avc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = avc.popoverPresentationController { popover.barButtonItem = shareButton }
        present(avc, animated: true)
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        UIView().then { v in
            v.backgroundColor = .secondarySystemBackground
            v.layer.cornerRadius = 20
            v.layer.cornerCurve = .continuous
        }
    }

    private func makeDivider() -> UIView {
        UIView().then { v in v.backgroundColor = .separator }
    }

    private func makeTextField(placeholder: String, keyboard: UIKeyboardType) -> UITextField {
        UITextField().then { tf in
            tf.placeholder = placeholder
            tf.keyboardType = keyboard
            tf.textAlignment = .right
            tf.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        }
    }

    private func makeInputRow(title: String, field: UITextField, unit: String) -> UIView {
        let row = UIView()
        let lbl = UILabel().then { l in l.text = title; l.font = .systemFont(ofSize: 16) }
        let unitLbl = UILabel().then { l in l.text = unit; l.font = .systemFont(ofSize: 16); l.textColor = .secondaryLabel }
        let tapOverlay = UIButton()
        tapOverlay.addTarget(field, action: #selector(UIResponder.becomeFirstResponder), for: .touchUpInside)
        row.addSubview(lbl)
        row.addSubview(unitLbl)
        row.addSubview(field)
        row.addSubview(tapOverlay)
        lbl.snp.makeConstraints { $0.left.equalToSuperview().offset(16); $0.centerY.equalToSuperview() }
        unitLbl.snp.makeConstraints { $0.right.equalToSuperview().offset(-16); $0.centerY.equalToSuperview() }
        field.snp.makeConstraints { make in
            make.right.equalTo(unitLbl.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(lbl.snp.right).offset(8)
            make.width.greaterThanOrEqualTo(80)
        }
        tapOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        return row
    }

    private func makeResultValue(color: UIColor) -> UILabel {
        UILabel().then { l in
            l.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
            l.textColor = color
            l.textAlignment = .right
        }
    }

    private func makePrimaryResultRow(title: String, value: UILabel) -> UIView {
        let accent = value.textColor ?? .label
        value.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
        value.textAlignment = .center
        value.adjustsFontSizeToFitWidth = true
        value.minimumScaleFactor = 0.6
        let row = UIView()
        row.backgroundColor = accent.withAlphaComponent(0.10)
        let lbl = UILabel().then { l in
            l.text = title.uppercased()
            l.font = .systemFont(ofSize: 12, weight: .semibold)
            l.textColor = accent
            l.textAlignment = .center
        }
        row.addSubview(lbl)
        row.addSubview(value)
        lbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        value.snp.makeConstraints { make in
            make.top.equalTo(lbl.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(16)
        }
        return row
    }

    private func makeResultRow(title: String, value: UILabel) -> UIView {
        let row = UIView()
        let lbl = UILabel().then { l in l.text = title; l.font = .systemFont(ofSize: 15); l.textColor = .secondaryLabel }
        row.addSubview(lbl)
        row.addSubview(value)
        lbl.snp.makeConstraints { $0.left.equalToSuperview().offset(16); $0.centerY.equalToSuperview() }
        value.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(lbl.snp.right).offset(8)
        }
        return row
    }
}
