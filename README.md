# Team Northwoods Sample Code

This project is for the code kata found at this link:
https://stefanroock.wordpress.com/2011/03/04/red-pencil-code-kata/

The solution for this kata will be written in Ruby and tested with RSpec

I have translated the kata requirements into what I think is a more logical flow although I am open to change


## RedPencilService

Assumptions:

- There is an independent data source of all price history changes for each item that wants to be checked by this service
- This source atleast has a unique item id, item price, and date when the price was set
- This service has access to this source and can base its decisions off of it
- This service has access to its own repository to keep track of current RedPencil deals going on, and when to expire those deals
- This RedPencil entity atleast has id, item price, date started, and date expired
- The consumer of this service will receive a boolean of true or false if has a RedPencil currently applicable for an item
- This service is pessimistic, it assumes there is no RedPencil(returns false) unless the conditions are met


Installation:

Run 'gem install bundler'
Run 'bundler install'
Run 'rspec' to run through all unit tests