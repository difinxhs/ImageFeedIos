//
//  OAuthTokenModel.swift
//  ImageFeedIos
//
//  Created by Alex Sacopini on 6.8.24..
//

import Foundation

struct OAuthToken: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
//        enum CodingKeys: String, CodingKey {
//            case accessToken = "access_token"
//            case tokenType = "token_type"
//            case scope
//            case createdAt = "created_at"
//        }
}
