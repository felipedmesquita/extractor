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
```
Taps have a perform method that can receive dates and arrays, but in the example file we just need basic 1,2,3 pagination, so we can simply call:
```ruby
  ExampleTap.new.perform
```
This will download all posts from jsonplaceholder as requests.
To clean up and analize the response contents, check out [dbt](https://github.com/felipedmesquita/dbt)
