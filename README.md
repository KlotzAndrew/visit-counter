# VisitCounter

Automatically track and report visits to your apps urls. VisitCounter is
middleware, so it will work with any rack-base web server

VisitCounter tracks visits to exact urls, and urls matched by regex

## Installation

`gem 'visit_counter'`

```shell
# run setup migration
db_migrate postgresql://postgres:@0.0.0.0:5432
```

```ruby
# config/initializers/visit_counter.rb
VisitCounter.configure do |config|
  config.db_url    = 'postgresql://postgres:@0.0.0.0:5432'
  config.exact_url = '/puppies'
  config.regex_url = /^\/pup.*/
end

# config.ru
use VisitCounter::Middleware
```

## Usage

```shell
# request to url gets tracked as a visit
curl -X GET http://0.0.0.0:9292/puppies

# view visit reports in json
curl -X GET \
  http://0.0.0.0:9292/visit_counter_results \
  -H 'authorization: Basic YWJjOmRlZg=='

# view visit reports in csv
curl -X GET \
  http://0.0.0.0:9292/visit_counter_results/csv \
  -H 'authorization: Basic YWJjOmRlZg=='

# runtime configuration
curl -X POST \
  http://0.0.0.0:9292/visit_counter_results/configure \
  -H 'authorization: Basic YWJjOmRlZg==' \
  -d '{ "exact_url=": "/good" }'
```
