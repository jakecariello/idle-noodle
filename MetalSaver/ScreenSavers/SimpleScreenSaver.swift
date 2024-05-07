//
//  SimpleScreenSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/2/24.
//

import Foundation
import ScreenSaver

class SimpleScreenSaverView: ScreenSaverView {
    let squareView = SquareView(color: .red)
    let blueView = SquareView(color: .blue)
    var t = 0.0
    let nestView = SquareView(color: .magenta)
    let innerView = SquareView(color: .yellow)

    override init?(frame: CGRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1 / 30.0
        addSubview(squareView)
        addSubview(blueView)
        
        nestView.addSubview(innerView)
        addSubview(nestView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAnimation() {
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
//        squareView.frame.size = NSSize(width: frame.width / 2.0, height: frame.height / 2.0)
        squareView.frame.size = NSSize(width: 100, height: 100)
        blueView.frame.size = NSSize(width: 100, height: 100)
        
        nestView.frame.origin = CGPoint(x: frame.size.width / 2 - 100, y: frame.size.height / 2 - 100)
        nestView.frame.size = NSSize(width: 200, height: 200)
        
        innerView.frame.origin = CGPoint(x: 50, y: 50)
        innerView.frame.size = NSSize(width: 100, height: 100)
    }

    override func animateOneFrame() {
        
        squareView.frame.origin = NSPoint(
            x: (frame.width - squareView.frame.size.width) * ((sin(5.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0),
            y: (frame.height - squareView.frame.size.height) * ((sin(7.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0)
        )
        
        nestView.frame.origin = NSPoint(
            x: (frame.width - nestView.frame.size.width) * ((sin(3.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0),
            y: (frame.height - nestView.frame.size.height) * ((sin(5.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0)
        )
        
        blueView.frame.origin = NSPoint(
            x: (frame.width - blueView.frame.size.width) * ((sin(4.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0),
            y: (frame.height - blueView.frame.size.height) * ((sin(9.0 * animationTimeInterval * t / 8.0) + 1.0) / 2.0)
        )


        t = t + 1
    }
}

class SquareView: NSView {
    init(color: NSColor) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
