//
//  ExpandingView.swift
//  ExpandButton
//
//  Created by Alexandr Lobanov on 4/18/19.
//  Copyright © 2019 Alexandr Lobanov. All rights reserved.
//

import UIKit

fileprivate func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180.0 * CGFloat.pi
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

@objc protocol ExpandingViewDelegate: class {
    func expandingView(_ view: ExpandingView, didSelectItemAt index: Int)
    @objc optional func expandingView(willShow view: ExpandingView)
    @objc optional func expandingView(didShow view: ExpandingView)
    @objc optional func expandingView(willHide view: ExpandingView)
    @objc optional func expandingView(didHide view: ExpandingView)
}

protocol ExpandingItemProtocol: class {
    var parrent: ExpandingView? { set get }
    var title: String? { get set }
    var icomImage: UIImage? { get set }
    func selected()
    func deselected()
}


class ExpandingItem: UIControl, ExpandingItemProtocol {
    
    weak var parrent: ExpandingView?
    
    var cirlceColor: UIColor? = nil {
        didSet {
            circleLayer.backgroundColor = cirlceColor?.cgColor
        }
    }
    
    fileprivate let circleLayer = CALayer()
    
    var size: CGFloat = 38
    
    private var _iconImageView: UIImageView? = nil
    private var _iconIMage: UIImage? = nil
    
    var icomImageView: UIImageView? {
        get {
            if _iconImageView == nil {
                _iconImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: size / 2, height: size / 2))
                _iconImageView?.center = CGPoint(x: size / 2, y: size / 2)
                _iconImageView?.contentMode = .scaleToFill
                addSubview(_iconImageView!)
            }
            return _iconImageView
        }
    }
    
    var title: String?
    
    var icomImage: UIImage? = nil {
        didSet {
            _iconIMage = icomImage
            icomImageView?.image = icomImage
        }
    }
    
    convenience init(icon: UIImage) {
        self.init()
        _iconIMage = icon
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        size = min(frame.size.width, frame.size.height)
        icomImageView?.image = _iconIMage
        createCilrceLayer()
    }
    
    fileprivate func createCilrceLayer() {
        circleLayer.frame = CGRect.init(x: 0, y: 0, width: size, height: size)
        circleLayer.cornerRadius = size / 2
        circleLayer.backgroundColor = cirlceColor?.cgColor
        layer.addSublayer(circleLayer)
    }
    
    func selected() {
        icomImageView?.tintColor = .white
    }
    
    func deselected() {
        icomImageView?.tintColor = .lightGray
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            if let hitView = self.hitTest(firstTouch.location(in: self), with: event) {
                sendActions(for: .touchUpInside)
                print("Touched button")
            }
        }
    }
}

enum ExpandingViewState {
    case expanded
    case collapsed
    
    mutating func switchSelf() {
        switch self  {
        case .collapsed:
            self = .expanded
        case .expanded:
            self = .collapsed
        }
    }
}

@IBDesignable class ExpandingView: UIView {
    
    @IBInspectable var indicatorColor: UIColor? {
        get {
            return selectionIndicatorView.backgroundColor
        }
        set {
            selectionIndicatorView.backgroundColor = newValue
        }
    }
    
    fileprivate var buttonItems: [ExpandingItem] = [] 
    
    fileprivate var selectionIndicatorView = UIView()
    
    private var state: ExpandingViewState = .collapsed
    
    fileprivate var size: CGFloat = 0.0
    
    var itemSize: CGFloat = 40
    var selectionIndicatorSize: CGFloat = 30
    var itemSpace: CGFloat = 2
    var animationSpeed = 1.0
    private var timer: Timer?
    
    fileprivate var sizeDeltaOffset: CGFloat {
        get {
            return  (itemSize - selectionIndicatorSize) / 2
        }
    }
    
    private var currentSelectedItem: ExpandingItem?
    private var currentIndex: Int = 0
    
    weak var delegate: ExpandingViewDelegate?
    
