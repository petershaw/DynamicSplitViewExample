//
//  ColoumnMasterViewController.swift
//  UIrowsExample
//
//  Created by Kris Wolff on 03/06/15.
//  Copyright (c) 2015 aus der Technik. All rights reserved.
//

import Foundation
import Cocoa

class ColoumnMasterViewController: NSViewController, NSSplitViewDelegate {
    
    @IBOutlet weak var scrollingView: NSScrollView!
    
    var maxDividerIndex = -1
    let ROW_MINIMUM = 300
    
    var contentView: NSSplitView?
    var widthtContraints: NSLayoutConstraint?
    
    var currentDividerLastPosition: CGFloat?
    var contentSizes = Dictionary<Int, CGFloat>()
    
    override func viewDidLayout() {
        super.viewDidLayout()
        updateContentWidth()
    }
    
    override func viewDidLoad() {
        contentView = NSSplitView(frame: NSRect(x: 0, y: 0, width: 0, height: self.view.frame.height))
        contentView!.vertical = true
        contentView!.wantsLayer = true
        contentView!.layer?.backgroundColor =  NSColor.clearColor().CGColor
        contentView!.dividerStyle = NSSplitViewDividerStyle.Thin
        contentView!.delegate = self
        
        scrollingView.documentView = contentView
        
        autoLayout(contentView!)
    }
    
    func add(){
        maxDividerIndex++

        let vc: NSViewController = self.storyboard?.instantiateControllerWithIdentifier("coloumn_view_controller") as! NSViewController
        vc.view.setFrameOrigin(NSPoint(x: 0, y: 0))
        vc.view.setFrameSize(NSSize(width: CGFloat(ROW_MINIMUM), height: self.view.frame.height))
        vc.view.wantsLayer = true
        vc.view.layer!.backgroundColor = getRandomColor().CGColor
        contentView!.addSubview(vc.view)

        // manage the size
        contentSizes[maxDividerIndex] = vc.view.frame.width

        updateContentWidth()
    }
    
    func autoLayout(contentView: NSView){
        let topPinContraints = NSLayoutConstraint(
            item: contentView
            , attribute: NSLayoutAttribute.Top
            , relatedBy: .Equal
            , toItem: contentView.superview
            , attribute: NSLayoutAttribute.Top
            , multiplier: 1.0
            , constant: 0
        )
        let bottomPinContraints = NSLayoutConstraint(
              item: contentView
            , attribute: NSLayoutAttribute.Bottom
            , relatedBy: .Equal
            , toItem: contentView.superview
            , attribute: NSLayoutAttribute.Bottom
            , multiplier: 1.0
            , constant: 0
        )

        let heightContraints = NSLayoutConstraint(
            item: contentView
            , attribute: NSLayoutAttribute.Height
            , relatedBy: .Equal
            , toItem: contentView.superview!
            , attribute: NSLayoutAttribute.Height
            , multiplier: 1.0
            , constant: 0
        )

        let calculatedWith: CGFloat = (CGFloat) (contentView.subviews.count * ROW_MINIMUM)
        widthtContraints = NSLayoutConstraint(
            item: contentView
            , attribute: NSLayoutAttribute.Width
            , relatedBy: .Equal
            , toItem: nil
            , attribute: NSLayoutAttribute.Width
            , multiplier: 1.0
            , constant: 0
        )
        widthtContraints!.constant = calculatedWith
        
        NSLayoutConstraint.activateConstraints([
              topPinContraints
             , bottomPinContraints
             , heightContraints
             , widthtContraints!
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.needsLayout = true
    }
    
    func updateContentWidth(){
        var calculatedWith = contentSizes.values.array.reduce(CGFloat(0)) { (total, width: CGFloat) in
            total + width
        }
        if calculatedWith < view.frame.width {
            calculatedWith = view.frame.width
        }
        if (widthtContraints != nil) {
            widthtContraints!.constant = calculatedWith
        }
        scrollingView.needsLayout = true;
    }
    
    func getRandomColor() -> NSColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return NSColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 0.3)
    }
    
    
    // MARK: SplitView
    
    func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return false
    }
    
    func splitView(splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        var minimum: CGFloat = 0
        if dividerIndex == 0 {
            return CGFloat(ROW_MINIMUM)
        }
        for i in 0...(dividerIndex - 1) {
            if var width = contentSizes[i] {
                if width < CGFloat(ROW_MINIMUM) { width = CGFloat(ROW_MINIMUM) }
                minimum += width
            }
        }
        minimum =  minimum + CGFloat(ROW_MINIMUM)
        return  minimum
    }
    
    func splitView(splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        var maximum: CGFloat = 0
        if dividerIndex == 0 {
            return contentView!.frame.width
        }
        for i in 0...(dividerIndex - 1) {
            if var width = contentSizes[i] {
                if width < CGFloat(ROW_MINIMUM) { width = CGFloat(ROW_MINIMUM) }
                maximum += width
            }
        }
        maximum =  maximum + view.frame.width
        return  maximum
    }
    
    func splitViewDidResizeSubviews(notification: NSNotification) {
        if let info = notification.userInfo as Dictionary<NSObject, AnyObject>! {
            if let dividerIndex: Int = info["NSSplitViewDividerIndex"] as? Int {
                let amount = self.positionOfDividerAtIndex(dividerIndex) - (currentDividerLastPosition ?? self.positionOfDividerAtIndex(dividerIndex))
                currentDividerLastPosition = nil;
                
                contentSizes[dividerIndex] = contentSizes[dividerIndex]! + amount
                splitViewResizeWidth(amount)
                if let content = contentView {
                    for i in 0...content.subviews.count - 1 {
                        if let a = content.subviews[i] as? NSView {
                            if let size = contentSizes[i] {
                                if size >= CGFloat(ROW_MINIMUM){
                                    a.setFrameSize(NSSize(width: size, height: a.frame.height))
                                } else {
                                    a.setFrameSize(NSSize(width: CGFloat(ROW_MINIMUM), height: a.frame.height))
                                }
                            }

                        }
                    }
                }
                
                
            }
        }
    }
    
    func splitViewWillResizeSubviews(notification: NSNotification) {
        if let info = notification.userInfo as Dictionary<NSObject, AnyObject>! {
            if let dividerIndex: Int = info["NSSplitViewDividerIndex"] as? Int {
                currentDividerLastPosition = self.positionOfDividerAtIndex(dividerIndex)
            }
        }
    }
    
    func positionOfDividerAtIndex(var dividerIndex: NSInteger) -> (CGFloat) {
        while (dividerIndex >= 0 && contentView!.isSubviewCollapsed(contentView!.subviews[dividerIndex] as! NSView) ){
            dividerIndex--
        }
        if (dividerIndex < 0) {
            return 0.0;
        }
        let priorViewFrame: NSRect = contentView!.subviews[dividerIndex].frame
        return contentView!.vertical ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame)
    }
    
    func splitViewResizeWidth(amount: CGFloat){
        if let view = contentView {
            let newSize = view.frame.width + amount
            contentView!.setFrameSize(NSSize(width: newSize, height: view.frame.height))
            updateContentWidth()
        }
        
    }
    
}
