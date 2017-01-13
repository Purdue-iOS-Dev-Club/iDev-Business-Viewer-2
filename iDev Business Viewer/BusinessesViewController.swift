//
//  BusinessesViewController.swift
//  iDev Business Viewer
//
//  Created by Siraj Zaneer on 1/9/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Alamofire
import AFNetworking
import SwiftyJSON

class BusinessesViewController: UITableViewController {
    
    var token: String? = nil //Stores apps temporary "token" to tell server that yeah this device has permission to use the api
    
    let baseUrl = "https://api.yelp.com/oauth2/token" //Url for getting access
    let grant_type = "client_credentials" //A paramter that tells the server we want access for "client"
    let client_id = "b5IWJOAwIKwyOsOGbS-sCA" //App specific information so server know who is requesting and for what. Put your id here.
    let client_secret = "vfXApOXb22emM3R0VBf2fnn2KTz7fuQJwAj00NbumxZ2YKldGvdEYOfgDZ0UNRqS" //Pretty much same as previous but put your secret
    
    
    let searchURL = "https://api.yelp.com/v3/businesses/search" //Url for searching for things
    let location = "West Lafayette, IN" //Some location
    
    var businesses: [Business] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        getToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func getToken() {
        /*
         This part looks like a lot of code but really what the first parameter is is just the url, the second is the method which type of request we are making which is a "POST" request which tells the server that we are sending information (clien id and secret) rather than asking for some, the third is parameters which are the information we are sending the server, the fourth is encoding which is the format in which we are sending the information, and then headers are nil because we don't have any. Then once we send the request the server sends back some information which we store in "response".
         */
        Alamofire.request(baseUrl, method: .post, parameters: ["grant_type" : grant_type, "client_id" : client_id, "client_secret" : client_secret], encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            // This part does different things based on whether or not it was successful
            switch response.result.isSuccess {
            case true:
                if let value = response.result.value {
                    let info = JSON(value) //Since it was successful we store it in a JSON object
                    
                    self.token = info["access_token"].stringValue //Store it into the token variable so we can use it later on to tell the server we already have access to it!
                    
                    self.loadBusiness()
                }
            case false:
                print(response.result.error?.localizedDescription ?? "error")
            }
            
        }
        
    }
    
    func loadBusiness() {
        /*
         By now I think you kinda get the gist of how the request works but the one major difference here is that we now have parameters in the header which in  our case is the token! This tells Yelp that we have been granted access and the token is our password to get into the Yelp club :D!
         */
        guard let token = token else {
            getToken()
            return
        }
        Alamofire.request(searchURL, method: .get, parameters: ["location" : location], encoding: URLEncoding.default, headers: ["Authorization" : "Bearer \(token)"]).validate().responseJSON { response in
            // This part does different things based on whether or not it was successfull
            switch response.result.isSuccess {
            case true:
                if let value = response.result.value {
                    let info = JSON(value) //Since it was successful we store it in a JSON object
                    print(info)
                    let businesses = info["businesses"].arrayValue //Store the businesses
                    
                    for business in businesses {
                        self.businesses.append(Business(json: business))
                    }
                    
                    self.tableView.reloadData()
                }
            case false:
                print(response.result.error?.localizedDescription ?? "error")
            }
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return businesses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        let businessInfo = businesses[indexPath.row]
        
        cell.nameLabel.text = businessInfo.name
        cell.priceLabel.text = businessInfo.price
        cell.ratingLabel.text = "Rating: \(businessInfo.rating)"
        cell.addressLabel.text = businessInfo.location
        cell.typesLabel.text = businessInfo.types
        cell.distanceLabel.text = "\(businessInfo.distance)"
        
        let imageURL = URL(string: businessInfo.imageURL)
        cell.businessView.setImageWith(imageURL!)

        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! BusinessCell
        let vc = segue.destination as! ViewController
        let indexPath = tableView.indexPath(for: cell)
        if let indexPath = indexPath {
            vc.info = businesses[indexPath.row]
        }
        
    }
    

}
