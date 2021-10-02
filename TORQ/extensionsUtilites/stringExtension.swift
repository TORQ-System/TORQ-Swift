import Foundation

extension String {
   var isValidEmail: Bool {
      // validate the email format:
      let regxForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailTest = NSPredicate(format:"SELF MATCHES %@", regxForEmail)
      return emailTest.evaluate(with: self)
   }
    
    var isValidPassword: Bool {
       // validate the password format:
       let regxForPassword = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
       let passwordText = NSPredicate(format:"SELF MATCHES %@", regxForPassword)
       return passwordText.evaluate(with: self)
    }
    
    var isParamedicUser: Bool{
        let domainRange = self.range(of: "@")!
        let domainTest = self[domainRange.upperBound...]
        return domainTest.elementsEqual("srca.org.sa")
    }
    
    var isValidParamedicPassword: Bool{
        let domainRange = self.range(of: "@")!
        let domainTest = self[...domainRange.lowerBound]
        return domainTest.elementsEqual("srca.org.sa")
    }
}
