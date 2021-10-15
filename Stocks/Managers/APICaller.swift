//
//  APICaller.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = APIKey.key
        static let sandboxApiKey = APIKey.sandboxKey
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    //MARK: - PUBLIC
    
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
    
    //search stock
    
    //MARK: - PRIVATE
    
    private enum Endpoint: String {
        case search
    }
    
    private enum APIError: Error {
        case noDataReturn
        case invalidURL
    }
    
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
        print("\n\(urlString)\n")
        return URL(string: urlString)
    }
    
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
