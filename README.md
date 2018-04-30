# DEVELOPMENT

## To run this locally, you should do the following:

### Install Postgres:

If you're on a Mac, download the Postgres App here: http://postgresapp.com/ If you're on Windows or Linux, you're on your own. Haven't had much experience with that, but should be pretty straight forward. Just make sure you have a Postgres server running at localhost:5432 (the default I believe)

### Install Rails

Again, if you're on a Mac, run gem install Rails. Linux should be similar. Window, no idea :)

### Bundle Install

I personally use [RVM](https://rvm.io/) for my Rails dependency management and have the repo set up for that, but feel free to use whatever you want. All in all, just run `gem install bundler` and then `bundle install` from within the repo.

### Create the DB

`rake db:create`

`rake db:migrate`

### Import data

`rake db:seed`

`rake db:import_districts`

`rake db:import_statistics` (this will take a while...368,022 data points in about 56 mins for me...see branch jp/stat-import-multithread if you want to help me fix my multithreaded approach...I got it down to 6 minutes, but it sometimes missed a row due to DB pool restrictions...best of luck :D )

### Start the server

`rails s` (the default port is 3000, but if you want to change that, you can run `rails s -p #{whatever_port}`)

### View the site

Visit localhost:3000

### Play with the API

I'm not currently pulling data from the API, but if you're curious, check out [Postman](https://app.getpostman.com/app/download/osx64) to see the potential response.

For now, I wanted to return pure GeoJSON for the districts. Endpoints are as follows:

Districts/geometries can be fetched as such:

GET `http://localhost:3000/api/v1/districts`

Statistics can be fetched like so:

GET `http://localhost:3000/api/v1/statistics`

Params: `{ statistics: { ethnicity_name: String, year: String, action_type: String } }`

ethnicity_name: per Matt's CSV, could be any of the following: `[ 'SPE', 'ECO', 'HIS', 'BLA', 'WHI', 'IND', 'ASI', 'PCI', 'TWO', 'ALL' ]`

action_type: also per CSV, could be any of the following: `[ 'EXP', 'DAE', 'ISS', 'OSS' ]`

year: `2006` - `2016`

### If you want to help

Feel free to create an issue if you run into any weirdness and I'll take a look.

From here, I will start focusing on the front end map implementation. Currently, we load the entire district geometry every time we select a new parameter. Ideally, I love to just load the districts once, on page load, and update it each time a new parameter is selected.

I created some indices, but it's not optimized completely. Currently, there are 368,022 statistics (data points based on year, ethnicity, and discipinary action), and statistic queries take an average of 5 seconds, which is not ideals, but better than any alternative that I can think of. If you have ideas, please let me know.

Thanks!
