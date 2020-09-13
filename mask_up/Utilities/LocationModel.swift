import SwiftUI
import CoreLocation

class LocationModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var authorisationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    public func requestAuthorisation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("need location to use location based notification")
            break
        default:
            print("need location for location based notificaion")
        }
//        if always {
//            self.locationManager.requestAlwaysAuthorization()
//        } else {
//            self.locationManager.requestWhenInUseAuthorization()
//        }
    }
}

extension LocationModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorisationStatus = status
    }
}