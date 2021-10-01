//
//  stringExtension.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 01/10/2021.
//

import Foundation

extension String {
   var isValidEmail: Bool {
      // validate the email format:
      let regxForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailTest = NSPredicate(format:"SELF MATCHES %@", regxForEmail)
      return emailTest.evaluate(with: self)
   }
    
   var isValidPhone: Bool {
      // validate the domain of the email address:
      let regxForPhone = "^\\[05]-\\d{4}-\\d{4}$"
      let phoneTest = NSPredicate(format:"SELF MATCHES %@", regxForPhone)
      return phoneTest.evaluate(with: self)
   }
    
    var isValidPassword: Bool {
       // validate the domain of the email address:
       let regxForPassword = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
       let passwordText = NSPredicate(format:"SELF MATCHES %@", regxForPassword)
       return passwordText.evaluate(with: self)
    }
    
    var isValidDomain: Bool {
        // validate the domain of the email address:
        let domainRange = self.range(of: "@")!
        let domainTest = self[domainRange.upperBound...]
        return !domainTest.elementsEqual("srca.org.sa")
    }
}


//if let range = snippet.range(of: "Phone: ") {
//    let phone = snippet[range.upperBound...]
//    print(phone) // prints "123.456.7891"
//}
