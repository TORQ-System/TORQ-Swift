import Foundation


struct Sensor{
    var vib: String
    var x: String
    var y: String
    var z: String
    var date: String
    var latitude: String
    var longitude: String
    var time: String
    
    
    init(vib: String, x: String, y:String, z: String, date: String, latitude: String, longitude: String, time: String) {
        self.vib = vib
        self.x = x
        self.y = y
        self.z = z
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
    
    func getVib()-> String{
        return vib
    }
    
    func getX()-> String{
        return x
    }
    
    func getY()-> String{
        return y
    }
    
    func getZ()-> String{
        return z
    }
    
    func getDate()-> String{
        return date
    }
    
    func getLatitude()-> String{
        return latitude
    }
    
    func getLongitude()-> String{
        return longitude
    }
    
    func getTime()-> String{
        return time
    }
}
