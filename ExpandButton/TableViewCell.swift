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
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with viewModel: TableCellViewModel) {
        viewModel.expandedModel.forEach({expandedTextView.addItem($0) })
        expandedTextView.delegate = viewModel
        expandedTextView.selectItem(viewModel.selectedIndex.value)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        expandedTextView.prepareForReuse()
    }

}


class TableCellViewModel: ExpandingViewDelegate {
    var expandedModel: [ExpandingItem] = [ExpandingItem.init(icon: #imageLiteral(resourceName: "train")),
                                          ExpandingItem.init(icon: #imageLiteral(resourceName: "plain")),
                                          ExpandingItem.init(icon: #imageLiteral(resourceName: "plain")),
                                          ExpandingItem.init(icon: #imageLiteral(resourceName: "train")),
                                          ExpandingItem.init(icon: #imageLiteral(resourceName: "plain"))]
    
    var selectedIndex: Observable<Int> = Observable(objet: 0)
    
    func expandingView(_ view: ExpandingView, didSelectItemAt index: Int) {
        print(index)
        selectedIndex.value = index
    }
    
    
    deinit {
        print("View model deinitd")
    }
}

// MARK: - Observalbe
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
    
    deinit {
        print("Deinit observable with value: \(value)")
    }
}
