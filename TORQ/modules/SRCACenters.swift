import Foundation
import CoreLocation

class SRCACenters {
    
    static let centers: [[String:Any]] = [
      [
        // 1-maseef
        "name": "almasiaf",
        "latitude": 24.766719982385496,
        "longitude": 46.67534595473277
      ],
      [
        // 2-malqa
        "name": "almalqa",
        "latitude": 24.813340812816,
        "longitude": 46.608601997063275,
      ],
      [
        // 3-khaldiya
        "name": "alkhalidiyyah",
        "latitude": 24.619958154092846,
        "longitude": 46.75525738171758,
      ],
      [
        // 4-king fahad
        "name": "kingfahad",
        "latitude": 24.739310634888415,
        "longitude": 46.674034268226166,
      ],
      [
        // 5-uraubah
        "name": "alorobah",
        "latitude": 24.70462364665244,
        "longitude": 46.64807129759366,
      ],
      [
        // 6-nafel
        "name": "alnafel",
        "latitude": 24.78216370748611,
        "longitude": 46.680739075994765,
      ],
      [
        // 7-sulaimaniyah
        "name": "alsulimaniyah",
        "latitude": 24.710575659754106,
        "longitude": 46.69030329759365,
      ],
      [
        // 8-rawdah
        "name": "alrawdah",
        "latitude": 24.739990461910555,
        "longitude": 46.75482089759365,
      ],
      [
        // 9-king faisal
        "name": "kingfaisal",
        "latitude": 24.758385968298718,
        "longitude": 46.77954013417631,
      ],
      [
        // 10-Nahdah
        "name": "alnahdah",
        "latitude": 24.764932864314947,
        "longitude": 46.824687073212694,
      ],
      [
        // 11-Ishbeliyah
        "name": "ishbiliyah",
        "latitude": 24.79760402644183,
        "longitude": 46.7870465262868,
      ],
      [
        // 12-Diriyah<3<3
        "name": "diriyah",
        "latitude": 24.751311059443832,
        "longitude": 46.56843443622849,
      ],
      [
        // 13-Irqah
        "name": "irqaah",
        "latitude": 24.685478009425,
        "longitude": 46.588807536228494,
      ],
      [
        // 14-rabwah
        "name": "alrabwah",
        "latitude": 24.691632342324862,
        "longitude": 46.7644165111836,
      ],
      [
        // 15-dhbab
        "name": "aldabab",
        "latitude": 24.663302422873645,
        "longitude": 46.71039090521693,
      ],
      [
        // 16-laban
        "name": "labaan",
        "latitude": 24.65519378984205,
        "longitude": 46.587670368287135,
      ],
      [
        // 17-naseem
        "name": "alnassim",
        "latitude": 24.751125038650233,
        "longitude": 46.82915955833446,
      ],
      [
        // 18-rimal
        "name": "alrimal",
        "latitude": 24.835299420469504,
        "longitude": 46.80158764475565,
      ],
      [
        // 19-khaleej
        "name": "alkhaleej",
        "latitude": 24.786104788767688,
        "longitude": 46.80613437245616,
      ],
      [
        // 20-twaiq
        "name": "twaaiq",
        "latitude": 24.585265317480754,
        "longitude": 46.547105141719804,
      ],
      [
        // 21-alqadisiyyah
        "name": "alqadisiyyah",
        "latitude": 24.824786989529542,
        "longitude": 46.81655385515806,
      ],
      [
        // 22-alawali
        "name": "alawali",
        "latitude": 24.55211787741151,
        "longitude": 46.63131015472793,
      ],
      [
        // 23-nadwah
        "name": "alnadwa",
        "latitude": 24.79054888623931,
        "longitude": 46.876853868227386,
      ],
      [
        // 24-alaziziyah
        "name": "alaziziyah",
        "latitude": 24.567103148393645,
        "longitude": 46.7685939682224,
      ],
      [
        // 25-alsharq
        "name": "alsharq",
        "latitude": 24.88285664307162,
        "longitude": 46.85941051240605,
      ],
      [
        // 26-narjis
        "name": "alnarjis",
        "latitude": 24.839968700490484,
        "longitude": 46.67215439706382,
      ],
      [
        // 27-salalm
        "name": "alsalam",
        "latitude": 24.71603727390603,
        "longitude": 46.811516483566905,
      ],
      [
        // 28-qaser Alhukum
        "name": "qasralhukm",
        "latitude": 24.62625068416492,
        "longitude": 46.70996480685846,
      ]
    ]
    
    static func getSRCAInfo(name: String)-> [String: Any]{
        
        for center in centers {
            let centerName = center["name"] as! String
            if centerName == name {
                print("srca: \(center)")
                return center
            }
        }
        return [String: Any]()
    }
    
    static func getNearest(longitude: Double, latitude:Double) -> [String: Any]{
        
        let accidentLoc = CLLocation(latitude: latitude, longitude: longitude)
        var nearest: [String: Any] = [:]
        var minDistance: CLLocationDistance?
        
        for center in centers {
            let centerLocation = CLLocation(latitude: center["latitude"] as! CLLocationDegrees, longitude: center["longitude"] as! CLLocationDegrees)
            let distance = centerLocation.distance(from: accidentLoc)
            if minDistance == nil || distance < minDistance! {
              nearest = center
              minDistance = distance
          }
        }
        
        return nearest
        
    }
    
    
    
}
