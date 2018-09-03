//
//  IAPHandler.swift
//  Coin
//
//  Created by Mialin Valentin on 30.01.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import UIKit
import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()


enum IAPHandlerAlertType{
    case disabled
    case purchased
    case failed
    
    func message() -> String{
        switch self {
        case .disabled: return NSLocalizedString("Purchases are disabled in your device!", comment: "Purchases are disabled in your device!")
        case .purchased: return NSLocalizedString("Thank you!", comment: "Thank you!")
        case .failed: return NSLocalizedString("Failed", comment: "Failed")
        }
    }
}


class IAPHandler: NSObject {
    static let shared = IAPHandler()
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    let coffee_ID = "mialin.Coin.coffee"
    let croissant_ID = "mialin.Coin.Croissant"
    let macBook_ID = "mialin.Coin.MacBook"
    
    fileprivate var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType, SKPayment?) -> Void)?
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(_ product: SKProduct){
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
        } else {
            purchaseStatusBlock?(.disabled, nil)
        }
    }

    func requestProducts() {
        let productIdentifiers = NSSet(objects: coffee_ID, croissant_ID, macBook_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        productsRequestCompletionHandler?(true, response.products)

        if (response.products.count > 0) {
            iapProducts = response.products
        }
    }
    
    // MARK: - IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased, trans.payment)
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.failed, trans.payment)
                default: break
                }}}
    }
}
