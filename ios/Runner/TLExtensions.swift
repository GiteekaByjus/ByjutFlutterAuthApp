

let INVALID_PASSCODE = "42304"
let EXPIRED_PASSCODE = "42302"
let INVALID_URL_TOKEN = "42305"
let EXPIRED_URL_TOKEN = "42306"
let RATE_LIMIT_EXCEEEDED = "40001"
let INVALID_CREDIENTIALS = "42201"

let RATE_LIMIT_EXHAUSTED = 40001
let API_VERSION = "2"

//Passcode
let kMaxAttemptsExhausted = "Maximum attempts exhausted"
let kExceededAttempts = "You have exceeded the maximum number of attempts."


extension TLUserDefaults{
    
    open func setLastAccessToken(token: String) {
        userDefaults.set(token, forKey: "OAuthAccessToken")
        userDefaults.synchronize()
    }
    
    open func getLastAccessToken()-> String? {
        return UserDefaults.standard.value(forKey: "OAuthAccessToken") as? String
    }
    
    open func setLastRefreshToken(token: String) {
        userDefaults.set(token, forKey: "OAuthRefreshToken")
        userDefaults.synchronize()
    }
    
    open func getLastRefreshToken()-> String? {
        return UserDefaults.standard.value(forKey: "OAuthRefreshToken") as? String
    }
    
    open func setLastIdToken(token: String) {
        userDefaults.set(token, forKey: "OAuthIdToken")
        userDefaults.synchronize()
    }
    
    open func getLastIdToken()-> String? {
        return UserDefaults.standard.value(forKey: "OAuthIdToken") as? String
    }
    
    open func setLastIdentityId(identityId: String) {
        userDefaults.set(identityId, forKey: "OAuthIdentityId")
        userDefaults.synchronize()
    }
    
    open func getLastIdentityId()-> String? {
        return UserDefaults.standard.value(forKey: "OAuthIdentityId") as? String
    }
    
    open func setUserHasSetPasscodeStatus(status: Bool) {
        userDefaults.set(status, forKey: "UserHasSetPasscode")
        userDefaults.synchronize()
    }
    
    open func getUserHasSetPasscodeStatus()-> Bool? {
        return UserDefaults.standard.value(forKey: "UserHasSetPasscode") as? Bool
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
    
    func offsetLong(from date: Date) -> String {
        if years(from: date)   > 0 { return years(from: date) > 1 ? "\(years(from: date)) years ago" : "\(years(from: date)) year ago" }
        if months(from: date)  > 0 { return months(from: date) > 1 ? "\(months(from: date)) months ago" : "\(months(from: date)) month ago" }
        if weeks(from: date)   > 0 { return weeks(from: date) > 1 ? "\(weeks(from: date)) weeks ago" : "\(weeks(from: date)) week ago"   }
        if days(from: date)    > 0 { return days(from: date) > 1 ? "\(days(from: date)) days ago" : "\(days(from: date)) day ago" }
        if hours(from: date)   > 0 { return hours(from: date) > 1 ? "\(hours(from: date)) hours ago" : "\(hours(from: date)) hour ago"   }
        if minutes(from: date) > 0 { return minutes(from: date) > 1 ? "\(minutes(from: date)) minutes ago" : "\(minutes(from: date)) minute ago" }
        if seconds(from: date) > 0 { return seconds(from: date) > 1 ? "\(seconds(from: date)) seconds ago" : "\(seconds(from: date)) second ago" }
        return ""
    }
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    //Returns number of days remaining from current date
    func daysRemaining(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
}




extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

}
