project: clean
	swift package generate-xcodeproj --enable-code-coverage
	ruby -e "require 'xcodeproj'; Xcodeproj::Project.open('Umbrella.xcodeproj').save" || true
	bundle install
	bundle exec pod install || bundle exec pod install --repo-update --verbose

clean:
	rm -rf Pods
