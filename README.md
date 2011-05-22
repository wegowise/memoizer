Description
===========

Memoizer will memoize the results of your methods. It acts much like
ActiveSupport::Memoizable without all of that freezing business. The API for unmemoizing
is also a bit more expicit.

Install
=======

    $ gem install memoizer

Usage
=====

To memoize an instance method:

    class A
      include Memoizer
      def hello() 'hello!'; end
      memoize :hello
    end

Or you can memoize many methods at once:

    class B
      extend Memoizer
      def hello() 'hello!'; end
      def goodbye() 'goodbye :('; end
      memoize :hello, :goodbye
    end

Memoizing class methods works the same way:

    class C
      class << self
        include Memoizer
        def hello() 'hello!'; end
        memoize :hello
      end
    end


To unmemoize a specific method:

    instance = A.new
    instance.hello  # the hello method is now memoized
    instance.unmemoize(:hello)    # the hello method is no longer memoized
    instance.hello  # the hello method is run again and re-memoized


To unmemoize all methods for an instance:

    instance = B.new
    instance.hello    # the hello method is now memoized
    instance.goodbye  # the goodbye method is now memoized
    instance.unmemoize_all    # neither hello nor goodbye are memoized anymore


License
=======

See LICENSE.txt
