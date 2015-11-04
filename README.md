Purpose
-------

The purpose of this library is to make DNS lookups more robust and faster
especially in a network environment where DNS looksups are known to fail.
This is done via two methods:

* DNS lookups are cached meaning that many times a DNS lookup is not even
  made and the previous answer is used.
* Failed lookups will retry to deal with random DNS lookup failures

Usage
-----

If using Rails and you just want to automatically make your DNS lookups more
robust add the following to your Gemfile:

    gem 'resolv-robust', require: 'resolv-robust-replace'

(Note this gem is currently in development so you will also need a git:
option to tell it the repo to load).

If you want more control the manual route is:

1. Add `require 'resolv-robust'` during initialization.
2. Set the cache store using `Resolv::cache_store=`. This is designed to use
   ActiveSupport's pluggable cache store although any cache store with a
   sufficiently compatible API will work.
3. Call the method `Resolv#get_address_robustly` instead of the normal
   `Resolv#getaddress`.

If you want to transparently use this resolv library on all requests you can
add `require 'resolv-robust-replace'`. You still need to set the cache store.

If you are using Rails and you want to use the default Rails cache store you can
skip setting the cache store. This is how the Gemfile line works. It
automatically includes the replacement functionality and automatically uses the
configured cache store.

Options
-------

In addition to configuring the cache store via `Resolv::cache_store=` there
are two other options you can configure:

`Resolv::cache_duration` - Allows the amount of time for which the cached value
is valid to be configured. This defaults to every hour. If you think you might
change IP addresses often or have a big networking change coming up you might
reduce this to 5 minutes. If you feel your network will be very stable then
perhaps a higher value such as 24 hours.

`Resolv::attempts` - Defines the number of times the library retries the lookup
before giving up. Defaults to 3. There is a slight delay between each retry
that increases with each attempt (no delay on the first retry, 0.1sec delay
on the second retry, 0.2sec delay on the third retry, etc.

Performance
-----------

The primary goal of this library is reliability. We are hoping a cache lookup is
more reliable than a full resolv. In the event that it is not, the retry adds an
additional level of robustness. But this library also benefits performance a
good bit due to a cache lookup being faster. The file benchmark.rb demonstrates
those differences. An example run is shown below:

    Single Thread
                                            user       system     total       real
    system single thread                    0.060000   0.130000   0.190000 (  1.596554)
    resolv single thread                    0.380000   0.040000   0.420000 (  1.545678)
    resolve in-memory cache single thread   0.010000   0.000000   0.010000 (  0.012951)
    resolve redis cache single thread       0.080000   0.020000   0.100000 (  0.124226)


    Thread Pool
                                            user       system     total       real
    system thread pool                      0.070000   0.110000   0.180000 (  0.523810)
    resolv thread pool                      0.360000   0.080000   0.440000 (  0.413677)
    resolv in-memory cache thread pool      0.020000   0.000000   0.020000 (  0.021634)
    resolv redis cache thread pool          0.110000   0.060000   0.170000 (  0.200680)

A few things we have learned from this:

1. In general the Resolv library results in a faster lookup than the system
   resolving. This was expected in a threaded environment as the Resolv library
   was designed for a threaded environment. But it is also generally true for
   a single thread environment. Due to random fluctionations the system library
   sometimes is faster but generally the Resolv will be.
2. The in-memory cache store is by far the fastest (order of magnitude faster
   than redis, order and a half magnitude faster than a thread pool doing a
   lookup each time and two orders of magnitude faster than a single thread doing
   a lookup each time). But it might have negative impacts on reliabiltiy (the
   primary goal). With redis you can share the cache even across processes. With
   in-memory the cache is not shared and therefore you are doing more lookups
   (which could fail).
3. Both in-memory and redis versions are slower in a thread pool. I'm guessing
   the reason for this is due to mutex locking to make the cache stores thread
   safe. But if you are already using threads for other reasons they are still
   faster than not caching.
