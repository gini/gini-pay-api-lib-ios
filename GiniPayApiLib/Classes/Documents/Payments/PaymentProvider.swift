//
//  PaymentProvider.swift
//  GiniPayApiLib
//
//  Created by Nadya Karaban on 15.03.21.
//

import Foundation

/**
 Struct for MinAppVersions in payment provider response
 */
struct MinAppVersions: Codable {
    var ios: String
    var android: String?
}
/**
 Struct for payment provider response
 */
public struct PaymentProvider: Codable {
    var id: String
    var name: String
    var appSchemeIOS: String
    var minAppVersion: MinAppVersions
}

public typealias PaymentProviders = [PaymentProvider]
