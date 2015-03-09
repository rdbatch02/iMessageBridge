//
//  IRCController.swift
//  iMessageBridge
//
//  Created by Ryan Batchelder on 3/7/15.
//  Copyright (c) 2015 Ryan Batchelder. All rights reserved.
//

import Foundation

class IRCController: NSObject, NSStreamDelegate
{
    var Host: String = "127.0.0.1"
    var Port: Int = 6667
    var InStream: NSInputStream?
    var OutStream: NSOutputStream?
    var Password: String = ""
    var chatBuffer = [UInt8](count: 10000, repeatedValue: 0)

    override init()
    {
        super.init()
        self.connect()
        // Connect
    }
    deinit
    {
        // Disconnect and stuff
    }
    
    func sendMessage(msg:String)
    {
        var message = String()
        if msg.hasPrefix("/")
        {
            msg.substringFromIndex(msg.startIndex.successor())
        }
        message += msg
        message += "\r\n"
        var data:NSData = msg.dataUsingEncoding(NSUTF8StringEncoding)!
        var buffer = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&buffer)
        OutStream!.write(&buffer, maxLength: data.length)
        
    }
    
    func connect()
    {
        NSStream.getStreamsToHostWithName(Host, port: Port, inputStream: &InStream, outputStream: &OutStream)
        InStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        OutStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        InStream!.delegate = self
        OutStream!.delegate = self
        
        InStream!.open()
        OutStream!.open()
        
        sendMessage("NICK message_bot" + String(Int(arc4random())))
        sendMessage("PASS " + self.Password)
        sendMessage("/join chat")
    }
    
    func chatLoop()
    {
        var message: String = ""
        if InStream!.hasBytesAvailable
        {
            while InStream!.hasBytesAvailable
            {
                InStream!.read(&chatBuffer, maxLength: chatBuffer.count)
                let data = NSData(bytes: &chatBuffer, length: chatBuffer.count)
                message = NSString(data: data, encoding: NSUTF8StringEncoding)!
                println(message)
            }
        }
    }

}