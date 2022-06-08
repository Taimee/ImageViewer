//
//  PageView.swift
//  ImageViewer
//
//  Created by 阿久津　岳志 on 2020/04/25.
//  Copyright © 2020 阿久津　岳志. All rights reserved.
//

import UIKit

public protocol ImageLoader: AnyObject {
    func load(_ imageURL: URL, into imageView: UIImageView, completion: (() -> Void)?)
}

protocol PageViewDelegate: AnyObject {
    func pageViewStatusDidChanged(_ status: PageView.Status)
    func pageViewDidLoadImage()
}

final class PageView: UIScrollView {
    lazy var imageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var loadingIndicator: UIView = { [unowned self] in
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        return indicator
    }()

    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(scrollViewDidDoubleTapped(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
    }()
    
    weak var pageViewDelegate: PageViewDelegate?
    
    init(imageURL: URL, imageLoader: ImageLoader?) {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(loadingIndicator)
        
        imageLoader?.load(imageURL, into: imageView) { [weak self] in
            self?.layoutImageViewIfNeeded()
            self?.loadingIndicator.removeFromSuperview()
            self?.pageViewDelegate?.pageViewDidLoadImage()
        }
        
        // initialize scrollView
        self.delegate = self
        maximumZoomScale = 2.0
        minimumZoomScale = 1.0
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutImageViewIfNeeded()
        loadingIndicator.center = .init(x: bounds.width / 2, y: bounds.height / 2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageView {
    
    enum Status {
        case normal
        case zoomIn
    }
    
    /*
    memo: 画像読み込みとlayoutSubviewsが終了後にImageViewのlayoutを整えないといけない。
    画像の読み込みが先に終わる時もあれば、layoutSubviewsの方が先に終わる場合もあるので、2箇所でこれを呼び出している
    */
    private func layoutImageViewIfNeeded() {
        guard imageView.frame == .zero else { return }
        if let imageSize = imageView.image?.size {
            let widthRatio = frame.width / imageSize.width
            let heightRatio = frame.height / imageSize.height
            let scale = min(widthRatio, heightRatio)
            imageView.frame.size = .init(width: imageSize.width * scale, height: imageSize.height * scale)
            
            contentSize = imageView.frame.size
            adjustContentInset()
        }
    }
    
    // MARK: centering the imageView
    private func adjustContentInset() {
        contentInset = .init(
            top: max((frame.height - imageView.frame.height) / 2, 0),
            left: max((frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0
        )
    }
    
    @objc func scrollViewDidDoubleTapped(_ sender: UITapGestureRecognizer) {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let tapped = sender.location(in: self)
            let size: CGSize = .init(width: contentSize.width / maximumZoomScale, height: contentSize.height / maximumZoomScale)
            let origin: CGPoint = .init(x: tapped.x - (size.width / 2), y: tapped.y - (size.height / 2))
            zoom(to: .init(origin: origin, size: size), animated: true)
        }
    }
}

extension PageView: UIScrollViewDelegate {
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if zoomScale > minimumZoomScale {
            pageViewDelegate?.pageViewStatusDidChanged(.zoomIn)
        } else {
            pageViewDelegate?.pageViewStatusDidChanged(.normal)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustContentInset()
    }
}
