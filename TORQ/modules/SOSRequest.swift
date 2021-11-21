//
//  SOSRequest.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/11/2021.
//

import Foundation

struct SOSRequest {
    var user_id: String
    var status: String
    var assignedCenter: String
    var sent: String
    var longitude: String
    var latitude: String
    var timeDate: String

    init(user_id: String, status: String, assignedCenter: String, sent: String, longitude: String, latitude: String, timeDate:String) {
        self.user_id = user_id
        self.status = status
        self.assignedCenter = assignedCenter
        self.sent = sent
        self.longitude = longitude
        self.latitude = latitude
        self.timeDate = timeDate
    }
    
    func getTimeDate()->String{
        return timeDate
    }
    
    func getUserID()->String{
        return user_id
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

