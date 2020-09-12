import SwiftUI
import CoreLocation
import MapKit

struct AutoLocate: View {
    @ObservedObject var lm = LocationManager()

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
        self.latitude = self.lm.location!.coordinate.latitude
        self.longitude = self.lm.location!.coordinate.longitude

        print("\nlat: \(self.latitude)")
        print("\nlong: \(self.longitude)")
    }

    func setDefault() {
        self.latitude = 0.0
        self.longitude = 0.0
    }
}

