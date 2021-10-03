import Foundation

struct Request {
    var user_id: Int
    var sensor_id: Int
    var request_id: Int
    var date: String
    var time: String
    var longitude: Double
    var latitude: Double
    var vib: Int
    var rotation: Int
    var status: Int
    
    init(user_id: Int, sensor_id: Int, request_id: Int, date: String, time: String, longitude: Double, latitude: Double, vib: Int, rotation: Int, status: Int ) {
        self.user_id = user_id
        self.sensor_id = sensor_id
        self.request_id = request_id
        self.date = date
        self.time = time
        self.longitude = longitude
        self.latitude = latitude
        self.vib = vib
        self.rotation = rotation
        self.status = status
    }
    
    func getUserID()->Int{
        return user_id
    }
    
    func getSensorID()->Int{
        return sensor_id
    }
    
    func getRequestID()->Int{
        return request_id
    }
    
    func getDate()->String{
        return date
    }
    
    func getTime()->String{
        return time
    }
    
    func getLongitude()->Double{
        return longitude
    }
    
    func getLatitude()->Double{
        return latitude
    }
    
    func getVib()->Int{
        return vib
    }
    
    func getRotation()->Int{
        return rotation
    }
    
    func getStatus()->Int{
        return status
    }
}
