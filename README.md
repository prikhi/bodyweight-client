# Bodyweight Client

[![Build Status](https://travis-ci.org/prikhi/bodyweight-client.svg?branch=master)](https://travis-ci.org/prikhi/bodyweight-client)

A Bodyweight Workout Log frontend written in Elm.

Right now only the following is supported:

* Creating an Account
* Viewing Routines & individual Exercises
* Registered Users can Create/Edit/Delete their Routines
* Admins can Create/Edit/Delete Exercises


Eventually we will support:

* Logging Workouts
* Subscribing to Routines
* Exporting Routines & Log Entries (Markdown, CSV)
* Reports & Graphs


The API server lives in a [separate
repository](https://github.com/prikhi/bodyweight-server), but the two repos
will probably be merged at some point.

# Setup

```
npm i
npm run dev
open http://localhost:7000
```

# Tests

```
npm run test-watch
```

# TODO

This is a mix of client & server stuffs... We should probably consolidate the
client & server repositories since they are tightly integrated.

* Add Screenshot to README
* Refactor backend URLs into `Endpoint` type
* Refactor view/model folders into folders by datatype(`routines/model`)
* Refactor API Command Messages into separate Message Type & Update Function
* Refactor model data into Dicts
* Reduce server queries(only load necessary sections, exercises, etc.)
* Fix 404 flash on initial load
* Add Exercise Form
    * Non-admin users can suggest new exercises or changes to exercises
    * Radio buttons for Reps/Holds instead of checkbox
        * Switch backend from bool to union type
    * Strip URL from Youtube/Amazon ID fields
    * Error messages!
* Add Routine Form
    * Refactor RoutineChange Messages into separate updateRoutineForm func/msg
    * Autocomplete Exercise Selects
    * Disable Save/Reset if no changes(for routines, sections, & exercises)
    * Default reps/hold time/reps to progress per section & routine
    * Add Up/Down Arrows for Exercise Progressions?
    * Error messages!
* Table/Cards toggle for Exercise page(embed yt vids as card thumbnails?)
* Add Routine Logging Forms
    * Log an already completed workout
    * Log a workout as you complete it
    * Export all logs to Excel & CSV
    * Export single log to Markdown
* Routines
    * Export to CSV & Markdown
    * Multiple Editors
* Users
    * Login/logout of all open tabs(watch for `window.storage` event)
    * Profiles & profile pages
        * Name
        * Subscribed routines
        * Created routines
        * Logged workouts
        * Reddit/twitter/facebook username
    * Routines owned by Users(add author to Routines table)
    * Only routine owners can edit/delete their routines
    * Admin Users allowed to add/edit/delete exercises
    * Page for admin users to see exercises w/o YouTube or Amazon links
    * Only a user can see their private routines
    * User can subscribe to a routine(Add subscriber count to Routines table)
    * Email field & lost password functionality
* Homepage
    * Short description of BWF
    * For anonymous users, benefits of registering(add/sub/log routines)
    * Links to subreddit
    * Links to a User's subscribed routines & logging form for those routines
* Sharing private routines w/ users
    * Password-protected
    * Subscribe Link
    * ?Share w/ specific users?
* Routine Feedback
    * Allow users to comment on routines
    * Versioning of routines, with list of changes between each version

* Data Validation
    * Routines
        * To Progress must be greater than Reps/Hold Time
        * Exercises in a single progression cannot be repeated
        * Sections must have at least 1 SectionExercise
        * Sets/Reps/Time/Progress cannot be 0
        * SectionExercises must have at least one Exercise
        * Section names cannot be blank
        * Routine names cannot be blank
    * Exercises
        * Has name
        * Valid Youtube/Amazon IDs

# License

GPL-3.0
