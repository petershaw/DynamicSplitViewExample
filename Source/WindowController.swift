//
//  WindowController.swift
//  ScrollSplitView
//
//  Created by Kris Wolff on 04/06/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func addRow(sender: AnyObject?){
        if let viewController = self.contentViewController as? ColoumnMasterViewController {
            viewController.add()
        }
    }
}
