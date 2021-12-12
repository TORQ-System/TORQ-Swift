//
//  Message.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 08/12/2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}
