# sequel-pg_advisory_lock 

[![Build Status](https://travis-ci.org/yuryroot/sequel-pg_advisory_lock.svg?branch=master)](https://travis-ci.org/yuryroot/sequel-pg_advisory_lock)
[![Gem Version](https://badge.fury.io/rb/sequel-pg_advisory_lock.svg)](https://badge.fury.io/rb/sequel-pg_advisory_lock)

Gem `sequel-pg_advisory_lock` is an extension for ruby [Sequel](https://github.com/jeremyevans/sequel) library 
that allows using [PostgreSQL advisory locks](https://www.postgresql.org/docs/9.6/static/explicit-locking.html#ADVISORY-LOCKS)
for application-level mutexes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-pg_advisory_lock'
```

and then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install sequel-pg_advisory_lock
```

## Usage

First, you should load an extension for `Sequel::Database` instance:

```ruby
DB.extension :pg_advisory_lock
```

Then, you should register new lock by specifying unique name:

```ruby
DB.register_advisory_lock(:my_lock)

```

By default, `pg_advisory_lock` *PostgreSQL* function will be associated with registered lock. 

It's also possible to specify different function in second parameter of `register_advisory_lock` method, for example:

```ruby
DB.register_advisory_lock(:my_lock, :pg_try_advisory_lock)
````

All supported lock functions are described [here](#available-types-of-locks). 

Finally, you can use registered lock:  

```ruby
DB.with_advisory_lock(:my_lock) do
  # do something
  # this block works like application-level mutex, 
  # so code inside block is protected from concurrent execution 
end

``` 
 
An optional *4-bytes integer* parameter can be passed to `with_advisory_lock` method call:

```ruby
DB.with_advisory_lock(:my_lock, 1) do
  # do something
  # this block works like application-level mutex, 
  # so code inside block is protected from concurrent execution 
end

```

## Available types of locks

There are 4 supported *PostgreSQL* lock functions which can be used in `register_advisory_lock`:

* `pg_advisory_lock` (default)

   Waits of lock releasing if someone already owns requested lock.

* `pg_try_advisory_lock`

   Doesn't wait of lock releasing, returns nil if someone already owns requested lock. 
 
* `pg_advisory_xact_lock`

   Waits of lock releasing if someone already owns requested lock.  
   Releases lock immediately after database transaction ends.  
   Requires manually opened transaction before using this lock.  

* `pg_try_advisory_xact_lock`

   Doesn't wait of lock releasing, returns nil if someone already owns requested lock.   
   Releases lock immediately after database transaction ends.  
   Requires manually opened transaction before using this lock.  

For more information see [PostgreSQL documentation](https://www.postgresql.org/docs/9.6/static/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS). 
 
## Contributing

1. Fork the project (https://github.com/yuryroot/sequel-pg_advisory_lock).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add tests for your feature or bug fix.
5. Run `rake` to make sure all tests pass.
6. Commit your changes (`git commit -am 'Add new feature'`).
7. Push to the branch (`git push origin my-new-feature`).
8. Create new pull request.
