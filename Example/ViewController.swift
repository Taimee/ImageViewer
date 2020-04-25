//
//  ViewController.swift
//  Example
//
//  Created by 阿久津　岳志 on 2020/04/25.
//  Copyright © 2020 阿久津　岳志. All rights reserved.
//

import UIKit
import ImageViewer
import Kingfisher

private func getRandomImageURL(id: Int = Int(arc4random_uniform(1000))) -> URL {
    return URL(string: "https://picsum.photos/800/600?image=\(id)")!
}

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = showImageViewerOnlyOnce
    }
    
    private lazy var showImageViewerOnlyOnce: Void = { [weak self] in
        let vc = ImageViewerController.init(imageURLs: [
            getRandomImageURL(id: 844),
            getRandomImageURL(id: 957),
            getRandomImageURL(id: 201),
            getRandomImageURL(id: 162),
            getRandomImageURL(id: 599)
        ])
        vc.delegate = self
        self?.present(vc, animated: true)
    }()
}

extension ViewController: ImageViewerControllerDelegate {
    func load(_ imageURL: URL, into imageView: UIImageView, completion: (() -> Void)?) {
//        ex. when you use Kingfisher as a background image loader
        imageView.kf.setImage(with: imageURL) { _ in
            completion?()
        }
    }
}
