//
//  WatchListhTableViewCell.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 18.10.2021.
//

import UIKit

protocol WatchListhTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListhTableViewCell: UITableViewCell {
    static let identifier = "WatchListhTableViewCell"
    
    weak var delegate: WatchListhTableViewCellDelegate?
    
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    // Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    // Company Label
    private let namelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    // Change Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false 
        chart.clipsToBounds = true
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(
        symbolLabel,
        namelLabel,
        priceLabel,
        changeLabel,
        miniChartView
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        namelLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - namelLabel.height )/2
        
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height
        )
        
        namelLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: namelLabel.width,
            height: namelLabel.height
        )
        
        let currentWidth = max(max(priceLabel.width, changeLabel.width),
                               WatchListViewController.maxChangeWidth
        )
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
            width: currentWidth,
            height: priceLabel.height
        )
        
        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )
        
        miniChartView.frame = CGRect(
            x:priceLabel.left - (contentView.width/3) - 5,
            y: 6,
            width: contentView.width/3,
            height: contentView.height - 12
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        namelLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        namelLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
