//
//  ImageViewerController.swift
//  ImageViewer
//
//  Created by 阿久津　岳志 on 2020/04/25.
//  Copyright © 2020 阿久津　岳志. All rights reserved.
//

import UIKit

public protocol ImageViewerControllerDelegate: ImageLoader {
    func dismiss(_ imageViewerController: ImageViewerController, lastPageIndex: Int)
}

public extension ImageViewerControllerDelegate {
    func dismiss(_ imageViewerController: ImageViewerController, lastPageIndex: Int) {}
}

public enum BackgroundStyle {
    case blurredImage
    case color(UIColor)
}

public final class ImageViewerController: UIViewController {

    lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        return scrollView
    }()

    private lazy var backgroundEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return effectView
    }()

    private lazy var backgroundImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(self.backgroundEffectView)
        return imageView
    }()
    
    private lazy var pageControl: UIPageControl = { [unowned self] in
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    private lazy var dismissButton: DismissButton = { [unowned self] in
        let button = DismissButton()
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()

    private var pageIndex: Int
    private let imageURLs: [URL]
    private var pageViews: [PageView] = []
    public weak var delegate: ImageViewerControllerDelegate?
    public let backgroundStyle: BackgroundStyle

  public init(imageURLs: [URL], pageIndex: Int = 0, useCustomTransitioning: Bool = true, backgroundStyle: BackgroundStyle = .blurredImage) {
        self.pageIndex = pageIndex
        self.imageURLs = imageURLs
        self.backgroundStyle = backgroundStyle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen

        if useCustomTransitioning {
            transitioningDelegate = self
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        guard let imageLoader = delegate else {
            fatalError("must confirm ImageViewerControllerDelegate")
        }
        imageURLs.forEach { [weak self] url in
            let pageView = PageView.init(imageURL: url, imageLoader: imageLoader)
            pageView.pageViewDelegate = self
            self?.scrollView.addSubview(pageView)
            self?.pageViews.append(pageView)
        }
        view.addSubview(pageControl)
        view.addSubview(dismissButton)

        let gestureRecognizer = PanDirectionGestureRecognizer(
          direction: .vertical,
          target: self,
          action: #selector(self.handleViewPanned)
        )
        
        gestureRecognizer.cancelsTouchesInView = false
      
        view.addGestureRecognizer(gestureRecognizer)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // setup layout
        scrollView.frame = view.bounds
        backgroundImageView.frame = view.bounds
        pageViews.enumerated().forEach { [unowned self] index, view in
            view.frame = self.scrollView.bounds
            view.frame.origin.x = self.scrollView.frame.width * CGFloat(index)
        }
        pageControl.frame = .init(
            x: (view.frame.width - 200) / 2,
            y: view.frame.height - 50,
            width: 200,
            height: 30
        )
        dismissButton.frame = .init(x: 16, y: 40, width: 48, height: 36)
        
        // configuration with initial values after initialize layout
        pageControl.numberOfPages = pageViews.count
        pageControl.currentPage = pageIndex
        pageControl.isHidden = pageViews.count == 1
        scrollView.contentSize.width = CGFloat(pageViews.count) * scrollView.frame.width
        scrollView.setContentOffset(.init(x: scrollView.bounds.width * CGFloat(pageIndex), y: 0), animated: false)
        updateDynamicBackgroundImage()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.dismiss(self, lastPageIndex: pageIndex)
    }
    
    private func updateDynamicBackgroundImage() {
        /*
         【PageViewでの画像読み込み】と【viewDidLayoutSubviews】の両方が終わったタイミングで、backgroundImageの更新をする必要がある。
         PageViewでの画像読み込みは非同期で行われているため、どのくらいの速さで終わるかは不安定。
         そのため、2箇所の両方でこの処理を呼び出すことで、両方が終わったタイミングで更新されることを保証している。
         */
        switch backgroundStyle {
        case .blurredImage:
            backgroundImageView.image = pageViews[pageIndex].imageView.image
            backgroundEffectView.isHidden = false
            backgroundImageView.backgroundColor = nil
        case .color(let color):
            backgroundImageView.image = nil
            backgroundEffectView.isHidden = true
            backgroundImageView.backgroundColor = color
        }
    }
    
    @objc func dismissAction() {
        dismiss(animated: true)
    }

    @objc func handleViewPanned(sender: UIPanGestureRecognizer) {
         let translation = sender.translation(in: view)
         let progress = abs(translation.y) / view.frame.height

         switch sender.state {
         case .changed:
             UIView.animate(
                 withDuration: 0.0,
                 delay: 0,
                 usingSpringWithDamping: 0.7,
                 initialSpringVelocity: 1,
                 options: .curveEaseOut,
                 animations: {
                   self.view.transform.ty = translation.y
                 }
             )
         case .cancelled:
             break

         case .ended:
             let velocity = sender.velocity(in: view).y

             if progress + abs(velocity) / view.bounds.height > 0.8 {
                 self.dismiss(animated: true, completion: nil)
             } else {
                 UIView.animate(
                     withDuration: 0.0,
                     delay: 0,
                     usingSpringWithDamping: 0.7,
                     initialSpringVelocity: 1,
                     options: .curveEaseOut,
                     animations: {
                         self.view.transform = .identity
                     }
                 )
             }
         default:
             break
         }
     }
}

extension ImageViewerController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        updateDynamicBackgroundImage()
        pageControl.currentPage = pageIndex
    }
}

extension ImageViewerController: PageViewDelegate {
    func pageViewStatusDidChanged(_ status: PageView.Status) {
        scrollView.isScrollEnabled = status == .normal
    }
    
    func pageViewDidLoadImage() {
        updateDynamicBackgroundImage()
    }
}

// MARK: CustomTransition
extension ImageViewerController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator.init(context: .present)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator.init(context: .dismiss)
    }
}
