//
//  MatchModel.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/3/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

struct MatchList {
    var matches: [MatchModel]
}

struct MatchModel {
    var ID: String
    var name: String
    var firstName: String
    var lastName: String
    var userName: String
    var userTag: String
    var about: String
    var gender: Int
    var birthday: String
    var age: Int
    var photo: String
    var device: String
    var latitude: Double
    var longitude: Double
    var distance: Double
    var email: String
    var categories: [UserCategory]
    var galleryCount: Int
    var gallery: [UserImage]
}

struct UserImage {
    var gID: Int
    var photo: String
}

struct UserCategory {
    var cID: Int
    var name: String
}
