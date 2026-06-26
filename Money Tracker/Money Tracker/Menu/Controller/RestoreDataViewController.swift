//
//  RestoreDataViewController.swift
//  Money Tracker
//

import CloudKit
import SnapKit
import Then
import UIKit
#if !targetEnvironment(macCatalyst)
    import ProgressHUD
#endif

class RestoreDataViewController: UIViewController {
    private var entries: [BackupEntry] = []

    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "BackupCell")
    }

    private lazy var deleteAllButton = UIBarButtonItem(
        image: UIImage(systemName: "trash"),
        style: .plain,
        target: self,
        action: #selector(tapDeleteAll))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Restore Data".localized()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = deleteAllButton
        deleteAllButton.tintColor = .expenseRed

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        loadBackups()
    }

    // MARK: - Load

    private func loadBackups() {
        #if !targetEnvironment(macCatalyst)
            ProgressHUD.show()
        #endif
        Task {
            do {
                let loaded = try await BackupManager.shared.fetchBackups()
                await MainActor.run {
                    #if !targetEnvironment(macCatalyst)
                        ProgressHUD.dismiss()
                    #endif
                    self.entries = loaded
                    self.tableView.reloadData()
                    self.deleteAllButton.isEnabled = !loaded.isEmpty
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

    // MARK: - Delete all

    @objc private func tapDeleteAll() {
        let alert = UIAlertController(
            title: "Delete All Backups".localized(),
            message: "This will permanently delete all iCloud backups. This action cannot be undone.".localized(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete All".localized(), style: .destructive) { [weak self] _ in
            self?.performDeleteAll()
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private func performDeleteAll() {
        #if !targetEnvironment(macCatalyst)
            ProgressHUD.show("Deleting...".localized())
        #endif
        Task {
            do {
                try await BackupManager.shared.deleteAllBackups()
                await MainActor.run {
                    #if !targetEnvironment(macCatalyst)
                        ProgressHUD.dismiss()
                    #endif
                    self.entries = []
                    self.tableView.reloadData()
                    self.deleteAllButton.isEnabled = false
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

    // MARK: - Helpers

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error".localized(), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        present(alert, animated: true)
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()
}

// MARK: - UITableViewDataSource / Delegate

extension RestoreDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackupCell", for: indexPath)
        let entry = entries[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.image = UIImage(systemName: "folder")
        config.imageProperties.tintColor = .secondaryLabel
        config.text = Self.dateFormatter.string(from: entry.date)
        config.secondaryText = String(
            format: "%d Transaction, %d User Category".localized(),
            entry.transactionCount,
            entry.categoryCount)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = entries[indexPath.row]
        let formatted = Self.dateFormatter.string(from: entry.date)
        let alert = UIAlertController(
            title: "Restore Data".localized(),
            message: String(
                format: "Restore from %@? This will replace all current transactions and categories.".localized(),
                formatted),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restore".localized(), style: .destructive) { [weak self] _ in
            self?.performRestore(entry: entry)
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete".localized()) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            let entry = self.entries[indexPath.row]
            Task {
                do {
                    try await BackupManager.shared.deleteBackup(record: entry.record)
                    await MainActor.run {
                        self.entries.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.deleteAllButton.isEnabled = !self.entries.isEmpty
                        completion(true)
                    }
                } catch {
                    await MainActor.run {
                        self.showError(error)
                        completion(false)
                    }
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    // MARK: - Restore

    private func performRestore(entry: BackupEntry) {
        #if !targetEnvironment(macCatalyst)
            ProgressHUD.show("Restoring...".localized())
        #endif
        Task {
            do {
                try await MainActor.run {
                    try BackupManager.shared.restoreFromBackup(entry: entry)
                }
                await MainActor.run {
                    #if !targetEnvironment(macCatalyst)
                        ProgressHUD.dismiss()
                    #endif
                    NotificationCenter.default.post(name: .backupDidRestore, object: nil)
                    let alert = UIAlertController(
                        title: "Success".localized(),
                        message: "Data restored successfully!".localized(),
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
                    self.present(alert, animated: true)
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
}
