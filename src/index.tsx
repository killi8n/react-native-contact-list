import { NativeModules } from 'react-native';

type ContactListType = {
  multiply(a: number, b: number): Promise<number>;
};

const { ContactList } = NativeModules;

export default ContactList as ContactListType;
