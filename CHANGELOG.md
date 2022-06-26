# v0.3.8 - [2022-06-27]
#### Found a bug? Report it! - Bug Bounty
- If you find a bug, report it on the discord server in #bug-report for a Ӿ5 reward (min) up to Ӿ100 depending on the severity of the bug
- To be elligible for the reward:
  - Must be reproducible / and or show the bug in some form (i.e. a screenshot or video recording)
  - The bug must not have already been reported before, or be directly related to an already reported bug
  - Bugs resulting from server outages and known bugs (things in the #todo channel) are not eligible
#### Added
#### Changed
- Backend hardware was migrated for better performance and reliability
#### Fixed
- Minor bugs related to the alerts system
- Nano <-> local currency price display bug
- Accounts sheet rendering fixes
## v0.3.7 - [2022-06-24]
#### Added
- Updated non-english translations with automatic translations
  - I'm sure the automatic translations aren't the best, but if you spot an error feel free to join the discord and send a translation submission, Or if you'd like to contribute to the project we have it setup so we can easily add translators (through localizely) so you can translate things as they're added
  - Over time the translations will be updated to be more accurate and future updates will contain at least machine translations
- Loading animation for when you reset the database
- Reliably display "~" when a transaction involves precision we can't fit on screen (too small)
- Sheet handles on the accounts sheet
- [WIP] - Contacts permission handling for an upcoming feature involving the ability to send nano to phone contacts
- Behind the scenes: working on integration tests to automatically test the UI/UX as well as take screenshots of the UI for the app stores
#### Changed
- Refactored account sheet to use the newer class
- Destroy the database -> Reset the database
#### Fixed
- Rounding bugs (PLEASE REPORT IF YOU NOTICE ANY)
- Contacts not saving properly
- bugs with Nyano mode, as well as the "max" send button
## v0.3.6 - [2022-06-21]
#### Fixed
- Bug with rendering usernames
- Usernames not displaying properly throughout the app
- Bugs related to contacts
- Lots of null safety bugs
## v0.3.5 - [2022-06-18]
#### Changed
- Visual updates to the home screen demo cards
- Cap drawer width to 500px (to make the view on tablets look nicer)
#### Fixed
- Bug with messages and search
- Couple of bugs with the receive QR code / reading QR codes
- Bug with the require auth on launch option
## v0.3.4 - [2022-06-15]
#### Added
- Node local_timestamps are now displayed in the transaction history
  - These aren't guaranteed to be accurate, but in most cases they will be fairly close
- Completely custom draggable scrollbar, optimized to not get in the way but still be easy to use
  - Now also visible in the settings drawer
- Info button on the send sheet
#### Changed
- Upgraded a *ton* of dependencies
- Null safety support! This improves overall security of the application and makes crashes less likely
  - The migration may have broken some things I didn't quite catch, so if you notice any issues please report them
#### Fixed
- On the gift card creation screen the amount field's next input button wasn't working properly
- Receive sheet minor visual fixes
- Minor state management bugs

## v0.3.3 - [2022-06-12]
#### Added
- Scrollbar to make it easier to go through the transaction history
- Testing out some new animations, likely will change again
- Converted E2EE from javascript to dart for a performance boost, (JS engine no longer needed!)
#### Changed
- Improved how animations are handled to not lag / be more consistent
- Total account balance is now shown on the accounts page
- Removed several ancient dependencies
- Info icon buttons to help explain things around the app
  - Receive minimum setting
  - Blocked users page
  - Currency mode setting
  - Block explorer setting 
- Min Raw receive setting now displays options based on whatever currency mode you're in
#### Fixed
- Nyano currency mode was not saving correctly
- Deleting a payment request from the slide action didn't update until after a pull-down refresh
- Bio auth message contained the wrong text for sends in some cases

## v0.3.2 - [2022-06-07]
#### Changed
- Accounts sheet colors swapped to match the home page slide buttons
#### Fixed
- Fixed rendering bug causing the home page to re-render unnecessarily
- Accounts sheet visual bug when deleting a row / editing an account name
- unpaid / paid transaction state tags were not being properly set
- bug related to upgrading from a previous version

## v0.3.1 - [2022-06-06]

#### Added
- Change Log (You're reading it!)
  - You can view this any time by clicking the "Change Log" button at the bottom of the settings drawer
- Send E2EE messages without sending an amount or request, no transaction required
  - Reply button added to messages via the drawer
- Support for ENS Domains
- Support for Unstoppable Domains
- Reminder to Rate the App after some time (dismissable)
- Button to change rep to the Nautilus Node
- Node status page in the settings drawer
- "not sent" transaction status tag for failed messages
- Button to destroy the internal db (useful to simulate a fresh install)
  - This will delete all requests, messages, and preferences
  - This will not delete your private seed
- Ported some outdated libraries for compatibility with flutter 3.0
- Favorites and Blocked users show known "Aliases" for the user's address on the details page for the user

#### Changed
- Change text for clarity
  - Requested -> Asked
  - unfulfilled / fulfilled -> paid / unpaid
- Many minor things had to be re-factored or tweaked visually to make Favorites, Blocked, and the send sheet support ENS/Unstoppable domains
- Complete overhaul of Favorites and Blocking of users
- Added text to the slidable account drawers
- Added handlebars so that people know that they're slidable
- drawerEdgeDragWidth: 200 -> 180 (to make it slightly easier to drag list items without opening the drawer)
#### Fixed
- Minor visual issues

## v0.3.0 - [2022-05-30]

#### Added
- Search by Request, Address, Username, Memo, and more
- Discord link in the settings drawer
  - https://chat.perish.co
- Added support for nano.community block explorer
#### Changed
- Moved Nyano Theme / mode to its own setting (Currency Mode)
- Made nano.community the default block explorer

## v0.2.X - [22-01 - 22-05]

#### Added
- Payment Requests with E2E Encrypted Memos
- End to End Encrypted Memos
- Digital Gift Card creation with a custom message
- Customize the QR code on the Receive Sheet
- Purchase NANO from within the app
  - Onramper, Simplex
- Randomize default Representative
- Ability to block a user by address / username
- Nyano Mode
  - Displays balances in nyano instead of NANO
#### Changed
- Contacts -> Favorites

## TODO:
- create a txdata for gift card open
- check for duplicate memos and remove them (just in case)
- make a UI for preferred username / display name in the case that there are multiple users with the same address
- update the welcome screen / example transactions and requests
- NFC support
- take new screenshots for the app / play store