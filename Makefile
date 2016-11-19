NAME := MantleXMLExtension

all: init synx

init:
	bundle install --path vendor/bundle
	bundle exec pod install

open:
	open ${NAME}.xcworkspace

synx:
	bundle exec synx ${NAME}.xcodeproj
