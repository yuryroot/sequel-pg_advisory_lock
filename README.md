# sequel-pg_advisory_lock
[![Build Status](https://travis-ci.org/yuryroot/sequel-pg_advisory_lock.svg?branch=master)](https://travis-ci.org/yuryroot/sequel-pg_advisory_lock)

`sequel-pg_advisory_lock` gem is an extension for ruby [Sequel](https://github.com/jeremyevans/sequel) library 
that helps using [PostgreSQL advisory locks](https://www.postgresql.org/docs/9.6/static/explicit-locking.html#ADVISORY-LOCKS)
in your application.

## Installation

Add this line to application's Gemfile:

```ruby
gem 'sequel-pg_advisory_lock'
```
and then run bundler:

```
$ bundle
```

or install it yourself as:

```
$ gem install 'sequel-pg_advisory_lock'
```

If you want to use the latest version from the `master`, then add the following line to the Gemfile:

```ruby
gem 'sequel-pg_advisory_lock', git: 'https://github.com/yuryroot/sequel-pg_advisory_lock'
```

## Usage

First, you should load an extension for `Sequel::Database` instance:

```ruby
DB.extension :pg_advisory_lock
```

Second, you should register new lock by specifying unique name:

```ruby
DB.register_advisory_lock(:my_lock_name)

```

By default, `pg_advisory_lock` function will be associated with registered lock. 

It's also possible to specify different function by passing second parameter of `register_advisory_lock`, for example:

```ruby
DB.register_advisory_lock(:my_lock_name, :pg_try_advisory_lock)

```

There are 4 supported PostgreSQL lock functions as lock types:

* `pg_advisory_lock` 
* `pg_try_advisory_lock`
* `pg_advisory_xact_lock`
* `pg_try_advisory_xact_lock`

For more information see [PostgreSQL documentation](https://www.postgresql.org/docs/9.6/static/functions-admin.html#FUNCTIONS-ADVISORY-LOCKS)
 
Finally, you can use registered lock:  

```ruby
DB.with_advisory_lock(:my_lock_name) do
  # do something   
end

``` 

An optional 4-bytes integer parameter can be passed to `with_advisory_lock` method call:

```ruby
DB.with_advisory_lock(:some_operation_name, 1) do
  # code inside block will be protected by PostgreSQL advisory lock 
end

```
 
## Contributing

1. Fork the project (https://github.com/yuryroot/sequel-pg_advisory_lock).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add tests for your feature or bug fix.
5. Run `rake` to make sure all tests pass.
6. Commit your changes (`git commit -am 'Add new feature'`).
7. Push to the branch (`git push origin my-new-feature`).
8. Create new pull request.
