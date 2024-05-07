//
//  PreviewViewController.swift
//  Preview
//
//  Created by Jake Cariello on 4/12/24.
//

import SwiftUI
import ScreenSaver

struct PreviewView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> PreviewViewController {
            return PreviewViewController() // Initialize your NSViewController here
        }

        func updateNSViewController(_ nsViewController: PreviewViewController, context: Context) {
            // Update your NSViewController if necessary
        }
}
