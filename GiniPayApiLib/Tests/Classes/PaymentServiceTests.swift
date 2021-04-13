//
//  PaymentTests.swift
//  GiniPayApiLib-Unit-Tests
//
//  Created by Nadya Karaban on 13.04.21.
//

import XCTest
@testable import GiniPayApiLib

class PaymentServiceTests: XCTestCase {
        var sessionManagerMock: SessionManagerMock!
        var defaultDocumentService: DefaultDocumentService!
        var accountingDocumentService: AccountingDocumentService!
       var paymentService: PaymentService!

        override func setUp() {
            sessionManagerMock = SessionManagerMock()
            defaultDocumentService = DefaultDocumentService(sessionManager: sessionManagerMock)
            accountingDocumentService = AccountingDocumentService(sessionManager: sessionManagerMock)
            paymentService = PaymentService(sessionManager: sessionManagerMock)
        }
    
        func testPaymentRequestCreation() {
            let expect = expectation(description: "it payment request id")
            
            paymentService.createPaymentRequest(sourceDocumentLocation: "", paymentProvider: "b09ef70a-490f-11eb-952e-9bc6f4646c57", recipient: "James Bond", iban: "DE02300209000106531065", bic: "", amount: "33.78:EUR", purpose: "save the world") { result in
                switch result {
                case .success(let paymentRequestId):
                    XCTAssertEqual(paymentRequestId,
                                   SessionManagerMock.paymentRequestId,
                                   "document ids should match")
                    expect.fulfill()
                case .failure:
                    break
                }
            }
            wait(for: [expect], timeout: 1)
        }
}
