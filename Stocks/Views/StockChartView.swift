//
//  StockChartView.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 18.10.2021.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /// Reset the chart view
    func reset() {
        
    }
    
    func configure(with viewModel: ViewModel) {
        
    }

}
