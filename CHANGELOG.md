## v0.5.2 - [2022-08-XX]
#### Added
#### Changed
#### Fixed
- Fixes on the send screen with local currencies and requests
## v0.5.1 - [2022-07-31]
#### Changed
- Update the character limit on memos / messages to 255 characters
- Memos / Messages now scroll if too long to display
- Move unopened send warning to the confirmation page, and only warn on sends instead of requests or messages
- Renamed "View Details" button to "View Transaction"
#### Fixed
- Fixes for handling ACK'd memos
- Significant performance improvements for sheets that display QR codes (previously drawing each frame, now cached)
- Minor styling changes on tx details page
## v0.5.0 - [2022-07-30]
#### Added
- New logo!
- Show QR button on the backup seed screen
- Warning when sending to an unopened account
#### Changed
- Re-worked how split gift cards work on the backend
#### Fixed
- Fixed some minor bugs with the new account screen
- Fixes to how the search bar works
## v0.4.9 - [2022-07-27]
#### Fixed
- Local currency fixes
## v0.4.8 - [2022-07-26]
#### Added
- Split Gift Cards, still unstable but only backend work left to do
#### Changed
- Minor UI tweaks to gift cards
## v0.4.7 - [2022-07-25]
#### Added
- The ability to show a QR code with a gift link on the completion page and gift details menu
- WIP: The ability to split Gift Cards so that they can be dispensed to multiple people
#### Changed
- Re-worked the gift card completion screen
#### Fixed
- Re-enabled insufficent balance check on the send screen
- Fixes for gift card creation
- Fixed QR code scanning raw address
## v0.4.6 - [2022-07-24]
#### Fixed
- Fixed loading animation when switching between accounts
## v0.4.5 - [2022-07-23]
#### Added
- Watch only addresses
- Ability to import contacts from both natrium and nault
- Localized currency displays
#### Changed
- Use a better short form of account address on the accounts screen
#### Fixed
- Ensure the local currency symbol always shows in local currency mode (i.e. on the send screen)
- Sped up receive screen QR code screen by pre-caching the QR image on load
- Accounts sheet was not reliably showing usernames / aliases
## v0.4.4 - [2022-07-17]
#### Changed
- Default tx viewer reverted back to nanolooker
#### Fixed
- All tx's were showing as receives lol
- Send sheet showing currency symbols incorrectly in local currency mode
- Donation contact (NautilusDonations) wasn't being added on a fresh install
- Bug with pay this request button in nyano mode
## v0.4.3 - [2022-07-16]
#### Added
- Sheet handle on the more details section of transactions
#### Changed
- Sheet handles consistency
- Funding Structure Changes for the iOS App Store
#### Fixed
- Bug with QR code scanning when done through the swipe up action on the send button
- Tablet mode was not working properly
- More QR code scanning bugs
## v0.4.2 - [2022-07-15]
#### Added
- New monochrome theme!
- Plausible Deniability Mode!
  - Setup a secondary pin which when entered will trigger Plausible Deniability Mode
  - Plausible Deniability Mode is identical to the normal mode except that when triggered, your seed is wiped and replaced with a hash of your seed
  - This is security feature designed to give you a plausible excuse in the event that you're forced to open your wallet
  - The seed hash is deterministic (i.e. the same every time, so you can load it with a "plausible" balance)
  - Entering plausible deniability mode is NOT reversible without logging out and logging back in, so be sure to backup your seed before trying it out in the security menu
#### Changed
- Updated QR Code Receive screen to look much cleaner
#### Fixed
- Delete slide action was the wrong color on some themes
- Bug regression with the search bar (change blocks)
- QR Code scanning fixes
- Share address button on the receive screen was not working
## v0.4.1 - [2022-07-11]
#### Added
- New intro page animation!
- Tablet mode! The settings drawer is now permanently open devices that are wide enough to display it
#### Changed
- Updates to the gift card completion screen, to make it clearer that the message section is editable
- Max drawer size is even smaller now for tablets -> 300px
- changed scroll physics back to what they were before (on android only, in the main list view)
#### Fixed
- Rendering bug on the accounts sheet page displaying currency symbols before loading balance
- Changing rep to your current rep caused infinite loading animation
- Funding page would've broken if someone donated past 100% on any of the goals lmao
- Additional safeguards to prevent giftcards from being "lost"
  - Now, if gift card creation fails in any way, either the funds won't be sent, or the gift card link will be copied to your clipboard
- Rendering of transaction tags were incorrectly displayed in some states
## v0.4.0 - [2022-07-06]
#### Added
- Ability to resend messages on message failure
#### Changed
- Max drawer size is even smaller now for tablets -> 325px
- Swap send and receive colors to be more consistent
#### Fixed
- A bunch of bugs related to payment requests / message deleting created in the last release by mistake
- Fixes for handling memos / messages in the background
- Scrollbar de-sync issues (mostly on iOS)
## v0.3.9 - [2022-07-02]
#### Added
- Support the project banner added (don't worry, you can hide it)
  - Breakdown of different funding goals
  - Donations are sent to different addresses for easy tracking of what people want to support
  - Funding Goals are just estimates at best and don't comee with any gaurantees, but I'll try my best to meet them
  - Different funding goals will be shown as they're funded / met, and the descriptions and amounts will get updated with dev progress as well
- Option to hide the support banner
#### Changed
- changed import / export contact icons to be more clear which is which
- improvements to background message handling
#### Fixed
- lots of minor bugs, nyano display bugs, more contacts issues
- bugs with gift cards
- contacts should stay saved now, (were getting removed after a day)
- importing and exporting of contacts, so even if they break again in the future, you can restore them
- mark as paid button not updating the state until after refresh
- reps list not showing up in the change rep screen
## v0.3.8 - [2022-06-27]
#### Found a bug? Report it! - Bug Bounty
- If you find a bug, report it on the discord server in #bug-report for a ??5 reward (min) up to ??100 depending on the severity of the bug
- To be elligible for the reward:
  - Must be reproducible / and or show the bug in some form (i.e. a screenshot or video recording)
  - The bug must not have already been reported before, or be directly related to an already reported bug
  - Bugs resulting from server outages and known bugs (things in the #todo channel) are not eligible
  - Minor visual inconsistencies are not elligible depending on the case
#### Added
- Ability to quickly create gift cards and customize them by sending without an address specified
  - After a gift card is created you can edit and copy the message to your clipboard right from within the app
#### Changed
- Backend hardware was migrated for better performance and reliability
- More consistent UI/colors for tx details (when you tap on a tx, the menu that pops up)
- Better handling of contacts / permissions, but still a WIP / texts feature not done
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
  - These aren't guaranteed to be accurate, but in most cases they'll be fairly close
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