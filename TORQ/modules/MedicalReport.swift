import Foundation

struct MedicalReport {
    var bloodType: String
    var allergies: String
    var chronic_disease: String
    var disabilities: String
    var prescribed_medication: String
    var userID: String
    
    init(userID: String, bloodType: String, allergies: String,chronic_disease: String, disabilities: String, prescribed_medication: String) {
        self.bloodType = bloodType
        self.allergies = allergies
        self.chronic_disease = chronic_disease
        self.disabilities = disabilities
        self.prescribed_medication = prescribed_medication
        self.userID = userID
    }
    
    func getUserID()-> String{
        return userID
    }
    
    func getBloodType()-> String{
        return bloodType
    }
    
    func getAllergies()-> String{
        return allergies
    }
    
    func getDiseases()-> String{
        return chronic_disease
    }
    
    func getDisabilities()-> String{
        return disabilities
    }
    
    func getMedications()-> String{
        return prescribed_medication
    }
}
