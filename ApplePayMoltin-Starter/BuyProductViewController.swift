//
//  BuyProductViewController.swift
//  ApplePayMoltin-Starter
//
//  Created by George FitzGibbons on 7/13/18.
//  Copyright © 2018 Moltin. All rights reserved.
//

import UIKit
import moltin
import PassKit

class BuyProductViewController: UIViewController {
   
    var product: Product?
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDecLabel: UILabel!
    //Replace with your client id
    let moltin = Moltin(withClientID: "u8cV0fAtS8ELXcyxWY2r4deLTHs1i3NkgV8rt7ZqWX")
    
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]  // Add in any extra support payments.
    let ApplePayMerchantID = "merchant.com.YOURDOMAIN.ApplePayMoltin" // Fill in your merchant ID here!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.productImage.load(urlString: product?.mainImage?.link["href"] ?? "")
        self.productPriceLabel.text = product?.meta.displayPrice?.withTax.formatted
        self.productDecLabel.text = product?.description
        
        applePayButton.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks)
    }

    @IBAction func applePayPressed(_ sender: Any) {
        // TODO: - Fill in implementation
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.requiredShippingContactFields = [.name, .postalAddress]
        
        //Item information formatting
        let productToBuy = PKPaymentSummaryItem(label: product?.name ?? "", amount: NSDecimalNumber(decimal:Decimal((self.product?.meta.displayPrice?.withoutTax.amount)!/100)), type: .final)
        
        let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: "5.0")
        let shipping = PKPaymentSummaryItem(label: "Shipping", amount: shippingPrice)
        let tax = PKPaymentSummaryItem(label: "tax", amount: NSDecimalNumber(decimal:Decimal((self.product?.meta.displayPrice?.withTax.amount)!)*0.0010))
        let total = PKPaymentSummaryItem(label: "Total amount", amount: NSDecimalNumber(decimal:Decimal((self.product?.meta.displayPrice?.withTax.amount)!)/100).adding(shippingPrice))
        
        //PKPaymentSummaryItem Array
        request.paymentSummaryItems = [productToBuy,shipping, tax, total]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self

        self.present(applePayController!, animated: true, completion: nil)

    }
}
extension BuyProductViewController: PKPaymentAuthorizationViewControllerDelegate
{
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping
    ((PKPaymentAuthorizationStatus) -> Void))
    {
        completion(PKPaymentAuthorizationStatus.success)
        ///Customer
        let customer = Customer(withEmail: payment.billingContact?.emailAddress, withName: payment.shippingContact?.name?.familyName)
    
        //Address
        let address = Address(withFirstName: (payment.shippingContact?.name?.givenName)!, withLastName: payment.shippingContact?.name?.familyName ?? "")
        address.line1 = payment.shippingContact?.postalAddress?.street
        address.county = payment.shippingContact?.postalAddress?.city
        address.country = payment.shippingContact?.postalAddress?.country
        address.postcode = payment.shippingContact?.postalAddress?.postalCode
        
         self.moltin.cart.checkout(cart: AppDelegate.cartID, withCustomer: customer, withBillingAddress: address, withShippingAddress: address)
         { (result) in
            switch result {
            case .success(let order):
                DispatchQueue.main.async {
                    let paymentMethod = ManuallyAuthorizePayment()
                    self.moltin.cart.pay(forOrderID: order.id, withPaymentMethod: paymentMethod) { (result) in
                        switch result {
                            case .success(let status):
                                DispatchQueue.main.async {
                                    print("Paid for order: \(status)")
                                    controller.dismiss(animated: true, completion: nil)

                                }
                            case .failure(let error):
                                print("Could not pay for order: \(error)")
                                controller.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    default: break
                }
            }
        }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController)
    {
        controller.dismiss(animated: true, completion: nil)
        
    }
}






