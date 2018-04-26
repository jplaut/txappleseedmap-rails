# DEVELOPMENT

## To run this locally, you should do the following:

### Install Postgres:

If you're on a Mac, download the Postgres App here: http://postgresapp.com/ If you're on Windows or Linus, you're on your own. Haven't had much experience with that, but should be pretty straight forward. Just make sure you have a Postgres server running at localhost:5432 (the default I believe)

### Install Rails

Again, if you're on a Mac, run gem install Rails. Linux should be similar. Window, no idea :)

### Bundle Install

I personally use [RVM](https://rvm.io/) for my Rails dependency management and have the repo set up for that, but feel free to use whatever you want. All in all, just run `gem install bundler` and then `bundle install` from within the repo.

### Create the DB

`rake db:create`

### Start the server

`rails s` (the default port is 3000, but if you want to change that, you can run `rails s -p #{whatever_port}`)

### View the site

Visit localhost:3000

### If you want to help

Feel free to create an issue if you run into any weirdness and I'll take a look.

From here, I want to create DB tables that correspond to the newest multi-year CSV, write an import script to upload that data to the DB, and create API endpoints to fetch that data from the client on dropdown change.
