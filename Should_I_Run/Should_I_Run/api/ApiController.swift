import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class apiController: NSObject {

    static let instance = apiController()

    func fetchData(latStart:Float, lngStart:Float, success: (JSON -> ()), fail: String -> ()) {
        let url = "https://tranquil-harbor-8717.herokuapp.com/bart"
        Alamofire.request(.POST, url, paramaters: [lat: latStart, lng: lngStart])
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    let json: JSON = JSON(data)
                    if json.count == 0 || json[0] == nil {
                        self.handleError(fail, message: "Sorry, no results")
                    } else {
                        success(json)
                    }
                case .Failure:
                    self.handleError(fail)
                }
            }
        
    }

    func handleError(fail: String -> (), message: String = "Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        fail(message)
    }
}
