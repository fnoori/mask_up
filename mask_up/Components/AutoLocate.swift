import SwiftUI
import CoreLocation
import MapKit

struct AutoLocate: View {
    @EnvironmentObject var isLoading: IsLoading
    @EnvironmentObject var locationModel: LocationModel

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
        if self.locationModel.authorisationStatus == .authorizedWhenInUse {
            self.locationModel.getLocationManager().distanceFilter = kCLDistanceFilterNone
            self.locationModel.getLocationManager().desiredAccuracy = kCLLocationAccuracyBest
            self.locationModel.getLocationManager().startUpdatingLocation()

            self.isLoading.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                let locValue: CLLocationCoordinate2D = self.locationModel.getLocationManager().location!.coordinate

                self.latitude = locValue.latitude
                self.longitude = locValue.longitude

                print("\nlat: \(self.latitude)")
                print("\nlong: \(self.longitude)")

                self.locationModel.getLocationManager().stopUpdatingLocation()
                self.isLoading.isLoading = false
            })
        } else {
            self.locationModel.requestAuthorisation()
            self.autoLocate.toggle()
        }
    }
}

