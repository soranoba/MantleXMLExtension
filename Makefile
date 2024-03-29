NAME := MantleXMLExtension

all: init synx format test podlint cartrelease

ci: init test podlint cartrelease

init:
	bundle install --path vendor/bundle
	carthage bootstrap --platform iOS --use-xcframeworks

open:
	open ${NAME}.xcworkspace

test:
	xcodebuild -workspace ${NAME}.xcworkspace -scheme ${NAME}Scheme -disable-concurrent-destination-testing \
		-destination-timeout 300 \
		-destination 'platform=iOS Simulator,name=iPhone 11,OS=14.4' \
		clean test

podlint:
	bundle exec pod lib lint --use-libraries --allow-warnings

cartrelease:
	carthage build --no-skip-current --use-xcframeworks

synx:
	bundle exec synx ${NAME}.xcodeproj

format:
	find ${NAME}* -type f -regex ".*\.[m,h]$$" | xargs clang-format -i
