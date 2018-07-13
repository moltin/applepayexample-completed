//
//  BuyProductViewController.swift
//  ApplePayMoltin-Starter
//
//  Created by George FitzGibbons on 7/13/18.
//  Copyright © 2018 Moltin. All rights reserved.
//

import UIKit
import moltin

class BuyProductViewController: UIViewController {
   
    var product: Product?
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDecLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.productImage.load(urlString: product?.mainImage?.link["href"] ?? "")
        self.productPriceLabel.text = product?.meta.displayPrice?.withTax.formatted
        self.productDecLabel.text = product?.description
    }

    @IBAction func applePayPressed(_ sender: Any) {
        // TODO: - Fill in implementation

    }
    

}
