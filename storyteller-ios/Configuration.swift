//******************************************************************************
//  Configuration.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

struct Configuration {
    let AWSAccountID: String = ""
    let CognitoPoolID: String = ""
    let CognitoRoleAuth: String? = nil
    let CognitoRoleUnauth: String? = ""
    let S3BucketRegion: String = ""
    let S3BucketName: String = ""
}
let config = Configuration()
