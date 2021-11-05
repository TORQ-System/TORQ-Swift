//
//  SOSRequest.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/11/2021.
//

import Foundation

struct SOSRequest {
    var user_id: String
    var user_name: String
    var status: String
    var assignedCenter: String
    var sent: String
    var longitude: String
    var latitude: String

    init(user_id: String, user_name: String, status: String, assignedCenter: String, sent: String, longitude: String, latitude: String) {
        self.user_id = user_id
        self.user_name = user_name
        self.status = status
        self.assignedCenter = assignedCenter
        self.sent = sent
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func getUserID()->String{
        return user_id
    }

    func getUserName()->String{
        return user_name
    }

    func getStatus()->String{
        return status
    }

    func getAssignedCenter()->String{
        return assignedCenter
    }

    func getSent()->String{
        return sent
    }

    func getLongitude()->String{
        return longitude
    }

    func getLatitude()->String{
        return latitude
    }


    
    
}

