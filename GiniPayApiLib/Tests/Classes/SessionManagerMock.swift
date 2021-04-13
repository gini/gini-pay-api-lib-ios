//
//  SessionManagerMock.swift
//  GiniPayApiLib-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

import Foundation
import XCTest
@testable import GiniPayApiLib

final class SessionManagerMock: SessionManagerProtocol {
    
    static let v1DocumentId = "626626a0-749f-11e2-bfd6-000000000000"
    static let partialDocumentId = "726626a0-749f-11e2-bfd6-000000000000"
    static let compositeDocumentId = "826626a0-749f-11e2-bfd6-000000000000"
    static let paymentProviderId = "7e72441c-32f8-11eb-b611-c3190574373c"
    static let paymentRequestId = "f4ec8dee-5f6a-4799-b4a8-42bbfaa491cf"

    var documents: [Document] = []
    var providers: [PaymentProvider] = []
    var paymentRequests: [PaymentRequest] = []


    init(keyStore: KeyStore = KeychainStore(),
         urlSession: URLSession = URLSession()) {
        
    }
    
    func initializeWithV1MockedDocuments() {
        documents = [
            load(fromFile: "document", type: "json")
        ]
    }
    
    func initializeWithPaymentProviders() {
        providers = load(fromFile: "providers", type: "json")
    }
    
    func initializeWithPaymentRequests() {
        paymentRequests = load(fromFile: "paymentRequests", type: "json")
    }
    
    func initializeWithV2MockedDocuments() {
        documents = [
            load(fromFile: "partialDocument", type: "json"),
            load(fromFile: "compositeDocument", type: "json")
        ]
    }
    
    func logIn(completion: @escaping (Result<Token, GiniError>) -> Void) {
        
    }
    
    func logOut() {
        
    }
    
    //swiftlint:disable all
    func data<T: Resource>(resource: T,
                           cancellationToken: CancellationToken?,
                           completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {                
            case .document(let id):
                switch (id, resource.params.method) {
                case (SessionManagerMock.v1DocumentId, .get):
                    let document: Document = load(fromFile: "document", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.v1DocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                case (SessionManagerMock.partialDocumentId, .get):
                    let document: Document = load(fromFile: "partialDocument", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.partialDocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                case (SessionManagerMock.compositeDocumentId, .get):
                    let document: Document = load(fromFile: "compositeDocument", type: "json")
                    completion(.success(document as! T.ResponseType))
                case (SessionManagerMock.compositeDocumentId, .delete):
                    documents.removeAll(where: { $0.id == id })
                    completion(.success("Deleted" as! T.ResponseType))
                default:
                    fatalError("Document id not found in tests")
                }
            case .createDocument(_, _, _, _):
                completion(.success(SessionManagerMock.compositeDocumentId as! T.ResponseType))
            case .createPaymentRequest:
                completion(.success(SessionManagerMock.paymentRequestId as! T.ResponseType))
            case .paymentProvider(_):
                let paymentProvider: PaymentProvider = load(fromFile: "paymentProvider", type: "json")
                completion(.success(paymentProvider as! T.ResponseType))
            default: break
                
            }
        }
    }
    
    func download<T: Resource>(resource: T,
                               cancellationToken: CancellationToken?,
                               completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        
    }
    
    func upload<T: Resource>(resource: T,
                             data: Data,
                             cancellationToken: CancellationToken?,
                             completion: @escaping (Result<T.ResponseType, GiniError>) -> Void) {
        if let apiMethod = resource.method as? APIMethod {
            switch apiMethod {
            case .createDocument(_, _, _, let documentType):
                switch documentType {
                case .none:
                    completion(.success(SessionManagerMock.v1DocumentId as! T.ResponseType))
                case .some:
                    completion(.success(SessionManagerMock.partialDocumentId as! T.ResponseType))
                }
            default: break
                
            }
        }
    }
}
