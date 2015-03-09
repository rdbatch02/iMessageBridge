//
//  sendMessage.swift
//  
//
//  Created by Duke Frederick Ayers on 3/8/15.
//
//

//You can call this in the command line via "swift sendMessage.swift"
//I have currently set it to send a message to Ryan but in all reality it will send it to whomever
//depenidng on the parameters passed. I had it return "Reached Here" as a precaution to let me know
//exactly where I am.
//Below is the Apple Script that was used to send the message.
/*
on run (arguments)
tell application "Messages"
set myid to get id of first service
set theBuddy to buddy (first item of arguments) of service id myid
send (second item of arguments) to theBuddy
end tell
end run
*/
import Foundation


func sendMessage(number : String , message : String) -> String{
    let task = NSTask()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["SendMessage.scpt", number, message]
    //let pipe = NSPipe()
    //task.standardOutput = pipe
    task.launch()
    return "Reached Here"
}
println(sendMessage("", "If you receive this message, I sent it via a Swift file using the Command Line, which will call an Apple Script"))
