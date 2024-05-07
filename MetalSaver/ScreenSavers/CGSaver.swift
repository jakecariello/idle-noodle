//
//  CGSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/4/24.
//

import Foundation
import ScreenSaver

extension NSRect {

    /// Insets and scales a rectangle around its center.
    ///
    /// - Parameter by: The scale factor to apply.
    /// - Returns: A new rectangle that is inset and scaled by the given factor.

    func insetScaleBy(by: CGFloat) -> CGRect {
        return insetBy(
            dx: -width * ((by - 1) / 2),
            dy: -height * ((by - 1) / 2)
        )
    }
}

class CGSaver: ScreenSaverView {

    var t: CGFloat = 0.0
    var radius: CGFloat {
        min(bounds.width, bounds.height) / 10
    }


    var redPath = NSBezierPath()
    var bluePath = NSBezierPath()
    var yellowPath = NSBezierPath()

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 0.03

    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)

        // Background
        NSColor.black.setFill()
        rect.fill()

        NSColor.red.setFill()
        redPath.fill()

        NSColor.blue.setFill()
        bluePath.fill()

        NSColor.yellow.setFill()
        yellowPath.fill()
    }

    override func startAnimation() {
        super.startAnimation()
        t = 0.0
    }


    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        t += animationTimeInterval

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        // Calculate circle position
        let x = center.x + cos(t) * (center.x - radius)
        let y = center.y + sin(t) * (center.y - radius)

        let redRect = NSRect(
            x: x - radius,
            y: y - radius,
            width: radius * 2,
            height: radius * 2)

        // Blue circle (Figure-8 motion)
        let xBlue = center.x + cos(t) * (center.x - radius)
        let yBlue = center.y + sin(2 * t) * (center.y - radius)

        let blueRect = NSRect(
            x: xBlue - radius,
            y: yBlue - radius,
            width: radius * 2,
            height: radius * 2)

        // Yellow circle (Horizontal motion)
        let horizontalAmplitude = bounds.width / 3 // Adjust for desired range
        let xYellow = center.x + cos(t * 2) * horizontalAmplitude // Faster motion
        let yYellow = center.y

        let yellowRect = NSRect(
            x: xYellow - radius,
            y: yYellow - radius,
            width: radius * 2,
            height: radius * 2)

        redPath.removeAllPoints() // Assumes you have a path variable
        redPath.appendOval(in: redRect)

        bluePath.removeAllPoints()
        bluePath.appendOval(in: blueRect)

        yellowPath.removeAllPoints()
        yellowPath.appendOval(in: yellowRect)

        /// Two rendering approaches:
        /// - a: multiple draw calls, centered around
//        setNeedsDisplay(redRect.insetScaleBy(by: 2))
//        setNeedsDisplay(blueRect.insetScaleBy(by: 2))
//        setNeedsDisplay(yellowRect.insetScaleBy(by: 2))
        /// - b: single draw call for entire window
        setNeedsDisplay(bounds)

    }
}
