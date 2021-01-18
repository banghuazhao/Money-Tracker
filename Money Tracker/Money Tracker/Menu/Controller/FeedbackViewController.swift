//
//  FeedbackViewController.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 2021/1/16.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import MessageUI
import UIKit

class FeedbackViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    var feedbackItems = [FeedbackItem]()

    lazy var backButton = UIButton(type: .custom).then { b in
        b.setImage(UIImage(named: "back_button"), for: .normal)
        b.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
    }

    lazy var titleLabel = UILabel().then { label in
        label.font = UIFont.bigTitle
        label.text = "Feedback".localized()
    }

    lazy var tableView = UITableView().then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(FeedbackItemCell.self, forCellReuseIdentifier: "FeedbackItemCell")
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Feedback".localized()

        if let regionCode = Locale.current.regionCode, regionCode == "CN" {
            feedbackItems = [
                FeedbackItem(
                    title: "微信公众号",
                    detail: "微信公众号 Apps Bay 里留言".localized(),
                    icon: UIImage(named: "icon_wechat")),
                FeedbackItem(
                    title: "电子邮件".localized(),
                    detail: "发送电子邮件给 appsbay@qq.com".localized(),
                    icon: UIImage(named: "icon_email")),
            ]
        } else {
            feedbackItems = [
                FeedbackItem(
                    title: "Facebook Page".localized(),
                    detail: "Send message to Apps Bay Facebook page".localized(),
                    icon: UIImage(named: "icon_facebook")),

                FeedbackItem(
                    title: "Email".localized(),
                    detail: "Write an email to appsbayarea@gmail.com".localized(),
                    icon: UIImage(named: "icon_email")),
            ]
        }

        view.addSubview(tableView)

        #if !targetEnvironment(macCatalyst)
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
        #endif

        tableView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}

extension FeedbackViewController {
    @objc func backToHome() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackItems.count
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50 + 16 + 16
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackItemCell", for: indexPath) as! FeedbackItemCell
        cell.feedbackItem = feedbackItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let regionCode = Locale.current.regionCode, regionCode == "CN" {
            if indexPath.row == 0 {
                let alterController = UIAlertController(title: "微信公众号留言".localized(), message: "请在微信中搜索\"Apps Bay\"公众号，关注后即可留言反馈，谢谢！", preferredStyle: .alert)
                let action = UIAlertAction(title: "好的".localized(), style: .cancel, handler: nil)
                alterController.addAction(action)
                present(alterController, animated: true)
            }
            if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["appsbay@qq.com"])
                    mail.setSubject("极简记账 - 反馈")
                    present(mail, animated: true)
                }
            }
        } else {
            if indexPath.row == 0 {
                let facebookAppURL = URL(string: "fb://profile/\(Constants.facebookPageID)")!
                if UIApplication.shared.canOpenURL(facebookAppURL) {
                    UIApplication.shared.open(facebookAppURL)
                } else {
                    UIApplication.shared.open(URL(string: "https://www.facebook.com/Apps-Bay-104357371640600")!)
                }
            }
            if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["appsbayarea@gmail.com"])
                    mail.setSubject("\("Money Tracker".localized()) - \("Feedback".localized())")
                    present(mail, animated: true)
                }
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result == .sent {
                let ac = UIAlertController(title: "Thanks for Your Feedback".localized(), message: "We will constantly optimize and maintain our App and make sure users have the best experience".localized(), preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
                ac.addAction(action1)
                self.present(ac, animated: true)
            }
        }
    }
}
