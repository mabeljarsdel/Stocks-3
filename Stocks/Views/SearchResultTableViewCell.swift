//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init? (coder: NSCoder) {
        fatalError()
    }
    
}
