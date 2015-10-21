//******************************************************************************
//  Configuration.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

struct Configuration {
    let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
    let DefaultServiceRegionType = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
    let CognitoIdentityPoolId = "us-east-1:371de83b-8ff2-4ea9-b184-9c33dfdfa37d"
    let S3BucketName = "storyteler"
}
let config = Configuration()