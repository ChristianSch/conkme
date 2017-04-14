//
//  AppDelegate.swift
//  conkbar
//
//  Created by Rauhul Varma on 12/15/16.
//  Modified by Christian Schulze 14/04/2017.
//  Copyright © 2017 Christian Schulze. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    var statusItem: NSStatusItem?

    @IBAction func quit(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* set up window size */
        let screen = NSScreen.main()!.frame
        let window = NSApplication.shared().windows.last!
        
        window.setFrame(
            NSRect(x: DESKTOP_INSET,
                   y: DESKTOP_INSET,
                   width: screen.width - (2 * DESKTOP_INSET),
                   height: screen.height - (2 * DESKTOP_INSET)),
            display: true)
        window.backgroundColor = NSColor.clear
        window.alphaValue = 1

        /* set up status bar item */
        let bar = NSStatusBar.system()

        statusItem = bar.statusItem(withLength:
            CGFloat(NSVariableStatusItemLength))
        statusItem!.title = ">_"
        statusItem!.menu = menu
        statusItem!.highlightMode = true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {

    }
}

