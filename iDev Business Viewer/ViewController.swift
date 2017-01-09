//
//  ViewController.swift
//  iDev Business Viewer
//
//  Created by Siraj Zaneer on 12/25/16.
//  Copyright © 2016 Siraj Zaneer. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AFNetworking

class ViewController: UIViewController {
    
    var info: Business?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard let info = info else {
            print("errror")
            return
        }
        
        nameLabel.text = info.name
        phoneLabel.text = info.phoneNumber
        priceLabel.text = info.price
        locationLabel.text = info.location
        let imageURL = URL(string: info.imageURL)
        if let url = imageURL {
            imageView.setImageWith(url)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

