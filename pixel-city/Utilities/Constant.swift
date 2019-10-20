//
//  Constant.swift
//  pixel-city
//
//  Created by farnaz on 2019-10-16.
//  Copyright © 2019 farnaz. All rights reserved.
//

import Foundation

let apiKey = "308f26e4e1a92a26cd58a5669967b891"
//let api_secret = "ab72673693533451"

func flickUrl(forapiKey apiKey : String, withAnotation annotation : DroppablePin,andNumberOfPhotos number : Int )-> String{
    let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=84d45099f4f60231c254110c39196627&lat=42.9&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1
