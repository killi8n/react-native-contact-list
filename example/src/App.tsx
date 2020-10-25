import * as React from 'react';
import {
  StyleSheet,
  View,
  Image,
  Button,
  FlatList,
  Text,
  SafeAreaView,
} from 'react-native';
import ContactList, { Contact } from 'react-native-contact-list';

export default function App() {
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
  return (
    <SafeAreaView style={styles.container}>
      <Button title="Get Contact List" onPress={getContactList} />
      <FlatList
        data={contactList}
        keyExtractor={(item, index) => `${item.phoneNumber}-${index}`}
        renderItem={({ item }) => {
          return (
            <View style={styles.item}>
              <Image
                style={styles.thumbnailImage}
                source={{
                  uri: item.thumbnailPath ? item.thumbnailPath : '',
                }}
              />
              <View style={styles.textWrapper}>
                <Text style={styles.displayName}>{item.displayName}</Text>
                <Text>{item.phoneNumber}</Text>
              </View>
            </View>
          );
        }}
        ItemSeparatorComponent={() => <View style={styles.seperator} />}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  item: { flexDirection: 'row', alignItems: 'center' },
  thumbnailImage: {
    width: 50,
    height: 50,
    borderRadius: 50 / 2,
    borderWidth: 1,
    borderColor: '#000000',
  },
  textWrapper: { marginLeft: 10 },
  displayName: { fontWeight: 'bold' },
  seperator: { height: 15 },
});
