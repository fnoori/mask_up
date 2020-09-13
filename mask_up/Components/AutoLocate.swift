import SwiftUI
import CoreLocation
import MapKit

struct AutoLocate: View {
    @EnvironmentObject var isLoading: IsLoading
    @ObservedObject var locationModel = LocationModel()

    @Binding var autoLocate: Bool
    @Binding var latitude: Double
    @Binding var longitude: Double

    var locationManager = CLLocationManager()

    var body: some View {
        Toggle(isOn: $autoLocate.didSet { (state) in
            if state == true {
                self.getCurrentLocation()
            } else {
                self.latitude = 0.0
                self.longitude = 0.0
            }
        }) {
            Text("Locate Me Automatically")
        }
    }

    func getCurrentLocation() {
//        if self.locationModel.authorisationStatus != .authorizedWhenInUse {
//            self.locationModel.requestAuthorisation()
//        }
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            self.askForLocationPermission()
        }

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()

            self.isLoading.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                let locValue: CLLocationCoordinate2D = self.locationManager.location!.coordinate

                self.latitude = locValue.latitude
                self.longitude = locValue.longitude

                print("\nlat: \(self.latitude)")
                print("\nlong: \(self.longitude)")

                self.locationManager.stopUpdatingLocation()
                self.isLoading.isLoading = false
            })
        } else {
            self.autoLocate.toggle()
        }
    }

    func askForLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("need location to use location based notification")
            break
        default:
            print("need location for location based notification")
        }
    }

    func setDefault() {
        self.latitude = 0.0
        self.longitude = 0.0
    }
}

