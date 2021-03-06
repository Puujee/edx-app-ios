//
//  LoadStateViewController.swift
//  edX
//
//  Created by Akiva Leffert on 5/13/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation


enum LoadState {
    case Initial
    case Loaded
    case Empty(icon : Icon, message : String?, attributedMessage : NSAttributedString?)
    // if attributed message is set then message is ignored
    // if message is set then the error is ignored
    case Failed(error : NSError?, icon : Icon?, message : String?, attributedMessage : NSAttributedString?)
    
    var isInitial : Bool {
        switch self {
        case .Initial: return true
        default: return false
        }
    }
    
    var isLoaded : Bool {
        switch self {
        case .Loaded: return true
        default: return false
        }
    }
    
    var isError : Bool {
        switch self {
        case .Failed(_): return true
        default: return false
        }
    }
    
    static func failed(error : NSError? = nil, icon : Icon? = nil, message : String? = nil, attributedMessage : NSAttributedString? = nil) -> LoadState {
        return LoadState.Failed(error : error, icon : icon, message : message, attributedMessage : attributedMessage)
    }
    
    static func empty(#icon : Icon, message : String? = nil, attributedMessage : NSAttributedString? = nil) -> LoadState {
        return LoadState.Empty(icon: icon, message: message, attributedMessage: attributedMessage)
    }
}

class LoadStateViewController : UIViewController, OEXStatusMessageControlling {
    
    private let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var contentView : UIView?
    private let messageView : IconMessageView
    
    private var madeInitialAppearance : Bool = false
    
    var state : LoadState = .Initial {
        didSet {
            updateAppearanceAnimated(madeInitialAppearance)
        }
    }
    
    var insets : UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    init(styles : OEXStyles?) {
        messageView = IconMessageView(styles: styles)
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var messageStyle : OEXTextStyle {
        return messageView.messageStyle
    }
    
    func setupInController(controller : UIViewController, contentView : UIView) {
        controller.addChildViewController(self)
        didMoveToParentViewController(controller)
        
        self.contentView = contentView
        contentView.alpha = 0
        
        controller.view.addSubview(loadingView)
        controller.view.addSubview(messageView)
        controller.view.addSubview(self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageView.alpha = 0
        view.addSubview(messageView)
        
        loadingView.startAnimating()
        view.addSubview(loadingView)
        
        state = .Initial
        
        self.view.setNeedsUpdateConstraints()
        self.view.userInteractionEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        madeInitialAppearance = true
    }
    
    override func updateViewConstraints() {
        loadingView.snp_updateConstraints {make in
            make.center.equalTo(view)
        }
        
        messageView.snp_updateConstraints {make in
            make.center.equalTo(view)
        }
        
        view.snp_updateConstraints { make in
            if let superview = view.superview {
                make.edges.equalTo(superview).insets(insets)
            }
        }
        super.updateViewConstraints()
    }
    
    private func updateAppearanceAnimated(animated : Bool) {
        var alphas : (loading : CGFloat, message : CGFloat, content : CGFloat) = (loading : 0, message : 0, content : 0)
        
        UIView.animateWithDuration(0.3 * NSTimeInterval(animated)) {
            switch self.state {
            case .Initial:
                alphas = (loading : 1, message : 0, content : 0)
            case .Loaded:
                alphas = (loading : 0, message : 0, content : 1)
            case let .Empty(info):
                UIView.performWithoutAnimation {
                    if let message = info.attributedMessage {
                        self.messageView.attributedMessage = message
                    }
                    else {
                        self.messageView.message = info.message
                    }
                    self.messageView.icon = info.icon
                }
                alphas = (loading : 0, message : 1, content : 0)
            case let .Failed(info):
                UIView.performWithoutAnimation {
                    if let error = info.error where error.oex_isNoInternetConnectionError() {
                        self.messageView.showNoConnectionError()
                    }
                    else {
                        if let message = info.attributedMessage {
                            self.messageView.attributedMessage = message
                        }
                        else {
                            self.messageView.message = info.message ?? info.error?.localizedDescription
                        }
                        self.messageView.icon = info.icon ?? .UnknownError
                    }
                }
                alphas = (loading : 0, message : 1, content : 0)
            }
            
            self.loadingView.alpha = alphas.loading
            self.messageView.alpha = alphas.message
            self.contentView?.alpha = alphas.content
        }
    }
    
    func overlayViewsForStatusController(controller: OEXStatusMessageViewController!) -> [AnyObject]! {
        return []
    }
    
    func verticalOffsetForStatusController(controller: OEXStatusMessageViewController!) -> CGFloat {
        return 0
    }
    
    func showOverlayError(message : String) {
        OEXStatusMessageViewController.sharedInstance().showMessage(message, onViewController: self)
    }
    
}