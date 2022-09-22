//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassCheckApp
@testable import CovPassCommon
import SwiftyJSON
import CertLogic

class ValidateCertificateUseCaseTests: XCTestCase {
    
    var sut: ValidateCertificateUseCase!
    var certLogic: DCCCertLogicMock!
    var revocationRepository: CertificateRevocationRepositoryMock!

    override func setUpWithError() throws {
        let token = CBORWebToken.mockRecoveryCertificate.mockRecoveryUVCI("FOO").extended()
        let persistence = UserDefaultsPersistence()
        revocationRepository = CertificateRevocationRepositoryMock()
        certLogic = DCCCertLogicMock()
        sut = ValidateCertificateUseCase(token: token,
                                         revocationRepository: revocationRepository,
                                         certLogic: certLogic,
                                         persistence: persistence)
    }
    
    override func tearDownWithError() throws {
        revocationRepository = nil
        certLogic = nil
        sut = nil
    }
    
    func test_isPassed_And_IsNotRevoked() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        certLogic.validationError = nil
        certLogic.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        revocationRepository.isRevoked = false
        // WHEN
        sut.execute().done { result in
            // THEN
            XCTAssertNotNil(result.token)
            XCTAssertTrue(result.token.vaccinationCertificate.isRecovery)
            XCTAssertEqual(result.token.vaccinationCertificate.hcert.dgc.uvci, "FOO")
            testExpectation.fulfill()
        }
        .catch { error in
            XCTFail("Should not fail")
        }
        wait(for: [revocationRepository.isRevokedExpectation,
                   testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_isPassed_And_IsRevoked() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        certLogic.validationError = nil
        certLogic.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            guard case CertificateError.revoked(_) = error else {
                XCTFail("Wrong error.")
                return
            }
            testExpectation.fulfill()

        }
        wait(for: [revocationRepository.isRevokedExpectation,
                   testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_isNotPassedFunctional_And_IsNotRevoked() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        certLogic.validationError = nil
        certLogic.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        revocationRepository.isRevoked = false
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            let certificateError = error as? ValidationResultError
            XCTAssertEqual(certificateError, .functional)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_isNotPassedFunctional_And_IsRevoked() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        certLogic.validationError = nil
        certLogic.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        revocationRepository.isRevoked = true
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            let certificateError = error as? ValidationResultError
            XCTAssertEqual(certificateError, .functional)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
    
    func test_isNotPassedTechnical_And_IsNotRevoked() {
        // GIVEN
        let testExpectation = XCTestExpectation()
        certLogic.validationError = nil
        certLogic.validateResult = []
        revocationRepository.isRevoked = false
        // WHEN
        sut.execute().done { token in
            // THEN
            XCTFail("Should fail")
        }
        .catch { error in
            let certificateError = error as? ValidationResultError
            XCTAssertEqual(certificateError, .technical)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation],
             timeout: 0.1,
             enforceOrder: true)
    }
}
