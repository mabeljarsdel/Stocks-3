//
//  APICaller.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation

/// Manages api calls
final class APICaller {
    
    /// Singleton
    public static let shared = APICaller()
    
    /// Constants
    private struct Constants {
        static let apiKey = APIKey.key
        static let sandboxApiKey = APIKey.sandboxKey
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    /// Private constructor
    private init() {}
    
    //MARK: - PUBLIC
    
    /// Search for a company
    /// - Parameters:
    ///   - newsType: Query string (symbol or name)
    ///   - completion: Callback for result
    public func search (
        query: String,
        completion: @escaping (Result<SearchResponse,Error>) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        request(url: url(
            for: .search,
               queryParams: ["q":safeQuery]
        ),
                expecting: SearchResponse.self,
                completion: completion
        )
    }
    
    
    /// Get news for type
    /// - Parameters:
    ///   - newsType: Company or top stories
    ///   - completion: Result callback
    public func news(
        for newsType: NewsViewController.NewsType,
        completion: @escaping (Result<[NewsStory],Error>) -> Void
    ) {
        switch newsType {
        case .topStroies:
            request(url: url(
                for: .topStories,
                   queryParams: ["category" : "general"]
            ),
                    expecting: [NewsStory].self,
                    completion: completion
            )
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(url: url(
                for: .companyNews,
                   queryParams: [
                    "symbol" : symbol,
                    "from" : DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                    "to" : DateFormatter.newsDateFormatter.string(from: today)
                   ]
            ),
                    expecting: [NewsStory].self,
                    completion: completion
            )
        }
    }
    
    /// Get market data
    /// - Parameters:
    ///   - symbol: Given symbol
    ///   - numberOfDays: Number of days from today
    ///   - completion: Result callback
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping(Result<MarketDataResponse,Error>) -> Void
    ) {
        let today = Date().addingTimeInterval(-(Constants.day))
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        request(url: url(
            for: .marketData,
               queryParams: [
                "symbol": symbol,
                "resolution" : "1",
                "from" : "\(Int(prior.timeIntervalSince1970))",
                "to" : "\(Int(today.timeIntervalSince1970))"
               ]
        ),
                expecting: MarketDataResponse.self, completion: completion)
    }
    
    /// Get financial metrics
    /// - Parameters:
    ///   - symbol: Symbol of company
    ///   - completion: Result callback
    public func financialMetrics(
        for symbol: String,
        completion: @escaping(Result<FinancialMetricsResponse, Error>) -> Void
    ) {
        request(url: url(
            for: .financials,
               queryParams: [
                "symbol":symbol,
                "metric": "all"
        ]),
                expecting: FinancialMetricsResponse.self, completion: completion)
    }
    
    //MARK: - PRIVATE
    
    /// API Endpoints
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    /// API Erros
    private enum APIError: Error {
        case noDataReturn
        case invalidURL
    }
    
    /// Creates optional url for endpoint
    /// - Parameters:
    ///   - endpoint: Endpoint to create for
    ///   - queryParams: Additional query arguments
    /// - Returns: Optional url
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        // Add parameters
        for(name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add tokern
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // Convert quiery items to string
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        return URL(string: urlString)
    }
    
    
    /// Perform API call
    ///  - Parameters:
    ///  - url: Target url
    ///  - expecting:  Type we expect to decode
    ///  - completion: Result callback
    private func request <T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void ) {
            
            guard let url = url else {
                completion(.failure(APIError.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.noDataReturn))
                    }
                    return
                }
                do{
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
}
