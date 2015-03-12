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


    @IBOutlet weak var outputField: NSTextField!
    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        var imc = iMessageController(outputField: outputField)
        println(imc.getNewMessages())
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}