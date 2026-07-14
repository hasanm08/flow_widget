import Foundation

enum FlowWidgetCapabilitiesProvider {
    static func capabilities() -> [String: Bool] {
        var flags: [String: Bool] = [
            "homeWidgets": true,
            "lockScreenWidgets": true,
            "interactiveWidgets": true,
            "configurableWidgets": true,
            "timelineProviders": true,
            "liveActivities": liveActivitiesSupported,
            "dynamicIsland": dynamicIslandSupported,
            "pinWidget": false,
            "backgroundUpdates": true,
            "scheduledUpdates": true,
            "pushUpdates": true,
            "remoteImageCaching": true,
            "appGroups": true,
            "wearTiles": false,
            "complications": false,
            "multipleInstances": true,
            "resizing": true,
            "themeSynchronization": true,
            "appIntents": true,
        ]
        return flags
    }

    private static var liveActivitiesSupported: Bool {
        if #available(iOS 16.2, *) {
            return true
        }
        return false
    }

    private static var dynamicIslandSupported: Bool {
        if #available(iOS 16.2, *) {
            return true
        }
        return false
    }
}
