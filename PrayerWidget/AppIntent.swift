//
//  AppIntent.swift
//  PrayerWidget
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Prayer Times" }
    static var description: IntentDescription { "Shows daily prayer times based on your location." }
}