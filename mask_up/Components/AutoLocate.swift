import SwiftUI
import CoreLocation
import MapKit

struct AutoLocate: View {
    @EnvironmentObject var isLoading: IsLoading

    @Binding var autoLocate: Bool
    @Binding var latitude: Double
    @Binding var longitude: Double

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
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.startUpdatingLocation()

        self.isLoading.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            let locValue: CLLocationCoordinate2D = locationManager.location!.coordinate

            self.latitude = locValue.latitude
            self.longitude = locValue.longitude

            print("\nlat: \(self.latitude)")
            print("\nlong: \(self.longitude)")

            locationManager.stopUpdatingLocation()
            self.isLoading.isLoading = false
        })
    }

    func setDefault() {
        self.latitude = 0.0
        self.longitude = 0.0
    }
}

