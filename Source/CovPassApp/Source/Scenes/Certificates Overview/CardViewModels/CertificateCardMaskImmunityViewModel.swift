//
//  CertificateCardViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateCardMaskImmunityViewModel: CertificateCardViewModelProtocol {
    // MARK: - Private Properties

    private var token: ExtendedCBORWebToken
    private var tokens: [ExtendedCBORWebToken]
    private var onAction: (ExtendedCBORWebToken) -> Void
    private var boosterLogic: BoosterLogicProtocol
    private var userDefaults: UserDefaultsPersistence
    private var holderNeedsMask: Bool
    private lazy var dgc: DigitalGreenCertificate = certificate.hcert.dgc
    private lazy var certificate = token.vaccinationCertificate
    private lazy var isExpired = certificate.isExpired
    private lazy var isRevoked = token.isRevoked
    private lazy var tokenIsInvalid = token.isInvalid
    private var anyCertExpiredMoreThan90Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.expiredMoreThan90Days).contains(where: { $0 == true })
    }
    private var anyCertExpiredForLessOrEqual90Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.expiredForLessOrEqual90Days).contains(where: { $0 == true })
    }
    private var anyCertWillExpireInLessOrEqual28Days: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        return certs.map(\.willExpireInLessOrEqual28Days).contains(where: { $0 == true })
    }
    private var showBoosterAvailabilityNotification: Bool {
        guard let boosterCandidate = boosterLogic.checkCertificates([token]) else { return false }
        return boosterCandidate.state == .new
    }
    private var showNotificationForExpiryOrInvalid: Bool {
        let certs = tokens.filterFirstOfAllTypes.map(\.vaccinationCertificate)
        let anyCertPassed28DaysExpiry = certs.map(\.passed28DaysBeforeExpiration).contains(where: { $0 == true })
        return anyCertPassed28DaysExpiry || (token.isInvalid && token.expiryAlertWasNotShown)
    }
    private let certificateHolderStatusModel: CertificateHolderStatusModelProtocol

    // MARK: public properties

    var showNotification: Bool {
        showBoosterAvailabilityNotification || showNotificationForExpiryOrInvalid
    }

    var maskRulesNotAvailable: Bool = true
    var regionText: String? {
        guard !isInvalid else { return nil }
        let region = ("DE_" + userDefaults.stateSelection).localized
        let text = "infschg_start_screen_status_federal_state".localized
        return String(format: text, region)
    }

    // MARK: - Lifecycle

    init(
        token: ExtendedCBORWebToken,
        tokens: [ExtendedCBORWebToken],
        onAction: @escaping (ExtendedCBORWebToken) -> Void,
        certificateHolderStatusModel: CertificateHolderStatusModelProtocol,
        repository _: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        userDefaults: UserDefaultsPersistence
    ) {
        self.token = token
        self.tokens = tokens
        self.onAction = onAction
        holderNeedsMask = true
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
        self.certificateHolderStatusModel = certificateHolderStatusModel
        updateCertificateHolderStatus().cauterize()
    }

    func updateCertificateHolderStatus() -> Promise<Void> {
        guard certificateHolderStatusModel.maskRulesAvailable(for: userDefaults.stateSelection) else {
            maskRulesNotAvailable = true
            delegate?.viewModelDidUpdate()
            return .value
        }
        maskRulesNotAvailable = false
        return certificateHolderStatusModel
            .holderNeedsMaskAsync(tokens, region: userDefaults.stateSelection)
            .done { holderNeedsMask in
                self.holderNeedsMask = holderNeedsMask
                DispatchQueue.main.async {
                    self.delegate?.viewModelDidUpdate()
                }
            }.asVoid()
    }

    // MARK: - Internal Properties

    var delegate: ViewModelDelegate?

    var reuseIdentifier: String {
        "\(CertificateMaskImmunityCollectionViewCell.self)"
    }

    var backgroundColor: UIColor {
        if isInvalid {
            return .onBackground40
        } else if holderNeedsMask {
            return .onBrandAccent70
        } else {
            return .brandAccent90
        }
    }

    var iconTintColor: UIColor {
        isInvalid ? UIColor(hexString: "737373") : .onBrandAccent70
    }

    let textColor: UIColor = .neutralWhite

    lazy var title: String = {
        if isInvalid {
            return "infschg_start_expired_revoked".localized
        } else if maskRulesNotAvailable {
            return "infschg_start_screen_status_grey_2".localized
        } else if holderNeedsMask {
            return "infschg_start_mask_mandatory".localized
        }
        return "infschg_start_mask_optional".localized
    }()

    lazy var subtitle: String = {
        if isInvalid {
            return "infschg_start_expired_revoked".localized
        }
        return ""
    }()

    lazy var headerSubtitle: String? = {
        guard showNotification else {
            return nil
        }
        if anyCertExpiredMoreThan90Days {
            return "certificates_overview_expired_title".localized
        } else if anyCertExpiredForLessOrEqual90Days {
            return "vaccination_start_screen_qrcode_renewal_note_subtitle".localized
        } else if anyCertWillExpireInLessOrEqual28Days {
            return "vaccination_start_screen_qrcode_renewal_note_subtitle".localized
        } else {
            return "infschg_start_notification".localized
        }
    }()

    var titleIcon: UIImage {
        if isInvalid {
            return .statusMaskInvalidCircle
        } else if maskRulesNotAvailable {
            return .statusMaskInvalidCircle
        } else if holderNeedsMask {
            return .statusMaskRequiredCircle
        } else {
            return .statusMaskOptionalCircle
        }
    }

    var subtitleIcon: UIImage {
        if isInvalid {
            return showNotification ? .expiredDotNotification : .statusInvalidCircle
        }
        return .iconRed
    }

    lazy var isInvalid: Bool = isExpired || tokenIsInvalid || isRevoked

    var showFavorite: Bool = true

    lazy var qrCode: UIImage? = {
        let code = isInvalid ? "" : token.vaccinationQRCodeData
        return code.generateQRCode()
    }()

    var name: String {
        dgc.nam.fullName
    }

    var tintColor: UIColor {
        textColor
    }

    // MARK: - Actions

    func onClickAction() {
        onAction(token)
    }
}
