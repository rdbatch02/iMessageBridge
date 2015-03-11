//
//  iMessageController.swift
//  iMessageBridge
//
//  Created by Ryan Batchelder on 3/7/15.
//  Copyright (c) 2015 Ryan Batchelder. All rights reserved.
//

import Foundation
import SQLite

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
    
    override init() {
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
        
        // This chat ID might be unique to my chat database. We should check this
        let chat_name = chat_name_table.select(rowid).filter(like("B040DCFF-5CBE-4366-AC98-4E2F93BFBD52", group_id))
        
        for chat in chat_name
        {
            chats.append(chat[rowid])
        }
        
        let message_relation = chat_message_join.select(message_id).filter(contains(chats, chat_id))
        
        for relation in message_relation
        {
            relations.append(relation[message_id])
        }
        
        super.init()
    }
    func getMessages() -> String
    {
        let query = message_db.select(message_text).filter(contains(relations, rowid)).order(rowid.desc).limit(1)
        
        if (query.first?.get(message_text) != nil)
        {
            return (query.first?.get(message_text)!)!
        }
        
//        for message in query
//        {
//            if (message[message_text] != nil)
//            {
//                return message[message_text]!
//            }
//        }
        
        return ""
    }
    
    func getNewMessages() -> Void
    {
        var oldMessage = getMessages()
        
        let priority = Int(QOS_CLASS_BACKGROUND.value)
        dispatch_async(dispatch_get_global_queue(priority, 0),
        {
            println(oldMessage)
            while true
            {
                if self.getMessages() != oldMessage
                {
                    oldMessage = self.getMessages()
                    println(oldMessage)
                }
                sleep(2)
            }
        })
        
        
    }
}