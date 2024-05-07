//
//  MetalSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 4/12/24.
//

import Foundation
import ScreenSaver

/// simple screen saver that renders a green rotating `NSView`
class GreenSquareScreenSaverView: ScreenSaverView {
    let greenSquareView = GreenSquareView()
    
    override init?(frame: CGRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1 / 30.0
        addSubview(greenSquareView)
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
        
        var squareFrame = NSRect.zero
        squareFrame.size = NSSize(width: 150, height: 150)
        squareFrame.origin.x = (rect.width - squareFrame.width) / 2.0
        squareFrame.origin.y = (rect.height - squareFrame.height) / 2.0
        greenSquareView.frame = squareFrame
    }
    
    override func animateOneFrame() {
        greenSquareView.rotate(byDegrees: 1)
    }
}

class GreenSquareView: NSView {
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.green.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
