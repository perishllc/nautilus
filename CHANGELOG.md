# v0.3.3 - [2022-06-10]
#### Added
- Testing out some new animations, likely will change again
#### Changed
- Improved how animations are handled to not lag / be more consistent
- Total account balance is now shown on the accounts page
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
- work on null safety ports of dependencies
- port E2EE to dart
- see how hard it will be to add windows store / desktop support
- update the welcome screen / example transactions and requests
- NFC support
- take new screenshots