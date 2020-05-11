# ImageViewer
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<a href="https://github.com/kishikawakatsumi/IBPCollectionViewCompositionalLayout/blob/master/LICENSE"><img alt="MIT License" src="http://img.shields.io/badge/license-MIT-blue.svg"/></a>

Timee ImageViewer is a lightweight image viewer framework for iOS app.

## Demo

|iOS 11.0+|
|---|
|<img src="https://raw.githubusercontent.com/Taimee/ImageViewer/master/images/demo.gif" width="375">|


## Usage

```swift
// ViewController

let imageURLs: [URL] = [ some url array ... ]
let vc = ImageViewerController.init(imageURLs: imageURLs)
present(vc, animated: true)

// Delegate for asynchronous image downloading
extension ViewController: ImageViewerControllerDelegate {
    func load(_ imageURL: URL, into imageView: UIImageView, completion: (() -> Void)?) {
        imageView.setImage(with: imageURL) { _ in
            completion?()
        }
    }
}
```

## Installation
### [Carthage](https://github.com/Carthage/Carthage)

```
github "Taimee/ImageViewer"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for up to date installation instructions.


## Committers

* Takeshi Akutsu ([@takeshi-akutsu](https://github.com/takeshi-akutsu))

## License

Copyright 2020 Timee, Inc.

Licensed under the MIT License.
