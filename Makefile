NAME := MantleXMLExtension

all: init synx format test podlint cartrelease

ci: init test podlint cartrelease

init:
	bundle install --path vendor/bundle
	carthage bootstrap --platform iOS

open:
	open ${NAME}.xcworkspace

test:
	xcodebuild -workspace ${NAME}.xcworkspace -scheme ${NAME}Scheme -disable-concurrent-destination-testing \
		-destination-timeout 300 \
		-destination 'platform=iOS Simulator,name=iPhone 11,OS=13.7' \
		clean test

podlint:
	bundle exec pod lib lint --use-libraries --allow-warnings

cartrelease:
	carthage build --no-skip-current
	carthage archive ${NAME}

synx:
	bundle exec synx ${NAME}.xcodeproj

format:
	find ${NAME}* -type f -regex ".*\.[m,h]$$" | xargs clang-format -i
