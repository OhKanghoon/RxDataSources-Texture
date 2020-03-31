project: clean
	swift package generate-xcodeproj --enable-code-coverage
	ruby -e "require 'xcodeproj'; Xcodeproj::Project.open('RxDataSources-Texture.xcodeproj').save" || true
	pod install

clean:
	rm -rf Pods