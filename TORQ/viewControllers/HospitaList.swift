//
//  HospitaList.swift
//  TORQ
//
//  Created by  Alshahrani on 15/03/1443 AH.
//

import UIKit

class HospitaList: UIViewController ,UITableViewDelegate ,UITableViewDataSource{

    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var tableList: UITableView!
    var  selhealth = "not"
    var numb = -1
    var UID1 : String!
    var text:String = ""


    
    let hospitallist = ["Security Forces Hospital",
                        "King Salman Hospital",
                        "King Abdulaziz Hospital",
                        " Dallah Hospital",
                        " Green Crescent Hospital",
                        "King Faisal Specialist Hospital & Research Centre",
                       " King Saud Medical City-Pediatric Hospital"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.dataSource = self
        tableList.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancel_butt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitallist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = hospitallist[indexPath.row]
            cell.selectionStyle = .none
            return cell
            
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selhealth = hospitallist[indexPath.row]
        numb = indexPath.row

        print(hospitallist[indexPath.row] )
    }
   
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableList.cellForRow(at: indexPath)?.accessoryType = .none
        print(hospitallist[indexPath.row] )
    }

    @IBAction func confirme(_ sender: Any) {
        if selhealth == "not"
        {
            print(selhealth)
            self.error.text = "Error,You have to select one first !!"
        }else{
            
            print(selhealth)
            print(UID1 as Any )

        }
    }
}

  
        
        
   

    
