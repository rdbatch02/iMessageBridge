//
//  AppDelegate.swift
//  iMessageBridge
//
//  Created by Ryan Batchelder on 3/6/15.
//  Copyright (c) 2015 Ryan Batchelder. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        //var imc = iMessageController()
        //println(imc.getMessages())
        var irc = IRCController()
        irc.sendMessage("test")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

