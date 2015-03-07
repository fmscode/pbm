[![Build Status](https://travis-ci.org/scottwainstock/pbm.svg?branch=master)](https://travis-ci.org/scottwainstock/pbm)
[![Coverage Status](https://coveralls.io/repos/scottwainstock/pbm/badge.png)](https://coveralls.io/r/scottwainstock/pbm)

*sweet pinballin' brah*

##API Documentation

Available here: [http://pinballmap.com/api/v1/docs](http://pinballmap.com/api/v1/docs)

##Mac Enviroment Setup
Below is a summary of the steps that [Brian Hanifin](https://github.com/brianhanifin) undertook to get the site up and running on OS X 10.9 or 10.10. If you would like to contribute, and have any trouble, please ask.

* Follow the Ruby install instructions at [railsapps.github.io/installrubyonrails-mac.html](http://railsapps.github.io/installrubyonrails-mac.html). Make sure you also download ruby-2.1.2 by using the `rvm install ruby-2.1.2`
* `cd /Projects-Path/`
* `git clone https://github.com/scottwainstock/pbm.git` (*I used the SourceTree app instead.*)
* `cd /Projects-Path/pbm`
 * Depending on which ruby version you have installed you may need to use `rvm --default use ruby-2.1.2`
* `bundle install`
 * This may fail at when trying to install the `pg` gem. To fix this run `brew install postgresql` and then run the `bundle install` again.
* `selenium install`
* `brew update && brew install phantomjs`
* Create config/database.yml with the following:

```
development:
    adapter: postgresql
    encoding: utf8
    database: pbm_dev
    template: template0
    host: localhost

test: &test
    adapter: postgresql
    encoding: utf8
    database: pbm_test
    template: template0

production:
    adapter: postgresql
    encoding: utf8
    database: pbm
    username: root
    password:
    template: template0

cucumber:
    <<: *test
```

* `brew install postgresql`
* `initdb /usr/local/var/postres -E utf8`
* Download [Postgres App](http://postgresapp.com/). (*I have mine run at startup on my "Dev" profile.*)
* `bundle exec rake db:create ; RAILS_ENV=test bundle exec rake db:create`
* `bundle exec rake db:migrate ; RAILS_ENV=test bundle exec rake db:migrate`
* `bundle exec rspec`
* `rake doc:app`  (*I think this generates documentation for the app, which sounds helpful for later.*)

* `curl get.pow.cx | sh`
* `cd ~/.pow`
* `ln -s /Projects-Path/pbm`
* Edit config.ru: change `run Pbm::Application` to `self.run Pbm::Application` (Workaround: so Pow can run the site.)
* `open http://pbm.dev`

If the site loads properly it will be an empty version of pinballmap.com, then ask Scott for a data dump so you can have a full set of data to work with.
