//
//  ProductsTableViewCell.swift
//  ApplePayMoltin-Starter
//
//  Created by George FitzGibbons on 7/13/18.
//  Copyright © 2018 Moltin. All rights reserved.
//

import UIKit
import moltin

class ProductsTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    func displayProducts(product: moltin.Product) {
        self.productImage.load(urlString: product.mainImage?.link["href"] ?? "")
        self.productPrice.text = product.meta.displayPrice?.withTax.formatted
        self.productName.text = product.name
    }

}

extension UIImageView {
    
    func load(urlString string: String?) {
        guard let imageUrl = string,
            let url = URL(string: imageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
            }.resume()
    }
}
