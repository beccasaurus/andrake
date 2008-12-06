# port of the Android Ant build file to Rake
#
# (for the purpose of learning all of the commands, etc)
#
# NOTE this will likely ALL be refactored, hardcore, i just wanna get it working first!

# global / sytem vars
sdk_folder = '/home/remi/downloads/android-sdk-linux_x86-1.0_r1'
tools_folder = File.join sdk_folder, 'tools'
android_framework = File.join tools_folder, 'lib', 'framework.aidl'
android_jar = File.join sdk_folder, 'android.jar'

# app specific vars
app_name = 'FooBar'
app_package = 'com.android.foobar'

# project dirs
resource_dir = 'res'
asset_dir = 'assets'
source_dir = 'src'
lib_dir = 'libs'
output_dir = 'bin'
output_class_dir = File.join output_dir, 'classes'
r_java_is_in_dir = source_dir
dex_file = 'classes.dex'
dex_dir = File.join output_dir, dex_file
resources_pkg = File.join output_dir, "#{ app_name }.ap_"
debug_pkg = File.join output_dir, "#{ app_name }-debug.apk"
unsigned_pkg = File.join output_dir, "#{ app_name }-unsigned.apk"

# calls a system command (printing it out first ... or maybe not executing it at all, if just testing?)
def call system_command
  puts system_command
  # system system_command
end

task :default => :build

desc 'build'
task :build do
  puts "the sdk_folder => #{ sdk_folder }"
end

task :dirs do
  puts "should create output and output-classes (output-*?) if they don't exist ... altho i think this should happen lazily instead"
end

desc "Generates R.java / Manifest.java from resources"
task :resource_src => :dirs do
  puts "generating R.java / Manifest.java from resources ..."
  call "aapt package -m -J #{ r_java_is_in_dir } -M AndroidManifest.xml -S #{ resource_dir } -I #{ android_jar }"
end

desc "Generate java classes from .aidl files"
task :aidl => :dirs do
  puts "generating java classes from .aidl files"
  call "aidl -p#{ android_framework } -I#{ source_dir } #{ Dir[File.join(source_dir, '**', '*.aidl')] }" # <-- use rake fileset or whatever?
end

desc "Compiles the project's .java files into .class files"
task :compile => [:dirs, :resource_src, :aidl] do
  call "javac command goes here ..."
end

desc "Convert this project's .class files into .dex files"
task :dex => :compile do
  call "dx --dex --output=#{ dex_dir } #{ output_class_dir } [external libs ... *.jar ...]"
end

=begin
  ANT OUTPUT

Buildfile: build.xml

dirs:
     [echo] Creating output directories if needed...

resource-src:
     [echo] Generating R.java / Manifest.java from the resources...

aidl:
     [echo] Compiling aidl files into Java classes...

compile:
    [javac] Compiling 2 source files to /home/remi/projects/phxandroid/examples/AndroidSansEclipse/bin/classes

dex:
     [echo] Converting compiled files and external libraries into bin/classes.dex...

package-res:

package-res-no-assets:
     [echo] Packaging resources...

debug:
     [echo] Packaging bin/AndroidSansEclipse-debug.apk, and signing it with a debug key...
     [exec] Using keystore: /home/remi/.android/debug.keystore

BUILD SUCCESSFUL
Total time: 3 seconds

=end
