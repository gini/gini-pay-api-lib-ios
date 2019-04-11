//
//  GiniSDK.swift
//  Gini
//
//  Created by Enrique del Pozo Gómez on 4/3/19.
//

import Foundation
#if PINNING_AVAILABLE
import TrustKit
#endif

/// The Gini SDK
public final class GiniSDK {
    
    private let docService: DocumentService!
    static var logLevel: LogLevel = .none

    init<T: DocumentService>(documentService: T) {
        self.docService = documentService
    }
    
    /**
     * The instance of a `DocumentService` that is used by the SDK. The `DocumentService` allows the interaction with
     * the Gini API.
     */
    public func documentService<T: DocumentService>() -> T {
        guard docService is T else {
            preconditionFailure("In order to use a \(T.self), you have to specify its corresponding api " +
                "domain when building the GiniSDK")
        }
        //swiftlint:disable force_cast
        return docService as! T
    }
    
    /// Removed the user stored credentials. Recommended when logging a different user in your app.
    public func removeStoredCredentials() throws {
        let keychainStore: KeyStore = KeychainStore()
        try keychainStore.remove(service: .auth, key: .userAccessToken)
        try keychainStore.remove(service: .auth, key: .userEmail)
        try keychainStore.remove(service: .auth, key: .userPassword)
    }
}

// MARK: - Builder

extension GiniSDK {
    /// Builds a Gini SDK
    public struct Builder {
        var client: Client
        var api: APIDomain = .default
        var logLevel: LogLevel
        
        /**
         *  Creates a Gini SDK
         *
         * - Parameter client:            The Gini API client credentials
         * - Parameter api:               The Gini API that the sdk interacts to. `APIDomain.default` by default
         * - Parameter logLevel:          The log level. `LogLevel.none` by default.
         */
        public init(client: Client, api: APIDomain = .default, logLevel: LogLevel = .none) {
            self.client = client
            self.api = api
            self.logLevel = logLevel
        }

        public func build() -> GiniSDK {
            // Save client information
            save(client)
            
            // Initialize logger
            GiniSDK.logLevel = logLevel
            
            // Initialize GiniSDK
            switch api {
            case .accounting:
                return GiniSDK(documentService: AccountingDocumentService(sessionManager: SessionManager()))
            case .default:
                return GiniSDK(documentService: DefaultDocumentService(sessionManager: SessionManager()))
            }
        }
        
        private func save(_ client: Client) {
            do {
                try KeychainStore().save(item: KeychainManagerItem(key: .clientId,
                                                                   value: client.id,
                                                                   service: .auth))
                try KeychainStore().save(item: KeychainManagerItem(key: .clientSecret,
                                                                   value: client.secret,
                                                                   service: .auth))
                try KeychainStore().save(item: KeychainManagerItem(key: .clientDomain,
                                                                   value: client.domain,
                                                                   service: .auth))
            } catch {
                preconditionFailure("There was an error using the Keychain. " +
                    "Check that the Keychain capability is enabled in your project")
            }
        }
    }
}
