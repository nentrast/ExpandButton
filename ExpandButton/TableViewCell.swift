//
//  TableViewCell.swift
//  ExpandButton
//
//  Created by Alexandr Lobanov on 4/22/19.
//  Copyright © 2019 Alexandr Lobanov. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var expandedTextView: ExpandingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configure(with viewModel: TableCellViewModel) {
//        expandedType.forEach({ self.expandedTextView.addItem($0) })
        
    }
}


class TableCellViewModel {
    var expandedModel: [ExpandingItem] = []
    var selectedItem: Observable<String> = Observable.init(objet: "")
    
}


class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }
    var valueChanged: ((T) -> Void)?
    
    init(objet: T) {
        value = objet
    }
}
