class MemoizerSpecClass
  include Memoizer
  def no_params() Date.today; end
  def with_params?(ndays, an_array) Date.today + ndays + an_array.length; end
  def returning_nil!() Date.today; nil; end

  def with_hash_parameter(ndays, options = {})
    subtract = options.fetch(:subtract, false)

    if subtract
      Date.today - ndays
    else
      Date.today + ndays
    end
  end

  def with_only_hash_parameter(options = {})
    ndays = options.fetch(:ndays)
    subtract = options.fetch(:subtract, false)

    if subtract
      Date.today - ndays
    else
      Date.today + ndays
    end
  end

  def with_kwargs(ndays, subtract: false)
    if subtract
      Date.today - ndays
    else
      Date.today + ndays
    end
  end

  def with_only_kwargs(ndays:, subtract: false)
    if subtract
      Date.today - ndays
    else
      Date.today + ndays
    end
  end

  def with_hash_and_kwargs(options = {}, **kwargs)
    # This is one of the "confusing examples" given for why keyword arguments
    # are changing in ruby 3. The keywords are assigned to the optional
    # positional argument on ruby 2.6 and 2.7, but we might expect them to be
    # assigned to kwargs.
    #
    # https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/
    #
    # This method is designed to work around the unexpected behavior, but it
    # should probably be avoided entirely.
    if options.empty?
      ndays = kwargs.fetch(:ndays)
    else
      ndays = options.fetch(:ndays)
    end

    subtract = kwargs.fetch(:subtract, false)

    if subtract
      Date.today - ndays
    else
      Date.today + ndays
    end
  end

  memoize :no_params,
          :with_params?,
          :returning_nil!,
          :with_hash_and_kwargs,
          :with_hash_parameter,
          :with_only_hash_parameter,
          :with_kwargs,
          :with_only_kwargs
end
class Beepbop < MemoizerSpecClass; end

