# need some way to namespace apps so i know i'm defining this stuff on the current app ... hrm ...
#
# want to make sure that i can load N apps into memory and access ALL of their settings and whatnot
#
# i don't like this implementation of namespacing, but i'll figure one out!
#
# maybe ... 
#
# Andrake::Resources do |res|
#   # where res.* will all be lazily initialized and default to empty hashes
#   # so we can always merge them, instead of accidentally overriding stuff
#   res.strings.merge({
#     :foo => bar
#   })
# end
#
Andrake::CurrentApp.res.strings = {
  :app_description => '',
  :foo => ''
}
