//
//  HapticsManager.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import Foundation
import UIKit

/// Manages haptics
final class HapticManager {
    /// Singleton
    static let shared = HapticManager()
    
    /// Private constructor
    private init () {}
    
    //MARK: - PUBLIC
    
    /// Vibrate for selection
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Play haptic for given type
    /// - Parameter type: Type of feedback
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
}
