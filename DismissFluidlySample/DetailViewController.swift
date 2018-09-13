//
//  DetailViewController.swift
//  DismissFluidlySample
//
//  Created by Hirobe Kazuya on 2018/05/17.
//  Copyright © 2018 Bunguu inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var parentImageViewRect:CGRect = .zero
    var parentImage:UIImage?
    //var parentViewController:CollectionViewController?

    var modalTransition:DetailModalTransition = DetailModalTransition()

    var panGesture: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = parentImage

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(DetailViewController.handleVerticalPanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        print("viewDidLoad")

        //∂setupPresentAnimation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.modalTransition.isForPresented = false
        self.modalTransition.swipeScale = 1.0
        self.modalTransition.swipePoint = CGPoint.zero
        self.modalTransition.swipeVelocity = CGPoint.zero

        self.modalTransition.dissmisFluidly(viewController: self)
    }

    @objc func handleVerticalPanGesture(_ sender: UIPanGestureRecognizer){
        let point: CGPoint = sender.translation(in: self.view)
        let velocity = sender.velocity(in: self.view)
        let per = fabs(point.y) / self.view.frame.size.height
        switch (sender.state) {
        case .cancelled, .failed:
            resetPosition()
        case .changed:
            // ドラッグ動作 + y移動量に合わせて縮小 (concatenatingの順番に注意)
            self.imageContainerView.transform =
                CGAffineTransform(scaleX: 1.0 - per, y: 1.0 - per)
                .concatenating( CGAffineTransform(translationX: point.x, y: point.y) )
        case .ended:
            if per > 0.1 || fabs(velocity.y) > 1000 {
                // 進行度0.3以上 or スワイプの勢いが一定以上なら遷移実行へ
                self.modalTransition.isForPresented = false
                self.modalTransition.swipeScale = 1.0 - per
                self.modalTransition.swipePoint = CGPoint(x: point.x , y: point.y )
                self.modalTransition.swipeVelocity = velocity

                self.modalTransition.dissmisFluidly(viewController: self)

            } else {
                resetPosition()
            }
        default:
            break
        }
    }

    func resetPosition() {
        UIView.animate(withDuration: 0.3) {
            self.imageContainerView.transform = CGAffineTransform.identity
        }
    }

    func detailImageRect(containerView:UIView, safeAreaInsets:UIEdgeInsets) -> CGRect {
        // 画像の表示座標を計算。presentの場合は、self.viewはまだレイアウトされていないので、containerViewのサイズをもとに自分で計算する
        let safeAreaFrame = CGRect(x: containerView.frame.minX + safeAreaInsets.left,
                                   y: containerView.frame.minY + safeAreaInsets.top,
                                   width: containerView.frame.width - safeAreaInsets.left - safeAreaInsets.right,
                                   height: containerView.frame.height - safeAreaInsets.top - safeAreaInsets.bottom)

        // imageViewはsafeArea一杯に配置されていて、aspectFillで表示中の画像はそれより小さい。縦横比から画面内のimageの領域を計算する
        let size:CGSize = parentImage?.size ?? .zero
        let rate = containerView.frame.size.width / size.width
        let imageSize = CGSize(width: size.width * rate, height: size.height * rate)
        var imageFrame = CGRect(x: (safeAreaFrame.width - imageSize.width) / 2.0 + safeAreaInsets.left,
                                y: (safeAreaFrame.height - imageSize.height) / 2.0 + safeAreaInsets.top,
                                width: imageSize.width,
                                height: imageSize.height)

        // imageViewのスワイプによるtransition後のframeを計算
        imageFrame.origin = CGPoint(x: imageFrame.origin.x + self.modalTransition.swipePoint.x,
                                    y: imageFrame.origin.y + self.modalTransition.swipePoint.y)
        imageFrame = CGRect(x: imageFrame.origin.x + (imageFrame.width * (1.0 - self.modalTransition.swipeScale))/2.0,
                            y: imageFrame.origin.y + (imageFrame.height * (1.0 - self.modalTransition.swipeScale))/2.0,
                            width: imageFrame.width * self.modalTransition.swipeScale,
                            height: imageFrame.height * self.modalTransition.swipeScale)

        return imageFrame
    }
}

