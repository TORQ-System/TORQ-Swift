import Foundation

struct Request {
    var user_id: String
    var sensor_id: String
    var request_id: String
    var dateTime: String
    var longitude: String
    var latitude: String
    var vib: String
    var rotation: String
    var status: String
    
    
    init(user_id: String, sensor_id: String, request_id: String, dateTime: String, longitude: String, latitude: String, vib: String, rotation: String, status: String ) {
        self.user_id = user_id
        self.sensor_id = sensor_id
        self.request_id = request_id
        self.dateTime = dateTime
        self.longitude = longitude
        self.latitude = latitude
        self.vib = vib
        self.rotation = rotation
        self.status = status
    }
    
    func getUserID()->String{
        return user_id
    }
    
    func getSensorID()->String{
        return sensor_id
    }
    
    func getRequestID()->String{
        return request_id
    }
    
    func getDateTime()->String{
        return dateTime
    }
    
    func getLongitude()->String{
        return longitude
    }
    
    func getLatitude()->String{
        return latitude
    }
    
    func getVib()->String{
        return vib
    }
    
    func getRotation()->String{
        return rotation
    }
    
    func getStatus()->String{
        return status
    }
}
