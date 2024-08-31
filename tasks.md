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

## Improvements

- make sure the email field is case insensitive for both clients and users.

## Pipeline

- account auth
- account profile management
- microsite rendering along with details
- jobs module (account can create the jobs and will be listed on the microsite)
