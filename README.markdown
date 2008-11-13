Andrake
=======

Andrake is a tool and a set of tools/libraries for making Android development easier and more enjoyable

The goal is to write every part of an Android app, except for the Java classes, in Ruby, making configuration *much* less painful.

Andrake should also work just as well for Eclipse development as for development from the command line.

Ideally, when you 'run' the appliction from Eclipse, it will 'compile' the correct files before executing.


Say What?
---------

Just wait until there are some examples!  You'll see  :)


TODO
----

 * create specs that take some `config.rb` files and confirm the output matches some `AndroidManifest.xml` files
 * create specs that some some `AndroidManifest.xml` files (from above) and confirm that the objects load properly
 * ... create MORE specs!
 * Test jirb (JRuby)
 * Test accessing android.jar classes via jirb
 * Test USING android.jar classes via jirb?  likely won't work off of Dalvik ... ?
 * Find a way to DRY up java classes without using ERB tags ... custom parsing?  likely the best route
 * Try XRuby for implementing the Java in Ruby?  If this helps DRY up the Java, then it's worth it.  It might be worth it to do it in a custom way, tho ... dunno yet!
