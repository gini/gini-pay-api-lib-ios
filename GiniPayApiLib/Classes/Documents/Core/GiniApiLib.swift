//
//  GiniApiLib.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 4/3/19.
//

import Foundation
#if PINNING_AVAILABLE
import TrustKit
#endif

/// The Gini Api Library
public final class GiniApiLib {
    
    private let docService: DocumentService!
    static var logLevel: LogLevel = .none

    init<T: DocumentService>(documentService: T) {
        self.docService = documentService
    }
    
    /**
     * The instance of a `DocumentService` that is used by the Gini Api Library. The `DocumentService` allows the interaction with
     * the Gini API.
     */
    public func documentService<T: DocumentService>() -> T {
        guard docService is T else {
            preconditionFailure("In order to use a \(T.self), you have to specify its corresponding api " +
                "domain when building the GiniApiLib")
        }
        //swiftlint:disable force_cast
        return docService as! T
    }
    
    /// Removes the user stored credentials. Recommended when logging a different user in your app.
    public func removeStoredCredentials() throws {
        let keychainStore: KeyStore = KeychainStore()
        try keychainStore.remove(service: .auth, key: .userAccessToken)
        try keychainStore.remove(service: .auth, key: .userEmail)
        try keychainStore.remove(service: .auth, key: .userPassword)
    }
}

// MARK: - Builder

extension GiniApiLib {
    /// Builds a Gini Api Library
    public struct Builder {
        var client: Client
        var api: APIDomain = .default
        var userApi: UserDomain = .default
        var logLevel: LogLevel
        
        /**
         *  Creates a Gini Api Library
         *
         * - Parameter client:            The Gini API client credentials
         * - Parameter api:               The Gini API that the library interacts with. `APIDomain.default` by default
         * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
         * - Parameter logLevel:          The log level. `LogLevel.none` by default.
         */
        public init(client: Client,
                    api: APIDomain = .default,
                    userApi: UserDomain = .default,
                    logLevel: LogLevel = .none) {
            self.client = client
            self.api = api
            self.userApi = userApi
            self.logLevel = logLevel
        }

        public func build() -> GiniApiLib {
            // Save client information
            save(client)
            
            // Initialize logger
            GiniApiLib.logLevel = logLevel
            
            // Initialize GiniApiLib
            switch api {
            case .accounting:
                return GiniApiLib(documentService: AccountingDocumentService(sessionManager: SessionManager(userDomain: userApi)))
            case .default:
                return GiniApiLib(documentService: DefaultDocumentService(sessionManager: SessionManager(userDomain: userApi)))
            case .custom:
                return GiniApiLib(documentService: DefaultDocumentService(sessionManager: SessionManager(userDomain: userApi),
                                                                       apiDomain: api))
            case .gym(let tokenSource):
                return GiniApiLib(documentService: DefaultDocumentService(sessionManager:
                    SessionManager(alternativeTokenSource: tokenSource)))
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
