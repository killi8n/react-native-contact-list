import { NativeModules } from 'react-native';

export interface Contact {
  displayName: string;
  givenName?: string;
  familyName?: string;
  phoneNumber: string;
  thumbnailPath?: string;
}

type ContactListType = {
  checkPermission: () => Promise<'authorized' | 'denied'>;
  requestPermission: () => Promise<'authorized' | 'denied'>;
  getContactList: () => Promise<Contact[]>;
};

const { ContactList } = NativeModules;

export default ContactList as ContactListType;
