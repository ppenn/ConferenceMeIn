conferencemein
==============

An IOS 6 Objective C app to one-touch dial into conferences in a user's calendar.
Application was in the Appstore at https://itunes.apple.com/us/app/conference-me-in/id510881378?mt=8.

### Design
A simple UI provides a conference view of a user's calendar. Tapping a conference will dial into the conference.
The core of the project is a set of Regex statements to parse calendar entries for phone numbers and accompanying passcodes. These are converted into phone URLs to open.

### Unit Tests
A set of tests exists to verify that each conference type e.g. ATT, WEBEX etc can be successfully parsed. In this way, you can modify the Regex and be sure that the program will continue to recognize each conference type.