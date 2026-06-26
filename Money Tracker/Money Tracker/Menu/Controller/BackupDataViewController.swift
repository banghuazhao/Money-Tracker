//
//  BackupDataViewController.swift
//  Money Tracker
//

import SnapKit
import Then
import UIKit
#if !targetEnvironment(macCatalyst)
    import ProgressHUD
#endif

class BackupDataViewController: UIViewController {
    private enum Row: Int, CaseIterable {
        case backupToiCloud
        case restoreFromiCloud
    }

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Back up Data".localized()
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension BackupDataViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? Row.allCases.count : 0
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        return [
            "•" + " " + "To back up data, users need to login in iCloud and have a network connection.".localized(),
            "•" + " " + "The backup is valid across different devices (iPhone, iPad, Mac) for the same Apple ID.".localized(),
            "•" + " " + "If users change a device or reinstall this App, \"Restore data from iCloud\" can restore their previous saved data.".localized(),
        ].joined(separator: "\n")
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "Back Up Data Notes".localized() : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        switch Row(rawValue: indexPath.row)! {
        case .backupToiCloud:
            config.text = "Back up data to iCloud".localized()
        case .restoreFromiCloud:
            config.text = "Restore data from iCloud".localized()
        }
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Row(rawValue: indexPath.row)! {
        case .backupToiCloud:
            confirmAndBackup()
        case .restoreFromiCloud:
            navigationController?.pushViewController(RestoreDataViewController(), animated: true)
        }
    }

    // MARK: - Backup action

    private func confirmAndBackup() {
        let count = CoreDataManager.shared.fetchLocalTransactions().count
        let alert = UIAlertController(
            title: "Back up data to iCloud".localized(),
            message: String(format: "This will save %d transaction(s) and %d category(s) to iCloud.".localized(),
                           count,
                           UserCategoryManager.shared.fetchAll().count),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back Up".localized(), style: .default) { [weak self] _ in
            self?.performBackup()
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func performBackup() {
        #if !targetEnvironment(macCatalyst)
            ProgressHUD.show("Backing up...".localized())
        #endif
        Task {
            do {
                try await BackupManager.shared.saveBackup()
                await MainActor.run {
                    #if !targetEnvironment(macCatalyst)
                        ProgressHUD.dismiss()
                    #endif
                    self.showSuccess("Backup successful!".localized())
                }
            } catch {
                await MainActor.run {
                    #if !targetEnvironment(macCatalyst)
                        ProgressHUD.dismiss()
                    #endif
                    self.showError(error)
                }
            }
        }
    }

    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Success".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error".localized(),
            message: error.localizedDescription,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        present(alert, animated: true)
    }
}
