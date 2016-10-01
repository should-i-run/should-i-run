import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class apiController: NSObject {

    static let instance = apiController()

    func fetchData(_ latStart:Float, lngStart:Float, success: @escaping ((JSON) -> ()), fail: @escaping (String) -> ()) {
        Alamofire.request("https://tranquil-harbor-8717.herokuapp.com/bart", method: .post, parameters: ["lat": latStart, "lng": lngStart], encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json: JSON = JSON(data)
                    if json.count == 0 || json[0] == nil {
                        self.handleError(fail, message: "Sorry, no results")
                    } else {
                        success(json)
                    }
                case .failure(let error):
                    self.handleError(fail, message: String(error.localizedDescription))
                }
            }
        
    }

    func handleError(_ fail: (String) -> (), message: String = "Couldn't find any BART, MUNI, or Caltrain trips between here and there...") {
        fail(message)
    }
}
