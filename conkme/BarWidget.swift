//
//  BarWidget.swift
//  conkme
//
//  Created by Christian Schulze on 14/04/2017.
//  Copyright © 2017 Christian Schulze. All rights reserved.
//


import Cocoa
import IOKit.ps

class BarWidget: WidgetController {

    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var kwmModeLabel: NSTextField!
    @IBOutlet weak var kwmSpaceLabel: NSTextFieldCell!
    @IBOutlet weak var batteryLabel: NSTextField!

    let formatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    override var REFRESH_INTERVAL: TimeInterval { return 3.0 }

    func batteryStatus() -> String {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        for ps in sources {
            // Fetch the information for a given power source out of our snapshot
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! Dictionary<String, Any>

            // Pull out the name and capacity
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int {
                return prettyBattery(capacity: capacity)
            }
        }

        return ""
    }

    func prettyBattery(capacity: Int) -> String {
        return "\(BATTERY_PREFIX)\(capacity)%"
    }

    func callKwmc(arguments: [String]) -> String {
        // see: http://stackoverflow.com/q/40062295/4120042
        let task = Process()
        task.launchPath = "/usr/local/bin/kwmc"
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe

        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }

    func kwmSpaceList() -> String {
        let spaces = callKwmc(arguments: ["query", "space", "list"])
            .components(separatedBy: "\n")
            // the last entry in the array is empty. this prevents some quirky
            // work arounds and error catches and stuff.
            .dropLast()

        let activeSpace = callKwmc(arguments: ["query", "space", "active", "id"])
        var out = ""

        for space in spaces {
            let s = space.components(separatedBy: ",")[0]

            // we just look at the first character. we could just trim the
            // whitespace after `activeSpace`, but this is a simple enough
            // solution
            if (s[s.startIndex] == activeSpace[activeSpace.startIndex]) {
                out.append(KWM_SCREEN_ACTIVE)

            } else {
                out.append(KWM_SCREEN)
            }
        }

        return out
    }

    override func refreshWidget() {
        willRefreshWidget()

        kwmModeLabel.stringValue = callKwmc(arguments:
            ["query", "space", "active", "mode"])
        kwmSpaceLabel.stringValue = kwmSpaceList()

        timeLabel.stringValue = formatter.string(from: Date())

        if SHOW_BATTERY_PERCENTAGE {
            batteryLabel.stringValue = batteryStatus()

        } else {
            if batteryLabel.stringValue != "" {
                batteryLabel.stringValue = ""
            }
        }

        didRefreshWidget()
    }
}
