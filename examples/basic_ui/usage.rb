# some random usage notes
#
# after Andrake has been 'loaded,' you should be able to:
#
# Andrake::BasicUI.application
# Andrake::BasicUI.package
# Andrake::BasicUI.icons
# Andrake::BasicUI.activities
# Android::BasicUI.resources.strings
# Android::BasicUI.resources.values
# Android::BasicUI.strings
# Android::BasicUI.values
# Android::BasicUI.layouts
# Android::BasicUI.activities.first.layout
# Android::BasicUI.layouts.first.activity
# Android::BasicUI.layouts.first.activities
#
# etc, etc, etc 
#
# These should all get loaded up and be accessible
#
# I need to test drive all of this stuff
#
# NOTE: I want to be able to load up multiple Android apps, so the namespacing is *essential*
#
# This API is useful, imho, for just getting meta-data about the app, but it's also useful 
# for things like ... activities/FooBar.java.erb ... how hot does *THAT* sound?  :)
#
# NOTE: *EVENTUALLY* all of these values should be accessible from a NORMAL android app, WITHOUT ANY Andrake ... it should parse the XML!!!!!!!!
#       SPECS should be written for this, early on!
