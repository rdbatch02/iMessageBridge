//
//  iMessageController.swift
//  iMessageBridge
//
//  Created by Ryan Batchelder on 3/7/15.
//  Copyright (c) 2015 Ryan Batchelder. All rights reserved.
//

import Foundation
import SQLite
import Dispatch
import AddressBook

class iMessageController: NSObject
{
    var db:Database
    var relations:[Int]
    var chats:[Int]
    var message_db:SQLite.Query
    var chat_message_join:SQLite.Query
    var chat_name_table:SQLite.Query
    var rowid:Expression<Int>
    var chat_id:Expression<Int>
    var message_id:Expression<Int>
    var group_id:Expression<String>
    var message_text:Expression<String?>
    var message_sender:Expression<String?>
    var address_book:ABAddressBook
    var outputField:NSTextField!
    
    init(outputField:NSTextField!) {
        self.db = Database(NSHomeDirectory() + "/Library/Messages/chat.db", readonly: true)
        self.relations = [Int]()
        self.chats = [Int]()
        self.message_db = db["message"]
        self.chat_message_join = db["chat_message_join"]
        self.chat_name_table = db["chat"]
        self.rowid = Expression<Int>("ROWID")
        self.chat_id = Expression<Int>("chat_id")
        self.message_id = Expression<Int>("message_id")
        self.group_id = Expression<String>("group_id")
        self.message_text = Expression<String?>("text")
        self.message_sender = Expression<String?>("account")
        self.address_book = ABAddressBook.sharedAddressBook()
        self.outputField = outputField
        
        super.init()
    }
    
    func getName(searchString:String) -> String
    {
        let emailSearch = ABPerson.searchElementForProperty(kABEmailProperty,
            label: nil,
            key: nil,
            value: searchString,
            comparison: CFIndex(kABContainsSubStringCaseInsensitive.value) as ABSearchComparison)
        
        let phoneSearch = ABPerson.searchElementForProperty(kABPhoneProperty,
            label: nil,
            key: nil,
            value: searchString,
            comparison: CFIndex(kABContainsSubStringCaseInsensitive.value) as ABSearchComparison)
        
        var search = ABSearchElement(forConjunction: CFIndex(kABSearchOr.value), children: [emailSearch, phoneSearch])
        var result = self.address_book.recordsMatchingSearchElement(search) as [ABRecord]
        var name = (result.first?.valueForProperty(kABFirstNameProperty) as String? ?? "") + " " + (result.first?.valueForProperty(kABLastNameProperty) as String? ?? "")
        return name
    }
    
    func getMessages() -> Array<String>
    {
        // This chat ID might be unique to my chat database. We should check this
        let chat_name = chat_name_table.select(rowid).filter(like("B040DCFF-5CBE-4366-AC98-4E2F93BFBD52", group_id))
        
        for chat in chat_name
        {
            chats.append(chat[rowid])
        }
        //chats = [116] //Remove this after testing
        let message_relation = chat_message_join.select(message_id).filter(contains(chats, chat_id))
        
        for relation in message_relation
        {
            relations.append(relation[message_id])
        }
        
        let query = message_db.select(message_text, message_sender).filter(contains(relations, rowid)).order(rowid.desc).limit(1)
        
        if (query.first?.get(message_text) != nil)
        {
            var account = (query.first?.get(message_sender)!)! as String
            var name = getName(account.substringFromIndex(advance(account.startIndex, 2)))
            if name == ""
            {
                name = account
            }
            return [name, (query.first?.get(message_text)!)!]
        }
        
        return []
    }
    
    func getNewMessages() -> Void
    {
        var oldMessage = self.getMessages()
        
        let priority = Int(QOS_CLASS_BACKGROUND.value)
        dispatch_async(dispatch_get_global_queue(priority, 0),
        {
            println(oldMessage[0] + ": " + oldMessage[1])
            self.outputField.stringValue = self.outputField.stringValue + "\n" + (oldMessage[0] + ": " + oldMessage[1])
            while true
            {
                if self.getMessages()[0] != oldMessage[0]
                {
                    oldMessage = self.getMessages()
                    println(oldMessage[0] + ": " + oldMessage[1])
                    self.outputField.stringValue = self.outputField.stringValue + "\n" + (oldMessage[0] + ": " + oldMessage[1])
                }
                sleep(1)
            }
        })
        
        
    }
}