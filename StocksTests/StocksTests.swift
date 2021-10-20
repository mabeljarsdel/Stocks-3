//
//  StocksTests.swift
//  StocksTests
//
//  Created by Dimitry Kodryan on 20.10.2021.
//

@testable import Stocks

import XCTest

class StocksTests: XCTestCase {

    func testCandleStickDataConversion() {
        let doubles: [Double] = Array(repeating: 12.5, count: 10)
        var timestamps: [TimeInterval] = []
        for i in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(i)).timeIntervalSince1970
            timestamps.append(interval)
        }
        timestamps.shuffle()
        
        let marketData = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            status: "success",
            timestamps: timestamps)
        
        let candleSticks = marketData.candleSticks
        
        XCTAssertEqual(candleSticks.count, marketData.open.count)
        XCTAssertEqual(candleSticks.count, marketData.close.count)
        XCTAssertEqual(candleSticks.count, marketData.high.count)
        XCTAssertEqual(candleSticks.count, marketData.low.count)
        XCTAssertEqual(candleSticks.count, marketData.timestamps.count)
        // Verify sort
        let dates = candleSticks.map { $0.date }
        for i in 0..<dates.count-1 {
            let current = dates[i]
            let next = dates[i+1]
            XCTAssertTrue(current > next)
        }
    }
}
