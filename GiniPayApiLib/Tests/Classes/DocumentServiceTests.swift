//
//  DocumentServicesTests.swift
//  GiniPayApiLib-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 3/26/19.
//

@testable import GiniPayApiLib
import XCTest

final class DocumentServicesTests: XCTestCase {
    var sessionManagerMock: SessionManagerMock!
    var defaultDocumentService: DefaultDocumentService!
    var accountingDocumentService: AccountingDocumentService!

    override func setUp() {
        sessionManagerMock = SessionManagerMock()
        defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        accountingDocumentService = AccountingDocumentService(sessionManager: sessionManagerMock)
    }

    func testV1DocumentCreation() {
        let expect = expectation(description: "it returns a document")

        accountingDocumentService.createDocument(with: Data(count: 1),
                                                 fileName: "",
                                                 docType: nil,
                                                 metadata: nil) { result in
            switch result {
            case let .success(document):
                XCTAssertEqual(document.id,
                               SessionManagerMock.v1DocumentId,
                               "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testPartialDocumentCreation() {
        let expect = expectation(description: "it returns a partial document")

        defaultDocumentService.createDocument(fileName: "",
                                              docType: nil,
                                              type: .partial(Data(count: 1)),
                                              metadata: nil) { result in
            switch result {
            case let .success(document):
                XCTAssertEqual(document.id,
                               SessionManagerMock.partialDocumentId,
                               "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testCompositeDocumentCreation() {
        let expect = expectation(description: "it returns a composite document")

        defaultDocumentService.createDocument(fileName: "",
                                              docType: nil,
                                              type: .composite(CompositeDocumentInfo(partialDocuments: [])),
                                              metadata: nil) { result in
            switch result {
            case let .success(document):
                XCTAssertEqual(document.id,
                               SessionManagerMock.compositeDocumentId,
                               "document ids should match")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testV1DocumentDeletion() {
        let expect = expectation(description: "it deletes a document")
        sessionManagerMock.initializeWithV1MockedDocuments()
        let document: Document = loadDocument(fileName: "document", type: "json")
        accountingDocumentService.delete(document) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testPartialDocumentDeletion() {
        let expect = expectation(description: "it deletes the partial document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = loadDocument(fileName: "partialDocument", type: "json")

        defaultDocumentService.delete(document) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.sessionManagerMock.documents.isEmpty, "documents should be empty")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testCompositeDocumentDeletion() {
        let expect = expectation(description: "it deletes the composite document")
        sessionManagerMock.initializeWithV2MockedDocuments()
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")

        defaultDocumentService.delete(document) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.sessionManagerMock.documents.count, 1,
                               "there should be one aprtial document left")
                expect.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func loadDocument(fileName: String, type: String) -> Document {
        let jsonData = loadFile(withName: fileName, ofType: type)

        return (try? JSONDecoder().decode(Document.self, from: jsonData))!
    }

    func loadExtractionResults(fileName: String, type: String) -> ExtractionsContainer {
        let jsonData = loadFile(withName: fileName, ofType: type)

        return (try? JSONDecoder().decode(ExtractionsContainer.self, from: jsonData))!
    }

    func testSubmitFeedback() {
        let expect = expectation(description: "feedback will be successfully sent")
        sessionManagerMock.initializeWithExtractionsContainer()
        let extractionResult = loadExtractionResults(fileName: "extractionsResults", type: "json")
        let document: Document = loadDocument(fileName: "compositeDocument", type: "json")
        if let compoundExtractions = extractionResult.compoundExtractions {
            defaultDocumentService.submitFeedback(for: document, with: extractionResult.extractions, and: compoundExtractions) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        expect.fulfill()
                    }
                case .failure:
                    break
                }
                self.wait(for: [expect], timeout: 1)
            }
        }
    }
}
