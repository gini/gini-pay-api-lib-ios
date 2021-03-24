//
//  Payment.swift
//  GiniPayApiLib
//
//  Created by Nadya Karaban on 19.03.21.
//

import Foundation
/**
 Struct for payment response
 */
public struct Payment: Codable {
    var paidAt, recipient, iban, bic: String
    var amount, purpose: String
    var links: PaymentLinks?

    enum CodingKeys: String, CodingKey {
        case paidAt, recipient, iban, bic, amount, purpose
        case links
    }
}

/**
 Struct for links in payment response
 */
public struct PaymentLinks: Codable {
    var paymentRequest, sourceDocumentLoction, linksSelf: String

    enum CodingKeys: String, CodingKey {
        case paymentRequest, sourceDocumentLoction
        case linksSelf
    }
}
