//
//  PaymentRequestBody.swift
//  GiniPayApiLib
//
//  Created by Nadya Karaban on 22.03.21.
//

import Foundation
/**
 Struct for payment request body
 */
struct PaymentRequestBody: Codable {
    var sourceDocumentLocation: String?
    var paymentProvider,recipient, iban, bic: String
    var amount, purpose: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sourceDocumentLocation, forKey: .sourceDocumentLocation)
        try container.encode(paymentProvider, forKey: .paymentProvider)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(iban, forKey: .iban)
        try container.encode(bic, forKey: .bic)
        try container.encode(amount, forKey: .amount)
        try container.encode(purpose, forKey: .purpose)
    }
}

/**
 Struct for resolving payment request body
 */
struct ResolvingPaymentRequestBody: Codable {
    var recipient, iban, bic: String
    var amount, purpose: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(iban, forKey: .iban)
        try container.encode(bic, forKey: .bic)
        try container.encode(amount, forKey: .amount)
        try container.encode(purpose, forKey: .purpose)
    }
}


