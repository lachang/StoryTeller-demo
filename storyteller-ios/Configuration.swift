//******************************************************************************
//  Configuration.swift
//  storyteller-ios
//
//  Copyright (c) 2015 storyteller. All rights reserved.
//******************************************************************************

import Foundation

struct Configuration {
    
    let StoryPointUnlockedDistance = 100
    let StoryPointLockedDistance   = 10000

    let CognitoRegionType = AWSRegionType.USEast1
    let CognitoIdentityPoolId = "us-east-1:371de83b-8ff2-4ea9-b184-9c33dfdfa37d"
    let S3Domain = "https://s3.amazonaws.com/"
    let S3BucketName = "storyteller-demo"
}
let config = Configuration()
