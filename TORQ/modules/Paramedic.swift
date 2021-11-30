//
//  Paramedic.swift
//  TORQ
//
//  Created by Norua Alsalem on 29/11/2021.
//

import Foundation

struct Paramedic {
    
    var longitude: String
    var latitude: String

    
    init(longitude: String, latitude: String) { 
        self.longitude = longitude
        self.latitude = latitude
    
}
    
    func getLongitude()-> String{
        return longitude
    }
    
    func getLatitude()-> String{
        return latitude
    }
    
}
