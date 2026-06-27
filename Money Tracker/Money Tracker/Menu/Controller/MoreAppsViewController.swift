//
//  MoreAppsViewController.swift
//  Money Tracker
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import SnapKit
import Then
import UIKit

class MoreAppsViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    let appItems = [
        AppItem(
            title: "SwiftSum".localized(),
            detail: "Math Solver & Calculator App".localized(),
            icon: UIImage(named: "appIcon_swiftsum"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.swiftSumAppID)")),
        AppItem(
            title: "Shows".localized(),
            detail: "Movie, TV Show Tracker".localized(),
            icon: UIImage(named: "appIcon_shows"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.showsAppID)")),
        AppItem(
            title: "Trip Mark".localized(),
            detail: "Travel Journal & Trip Planner".localized(),
            icon: UIImage(named: "appIcon_small"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.tripMarkAppID)")),
        AppItem(
            title: "Falling Block Puzzle".localized(),
            detail: "Retro".localized(),
            icon: UIImage(named: "appIcon_falling_block_puzzle"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.fallingBlockPuzzleAppID)")),
        AppItem(
            title: "CalmCanvas".localized(),
            detail: "Meditation, Relaxing".localized(),
            icon: UIImage(named: "appIcon_relaxing_up"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.calmCanvasAppID)")),
        AppItem(
            title: "We Play Piano".localized(),
            detail: "Piano Keyboard".localized(),
            icon: UIImage(named: "appIcon_we_play_piano"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.wePlayPianoAppID)")),
        AppItem(
            title: "ClassicReads".localized(),
            detail: "Novels & Fiction".localized(),
            icon: UIImage(named: "appIcon_novels_Hub"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.novelsHubAppID)")),
        AppItem(
            title: "World Weather Live".localized(),
            detail: "All Cities".localized(),
            icon: UIImage(named: "appIcon_world_weather_live"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.worldWeatherLiveAppID)")),
        AppItem(
            title: "Minesweeper Z".localized(),
            detail: "Minesweeper App".localized(),
            icon: UIImage(named: "appIcon_minesweeper"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.minesweeperZAppID)")),
        AppItem(
            title: "Sudoku Lover".localized(),
            detail: "Sudoku Puzzles".localized(),
            icon: UIImage(named: "appIcon_sudoku_lover"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.sudokuLoverAppID)")),
        AppItem(
            title: "BMI Diary".localized(),
            detail: "Fitness, Weight Loss & Health".localized(),
            icon: UIImage(named: "appIcon_bmiDiary"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.BMIDiaryAppID)")),
        AppItem(
            title: "Countdown Days".localized(),
            detail: "Events, Anniversary & Big Days".localized(),
            icon: UIImage(named: "appIcon_countdown_days"),
            url: URL(string: "http://itunes.apple.com/app/id\(Constants.AppID.countdownDaysAppID)")),
        AppItem(
            title: "More Apps".localized(),
            detail: "Check out more Apps made by us".localized(),
            icon: UIImage(named: "appIcon_appStore"),
            url: URL(string: "https://apps.apple.com/us/developer/%E7%92%90%E7%92%98-%E6%9D%A8/id1599035519")),
    ]

    lazy var tableView = UITableView().then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(AppItemCell.self, forCellReuseIdentifier: "AppItemCell")
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More Apps".localized()

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

extension MoreAppsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        appItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        82
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppItemCell", for: indexPath) as! AppItemCell
        cell.appItem = appItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let appItem = appItems[indexPath.row]
        if let url = appItem.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
