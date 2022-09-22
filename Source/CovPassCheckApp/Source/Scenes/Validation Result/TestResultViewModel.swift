//
//  TestResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class TestResultViewModel: ValidationResultViewModel {
    
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    let countdownTimerModel: CountdownTimerModel?
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?
    var revocationKeyFilename: String
    let revocationRepository: CertificateRevocationRepositoryProtocol?
    let audioPlayer: AudioPlayerProtocol?

    var icon: UIImage? {
        .group
    }

    var resultTitle: String {
        guard let testCert = certificate?.vaccinationCertificate.hcert.dgc.t?.first else {
            return ""
        }
        let hours = Date().hoursSince(testCert.sc)
        let formatString = testCert.isPCR ? "validation_check_popup_valid_pcr_test_title" : "validation_check_popup_test_title"
        return String(format: formatString.localized, hours)
    }

    var resultBody: String {
        "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dgc = certificate?.vaccinationCertificate.hcert.dgc, let testCert = dgc.t?.first else {
            return []
        }
        return [
            Paragraph(
                icon: .data,
                title: dgc.nam.fullName,
                subtitle: "\(dgc.nam.fullNameTransliterated)\n\(String(format: "validation_check_popup_test_date_of_birth".localized, DateUtils.displayDateOfBirth(dgc)))"
            ),
            Paragraph(
                icon: .calendar,
                title: DateUtils.displayDateTimeFormatter.string(from: testCert.sc),
                subtitle: "validation_check_popup_test_date_of_issue".localized
            )
        ]
    }

    var info: String? {
        nil
    }
    
    var buttonHidden: Bool = false
    var userDefaults: Persistence
    var isLoadingScan: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    // MARK: - Lifecycle
    
    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken?,
         userDefaults: Persistence,
         revocationKeyFilename: String,
         countdownTimerModel: CountdownTimerModel,
         revocationRepository: CertificateRevocationRepositoryProtocol?,
         audioPlayer: AudioPlayerProtocol
    ) {
        self.audioPlayer = audioPlayer
        self.revocationRepository = revocationRepository
        self.resolvable = resolvable
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.userDefaults = userDefaults
        self.revocationKeyFilename = revocationKeyFilename
        self.countdownTimerModel = countdownTimerModel
        countdownTimerModel.onUpdate = onCountdownTimerModelUpdate
        countdownTimerModel.start()
    }

    private func onCountdownTimerModelUpdate(countdownTimerModel: CountdownTimerModel) {
        if countdownTimerModel.shouldDismiss {
            cancel()
        } else {
            delegate?.viewModelDidUpdate()
        }
    }
    
    func scanCertificateStarted() {
        isLoadingScan = true
    }
    
    func scanCertificateEnded() {
        isLoadingScan = false
    }
}
