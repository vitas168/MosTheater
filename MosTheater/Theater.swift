//
//  Theater.swift
//  MosTheater
//
//  Created by Vitaly Shpinyov on 27/06/2017.
//  Copyright © 2017 Vitaly Shpinyov. All rights reserved.
//

import UIKit

let TheaterType:[String: String] = ["Chilren's": "Детский", "Drama": "Драматический", "Misc": "Прочее"]

class Theater: NSObject {

    var id = ""
    var name_ru = ""
    var address = ""
    var phone = ""
    var desc = ""
    var lat:Float = 0
    var long:Float = 0
    var type = TheaterType["Misc"]
    var detailImageName = ""
    var smallImageName = ""
    var smallImageData:Data?
    var reviews = [Review]()
    
}
