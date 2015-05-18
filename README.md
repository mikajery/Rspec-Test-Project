Turing Email
==========

[![Build Status](https://semaphoreci.com/api/v1/projects/1b195c1b-21bc-46ec-9793-e25602ee45d5/381816/shields_badge.svg)](https://semaphoreci.com/turinginc/turing-email)

The primary technologies used to develop Turing email include:

* Ruby on Rails

* Backbone.js

* Ractive.js

* RSpec & Capybara

* AWS

## Authentication

The email client uses basic http authentication for the landing page and the mail page. The credentials for this are:

* username: turing

* password: email2

## Rails API Documentation

Documentation for the Rails API can be generated using:

rake swagger:docs

and then accessed locally at:

localhost:4000/swagger-ui/

## Front-end (Bower) dependencies

Bower is the main way to handle 3rd-party javascript dependencies on the
project. All dependency files are stored in the repository, so you don't need
to do anything unless you are adding/removing/updating some front-end
dependency.

However some dependencies are still handled in the old way (i.e. simply
copy-pasted to `vendor/javascripts` dir) for various reasons.

The right way to add a new front-end dependency:

1. If it is open-source and available in Bower (most cases), just add it to Bowerfile (don't forget to specify version) and then execute `rake bower:install` `rake bower:clean`
2. If it is open-source and not available in Bower (rare cases), add it to Bowerfile and specify its GitHub URL including the revision (see examples in Bowerfile) and execute the same commands
3. If it is either proprietary or not available on both Bower and GitHub, copy it to `vendor/javascripts`

If you are adding the dependencies via Bowerfile, you'll also need to add
them to `application.js` (otherwise it is most likely unnecessary since the
files in `vendor/javascripts` are added recursively).

## Continuous Integration

Please open a pull request when you want to merge new commits into the master branch. The pull request's commits will then be reviewed for test failures, bugs, potential improvements, etc. Once issues identified in the review have been resolved, the pull request can be merged in.

All RSpec tests are to be passing (bundle exec rspec) in a branch before
that branch is merged into master.

Front-end (Capybara) specs can be run loccally using either capybara-webkit
(headless, default) or selenium (real Firefox instance) driver. Normally
all the front-end specs should pass on both drivers.

To be able to use capybara-webkit successfully you need to install Qt 5.x
(some tests will fail with Qt 4.8).

If you can't or don't want to for some reason, you can use selenium by
specifying `CAPYBARA_JS_DRIVER=selenium` in environment variables when calling
`rspec` (i.e. `CAPYBARA_JS_DRIVER=selenium bundle exec rspec`). This is also the
default option for Semaphore CI (looks like they have Qt 4.8).
