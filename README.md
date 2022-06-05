Essential App Case Study
========================

Image Feed Feature Specs
-------------------------------------------------------

#Narrative #1

As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends

##Scenarios (Acceptance criteria)

Given the customer has connectivity
When the customer requests to see their feed
Then the app should display the latest feed from remote
And replace the cache with the new feed

#Narrative #2

As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends

##Scenarios (Acceptance criteria)

Given the customer doesn't have connectivity
And there’s a cached version of the feed
And the cache is less than seven days old
When the customer requests to see the feed
Then the app should display the latest feed saved

Given the customer doesn't have connectivity
And there’s a cached version of the feed
And the cache is seven days old or more
When the customer requests to see the feed
Then the app should display an error message

Given the customer doesn't have connectivity
And the cache is empty
When the customer requests to see the feed
Then the app should display an error message

## Use cases

### Load Feed from remote use case

#### Data:
- URL

#### Primary course (Happy path):
Execute "Load Image Feed" command with above data.
System downloads data from the URL.
System validates downloaded data.
System creates image feed from valid data.
System delivers image feed.

#### Invalid data – error course (sad path):
System delivers invalid data error.

#### No connectivity – error course (sad path):
System delivers connectivity error.


### Load Feed Image Data From Remote Use Case

#### Data:
-URL
#### Primary course (happy path):

Execute "Load Image Data" command with above data.
System downloads data from the URL.
System validates downloaded data.
System delivers image data.

#### Cancel course:
System does not deliver image data nor error.

#### Invalid data – error course (sad path):
System delivers invalid data error.

#### No connectivity – error course (sad path):
System delivers connectivity error.
