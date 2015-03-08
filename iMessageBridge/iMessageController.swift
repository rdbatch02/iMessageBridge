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
    func getMessages() -> Array<String>
    {
        var messages = [String]() // This is going to be returned at the end of this
        var relations = [Int]()
        var chats = [Int]()
        let db = Database(NSHomeDirectory() + "/Library/Messages/chat.db", readonly: true)
        let message_db = db["message"]
        let chat_message_join = db["chat_message_join"]
        let chat_name_table = db["chat"]
        let message_text = Expression<String?>("text")
        let rowid = Expression<Int>("ROWID")
        let chat_id = Expression<Int>("chat_id")
        let message_id = Expression<Int>("message_id")
        let group_id = Expression<String>("group_id")
        
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
        
        let query = message_db.select(message_text).filter(contains(relations, rowid)).order(rowid.desc).limit(1)
        
        for message in query
        {
            if (message[message_text] != nil)
            {
                messages.append(message[message_text]!)
            }
        }
        
        return messages
    }
}