//
//  StripeClient.swift
//  SnowPlow
//
//  Created by Kyle Hannibal on 3/13/19.
//  Copyright © 2019 Baraty Hannibal Enterprises. All rights reserved.
//

import Foundation
import Stripe
import Parse


enum Result {
    case success
    case failure(Error)
}

final class StripeClient{
    
    static let shared = StripeClient()
    
    func completeCharge(with token: STPToken, amount: Int, completion: @escaping (Result) -> Void){
        //add backend here
        
        let params: [String: Any] = [
            "token": token.tokenId,
            "amount": amount,
            "currency": Global.defaultCurrency,
            "description": Global.defaultDescription
        ]
        
        //Validate
        do{
            try PFCloud.callFunction("", withParameters: ["": ""])
        }catch {
            
        }
        
    }
    
}
