Kijitora
==========

## What is this?

Kijitora is a simple Twitter user streams viewer.

## How to run

Obtain the source tree.

`$ git clone git://github.com/cesare/kijitora.git`

Copy config/kijitora.coffee.sample to config/kijitora.coffee and edit it.

    module.exports =
      application:
        port: 8080
      twitter:
        consumer_key: "REPLACE THIS VALUE WITH YOUR CONSUMER KEY"
        consumer_secret: "REPLACE THIS VALUE WITH YOUR CONSUMER SECRET"

Run the application

`$ coffee app.coffee`

Open [http://localhost:8080](http://localhost:8080) your browser.

That's it. Have fan!

