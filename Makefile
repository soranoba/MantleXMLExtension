NAME := MantleXMLExtension

all: init test synx format

init:
	bundle install --path vendor/bundle
	bundle exec pod install

open:
	open ${NAME}.xcworkspace

test:
	xcodebuild -workspace ${NAME}.xcworkspace -scheme ${NAME} -sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=9.0' \
		-destination 'platform=iOS Simulator,name=iPhone 6,OS=10.0' \
		-destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' \
		clean test

synx:
	bundle exec synx ${NAME}.xcodeproj

format:
	find ${NAME}* -type f -regex ".*\.[m,h]$$" | xargs clang-format -i
