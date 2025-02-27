//
//  AppInformationViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation

class CheckAppInformationBaseViewModel: AppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        super.entries + [
            checkSituationEntry,
            revocationSettingsEntry,
            acousticFeedbackSettingsEntry
        ]
    }

    internal var checkSituationEntry: AppInformationEntry {
        let scene = CheckSituationSceneFactory(
            router: CheckSituationRouter(sceneCoordinator: router.sceneCoordinator),
            userDefaults: persistence
        )
        return AppInformationEntry(title: LocalText.rulesTitle, scene: scene)
    }

    internal var revocationSettingsEntry: AppInformationEntry {
        let rightTitle = persistence.revocationExpertMode ? LocalText.revocationHintOn : LocalText.revocationHintOff
        let revocationSettingsRouter = RevocationSettingsRouter(sceneCoordinator: router.sceneCoordinator)
        let scene = RevocationSettingsSceneFactory(router: revocationSettingsRouter, userDefaults: persistence)
        return AppInformationEntry(title: LocalText.revocationTitle, scene: scene, rightTitle: rightTitle)
    }

    internal var acousticFeedbackSettingsEntry: AppInformationEntry {
        let rightTitle = persistence.enableAcousticFeedback ?
            LocalText.acousticFeedbackOn : LocalText.acousticFeedbackOff
        let acousticFeedbackSettingsRouter = AcousticFeedbackSettingsRouter(
            sceneCoordinator: router.sceneCoordinator
        )
        let scene = AcousticFeedbackSettingsSceneFactory(
            router: acousticFeedbackSettingsRouter
        )
        return AppInformationEntry(
            title: LocalText.acousticFeedbackTitle,
            scene: scene,
            rightTitle: rightTitle
        )
    }
}

class GermanAppInformationViewModel: CheckAppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        [
            checkSituationEntry,
            whatsNewEntry,
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/verification-app/faq/")!,
                      openingAnnounce: Accessibility.Opening.faqTitle,
                      closingAnnounce: Accessibility.Closing.faqTitle),
            acousticFeedbackSettingsEntry,
            .webEntry(title: Texts.leichteSprache,
                      url: URL(string: "https://digitaler-impfnachweis-app.de/webviews/leichte-sprache/covpasscheckapp")!,
                      openingAnnounce: Accessibility.Opening.leichteSprache,
                      closingAnnounce: Accessibility.Closing.leichteSprache),
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpasscheck-de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.contactTitle,
                      closingAnnounce: Accessibility.Closing.contactTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpasscheck-de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.datenschutzTitle,
                      closingAnnounce: Accessibility.Closing.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/imprint/")!,
                      openingAnnounce: Accessibility.Opening.companyDetailsTitle,
                      closingAnnounce: Accessibility.Closing.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_de", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                      closingAnnounce: Accessibility.Closing.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/webviews/covpasscheck-app-ios-barrierefreiheitserklaerung/")!,
                      openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                      closingAnnounce: Accessibility.Closing.accessibilityStatementTitle),
            revocationSettingsEntry
        ]
    }
}

class EnglishAppInformationViewModel: CheckAppInformationBaseViewModel {
    override var entries: [AppInformationEntry] {
        [
            checkSituationEntry,
            whatsNewEntry,
            .webEntry(title: Texts.faqTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/client-app/faq/")!,
                      openingAnnounce: Accessibility.Opening.faqTitle,
                      closingAnnounce: Accessibility.Closing.faqTitle),
            acousticFeedbackSettingsEntry,
            .webEntry(title: Texts.contactTitle,
                      url: mainBundle.url(forResource: "contact-covpasscheck-en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.contactTitle,
                      closingAnnounce: Accessibility.Closing.contactTitle),
            .webEntry(title: Texts.datenschutzTitle,
                      url: mainBundle.url(forResource: "privacy-covpasscheck-en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.datenschutzTitle,
                      closingAnnounce: Accessibility.Closing.datenschutzTitle),
            .webEntry(title: Texts.companyDetailsTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/imprint/")!,
                      openingAnnounce: Accessibility.Opening.companyDetailsTitle,
                      closingAnnounce: Accessibility.Closing.companyDetailsTitle),
            .webEntry(title: Texts.openSourceLicenseTitle,
                      url: licenseBundle.url(forResource: "license_en", withExtension: "html")!,
                      enableDynamicFonts: true,
                      openingAnnounce: Accessibility.Opening.openSourceLicenseTitle,
                      closingAnnounce: Accessibility.Closing.openSourceLicenseTitle),
            .webEntry(title: Texts.accessibilityStatementTitle,
                      url: URL(string: "https://www.digitaler-impfnachweis-app.de/en/webviews/covpasscheck-app-ios-accessibility-statement/")!,
                      openingAnnounce: Accessibility.Opening.accessibilityStatementTitle,
                      closingAnnounce: Accessibility.Closing.accessibilityStatementTitle),
            revocationSettingsEntry
        ]
    }
}

private enum LocalText {
    static let rulesTitle = "settings_rules_list_title".localized
    static let revocationTitle = "app_information_authorities_function_title".localized
    static let revocationHintOn = "app_information_authorities_function_state_on".localized
    static let revocationHintOff = "app_information_authorities_function_state_off".localized
    static let acousticFeedbackTitle = "app_information_beep_when_checking_title".localized
    static let acousticFeedbackOn = "app_information_authorities_function_state_on".localized
    static let acousticFeedbackOff = "app_information_authorities_function_state_off".localized
}
