//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import SafariServices
import UIKit

/// VC to show stock details
final class StockDetailsViewController: UIViewController {
    // MARK: - Properties
    
    /// Stock symbol
    private let symbol: String
    
    /// Company name
    private let companyName: String
    
    /// Collection of data
    private var candleStickData: [CandleStick] = []
    
    /// Primary view
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return table
    }()
    
    /// Collection of news stories
    private var stories: [NewsStory] = []
    
    /// Company metrics
    private var metrics: Metrics?
    
    // MARK: - Init
    
    init(
        symbol:String,
        companyName:String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
    }
    
    // MARK: - Private
    
    /// Sets up close button
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    /// Handle close button tap
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Sets up table
    private func setUpTable() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView  = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.height * 0.3) + 100))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    /// Fetches fincancial metrics
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        // Fetch candlesticks if needed
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer { group.leave() }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
        
    }
    
    /// Fetch news for given type
    private func fetchNews () {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] results in
            
            switch results {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    /// Render chart and metrics
    private func  renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.height * 0.3) + 100
        )
        )
        
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            
            viewModels.append(.init(name: "52W High", value: String(metrics.AnnualWeekHigh)))
            viewModels.append(.init(name: "52W Low", value: String(metrics.AnnualWeekLow)))
            viewModels.append(.init(name: "52W Return", value: String(metrics.AnnualWeekPriceReturnDaily)))
            viewModels.append(.init(name: "Beta", value: String(metrics.beta)))
            viewModels.append(.init(name: "10D Vol.", value: String(metrics.TenDayAverageTradingVolume)))
            
        }
        
        // Configure
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(chartViewModel: .init(
            data: candleStickData.reversed().map {$0.close},
            showLegend: true,
            showAxis: true,
            fillColor: change < 0 ? .systemRed : .systemGreen
        ), metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
    }
    /// Get change percentage
    /// - Parameters:
    ///   - symbol: Symbol of company
    ///   - data: Collection of data
    /// - Returns: Percent
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close  else {
                  return 0
              }
        
        let diff = 1 - priorClose/latestClose
        return diff
    }
}

//MARK: - TableView

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistanceManager.shared.watchListContains(symbol: symbol)
        )
        )
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        HapticManager.shared.vibrateForSelection()
        let vc = SFSafariViewController(url: url)
        present(vc,animated: true)
    }
}

// MARK: - NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        
        HapticManager.shared.vibrate(for: .success)
        
        headerView.button.isHidden = true
        PersistanceManager.shared.addToWatchlist(
            symbol: symbol,
            companyName: companyName
        )
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "\(companyName) added to your watchlist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
}
