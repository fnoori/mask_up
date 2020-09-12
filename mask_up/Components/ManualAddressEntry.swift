import SwiftUI
import CoreLocation

struct ManualAddressEntry: View {

    @Binding var address: String
    @Binding var latitude: Double
    @Binding var longitude: Double

    var body: some View {
        TextField("Address", text: $address, onCommit: {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(self.address) { (placemarks, error) in
                guard let placemarks = placemarks, let location = placemarks.first?.location else { return }

                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude

                print("\nlat: \(self.latitude)")
                print("\nlong: \(self.longitude)")
            }
        }).keyboardType(.webSearch)
    }
}
