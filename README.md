#Minecraft Chat Interceptor

This utility runs as a daemon and intercepts chat messages  sent to the Minecraft server. Messages are then inspected for commands and if any are found they are executed and information is then reported back to the requesting user.

##Install

Requires RubyGems and Bundler

* `sudo gem install bundler`
* `bundle install`

##Running

Simply fire up the daemon and it will take care of the rest!

	ruby mcchatter_control.rb start

##Daemon Commands

The daemon supports the following commands:

* start
* stop
* restart