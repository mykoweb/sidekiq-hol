Sidekiq HOL (Head-of-Line)
==========================

## Description

For high priority jobs, and you don't want to bypass the job queue, submit your Sidekiq job to the head of the queue.

## Installation

Add this line to your application's Gemfile:

  gem 'sidekiq-hol'

## Caveats

`sidekiq-hol` does not work with `reliable_fetch`, Sidekiq Enterprise Rate Limiting, or any other feature that dynamically reorders jobs within a Sidekiq queue.

## Usage

Add a worker to process jobs asynchronously using Sidekiq-HOL:

```ruby
class SomeWorker
  include Sidekiq::Hol::Worker

  def perform(name, count)
    # do something
  end
end
```

Create the asynchronous job:

```ruby
SomeWorker.perform_hol_async 'bart', 17
```

Licence
=======

See [LICENCE](https://github.com/mykoweb/sidekiq-hol/blob/master/LICENSE)