    override var frame: CGRect {
        didSet {
            layer.cornerRadius = frame.height / 2
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        size = min(frame.size.width, frame.size.height)
        initSelectedLayer()
    }
    
    private func initSelectedLayer() {
        selectionIndicatorView.frame = CGRect.init(x: itemSpace / 2 + sizeDeltaOffset,
                                                   y: 0 + sizeDeltaOffset,
                                                   width: selectionIndicatorSize,
                                                   height: selectionIndicatorSize)
        selectionIndicatorView.layer.cornerRadius = selectionIndicatorSize / 2
        selectionIndicatorView.backgroundColor = indicatorColor
        selectionIndicatorView.clipsToBounds = true
        addSubview(selectionIndicatorView)
        sendSubviewToBack(selectionIndicatorView)
    }
    

    func addItem(_ item: ExpandingItem) {
        let offsetX = buttonItems.count * Int(itemSize) + Int(itemSpace)
        item.frame = CGRect.init(x: CGFloat(offsetX),
                                 y: CGFloat(0) + itemSpace / 2,
                                 width: itemSize - itemSpace,
                                 height: itemSize - itemSpace)
        item.parrent = self
        item.isUserInteractionEnabled = false
        item.addTarget(self, action: #selector(didPressItem(_:)), for: .touchUpInside)
        buttonItems.append(item)
        addSubview(item)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            if let hitView = self.hitTest(firstTouch.location(in: self), with: event) {
                expand()
                buttonItems.forEach({ $0.isUserInteractionEnabled = true })
                print("Touched view")
            }
        }
    }
    
    @objc func didPressItem(_ sender: ExpandingItem) {
        expand()
        
        let index = buttonItems.firstIndex(of: sender)
        selectItem(at: index ?? 0)
        
        createTimer()
    }
    
    private func calculateIndicatorDistance(from sender: ExpandingItem) -> CGFloat {
        return  sender.frame.origin.x - itemSpace / 2 + sizeDeltaOffset
    }
    
    func expand() {
        guard  state == .collapsed else { return }
        state.switchSelf()
        let totalItemsSize = buttonItems.count * Int(itemSize)
        let totalSpacingSize = Int(itemSpace) * (buttonItems.count - 1)
        
        let totalWidth = totalItemsSize + totalSpacingSize
        
        delegate?.expandingView?(willShow: self)
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.size.width = CGFloat(totalWidth)
            if let sender = self.currentSelectedItem {
                let first = self.buttonItems.first!
                self.swapItems(firsItem: sender, secondItem: first)
            }
        }) { _ in
            self.createTimer()
            self.delegate?.expandingView?(didShow: self)
        }
    }
    
    @objc func shrink() {
        let totalWidth = itemSize
        timer?.invalidate()
        buttonItems.forEach({ $0.isUserInteractionEnabled = false })
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.size.width = totalWidth
            
            if let sender = self.currentSelectedItem {
                let first = self.buttonItems.first!
                self.swapItems(firsItem: sender, secondItem: first)
            }
            
        }) { _ in
            self.state.switchSelf()
        }
    }
    
    private func swapItems(firsItem: ExpandingItem, secondItem: ExpandingItem, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            let firstItemFrame = firsItem.frame
            let seconfItemFrame = secondItem.frame
            
            firsItem.frame = seconfItemFrame
            secondItem.frame = firstItemFrame
            self.selectionIndicatorView.frame.origin.x = self.calculateIndicatorDistance(from: firsItem)
        }) { _ in
            
        }
    }
    
    private func createTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.shrink), userInfo: nil, repeats: false)
        
    }
    
    private func selectItem(at index: Int) {
        guard index < buttonItems.count else { return }
        
        let button = buttonItems[index]
        buttonItems.forEach({ if $0 != button { $0.deselected() }})
        
        let resultPoint = calculateIndicatorDistance(from: button)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.selectionIndicatorView.frame.origin.x = resultPoint
        }) { (_) in
            button.selected()
            self.delegate?.expandingView(self, didSelectItemAt: index)
            self.currentSelectedItem = button
            self.currentIndex = index
        }
    }
    
    func selectItem(_ index: Int) {
        guard let first = buttonItems.first else { return }
        let selectedButon = buttonItems[index]
        selectedButon.selected()
        
        buttonItems.forEach({ if $0 != selectedButon { $0.deselected() }})

        swapItems(firsItem: selectedButon, secondItem: first, duration: 0.0)
    }
    
    func prepareForReuse() {
        shrink()
        state = .expanded
        delegate = nil
        buttonItems.forEach({ $0.removeFromSuperview() })
        buttonItems.removeAll()
    }
}

