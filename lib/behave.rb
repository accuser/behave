#--
# Copyright (c) 2010 Matthew Gibbons <mhgibbons@me.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'

gem 'activemodel', '>= 3.0.0'
gem 'activesupport', '>= 3.0.0'
gem 'delayed_job', '>= 1.7.0'
gem 'mongoid', '>= 2.0.0.beta.17'
gem 'mongoid_cached_document', '>= 0.1.0'
gem 'RedCloth'
gem 'sunspot_rails', '>= 1.0.0'

Dir.glob(File.join(File.dirname(__FILE__), 'behave', '**', '*.rb'), &method(:require))

module Behave
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    include Behave::Behaviors
  end
end
