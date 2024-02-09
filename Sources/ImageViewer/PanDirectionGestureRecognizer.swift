//
//  PanDirectionGestureRecognizer.swift
//
//
//  Created by 三好孝明 on 2024/02/09.
//

import Foundation
import UIKit

// ref: https://stackoverflow.com/a/30607392
enum PanDirection {
    case vertical
    case horizontal
}

/// UIPanGestureRecognizer - Only vertical or horizontal
final class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    private let direction: PanDirection

    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where fabs(vel.y) > fabs(vel.x):
                state = .cancelled
            case .vertical where fabs(vel.x) > fabs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}
