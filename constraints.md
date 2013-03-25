Mobile Notes 
===================
Goal: Take note the most quickly possible.

# Functionalities

- Record notes, upload pictures and audio, or save a numerical value (distance, weight, ...) in any channel/folder and in a very easy way.
- Have a shortcuts to the latest used event-type & folders to save an event more quickly.
- Browse through channels/folders and view the events and eventually edit them.


# Constraints

## Use Pryv API

see [http://dev.pryv.com](http://dev.pryv.com)


## Platform support

The app must support iOS 4.3+ (to be discussed). Target is iPhone-only but developped as _Universal_ (iPad & iPhone). 
This does mean that there is no need to have a different layout for the iPad but it musn't be an iPhone only app that scales with the (2x) button. This is to be sure both viewPorts are considered from start.


## Offline support

TODO: determine the extent of offline support:

- Full, i.e. the app keeps a local copy of the entire data set, syncing with the server when connection is available
- Limited, i.e. the app can run when no connection is available, but will be limited to data previously loaded; it will keep track of changes made while offline and sync them when connection is restored.


## Multiple languages

The user interface must be globalized (i.e. support multiple languages). 
(For information, the initial release is planned to be localized into: English and French)
French translations will be done by Pryv Team.


## Code reuse

- Code must be properly componentized so that common functionality (at least basic interaction with the API) is written as a reusable library into an separate independant git submodule.
- Use Core Data ?

# Design infos

## Start Screen:

### Header
- A button to browse the Folders

### Split1: Shows the X(4?) lasts used folders.
Folders are displayed with the channel Icon, their name, and as many caracters possible of their path.

 - A touch on the object brings to **Add an event** to this Folder.
 - A touch on the *arrow icon* (next) make the user browse tho this folder

### Split2: Shows a list of the last events.
(Should be live with socket I/O.) next step  
The list is scrollable down to the first event with pagination reloading.
An event line displays the date and time of the event. The channel/folder it belongs to. First chars of it's comment. It's type as an icon or the picture if it's a picture.

 - A touch on the object brings to **Add an event** in edit mode of this event.

# Browse Screen
### Find a place for
- A home button
- Maybe this page can host edit mode and management of folders

### Header
- The path we are in (at least the last element)
	- touch it to go back	

### Shows the folders.
Folders are displayed with their icon (if any) and their name
 - A touch on the object brings to **Add an event** to this Folder.
 - A touch on the *arrow icon* (next) make the user browse tho this folder

### Shows a list of the events within this folder and subfolders.
Should be live with socket I/O. 
The list is scrollable down to the first event with pagination reloading.
An event line displays the date and time of the event. 
If the events belongs to as subfolder it should the subpath is displayed. First chars of it's comment. It's type as an icon or the picture if it's a picture.

 - A touch on the object  brings to **Add an event** in edit mode of this event.
