import Foundation

extension String {
   var isValidEmail: Bool {
      // validate the email format:
      let regxForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z ]{2,64}"
      let emailTest = NSPredicate(format:"SELF MATCHES %@", regxForEmail)
      return emailTest.evaluate(with: self)
   }
    
   var isValidPhone: Bool {
      // validate the phone format:
      let regxForPhone = "^(0|05|05[0-9]{1,9})$"
      let phoneTest = NSPredicate(format:"SELF MATCHES %@", regxForPhone)
       return phoneTest.evaluate(with: self) && (self.count == 10)
   }
    var isValidName: Bool{
        // Validate Name
        let regxName = "^[a-zA-Z]+[ ]+[a-zA-Z]+$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regxName)
        return nameTest.evaluate(with: self)
    }
 
    var isValidPassword: Bool {
       // validate the password format:
        return self.count >= 6
    }
    
    var isValidDomain: Bool {
        // validate the domain of the email address:
        let domainRange = self.range(of: "@")!
        let domainTest = self[domainRange.upperBound...]
        return !domainTest.elementsEqual("srca.org.sa")
    }
    
    var isValidNationalID: Bool {
        // validate the nationalID format:
        let digitsCharacters = CharacterSet.decimalDigits
        return (CharacterSet(charactersIn: self).isSubset(of: digitsCharacters) && self[self.startIndex] == "1" && self.count == 10)
    }
    
    var isParamedicUser: Bool{
        let domainRange = self.range(of: "@")!
        let domainTest = self[domainRange.upperBound...]
        return domainTest.elementsEqual("srca.org.sa")
    }
    
    // a function that trims trailing white spaces
    func trimWhiteSpace() -> String {
            if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
                return self.replacingCharacters(in: trailingWs, with: "")
            } else {
                return self
            }
        }
    
}

