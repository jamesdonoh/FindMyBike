# FindMyBike

## Privacy policy

### What personal information does FindMyBike collect?

FindMyBike ('the app') does not collect any personally identifiable information such as your name or e-mail address.

#### Photographs

You may associate a photo from your library with your bike information for convienience. This photo is never shared with FindMyBike's servers or with any other users of the app.

#### Device tokens

In order to be able to send 'push' notifications when your bike is missing and is detected, FindMyBike requests a 'device token' from Apple's Push Notifiation service (APNs). The device token is:

    a unique identifier assigned by Apple to a specific app on a specific device. Only APNs can decode and read the contents of a device token
    
FindMyBike is unable to identify you personally or anything about your device from this token. You can read more about device tokens [on the Apple website](https://developer.apple.com/go/?id=push-notifications).

### Use of location information

Location information is integral to the functionality provided by FindMyBike, and therefore permission to use Location Services is required in order for it to work correctly. Refusing permission for Location Services will render the app largely non-functional.

Location Services is used by FindMyBike in two ways:

1) in order to determine when a user is in proximity to a missing bike, using Bluetooth Low Energy (BLE) monitoring
2) in order to report the physical location of a missing bike once detected, using Global Positioning System (GPS)

During 1 no information is shared with FindMyBike's servers or with any other users.

For 2, a one-off request for the user's location is made. The user has the opportunity to confirm that they are happy for their location to be used before the request is made. If the request is successful, the location in which the bike was reported is shared with FindMyBike's servers and the owner of the missing bike _only_. No personal information about you or your bike is shared, only your GPS coordinates.

### How is my information used?

Information collected by FindMyBike is used solely for the purpose of providing essential app functionality. Information collected is never used for any other purpose or made available to third parties.

### How do I raise questions or concerns about privacy?

Please open an [issue report](https://github.com/jamesdonoh/FindMyBike/issues) and a support engineer will contact you.
