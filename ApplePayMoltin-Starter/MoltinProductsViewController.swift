//
//  MoltinProductsViewController.swift
//  ApplePayMoltin-Starter
//
//  Created by George FitzGibbons on 7/13/18.
//  Copyright © 2018 Moltin. All rights reserved.
//

import UIKit
import moltin

class MoltinProductsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //Replace with your client id
    let moltin = Moltin(withClientID: "u8cV0fAtS8ELXcyxWY2r4deLTHs1i3NkgV8rt7ZqWX")
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moltin.product.include([.mainImage]).all { (result: Result<PaginatedResponse<[moltin.Product]>>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.products = response.data ?? []
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Products error", error)
            }
        }

        self.tableView.register(UINib(nibName: "ProductsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

}


extension MoltinProductsViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductsTableViewCell
        cell.displayProducts(product: products[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "buyview") as? BuyProductViewController
        vc?.product =  self.products[indexPath.row]
        self.present(vc!, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180.0
    }

}
