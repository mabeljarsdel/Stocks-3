//
//  Extensions.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation
import UIKit

// Notofication

extension Notification.Name {
    /// Notofication when symbol gets added to watchlist
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// NumberFormatter

extension NumberFormatter {
    /// Formatter for percent style
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    /// Formatter for decimal style
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
}


// MARK: - String

extension String {
    /// Create string from time interval
    /// - Parameter timeInterval: Timeinterval since 1970
    /// - Returns: Formatted string
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    /// Percentage formatted string
    /// - Parameter double: Double to format
    /// - Returns: String in percent format
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    /// Format number to string
    /// - Parameter number: Number to form
    /// - Returns: Formated string
    static func formatedNumber(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - DateFormatter

extension DateFormatter {
    /// Formates time to "YYYY-MM-dd"
    static let newsDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    ///  Formates time in pretty style such as “Nov 23, 1937”
    static let prettyDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Add Subview

extension UIView{
    /// Adds mulitple subviews
    /// - Parameter views: Collection of subviews
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

// MARK: - Framing

extension UIView {
    
    /// Width of view
    var width: CGFloat {
        frame.size.width
    }
    /// Height of view
    var height: CGFloat {
        frame.size.height
    }
    /// Left edge of view
    var left: CGFloat {
        frame.origin.x
    }
    /// Right edge of view
    var right: CGFloat {
        left + width
    }
    /// Top edge of view
    var top: CGFloat {
        frame.origin.y
    }
    /// Bottom edge of view
    var bottom: CGFloat {
        top + height
    }
    
}

