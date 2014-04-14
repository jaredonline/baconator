# Baconator

The Baconator is a Rails app that covers three basic things:

  1. Parsing a set of JSON files that contain films and actors into a
     relational DB
  2. Scanning that database and building shortest path relationship from
     every actor to Kevin Bacon
  3. Allowing a user to query by actor name and see their Bacon Path

## Running

  * [Ruby version](#ruby-version)
  * [System dependencies](#system-dependencies)
  * [Configuration](#configuration)
  * [Database creation](#database-creation)
  * [Database initialization](#database-initialization)
  * [How to run the test suite](#how-to-run-the-test-suite)

### Ruby Version

The app was built using [Ruby](https://www.ruby-lang.org/en/) `2.1.0p0` and [Rails](http://rubyonrails.org/) `4.1.0`

### System dependencies

Other than ruby and Rails, you'll need a SQL based database. I used the
default Rails setup with [Sqlite](https://sqlite.org/) and a webserver
of some sort. I built it using [POW](http://pow.cx/)

