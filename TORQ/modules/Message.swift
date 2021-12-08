//
//  Message.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 08/12/2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
