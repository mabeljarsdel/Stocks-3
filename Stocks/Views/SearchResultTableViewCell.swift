//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Dimitry Kodryan on 05.10.2021.
//

import UIKit

/// Tableview cell for search result
class SearchResultTableViewCell: UITableViewCell {
    /// Cell identifier
    static let identifier = "SearchResultTableViewCell"
    
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init? (coder: NSCoder) {
        fatalError()
    }
    
}
