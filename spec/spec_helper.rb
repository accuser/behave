$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'behave'
require 'spec'
require 'spec/autorun'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('behave_test')
end

Spec::Runner.configure do |config|
  config.after :suite do
    Mongoid.master.collections.each(&:drop)
  end
end
