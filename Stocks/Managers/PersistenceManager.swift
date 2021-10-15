//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation

final class PresistanceManager {
    static let shared = PresistanceManager()
    
    private let userDefaulst: UserDefaults = .standard
    
    
    private struct Constants {
        
    }
    
    private init() { }
    
    //MARK: - PUBLIC
    
    var watchlist: [String] {
        return []
    }

    public func addToWatchlist() {
        
    }
    
    public func removeFromWatchlist() {
        
    }
    
    //MARK: - PRIVATE
    
    private var hasOnboarded: Bool {
        return false
    }
    
}
