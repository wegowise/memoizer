[![Build Status](https://travis-ci.org/wegowise/memoizer.svg?branch=setup-travis-ci)](https://travis-ci.org/wegowise/memoizer)

# memoizer

Memoizer will memoize the results of your methods. It acts much like
`ActiveSupport::Memoizable` without all of that freezing business. The API for
unmemoizing is also a bit more explicit.

## Install

```
$ gem install memoizer
```

## Usage

To memoize an instance method:

```ruby
class A
  include Memoizer
  def hello() 'hello!'; end
  memoize :hello
end
```

Or you can memoize many methods at once:

```ruby
class B
  extend Memoizer
  def hello() 'hello!'; end
  def goodbye() 'goodbye :('; end
  memoize :hello, :goodbye
end
```

Memoizing class methods works the same way:

```ruby
class C
  class << self
    include Memoizer
    def hello() 'hello!'; end
    memoize :hello
  end
end
```


To unmemoize a specific method:

```ruby
instance = A.new
instance.hello              # the hello method is now memoized
instance.unmemoize(:hello)  # the hello method is no longer memoized
instance.hello              # the hello method is run again and re-memoized
```


To unmemoize all methods for an instance:

```ruby
instance = B.new
instance.hello          # the hello method is now memoized
instance.goodbye        # the goodbye method is now memoized
instance.unmemoize_all  # neither hello nor goodbye are memoized anymore
```


## License

See [LICENSE.txt](https://github.com/wegowise/memoizer/blob/master/LICENSE.txt)
