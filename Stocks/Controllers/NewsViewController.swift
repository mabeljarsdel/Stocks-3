//
//  TopStoriesNewsViewController.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import SafariServices
import UIKit

/// Controller to show news
final class NewsViewController: UIViewController {
    
    /// Type of news
    enum NewsType {
        case topStroies
        case company(symbol: String)
        
        /// Title for given type
        var title: String {
            switch self {
            case .topStroies:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    /// Collection of models
    private var stories = [NewsStory]()
    
    /// Instance of type
    private let newsType: NewsType
    
    /// Primaty news view
    let tableView:UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        table.backgroundColor = .clear
        return table
    }()
    
    // MARK: - Init
    
    /// Crate VC with type
    init(newsType: NewsType) {
        self.newsType  = newsType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUptable()
        fetchNews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    /// Sets up Table view
    private func setUptable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Fetch news models
    private func fetchNews() {
        APICaller.shared.news(for: self.newsType) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories.append(contentsOf: stories)
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Open a story
    /// - Parameter url: URL to open
    private func open(url:URL) {
        let vc = SFSafariViewController(url: url)
        present(vc,animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(title: self.newsType.title, shouldShowAddButton: false))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticManager.shared.vibrateForSelection()
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFaildToOpenAlert()
            return
        }
        open(url: url)
    }
    
    /// Show an alert if an error occurred when opening story
    private func presentFaildToOpenAlert() {
        HapticManager.shared.vibrate(for: .error)
        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
}
