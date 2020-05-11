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

public final class ImageViewerController: UIViewController {

    lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        return scrollView
    }()
    
    private lazy var backgroundImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let effect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView.init(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.addSubview(effectView)
        return imageView
    }()
    
    private lazy var pageControl: UIPageControl = { [unowned self] in
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    private lazy var dismissButton: UIButton = { [unowned self] in
        let button = UIButton()
        let image = UIImage.init(named: "icon_close", in: Bundle(for: ImageViewerController.self), compatibleWith: .none)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()

    private var pageIndex: Int
    private let imageURLs: [URL]
    private var pageViews: [PageView] = []
    public weak var delegate: ImageViewerControllerDelegate?

    public init(imageURLs: [URL], pageIndex: Int = 0) {
        self.pageIndex = pageIndex
        self.imageURLs = imageURLs
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        transitioningDelegate = self
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
        dismissButton.frame = .init(x: 0, y: 40, width: 50, height: 50)
        
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
        backgroundImageView.image = pageViews[pageIndex].imageView.image
    }
    
    @objc func dismissAction() {
        dismiss(animated: true)
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
