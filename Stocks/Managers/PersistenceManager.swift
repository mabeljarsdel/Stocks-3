//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation

final class PersistanceManager {
    static let shared = PersistanceManager()
    
    private let userDefaulst: UserDefaults = .standard
    
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    private init() {}
    
    //MARK: - PUBLIC
    
    var watchlist: [String] {
        if !hasOnboarded {
            userDefaulst.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaulst.stringArray(forKey: Constants.watchlistKey) ?? [] 
    }

    public func addToWatchlist() {
        
    }
    
    public func removeFromWatchlist() {
        
    }
    
    //MARK: - PRIVATE
    
    private var hasOnboarded: Bool {
        return userDefaulst.bool(forKey: Constants.onboardedKey)
    }
    
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
        userDefaulst.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaulst.set(name, forKey: symbol)
        }
    }
}
