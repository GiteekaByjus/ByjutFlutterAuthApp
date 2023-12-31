//
//  JWTParser.swift
//  IDService
//
//  Created by Suhas K on 20/02/21.
//  Copyright © 2021 BYJUS. All rights reserved.
//

import Foundation
/*
 Parses the JWT token passed by the HYdra and gives the paylod
 */
class JWTParser {
    
 class func decode(jwtToken jwt: String) throws -> [String: Any] {
        enum DecodeErrors: Error {
            case badToken
            case other
        }
        
        func base64Decode(_ base64: String) throws -> Data {
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else {
                throw DecodeErrors.badToken
            }
            return decoded
        }
        
        func decodeJWTPart(_ value: String) throws -> [String: Any] {
            let bodyData = try base64Decode(value)
            let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
            guard let payload = json as? [String: Any] else {
                throw DecodeErrors.other
            }
            return payload
        }
        let segments = jwt.components(separatedBy: ".")
        return try decodeJWTPart(segments[1])
    }
}
