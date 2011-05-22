require 'memoizer'
require 'spec_helper'

class MemoizerSpecClass
  include Memoizer
end

describe Memoizer do
  let(:today) { Date.today }

  describe '.memoize' do
    let(:object) { MemoizerSpecClass.new }
    let(:tomorrow) { Date.today + 1 }
    context "for a method with no params" do
      class MemoizerSpecClass
        def no_params() Date.today; end
        memoize :no_params
      end

      it "stores memoized value" do
        Timecop.freeze(today)
        object.no_params.should == today
        Timecop.freeze(tomorrow)
        object.no_params.should == today
      end
    end

    context "for a method with params" do
      class MemoizerSpecClass
        def with_params(ndays, an_array) Date.today + ndays + an_array.length; end
        memoize :with_params
      end

      it "stores memoized value" do
        Timecop.freeze(today)
        object.with_params(1, [1,2]).should == (today + 3)
        Timecop.freeze(tomorrow)
        object.with_params(1, [1,2]).should == (today + 3)
      end
      it "does not confuse one set of inputs for another" do
        Timecop.freeze(today)
        object.with_params(1, [1,2]).should == (today + 3)
        object.with_params(2, [1,2]).should == (today + 4)
        Timecop.freeze(tomorrow)
        object.with_params(1, [1,2]).should == (today + 3)
        object.with_params(1, [2,2]).should == (today + 4)
      end
    end

    context "for a method that returns nil" do
      class MemoizerSpecClass
        def returning_nil() Date.today; nil; end
        memoize :returning_nil
      end

      it "stores the memoized value" do
        object.returning_nil
        Date.stub!(:today).and_raise(ArgumentError)
        object.returning_nil.should be_nil
      end
    end

    describe '._memoizer_methods' do
      class A < MemoizerSpecClass
        def a() end
        def b() end
        def c() end
        memoize :a, :b
      end
      class B < MemoizerSpecClass
        def d() end
        def e() end
        def f() end
        memoize "d", "f"
      end
      class C < MemoizerSpecClass
        def z() end
      end
      it "saves names of memoized methods for each class" do
        A._memoizer_methods.should == [:a, :b]
        B._memoizer_methods.should == [:d, :f]
        C._memoizer_methods.should be_nil
      end
    end

    context 'for private methods' do
      class D < MemoizerSpecClass
        def foo() bar; end
        private
        def bar() Date.today; end
        memoize :bar
      end
      let(:object) { D.new }

      it "respects the privacy of the memoized method" do
        D.private_method_defined?(:bar).should be_true
        D.private_method_defined?(:_unmemoized_bar).should be_true
      end

      it "memoizes things" do
        Timecop.freeze(today)
        object.foo.should == today
        Timecop.freeze(today + 1)
        object.foo.should == today
      end
    end

    context 'for protected methods' do
      class E < MemoizerSpecClass
        def foo() bar; end
        protected
        def bar() Date.today; end
        memoize :bar
      end
      let(:object) { E.new }

      it "respects the privacy of the memoized method" do
        E.protected_method_defined?(:bar).should be_true
        E.protected_method_defined?(:_unmemoized_bar).should be_true
      end

      it "memoizes things" do
        Timecop.freeze(today)
        object.foo.should == today
        Timecop.freeze(today + 1)
        object.foo.should == today
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
      object.today.should == today
      object.plus_ndays(1).should == today + 1
      object.plus_ndays(3).should == today + 3
    end

    describe '#unmemoize' do
      context "for a method with no arguments" do
        it "clears the memoized value so it can be rememoized" do
          Timecop.freeze(today + 1)
          object.today.should == today

          object.unmemoize(:today)
          object.today.should == today + 1

          Timecop.freeze(today + 2)
          object.today.should == today + 1
        end
      end

      context "for a method with arguments" do
        it "unmemoizes for all inupts" do
          Timecop.freeze(today + 1)
          object.plus_ndays(1).should == today + 1
          object.plus_ndays(3).should == today + 3

          object.unmemoize(:plus_ndays)
          object.plus_ndays(1).should == today + 2
          object.plus_ndays(3).should == today + 4

          Timecop.freeze(today + 2)
          object.plus_ndays(1).should == today + 2
          object.plus_ndays(3).should == today + 4
        end
      end

      it "only affects the method specified" do
        Timecop.freeze(today + 1)
        object.today.should == today

        object.unmemoize(:plus_ndays)
        object.today.should == today

        object.unmemoize(:today)
        object.today.should == today + 1
      end
    end

    describe '#unmemoize_all' do
      it "clears all memoized values" do
        Timecop.freeze(today + 1)
        object.today.should == today
        object.plus_ndays(1).should == today + 1
        object.plus_ndays(3).should == today + 3

        object.unmemoize_all

        object.today.should == today + 1
        object.plus_ndays(1).should == today + 2
        object.plus_ndays(3).should == today + 4
      end
    end

  end

end
