//
//  TableViewCell.swift
//  WebCrawlingProject
//
//  Created by 김진혁 on 4/4/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    
    private let label: UILabel = {
        
        let label = UILabel()
        
        label.text = "상어상어"
        
        label.textColor = UIColor.gray
        
        return label
        
    }()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
