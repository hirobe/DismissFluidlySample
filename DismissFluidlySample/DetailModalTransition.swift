//
//  DetailModalTransition.swift
//  DismissFluidlySample
//
//  Created by hirobe on 2018/09/12.
//  Copyright © 2018 Bunguu inc. All rights reserved.
//

import UIKit

class DetailModalTransition : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    var isForPresented:Bool = true

    var dismissComplated: (() -> Void)?

    var swipePoint: CGPoint = CGPoint.zero
    var swipeScale : CGFloat = 1.0
    var swipeVelocity : CGPoint = CGPoint.zero

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isForPresented = false
        return self
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isForPresented = true
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isForPresented { // present
            return 0.2
        } else { // dissmis
            return 0.4
        }
    }


    func animationEnded(_ transitionCompleted: Bool) {
        if !isForPresented && transitionCompleted {
            dismissComplated?()
        }
    }

    func presentAnimation(containerView: UIView,
                          from: UIViewController?,
                          to: UIViewController?,
                          duration: TimeInterval,
                          completeTransition:@escaping (_ didComplete: Bool) -> Void) {

        guard let nav = to as? UINavigationController,
            let detailVC:DetailViewController = nav.visibleViewController as? DetailViewController
            else { fatalError() }

        let fromImageRect = detailVC.parentImageViewRect
        let toImageRect = detailVC.detailImageRect(containerView: containerView, safeAreaInsets: from?.view?.safeAreaInsets ?? .zero)

        // imageを移動するためのviewを作成
        let imageView:UIImageView = UIImageView(frame: fromImageRect)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = detailVC.parentImage
        containerView.addSubview(imageView)

        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction,.curveEaseOut], animations: { () -> Void in
            imageView.frame = toImageRect
        }) { (finished) -> Void in
            containerView.addSubview(nav.view)
            imageView.removeFromSuperview()
            completeTransition(true)
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isForPresented { // present
            self.presentAnimation(containerView: transitionContext.containerView,
                                  from: transitionContext.viewController(forKey: .from),
                                  to: transitionContext.viewController(forKey: .to),
                                  duration: self.transitionDuration(using: transitionContext),
                                  completeTransition: transitionContext.completeTransition)
        } else { // dissmis
            self.dissmisAnimation(containerView: transitionContext.containerView,
                                  from: transitionContext.viewController(forKey: .from),
                                  to: transitionContext.viewController(forKey: .to),
                                  duration: self.transitionDuration(using: transitionContext),
                                  completeTransition: transitionContext.completeTransition)
        }
    }
    func dissmisAnimation(containerView: UIView,
                          from: UIViewController?,
                          to: UIViewController?,
                          duration: TimeInterval,
                          completeTransition:@escaping (_ didComplete: Bool) -> Void) {

        guard let nav = from as? UINavigationController,
            let detailVC:DetailViewController = nav.visibleViewController as? DetailViewController
            else { fatalError() }

        let fromImageRect = detailVC.detailImageRect(containerView: containerView, safeAreaInsets: from?.view?.safeAreaInsets ?? .zero)
        let toImageRect = detailVC.parentImageViewRect

        // imageを移動するためのviewを作成
        let imageView:UIImageView = UIImageView(frame: fromImageRect)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = detailVC.parentImage
        containerView.addSubview(imageView)

        // 縮小アニメーション
        nav.view.isHidden = true
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
            imageView.frame = toImageRect
        }) { (finished) -> Void in
            nav.view.removeFromSuperview()
            completeTransition(true)
        }
    }

}

extension DetailModalTransition {
    func dissmisFluidly(viewController:UIViewController?) {
        guard let parent = viewController?.presentingViewController,
            let child = parent.presentedViewController,
            let window = parent.view?.window else { return }

        viewController?.dismiss(animated: false) {
            // viewDidDisappearの後に呼ばれるので注意
            let containerView = UIView(frame: window.bounds)
            containerView.isUserInteractionEnabled = false
            window.addSubview(containerView)
            self.dissmisAnimation(containerView: containerView,
                                  from: child,
                                  to: parent,
                                  duration: 0.6,
                                  completeTransition: { didComplete in
                                    containerView.removeFromSuperview()
            })
        }
    }
}
