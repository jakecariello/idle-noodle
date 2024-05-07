//
//  MetalHelloWorld.swift
//  MetalSaver
//
//  Created by Jake Cariello on 4/12/24.
//

import Foundation
import ScreenSaver
import Cocoa
import MetalKit

class MetalHelloWorldScreenSaverView: ScreenSaverView {
    let mtkView = MTKViewContainer()
    
    override init?(frame: CGRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1 / 30.0
        addSubview(mtkView)
        mtkView.frame = self.frame
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
        
    }
    
    override func animateOneFrame() {
        mtkView.rotate(byDegrees: 1)
    }
}

class MTKViewContainer: NSView {
    var view: MTKView!
    var renderer: SimpleRenderer!
    
    // NSView overrides
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupMetalView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        return true // Coordinates in Metal are traditionally flipped compared to Cocoa
    }
    
    // Metal setup
    
    private func setupMetalView() {
        // Creat e MTKView
        view = MTKView(frame: bounds)
        view.autoresizingMask = [.width, .height]
        addSubview(view)

        // Get default Metal device
        view.device = MTLCreateSystemDefaultDevice()
        if view.device == nil {
            print("Metal is not supported on this device")
        }
        
        view.clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0)
        
        view.enableSetNeedsDisplay = true
        
        renderer = SimpleRenderer(metalKitView: view)
        renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)
        view.delegate = renderer
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        view.draw()
    }
}
