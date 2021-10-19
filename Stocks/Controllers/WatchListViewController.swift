//
//  ViewController.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import FloatingPanel
import UIKit

/// VC to render user watch list
final class WatchListViewController: UIViewController {
    
    /// Timer to optimize searching
    private var searchTimer: Timer?
    
    /// Floating news panel
    private var panel: FloatingPanelController?
    
    /// Width to track change label geometry
    static var maxChangeWidth: CGFloat = 0
    
    /// Models
    private var watchListMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListhTableViewCell.ViewModel] = []
    
    /// Main view to render watch list
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListhTableViewCell.self, forCellReuseIdentifier: WatchListhTableViewCell.identifier)
        return table
    }()
    
    /// Observer for watch list updates
    private var observer: NSObjectProtocol?
    
    //MARK: - Lifecycle
    
    /// Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setupTableView()
        setUPFloatingPalnel()
        setUpTitleView()
        fetchWatchListData()
        setUpObserver()
        
    }
    
    /// Layout subiews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Private
    
    ///  Seys up observer for watch list updates
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main
            ) { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchWatchListData()
                self?.tableView.reloadData()
        }
    }
    
    /// Fetch watch list models
    private func  fetchWatchListData() {
        let symbols = PersistanceManager.shared.watchlist
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchListMap[symbol] == nil {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    /// Creates view models from models
    private func createViewModels() {
        var viewModels = [WatchListhTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(
                symbol: symbol,
                companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                price: getLatestClosingPrice(from: candleSticks),
                changeColor: changePercentage < 0 ? .systemRed : .systemGreen ,
                changePercentage: String.percentage(from: changePercentage), chartViewModel: .init(
                    data: candleSticks.reversed().map { $0.close },
                    showLegend: false,
                    showAxis: false,
                    fillColor: changePercentage < 0 ? .systemRed : .systemBlue
                    )
                )
            )
        }
        self.viewModels = viewModels
    }
    
    /// Gets change percentage for symbol
    /// - Parameters:
    ///   - symbol: Symbol to chek for
    ///   - data: Collection of data
    /// - Returns: Double percentage
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
    
    /// Gets latest closing price
    /// - Parameter data: Collection of data
    /// - Returns: String
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let clsoingPrice = data.first?.close else  { return "" }
        return String.formatedNumber(number: clsoingPrice)
    }
    
    /// Sets up tableview
    private func setupTableView() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Sets up floating news panel
    private func setUPFloatingPalnel() {
        let vc = NewsViewController(newsType: .topStroies)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    /// Set up custom title view
    private func setUpTitleView(){
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100
            )
        )
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    /// Sets up search and result controller
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
}

//MARK: - UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
    /// Update search on key tap
    /// - Parameter searchController: Reference of the search controller
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultVC = searchController.searchResultsController as?  SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                  return
              }
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

//MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController: SearchResultsViewControllerDelegate {
    /// Notify of search result selection
    /// - Parameter searchResult: Search result that was selected
    func searchResultsViewControllerDidSelect(searchResult: SearchResults) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        let vc = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    /// Gets floation panel state change
    /// - Parameter fpc: Reference of controller
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

//MARK: - Table View

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListhTableViewCell.identifier, for: indexPath) as? WatchListhTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        WatchListhTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Open details for selection
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchListMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // Upadte persistance
            PersistanceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            // Update viewmodel
            viewModels.remove(at: indexPath.row)
            
            // Delete row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
}

// MARK: - WatchListhTableViewCellDelegate

extension WatchListViewController: WatchListhTableViewCellDelegate {
    /// Notify delegate pf change label witdh 
    func didUpdateMaxWidth() {
        // TODO: Optimize: Only refresh rows prior to the current row that changes the max width 
        tableView.reloadData()
    }
}
