//
//  ValidationServiceRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    enum Text {
        enum Alert {
            static let message = "cancellation_share_certificate_title".localized
            static let ok = "cancellation_share_certificate_action_button_no".localized
            static let cancel = "cancellation_share_certificate_action_button_yes".localized
        }
    }
}

protocol ValidationServiceRoutable: DialogRouterProtocol {
    func routeToConsentGeneralConsent()
    func routeToWarning()
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation)
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol)
    func routeToPrivacyStatement(url: URL)
    func routeToCertificateValidation(for certificate: ExtendedCBORWebToken)
}

struct ValidationServiceRouter: ValidationServiceRoutable {
    var sceneCoordinator: SceneCoordinator
    
    func routeToConsentGeneralConsent() {
        
    }
    
    public func routeToWarning() {
        showDialog(title: "",
                   message: Constants.Text.Alert.message,
                   actions: [
                    DialogAction(title: Constants.Text.Alert.ok, style: UIAlertAction.Style.default, isEnabled: true, completion: nil),
                    DialogAction(title: Constants.Text.Alert.cancel, style: UIAlertAction.Style.destructive, isEnabled: true, completion: { _ in
                        sceneCoordinator.dimiss(animated: true)
                    })],
                   style: .alert)
    }
    
    func routeToSelectCertificate(ticket: ValidationServiceInitialisation) {
        sceneCoordinator.push(
            ChooseCertificateSceneFactory(
                router: self,
                ticket: ticket
            ),
            animated: true)
    }
    
    func routeToCertificateConsent(ticket: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken, vaasRepository: VAASRepositoryProtocol) {
        sceneCoordinator.push(ConsentExchangeFactory(router: self, vaasRepository: vaasRepository, initialisationData: ticket, certificate: certificate))
    }
    
    func routeToPrivacyStatement(url: URL) {
        let webViewScene = WebviewSceneFactory(title: "app_information_title_datenschutz".localized,
                                               url: url, isToolbarShown: true)
        sceneCoordinator.push(webViewScene)
    }

    func routeToCertificateValidation(for certificate: ExtendedCBORWebToken) {
        sceneCoordinator.push(
            CertificateItemDetailSceneFactory(
                router: CertificateItemDetailRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate
            )
        )
    }
}
