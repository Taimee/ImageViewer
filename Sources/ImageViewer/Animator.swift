//
//  Animator.swift
//  ImageViewer
//
//  Created by 阿久津　岳志 on 2020/04/25.
//  Copyright © 2020 阿久津　岳志. All rights reserved.
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Context {
        case present
        case dismiss
    }

    private let context: Context
    
    init(context: Context) {
        self.context = context
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return context == .present ? 0.3 : 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else { return }
        
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView) // fromViewは最初から追加されている
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                fromView.alpha = 0
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromView.alpha = 1
        }
    }
}
