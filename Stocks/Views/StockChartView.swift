//
//  StockChartView.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 18.10.2021.
//
import Charts
import UIKit

/// View to show a chart
final class StockChartView: UIView {
    
    /// Chart View ViewModels
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }
    
    /// Chart View
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        
        return chartView
    }()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    /// Reset the chart view
    func reset() {
        chartView.data = nil
    }
    
    /// Configure View
    /// - Parameter viewModel: View ViewModel
    func configure(with viewModel: ViewModel) {
        var entires = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated() {
            entires.append(.init(x: Double(index), y: value))
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entires, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSets: [dataSet])
        chartView.data = data
    }

}
