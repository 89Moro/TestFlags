//
//  ViewController.swift
//  TestFlags
//
//  Created by Ospite on 09/06/17.
//  Copyright © 2017 Ospite. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    var arrCountryTag:[String] = []
    var arrCountry:[String] = []
    var arrFlags:[UIImage] = []

    @IBOutlet weak var aiIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        aiIndicator.hidesWhenStopped = true
        getCountry()
        myCollection.delegate = self
        myCollection.dataSource = self


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(arrCountryTag.count) , \(arrCountry.count), \(arrFlags.count)")
        return arrCountry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var flag = cell.viewWithTag(1) as! UIImageView
        var label = cell.viewWithTag(2) as! UILabel
        label.text = arrCountryTag[indexPath.row]
        flag.image = arrFlags[indexPath.row]

        return cell
        
    }
    
    func getCountry()
    {
        let myURL = URL(string:"http://www.geognos.com/api/en/countries/info/all.json")!
        
        //per customizzare la richiesta
        var myRequest = URLRequest(url: myURL)
        
        myRequest.httpMethod = "GET"
        
        self.aiIndicator.startAnimating()
        let session = URLSession.shared.dataTask(with: myURL){(data,response,error)in
            
            if let myError = error
            {
                print ("Errore in chiamata WS : \(error?.localizedDescription)")
            }
            else
            {
                let myResponse = (response as! HTTPURLResponse)
                
                if myResponse.statusCode == 200
                {
                    var jsonData = self.json_parseData(data!)
                    let jsResult:NSDictionary = jsonData?.value(forKey: "Results")! as! NSDictionary
                    for (key, value) in jsResult {
                        var jsNation:NSDictionary = jsResult.value(forKey: key as! String) as! NSDictionary
                        self.arrCountryTag.append(key as! String)
                        //print(key)
                        self.arrCountry.append(jsNation.value(forKey: "Name")! as! String)
                        //print (jsNation.value(forKey: "Name")!)
                        let urlIcon = URL(string:"http://www.geognos.com/api/en/countries/flag/\(key).png")
                        let data = try? Data(contentsOf: urlIcon!)
                        self.arrFlags.append(UIImage(data: data!)!)
                    }

                    
                    
                }
                else
                {
                    print("Errore in Response: \(myResponse.description)")
                }
                
                self.aiIndicator.stopAnimating()
                
            }
            print("Chiamata WS")
            print("\(self.arrCountryTag.count) , \(self.arrCountry.count) , \(self.arrFlags.count)")
            self.myCollection.reloadData()
        }
        session.resume()
        
        print("Fine Chiamata")
    }
    
    func json_parseData( _ data: Data) -> NSDictionary?
    {
        do
        {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            return (json as? NSDictionary)
        }
        catch
        {
            print ("Errore: Json data not correct")
            return nil
        }
    }


}

