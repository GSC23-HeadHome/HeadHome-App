# HeadHome App

---

## Technology Stack

<div align="center">
	<img height="60" src="https://user-images.githubusercontent.com/25181517/186150365-da1eccce-6201-487c-8649-45e9e99435fd.png" alt="Flutter" title="Flutter" />
	<img height="60" src="https://user-images.githubusercontent.com/63765620/228300098-4aa01eeb-003c-48f2-acfb-e1d17883b1ad.png" alt="Dart" title="Dart" />
 	<img height="60" src="https://user-images.githubusercontent.com/63765620/228297319-699b5cee-0fc4-4c1f-972c-5a945ca30af9.png" alt="Google Maps" title="Google Maps Platform" />
	<img height="60" src="https://user-images.githubusercontent.com/25181517/189716855-2c69ca7a-5149-4647-936d-780610911353.png" alt="Firebase" title="Firebase" />
	<img height="58" src="https://user-images.githubusercontent.com/63765620/228302531-4822866b-d460-4741-9185-958f17fce9f7.png" alt="GCP" title="Google Cloud Platform" />
</div>

---

## Install

    $ git clone https://github.com/GSC23-HeadHome/HeadHome-App.git
    $ cd HeadHome-App
    $ flutter pub get

### Configure app

Ensure that you have either Android Studio or IOS Simulator running and able to be detected.
Alternatively, you can connect a mobile device and build the release version of the app.

## Start

    $ flutter run

## Start for release build

    $ flutter run --release

---

## Testing Details

Currently, we have a couple of testing accounts that can be used to test out the app. These accounts can be found in the [testing_accounts.md][testing_accounts.md]

## Application Flow

1. Care Receiver

Our `care receivers` can request for help from their `care giver` and begin the navigation back home by tapping on the red `Navigate Home` button on their home page. The application will also begin navigation when the `care receiver` leaves the configurable safezone radius around their home, or when they press the red button the companion wrist wearable device.

This will display a route home on the Google Maps widget. This route will be updated as the patient goes along, rerouting when necessary.

The care receiver would each have an Authentication ID which is used to ensure that the `Volunteer` will only have access to the `care receiver's` home address when they have actually met them. 

2. Care Giver

The `care giver` will receive a notification when their respective `care receivers` have started to navigate home. This will inform them about the `care receiver's` current location, and also allow them to choose to send an SOS alert signal to `volunteers`. 

The `care giver` will then be able to contact the `volunteers` who have started to guide the `care receivers` back home through the `contact` button of the application. 

3. Volunteers

Volunteers would be able to view all the care receiver's SOS alerts, and select the care receiver they wish to help. The app would provide them with the current location of the care receiver, and also allow them to redirect to Google Maps to find their way to these care givers. 

Thereafter, when the volunteers reach the care receiver, they would be able to start leading them home after verifying the `care receiver's` Authentication ID

---

Thank you for taking the time to review our work. We hope you have found our development project interesting and meaningful!