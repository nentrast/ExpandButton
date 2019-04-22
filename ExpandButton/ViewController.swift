//
//  ViewController.swift
//  ExpandButton
//
//  Created by Alexandr Lobanov on 4/18/19.
//  Copyright © 2019 Alexandr Lobanov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var expandView: ExpandingView!
    
    var expandItems: [ExpandingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        expandView.delegate = self
        
        let button = ExpandingItem.init()
        button.icomImage = #imageLiteral(resourceName: "plain")
        
        let button1 = ExpandingItem.init()
        button1.icomImage = #imageLiteral(resourceName: "plain")

        
        let button2 = ExpandingItem.init()
        button2.icomImage = #imageLiteral(resourceName: "train")
        
        let button3 = ExpandingItem.init()
        button3.icomImage = #imageLiteral(resourceName: "plain")


        expandView.addItem(button)
        expandView.addItem(button1)
        expandView.addItem(button2)
        expandView.addItem(button3)
        
        expandView.selectItem(at: 0)
    }
}

extension ViewController:  ExpandingViewDelegate {
    func expandingView(_ view: ExpandingView, didSelectItemAt index: Int) {
        print(index)
    }
}

