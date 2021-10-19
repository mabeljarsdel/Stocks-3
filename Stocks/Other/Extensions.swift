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
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// NumberFormatter

extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
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
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatedNumber(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - DateFormatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
      let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Add Subview

extension UIView{
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

// MARK: - Framing

extension UIView {
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
    var left: CGFloat {
        frame.origin.x
    }
    var right: CGFloat {
        left + width
    }
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        top + height
    }
    
}

