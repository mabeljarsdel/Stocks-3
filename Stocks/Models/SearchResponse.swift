//
//  SearchResponse.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 15.10.2021.
//

import Foundation

/// API response for search
struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResults]
}

/// Single search result
struct SearchResults: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
