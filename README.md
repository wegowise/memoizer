[![Build Status](https://travis-ci.org/makandra/memoized.svg?branch=master)](https://travis-ci.org/makandra/memoized)

# Memoized

Memoized will memoize the results of your methods. It acts much like
`ActiveSupport::Memoizable` without all of that freezing business. The API for
unmemoizing is also a bit more explicit.

## Install

```
$ gem install memoized
```

## Usage

To define a memoized instance method, use `memoized def``:

```ruby
class A
  include Memoized

  memoize def hello
    'hello!'
  end
end
```

You may also `memoize` one or more methods after they have been defined:

```ruby
class B
  include Memoized

  def hello
    'hello!'
  end

  def goodbye
    'goodbye :('
  end

  memoize :hello, :goodbye
end
```

Memoizing class methods works the same way:

```ruby
class C
  class << self
    include Memoized

    memoize def hello
      'hello!'
    end
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

See [LICENSE.txt](https://github.com/makandra/memoized/blob/master/LICENSE.txt)


## Credits

- This gem is a fork of [Memoizer](https://github.com/wegowise/memoizer) by [Wegowise](https://www.wegowise.com/).
- Changes in this fork by [makandra](https://makandra.com).
