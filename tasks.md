## List of tasks to do

- find a tagline and a good name
- select the color theme.
- create a plug to expose the version and tagline and other info like author for all the pages.
- create a plug to check that the user is validated or not and use that for the auth scope
- get a basic idea of how does the brcypt work under the hood
- what are the other fields that we can include in the clients table to make it more better.
- how can we and add those constraint that the social media profiles are array of types. and remove the types that are not valid.
- why for the context, when the db operation fails, it returns a changeset. when db fails, it should include the reason why it is failing. then why the default code chooses to return a changeset.
  find the reasoning behind that.
- what does it mean by the changeset. what all is included in the changeset.
- what is the difference between the context and the module. and how do they intertwine.
- meaning of temporary assigns and it's use case.
- can handle_event func in the liveview be private?
- what is fixation attacks in the auth.
- what can be some good things to put into the client when the session is cleared.
- why do we need the refresh token in the auth flow.
- byte_size(password) > 0 what can this function be used for.
- what is the difference between the normal html files that are being rendered and the live_view files
  in the way they render.
- what is the flash data which can be accessed via Flash.get and when should we use this
- write test cases for common functions like url validation and other things.
- read more regarding assigns v/s temporary_assigns and when should we use what
- improve the logic to validate the year in the profile form
- suppose each request is pushed into its beam process then how does the GC work to collect the garbage.s
- how does the valdiations and changesets works with embedded schemas.
- when the pattern matching or something throws an error then what does happen? how does the gc handle that.
- how does the profiler work and we can check where the time is being taken in the app.
- change the text field in the social media handles for client profile to be the select dropdown.
- how can we make a utils library in which we will be making the common fnctions of validation and other things
- add the form for adding the manpower ranges and other things in the porfile for the client
- how do I add the validations for the array of list in the clients schema. like the social profiles have to the array of social profiles only
- add async assign for client microsite. it should be loaded lazily
- location needs to be meged here. like how can we embed the locations and educations so that we will be able to filter the list as per some parameters.
- skills will be a good target for introducing full text search and include the id of the skills. will allow the filtering.
- implement a hook to focus on first input element with error.

## Improvements

- make sure the email field is case insensitive for both clients and users.

## Pipeline

- account auth
- account profile management
- microsite rendering along with details
- jobs module (account can create the jobs and will be listed on the microsite)
- create a feature of inbox for the clients. so that they can see what updates they have got.
- jp can send an email to the client directly from the profile page
-
