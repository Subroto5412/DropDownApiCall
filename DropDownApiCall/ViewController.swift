//
//  ViewController.swift
//  DropDownApiCall
//
//  Created by masco bazar on 21/12/21.
//

import UIKit

class CellClass: UITableViewCell {
}

class ViewController: UIViewController {

    @IBOutlet weak var countrySelect: UIButton!
    
    let transparentView = UIView()
    let tableViewDropDown = UITableView()
    
    var selectedButton = UIButton()
    var dataSource = [ListFinalYear]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getYearList()
        
        tableViewDropDown.delegate = self
        tableViewDropDown.dataSource = self
        tableViewDropDown.register(CellClass.self, forCellReuseIdentifier: "Cell")
    }

    @IBAction func countryBtn(_ sender: Any) {
        
        selectedButton = countrySelect
        addTransparentView(frames: countrySelect.frame)
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableViewDropDown.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableViewDropDown)
        tableViewDropDown.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableViewDropDown.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableViewDropDown.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableViewDropDown.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    func getYearList(){
        
        let url = URL(string: "https://mis-api.mascoknit.com/api/v1/Attendance/getFinalYear")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print("Error took place \(error)")
                        return
                    }
                    guard let data = data else {return}

                    do{
                
                        let todoItemModel = try JSONDecoder().decode(ListFinalYearResponse.self, from: data)
                        print("Response data:\n \(todoItemModel)")
                        print("todoItemModel error: \(todoItemModel.error)")
                        
                        self.dataSource = todoItemModel._listFinalYear

                        for leaveHistoryformatList in todoItemModel._listFinalYear {
                            print("Final Year Name : \(leaveHistoryformatList.finalYearName)")
                        }
                        
                    }catch let jsonErr{
                        print(jsonErr)
                   }
                }
        }
        task.resume()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].finalYearName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedButton.setTitle(dataSource[indexPath.row].finalYearName, for: .normal)
        print("Final Year id: \(dataSource[indexPath.row].finalYearNo!)")
        removeTransparentView()
    }
}


extension ViewController {
  
    struct ListFinalYear: Codable {
        var finalYearNo: Int?
        var finalYearName: String = ""
        var yearName: String = ""
        
        enum CodingKeys: String, CodingKey {
            case finalYearNo = "finalYearNo"
            case finalYearName = "finalYearName"
            case yearName = "yearName"
        }
        
        init(from decoder: Decoder) throws {

               let container = try decoder.container(keyedBy: CodingKeys.self)
               self.finalYearNo = try container.decodeIfPresent(Int.self, forKey: .finalYearNo) ?? 0
               self.finalYearName = try container.decodeIfPresent(String.self, forKey: .finalYearName) ?? ""
               self.yearName = try container.decodeIfPresent(String.self, forKey: .yearName) ?? ""
           }

           func encode(to encoder: Encoder) throws {

               var container = encoder.container(keyedBy: CodingKeys.self)
               try container.encode(finalYearNo, forKey: .finalYearNo)
               try container.encode(finalYearName, forKey: .finalYearName)
               try container.encode(yearName, forKey: .yearName)
           }
    }
    
    struct ListFinalYearResponse: Codable {
        var error: String = ""
        var _listFinalYear : [ListFinalYear]

        enum CodingKeys: String, CodingKey {
            case error = "error"
            case _listFinalYear
        }
        
         init(from decoder: Decoder) throws {

                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.error = try container.decodeIfPresent(String.self, forKey: .error) ?? ""
                self._listFinalYear = try container.decodeIfPresent([ListFinalYear].self, forKey: ._listFinalYear) ?? []
            }

            func encode(to encoder: Encoder) throws {

                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(error, forKey: .error)
                try container.encode(_listFinalYear, forKey: ._listFinalYear)
            }
    }
    
}
