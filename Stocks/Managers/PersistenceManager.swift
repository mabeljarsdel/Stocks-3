//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation


/// Manages saved caches
final class PersistanceManager {
    
    /// Singleton
    static let shared = PersistanceManager()
    
    /// Reference to user defaults
    private let userDefaults: UserDefaults = .standard
    
    
    /// Constants
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    /// Privatized constructor
    private init() {}
    
    //MARK: - PUBLIC
    
    /// Get user watchlist
    var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    /// Check if watchlist contains item
    /// - Parameter symbol: Symbol to check
    /// - Returns: Boolean
    public func watchListContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    /// Adds a symbol to watchlist
    /// - Parameters:
    ///   - symbol: Symbol to add
    ///   - companyName: Company name for symbol being added
    public func addToWatchlist(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)
        
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
        
    }
    
    /// Remove item from watchlist
    /// - Parameter symbol: symbol to remove
    public func removeFromWatchlist(symbol: String) {
        var newList = [String]()
        
        userDefaults.set(nil, forKey: symbol)
        
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlistKey)
    }
    
    //MARK: - PRIVATE
    
    /// Check if user has been onboarded
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    /// Set up default watch list
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL" : "Apple Inc",
            "MSFT" : "Microsfot Corporation",
            "SNAP" : "Snap Inc.",
            "GOOG" : "Alphabet",
            "AMZN" : "Amazon.com, Inc.",
              "FB" : "Facebook Inc.",
            "NVDA" : "Nvidia Inc.",
             "NKE" : "Nike",
            "PINS" : "Pinterest"
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
