//
//  IAPManager.swift
//  Money Tracker
//

import StoreKit

final class IAPManager: NSObject {
    static let shared = IAPManager()

    static let removeAdsProductID = "com.BanghuaZhao.MoneyTracker.RemoveAdsForever"

    var adsRemoved: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.adsRemoved)
    }

    private var removeAdsProduct: SKProduct?
    private var productsRequest: SKProductsRequest?
    private var restoredCount = 0

    // Set these before calling purchaseRemoveAds() or restorePurchases().
    var onPurchaseComplete: (() -> Void)?
    var onRestoreComplete: (() -> Void)?
    var onRestoreEmpty: (() -> Void)?
    var onFailed: ((String) -> Void)?

    private override init() { super.init() }

    /// Start listening for transactions. Call once at app launch.
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    // MARK: - Purchase

    func purchaseRemoveAds() {
        guard SKPaymentQueue.canMakePayments() else {
            fail("In-App Purchases are disabled on this device.")
            return
        }
        if let product = removeAdsProduct {
            SKPaymentQueue.default().add(SKPayment(product: product))
        } else {
            fetchThenPurchase()
        }
    }

    func restorePurchases() {
        restoredCount = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Prefetch the product so the price is ready (call from MenuViewController.viewDidLoad).
    func prefetchProduct() {
        guard removeAdsProduct == nil else { return }
        let req = SKProductsRequest(productIdentifiers: [Self.removeAdsProductID])
        req.delegate = self
        productsRequest = req
        req.start()
    }

    /// Localised price string, e.g. "$0.99". Nil until product is fetched.
    var localizedPrice: String? {
        guard let product = removeAdsProduct else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }

    // MARK: - Private

    private func fetchThenPurchase() {
        let req = SKProductsRequest(productIdentifiers: [Self.removeAdsProductID])
        req.delegate = self
        productsRequest = req
        req.start()
    }

    private func markAdsRemoved() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.adsRemoved)
    }

    private func fail(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.onFailed?(message)
            self?.onFailed = nil
        }
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            fail("Product not available. Please try again later.")
            return
        }
        removeAdsProduct = product
        // Only queue a payment when triggered by purchaseRemoveAds (not prefetch).
        // We distinguish by checking if onPurchaseComplete or onFailed is set.
        if onPurchaseComplete != nil || onFailed != nil {
            SKPaymentQueue.default().add(SKPayment(product: product))
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        fail(error.localizedDescription)
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                markAdsRemoved()
                queue.finishTransaction(transaction)
                DispatchQueue.main.async { [weak self] in
                    self?.onPurchaseComplete?()
                    self?.onPurchaseComplete = nil
                    self?.onFailed = nil
                }
            case .restored:
                markAdsRemoved()
                restoredCount += 1
                queue.finishTransaction(transaction)
            case .failed:
                queue.finishTransaction(transaction)
                let msg = (transaction.error as? SKError).map { $0.localizedDescription } ?? "Purchase failed."
                // Ignore user-cancelled silently if SKError.code == .paymentCancelled
                if let skErr = transaction.error as? SKError, skErr.code == .paymentCancelled {
                    DispatchQueue.main.async { [weak self] in
                        self?.onFailed = nil
                        self?.onPurchaseComplete = nil
                    }
                } else {
                    fail(msg)
                }
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.restoredCount > 0 {
                self.onRestoreComplete?()
                self.onRestoreComplete = nil
            } else {
                self.onRestoreEmpty?()
                self.onRestoreEmpty = nil
            }
            self.onFailed = nil
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        fail(error.localizedDescription)
    }
}
