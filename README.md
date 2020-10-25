# react-native-contact-list

get contact list from user device

## Installation

```sh
npm install react-native-contact-list
```

## Usage

## Android
`AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

## iOS
`Info.plist`
```xml
<key>NSContactsUsageDescription</key>
<string>연락처를 쓰겠습니다.</string>
```

```jsx
import ContactList, { Contact } from "react-native-contact-list";

// ...

function App() {
    const [contactList, setContactList] = React.useState<Contact[]>([]);
    const getContactList = async () => {
        try {
        const isPermissionAuthorized = await ContactList.checkPermission();
        if (isPermissionAuthorized === 'authorized') {
            setContactList(await ContactList.getContactList());
        } else {
            const permissionResult = await ContactList.requestPermission();
            if (permissionResult === 'authorized') {
            setContactList(await ContactList.getContactList());
            } else {
            // todo: PERMISSION DENIED EXCEPTION
            console.log('todo: PERMISSION DENIED EXCEPTION');
            }
        }
        } catch (e) {
        console.error();
        }
    };
    ...
    render() {
        ...
    }
}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