describe Memoizer do
  let(:today) { Date.today }

  describe '.memoize' do
    let(:object) { MemoizerSpecClass.new }
    let(:tomorrow) { Date.today + 1 }

    context "for a method with no params" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.no_params).to eq(today)
        Timecop.freeze(tomorrow)
        expect(object.no_params).to eq(today)
      end
    end

    context "for a method with params (and ending in ?)" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_params?(1, [1,2])).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_params?(1, [1,2])).to eq(today + 3)
      end
      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_params?(1, [1,2])).to eq(today + 3)
        expect(object.with_params?(2, [1,2])).to eq(today + 4)
        Timecop.freeze(tomorrow)
        expect(object.with_params?(1, [1,2])).to eq(today + 3)
        expect(object.with_params?(1, [2,2])).to eq(today + 4)
      end
    end

    context "for a method with a mix of positional and hash args" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_hash_parameter(3)).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_hash_parameter(3)).to eq(today + 3)
      end

      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_hash_parameter(3)).to eq(today + 3)
        expect(object.with_hash_parameter(3, subtract: true)).to eq(today - 3)
        Timecop.freeze(tomorrow)
        expect(object.with_hash_parameter(3)).to eq(today + 3)
        expect(object.with_hash_parameter(3, subtract: true)).to eq(today - 3)
      end
    end

    context "for a method with only a hash arg" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_only_hash_parameter(ndays: 3)).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_only_hash_parameter(ndays: 3)).to eq(today + 3)
      end

      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_only_hash_parameter(ndays: 3)).to eq(today + 3)
        expect(object.with_only_hash_parameter(ndays: 3, subtract: true)).to eq(today - 3)
        Timecop.freeze(tomorrow)
        expect(object.with_only_hash_parameter(ndays: 3)).to eq(today + 3)
        expect(object.with_only_hash_parameter(ndays: 3, subtract: true)).to eq(today - 3)
      end
    end

    context "for a method with a mix of positional and keyword arguments" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_kwargs(3)).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_kwargs(3)).to eq(today + 3)
      end

      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0')
        it 'raises an error when the keyword args are passed as a hash' do
          expect { object.with_kwargs(3, { subtract: true }) }.to raise_error(
            ArgumentError,
            'wrong number of arguments (given 2, expected 1)'
          )
        end
      end

      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_kwargs(3)).to eq(today + 3)
        expect(object.with_kwargs(3, **{ subtract: true })).to eq(today - 3)
        Timecop.freeze(tomorrow)
        expect(object.with_kwargs(3)).to eq(today + 3)
        expect(object.with_kwargs(3, **{ subtract: true })).to eq(today - 3)
      end
    end

    context "for a method with only keyword args" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_only_kwargs(ndays: 3)).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_only_kwargs(ndays: 3)).to eq(today + 3)
      end

      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0')
        it 'raises an error when the keyword args are passed as a hash' do
          expect { object.with_only_kwargs({ ndays: 3, subtract: true }) }.to raise_error(
              ArgumentError,
              'wrong number of arguments (given 1, expected 0; required keyword: ndays)'
            )
        end
      end

      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_only_kwargs(ndays: 3)).to eq(today + 3)
        expect(object.with_only_kwargs(**{ ndays: 3, subtract: true })).to eq(today - 3)
        Timecop.freeze(tomorrow)
        expect(object.with_only_kwargs(ndays: 3)).to eq(today + 3)
        expect(object.with_only_kwargs(**{ ndays: 3, subtract: true })).to eq(today - 3)
      end
    end

    context "for a method with both a hash and keyword args" do
      it "stores memoized value" do
        Timecop.freeze(today)
        expect(object.with_hash_and_kwargs({ ndays: 3 }, subtract: false)).to eq(today + 3)
        Timecop.freeze(tomorrow)
        expect(object.with_hash_and_kwargs({ ndays: 3 }, subtract: false)).to eq(today + 3)
      end

      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0')
        it 'raises an error when the keyword args are passed as a hash' do
          expect { object.with_hash_and_kwargs({ ndays: 3 }, { subtract: true }) }.to raise_error(
              ArgumentError,
              'wrong number of arguments (given 2, expected 0..1)'
            )
        end
      end

      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        expect(object.with_hash_and_kwargs({ ndays: 3 })).to eq(today + 3)
        expect(object.with_hash_and_kwargs({ ndays: 3 }, **{ subtract: true })).to eq(today - 3)
        Timecop.freeze(tomorrow)
        expect(object.with_hash_and_kwargs({ ndays: 3 })).to eq(today + 3)
        expect(object.with_hash_and_kwargs({ ndays: 3 }, **{ subtract: true })).to eq(today - 3)
      end
    end

    context "for a method that returns nil (and ends in !)" do
      it "stores the memoized value" do
        object.returning_nil!
        allow(Date).to receive(:today).and_raise(ArgumentError)
        expect(object.returning_nil!).to be_nil
      end
    end

    context "for subclasses" do
      let(:object) { Beepbop.new }
      it "still memoizes things" do
        Timecop.freeze(today)
        expect(object.no_params).to eq(today)
        Timecop.freeze(tomorrow)
        expect(object.no_params).to eq(today)
      end
    end

    context 'for private methods' do
      class Beirut < MemoizerSpecClass
        def foo() bar; end
        private
        def bar() Date.today; end
        memoize :bar
      end
      let(:object) { Beirut.new }

      it "respects the privacy of the memoized method" do
        expect(Beirut.private_method_defined?(:bar)).to be_truthy
        expect(Beirut.private_method_defined?(:_unmemoized_bar)).to be_truthy
      end

      it "memoizes things" do
        Timecop.freeze(today)
        expect(object.foo).to eq(today)
        Timecop.freeze(today + 1)
        expect(object.foo).to eq(today)
      end
    end

    context 'for protected methods' do
      class Wonka < MemoizerSpecClass
        def foo() bar; end
        protected
        def bar() Date.today; end
        memoize :bar
      end
      let(:object) { Wonka.new }

      it "respects the privacy of the memoized method" do
        expect(Wonka.protected_method_defined?(:bar)).to be_truthy
        expect(Wonka.protected_method_defined?(:_unmemoized_bar)).to be_truthy
      end

      it "memoizes things" do
        Timecop.freeze(today)
        expect(object.foo).to eq(today)
        Timecop.freeze(today + 1)
        expect(object.foo).to eq(today)
      end
    end

  end


  describe 'instance methods' do
    class MemoizerSpecClass
      def today() Date.today; end
      def plus_ndays(ndays) Date.today + ndays; end
      memoize :today, :plus_ndays
    end

    let(:object) { MemoizerSpecClass.new }
    before do
      Timecop.freeze(today)
      expect(object.today).to eq(today)
      expect(object.plus_ndays(1)).to eq(today + 1)
      expect(object.plus_ndays(3)).to eq(today + 3)
    end

    describe '#unmemoize' do
      context "for a method with no arguments" do
        it "clears the memoized value so it can be rememoized" do
          Timecop.freeze(today + 1)
          expect(object.today).to eq(today)

          object.unmemoize(:today)
          expect(object.today).to eq(today + 1)

          Timecop.freeze(today + 2)
          expect(object.today).to eq(today + 1)
        end
      end

      context "for a method with arguments" do
        it "unmemoizes for all inupts" do
          Timecop.freeze(today + 1)
          expect(object.plus_ndays(1)).to eq(today + 1)
          expect(object.plus_ndays(3)).to eq(today + 3)

          object.unmemoize(:plus_ndays)
          expect(object.plus_ndays(1)).to eq(today + 2)
          expect(object.plus_ndays(3)).to eq(today + 4)

          Timecop.freeze(today + 2)
          expect(object.plus_ndays(1)).to eq(today + 2)
          expect(object.plus_ndays(3)).to eq(today + 4)
        end
      end

      it "only affects the method specified" do
        Timecop.freeze(today + 1)
        expect(object.today).to eq(today)

        object.unmemoize(:plus_ndays)
        expect(object.today).to eq(today)

        object.unmemoize(:today)
        expect(object.today).to eq(today + 1)
      end

      context "for subclasses" do
        let(:object) { Beepbop.new }
        it "clears the memoized value" do
          Timecop.freeze(today + 1)
          expect(object.today).to eq(today)

          object.unmemoize(:today)
          expect(object.today).to eq(today + 1)

          Timecop.freeze(today + 2)
          expect(object.today).to eq(today + 1)
        end
      end
    end

    describe '#unmemoize_all' do
      shared_examples_for "unmemoizing methods" do
        it "clears all memoized values" do
          Timecop.freeze(today + 1)
          expect(object.today).to eq(today)
          expect(object.plus_ndays(1)).to eq(today + 1)
          expect(object.plus_ndays(3)).to eq(today + 3)

          object.unmemoize_all

          expect(object.today).to eq(today + 1)
          expect(object.plus_ndays(1)).to eq(today + 2)
          expect(object.plus_ndays(3)).to eq(today + 4)
        end
      end

      it_should_behave_like "unmemoizing methods"

      context "for subclasses" do
        let(:object) { Beepbop.new }
        it_should_behave_like "unmemoizing methods"
      end
    end

  end

end
