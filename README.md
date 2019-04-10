# Team Northwoods Sample Code

This project is for the code kata found at this link:
https://stefanroock.wordpress.com/2011/03/04/red-pencil-code-kata/

The solution for this kata will be written in Ruby and tested with RSpec

I have translated the kata requirements into what I think is a more logical flow although I am open to change


## RedPencilService

### Assumptions:

- There is an independent data source of all price history changes for each item that wants to be checked by this service
- This source atleast has a unique item id, item price, and date when the price was set
- This service has access to this source and can base its decisions off of it
- This service has access to its own repository to keep track of current RedPencil deals going on, and when to expire those deals
- This RedPencil entity atleast has id, item price, date started, and date expired
- The consumer of this service will receive a boolean of true or false if has a RedPencil currently applicable for an item
- This service is pessimistic, it assumes there is no RedPencil(returns false) unless the conditions are met

### Eligibility Logic:

The validator needs three things to be successful in validation: 
  1) The latest item history for an item
  2) The previous item history for that item
  3) a potential existing red pencil entry, the latest one for the item id

These three things are fed in with initialization. Then the logic tree to decide eligibility can begin

  - Can it potentially add a Red Pencil? It checks by seeing if there are no red pencils for the item OR 30 days has passed since the last red pencil expired
    - Assuming it passes this check it, it can check the red of the addition conditions. It will NOT add if:
      - Does not have both price histories
      - The item ids between the entries are not equal
      - If there is less than 30 days between the two item histories(price has not been stable for 30 days)
      - If the price difference between the two item histories is not reduced in the range of 5 to 30 percent(price change qualifies)
    - If it got past these checks, then it can add. It will add it to the repository for further queries and return true
      - It stores the item id for the item, the price of the previous history item(for further evaluation for expiration based on price), and the latest item history's entry date as its own entry date
  - If it cannot add a red pencil, we should check if there is a current red pencil that needs expired. Does the Red Pencil Exist and is it not expired?
    - Assuming it passes this check, we need to see if it falls within the expiration conditions. It WILL expire and return false if:
      - The entry date for the Red Pencil is more than 30 days old. Set the expiration date 30 days from the entry date(maximum red pencil duration)
      - The latest price has reduced from the Red Pencil price by more than 30%. Since this was set from the previous item history, we can keep track if it breaks the 30% mark with each new item price history
      - The latest price has increased at all
      - If either of these price changes expire it set the expiration date as the current date time(expires immediately)
  - If neither of the previous conditions hit, we need to just check the potential existing Red Pencil entry. Does the Red Pencil exist? Does it have an expiration date?
    - Assuming this check is passed, we simply return true.
  - If none of these hit, we hit an uncovered scenario by the requirements and therefore it is false
     

### Installation and Running:

Run 'gem install bundler'
Run 'bundler install'
Run 'rspec' to run through all unit tests
Run 'ruby rest.rb' to start up the sinatra endpoint. You can use the attached Postman collection to test

For the rest endpoint, I have prepopulated the item entries with some data, but red pencils are empty.

Each entry id and item id is randomly generated, so everytime you run the sinatra server the data will be different for these

To get a quick sample working, get all the item histories, grab the item_id off the first history, and add a new entry that meets the price and date requirements

Then use that same item_id to run the Red Pencil Eligibility. It should return true if it was done right and you can see the entries with the all red pencils calls and the by item id call


The tests and code should be configurable with the red_pencil.yaml in configurables

Any questions please feel free to contact me at ldieter@gmail.com