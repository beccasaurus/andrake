$:.unshift File.dirname(__FILE__)
require 'javaclass' # <--- should be moved to a gem, eventually

class Android
end

require 'android/extensions'
require 'android/application'
require 'android/javaclass'
require 'android/activity'
require 'android/layout'
