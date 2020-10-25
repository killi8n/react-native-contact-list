package com.reactnativecontactlist

import android.Manifest
import android.content.pm.PackageManager
import android.provider.ContactsContract
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener


class ContactListModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), PermissionListener {
    var requestPromise: Promise? = null

    companion object {
      const val READ_CONTACTS_REQUEST_CODE: Int = 100
      const val READ_CONTACTS_PERMISSION: String = Manifest.permission.READ_CONTACTS
    }


    override fun getName(): String {
        return "ContactList"
    }

    private fun isPermissionGranted(): String {
      val res = reactApplicationContext.checkCallingOrSelfPermission(READ_CONTACTS_PERMISSION)
      return if (res == PackageManager.PERMISSION_GRANTED) {
        "authorized"
      } else {
        "denied"
      }
    }

    private fun parseContactList(): WritableNativeArray {
      val uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
      val cursor = reactApplicationContext.contentResolver.query(
        uri,
        arrayOf(ContactsContract.Contacts._ID,
          ContactsContract.Contacts.PHOTO_ID,
          ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
          ContactsContract.CommonDataKinds.Phone.NUMBER,
          ContactsContract.CommonDataKinds.Contactables.PHOTO_URI),
        null,
        null,
        null)
      val contactList: WritableNativeArray = WritableNativeArray()
      if (cursor != null && cursor.moveToFirst()) {
        do {
          val contact = Arguments.createMap()
          contact.putString("displayName", cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)))
          contact.putString("phoneNumber", cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)))
          contact.putString("thumbnailPath", cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Contactables.PHOTO_URI)))
          contactList.pushMap(contact)
        } while (cursor.moveToNext())
      }
      return contactList
    }

    @ReactMethod
    fun getContactList(promise: Promise) {
      promise.resolve(this.parseContactList())
    }

    @ReactMethod
    fun checkPermission(promise: Promise) {
      promise.resolve(this.isPermissionGranted())
    }

    @ReactMethod
    fun requestPermission(promise: Promise) {
      currentActivity.let { it
        if (it == null) {
          promise.resolve("denied")
        } else {
          this.requestPromise = promise
          val activity: PermissionAwareActivity = currentActivity as PermissionAwareActivity
          activity.requestPermissions(arrayOf(Manifest.permission.READ_CONTACTS), READ_CONTACTS_REQUEST_CODE, this)
        }
      }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
      if (requestCode == READ_CONTACTS_REQUEST_CODE && grantResults != null) {
        this.requestPromise.let { it
          val isGranted: Boolean = grantResults[0] == PackageManager.PERMISSION_GRANTED
          if (isGranted) {
            it?.resolve("authorized")
          } else {
            it?.resolve("denied")
          }
        }
      } else {
        this.requestPromise.let { it
          it?.resolve("denied")
        }
      }
      return true
    }
}
