NAME := MantleXMLExtension

all: init synx format test podlint cartrelease

ci: init test podlint cartrelease

init:
	bundle install --path vendor/bundle
	carthage update --platform iOS

open:
	open ${NAME}.xcworkspace

test:
	xcodebuild -workspace ${NAME}.xcworkspace -scheme ${NAME}Scheme -disable-concurrent-destination-testing \
		-destination-timeout 300 \
		-destination 'platform=iOS Simulator,name=iPhone 7,OS=10.3.1' \
		-destination 'platform=iOS Simulator,name=iPhone X,OS=11.4' \
		-destination 'platform=iOS Simulator,name=iPhone Xs,OS=12.2' \
		-destination 'platform=iOS Simulator,name=iPhone 11,OS=13.0' \
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
