# Extractor
 A Ruby Gem to extract data from apis with mininal configuration
## Installation
 Add this to your Gemfile:
 ```ruby
gem "extractor", github: "felipedmesquita/extractor"
 ```
Create the requests model:
```bash
rails generate extractor:requests
rails db:migrate
```
To get newer changes from the main branch run `bundle update extractor`

## Usage
Create a tap:
```bash
rails generate extractor:tap example
# => create  app/extractors/example_tap.rb
# => create  app/sql/example.sql
```
Taps inherit the initilizer and perform methods from Extractor::Tap. To run our example tap, we can simply call:
```ruby
ExampleTap.new.perform
```
This will download all posts from jsonplaceholder as requests.
To clean up and analize the response contents, check out [dbt](https://github.com/felipedmesquita/dbt)

## How it works
The perform method takes no arguments and just runs until reached_end? returns true for any response received.
