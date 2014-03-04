# BundleCache

[![Build Status](https://travis-ci.org/data-axle/bundle_cache.png?branch=master)](https://travis-ci.org/data-axle/bundle_cache)

Utility for caching bundled gems on S3. Useful for speeding up Travis builds - 
it doesn't need to wait for `bundle install` to download/install all gems.

## Installation

Adding this to your Gemfile defeats the purpose. Instead, run

    $ gem install bundle_cache

## Usage

You'll need to set some environment variables to make this work.

```
AWS_S3_KEY=<your aws access key>
AWS_S3_SECRET=<your aws secret>
AWS_S3_BUCKET=<your bucket name>
BUNDLE_ARCHIVE=<the filename to use for your cache>
```

Optionally, you can set the `AWS_S3_REGION` variable if you don't use us-east-1.

## Travis configuration

Add these to your Travis configuration:

```
bundler_args: --without development --path=~/.bundle
before_install:
- "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
- gem install bundler bundle_cache
- bundle_cache_install
after_script:
- bundle_cache
env:
  global:
  - BUNDLE_ARCHIVE="your_project_bundle"
  - AWS_S3_BUCKET="your_bucket"
  - RAILS_ENV=test
```

You'll also want to add your AWS credentials to a secure section in there. Full instructions
are on Matias' site below, but if you've already added the above Travis configuration, this will
add the AWS credentials:

1. Install the travis gem with gem install travis
2. Log into Travis with travis login --auto (from inside your project respository directory)
3. Encrypt your S3 credentials with: travis encrypt AWS_S3_KEY="" AWS_S3_SECRET="" --add (be sure to add your actual credentials inside the double quotes)

## License

This code was originally written by Matias Korhonen and is available at 
http://randomerrata.com/post/45827813818/travis-s3. It is MIT licensed.
