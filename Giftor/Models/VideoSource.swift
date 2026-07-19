//
//  VideoSource.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//

import SwiftUI
import PhotosUI

enum VideoSource {
    case photos(PhotosPickerItem)
    case file(URL)
}
