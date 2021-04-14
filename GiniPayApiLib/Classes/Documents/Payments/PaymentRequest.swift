//
//  PaymentRequest.swift
//  GiniPayApiLib
//
//  Created by Nadya Karaban on 19.03.21.
//

import Foundation
/**
 Struct for payment request response
 */
public struct PaymentRequest: Codable {
    var paymentProvider, requesterURI, iban: String
    var bic: String?
    var amount, purpose, recipient, createdAt: String
    var status: String
    var links: Links?

    enum CodingKeys: String, CodingKey {
        case paymentProvider
        case requesterURI = "requesterUri"
        case iban, bic, amount, purpose, recipient, createdAt, status
        case links = "_links"
    }
}

/**
 Struct for links in payment request response
 */
public struct Links: Codable {
    var linksSelf, paymentProvider: String
    var payment: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case paymentProvider, payment
    }
}

public typealias PaymentRequests = [PaymentRequest]
