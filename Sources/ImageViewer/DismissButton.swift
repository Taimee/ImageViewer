//
//  DismissButton.swift
//  
//
//  Created by 三好孝明 on 2024/02/06.
//

import Foundation
import UIKit

final class DismissButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)

    let configuration = UIImage.SymbolConfiguration.init(
      pointSize: 16,
      weight: .semibold,
      scale: .large
    )
    let image = UIImage.init(systemName: "multiply")!
        .withConfiguration(configuration)
    tintColor = .init(red: 52 / 255, green: 52 / 255, blue: 52 / 255, alpha: 1)
    setImage(image, for: .normal)
    backgroundColor = .init(red: 234 / 255, green: 234 / 255, blue: 234 / 255, alpha: 1)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
}
