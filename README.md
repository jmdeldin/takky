# Takky, an asynchronous image/file attachment gem

[![Build Status](https://travis-ci.org/jmdeldin/takky.svg)](https://magnum.travis-ci.com/jmdeldin/takky)
[![Code Climate](https://codeclimate.com/github/jmdeldin/takky/badges/gpa.svg)](https://codeclimate.com/github/jmdeldin/takky)

Takky aims to make uploading, storing, and processing file attachments
more transparent and robust than existing file management gems. It works
best in asynchronous environments using Sidekiq, but it also supports
synchronous uploads to Amazon S3.

## Features

- All uploads are performed in Sidekiq jobs, which allows you to utilize
  background processing and Sidekiq's retry queue for when things go awry
- Minimal metaprogramming -- everything is plain old Ruby code where
  possible
- Simple to read source code (if not, file a bug!)
- While you can create multiple attachment models, we encourage you to
  use a single table for all attachments and add additional metadata via
  another model.

## Impetus

At [The Clymb](http://www.theclymb.com/invite-from/jonmichael), images
are a core component of our site. We started with Paperclip in the
beginning, but overtime, we accumulated a lot of cruft and have outgrown
Paperclip. We implemented a new file attachment solution for a few
reasons:

- We are heavy users of [Sidekiq](http://sidekiq.org) and rely on it for
  handling third-party failures with automatic job retries. When S3 is
  down or your system's struggling to keep up with ImageMagick, it is
  desirable to have upload and processing jobs tracked and retried
  appropriately. Adding background processing capabilities to Paperclip
  and Carrierwave requires additional gems that aren't part of the main
  project, and we didn't want to add unnecessary complexity -- we want
  background processing to be a first-class citizen.

- Some upload operations are best performed asynchronously -- the user
  may not need to wait around for the upload to complete, or the
  compositing operations can happen in the background.

- Unlike Paperclip and the like, adding an attachment does not involve
  adding four columns to your model when you "attach" a file. Takky will
  require one foreign key on the model that references an `attachments`
  table. While you sacrifice initial convenience, requiring attachments
  to be stored separately out of the box prevents you from having models
  with 44 columns for 11 attachments, for example.

Finally, after spending many hours debugging one line methods, tiny
classes, and gratuitous metaprogramming in other attachment gems, we
want to emphasize clear and concise source code in Takky.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "takky"
```

And then execute:

```sh
% bundle
```

## Usage

First, configure Takky for your app, e.g., in a Rails initializer like
`config/initializers/takky.rb`:

```ruby

# Takky will reuse AWS configuration, but your app must execute the
# following somewhere, or you must have defined the environment
# variables listed here: http://docs.aws.amazon.com/AWSSdkDocsRuby/latest//DeveloperGuide/prog-basics-creds.html
#
#  AWS.config({
#    access_key_id:      s3_credentials['access_key_id'],
#    secret_access_key:  s3_credentials['secret_access_key']
#  })

Takky.configure do |c|
  c.src_host = 's3.amazonaws.com/bucket'
  c.cdn_host = 'cdn.example.com'
end
```

## Bugs? Features?

Please [file an issue](https://github.com/jmdeldin/takky/issues) on GitHub.
