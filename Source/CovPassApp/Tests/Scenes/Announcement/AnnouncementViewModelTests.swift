//
//  AnnouncementViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import PromiseKit
import XCTest

class AnnouncementViewModelTests: XCTestCase {
    private var persistence: MockPersistence!
    private var promise: Promise<Void>!
    private var sut: AnnouncementViewModel!

    override func setUpWithError() throws {
        let (promise, resolver) = Promise<Void>.pending()
        self.promise = promise
        persistence = .init()
        let whatsNewURL = try XCTUnwrap(Bundle.main.germanAnnouncementsURL)
        sut = .init(
            router: AnnouncementRouter(sceneCoordinator: SceneCoordinatorMock()),
            resolvable: resolver,
            persistence: persistence,
            whatsNewURL: whatsNewURL
        )
    }

    override func tearDownWithError() throws {
        persistence = nil
        promise = nil
        sut = nil
    }

    func testWhatsNewURL() throws {
        // When
        let url = sut.whatsNewURL

        // Then
        XCTAssertNotNil(url)
    }

    func test_whatsNew_content() throws {
        // When
        let value = try String(contentsOf: sut.whatsNewURL)
        // Then
        XCTAssertEqual(value.sha256(), "cad41b19a755220d7db131062bd69d9918a94340a651ae20746a8c1697d47ae3")
    }

    func testDone() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.done()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testCancel() {
        // Given
        let expectation = XCTestExpectation()
        promise.done { _ in
            expectation.fulfill()
        }.cauterize()

        // When
        sut.cancel()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testDisbaleWhatsNew_default() {
        // When
        let isDisabled = sut.disableWhatsNew

        // Then
        XCTAssertFalse(isDisabled)
    }

    func testDisableWhatsNew_set() {
        // When
        sut.disableWhatsNew = true

        // Then
        XCTAssertTrue(persistence.disableWhatsNew)
    }

    func testCheckboxAccessibilityValue_default() {
        // When
        let value = sut.checkboxAccessibilityValue

        // Then
        XCTAssertEqual(value, "Off")
    }

    func testCheckboxAccessibilityValue_true() {
        // Given
        sut.disableWhatsNew = true

        // When
        let value = sut.checkboxAccessibilityValue

        // Then
        XCTAssertEqual(value, "On")
    }
}
