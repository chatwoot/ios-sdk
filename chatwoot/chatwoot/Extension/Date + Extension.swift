//
//  Date + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension Date {
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func getTodaysDate() -> String {
        let date = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    static func getTimeFrom(dateInterval: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(dateInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "hh:mm a"
        let convertedDate: String = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getHourFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        var string = dateFormatter.string(from: date)
        if string.last == "M" {
            string = String(string.prefix(string.count - 3))
        }
        return string
    }
    
    static func getDayOfWeekFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        var string = dateFormatter.string(from: date)
        if let index = string.firstIndex(of: ",") {
            string = String(string.prefix(upTo: index))
            return string
        }
        return "--"
    }
}

extension String {
    func getTimeFrom() -> String {
        let dateFormatter = DateFormatter()
        // step 1
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        
        guard let date = dateFormatter.date(from: self) else {
            return ""
        }
        // step 2
        dateFormatter.dateFormat = "hh:mm a" // output format
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    func getConvertedDate(dateFormat: String = "dd MMM yyy") -> String {
        let formatter = DateFormatter()
        var strDate = ""
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        if let date = formatter.date(from: self) {
            formatter.dateFormat = dateFormat
            strDate = formatter.string(from: date)
        }
        return strDate
    }
    
    func getDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        if let date = formatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
    
    func utcToLocal() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone.current
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
}

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}

extension Date {
    var yearsFromNow: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    var monthsFromNow: Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
    }
    var weeksFromNow: Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear!
    }
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    var hoursFromNow: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
    }
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
    }
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second!
    }
    var relativeTime: String {
        if yearsFromNow > 0 { return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago" }
        if monthsFromNow > 0 { return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago" }
        if weeksFromNow > 0 { return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago" }
        if isInYesterday { return "Yesterday" }
        if daysFromNow > 0 { return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago" }
        if hoursFromNow > 0 { return "\(hoursFromNow) hour" + (hoursFromNow > 1 ? "s" : "") + " ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow) second" + (secondsFromNow > 1 ? "s" : "") + " ago" }
        return ""
    }
}
