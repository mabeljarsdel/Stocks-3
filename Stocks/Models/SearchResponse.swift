//
//  SearchResponse.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 15.10.2021.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResults]
}

struct SearchResults: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
