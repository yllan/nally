# Mengjuei Hsieh, University of California Irvine

all:
	xcodebuild

clean:
	xcodebuild clean;	\
	rm -fr build;		\
	rm -f Nally.xcodeproj/${USER}.*

install: all
	rm -r /Applications/Nally.app; mv build/Release/Nally.app /Applications/

test: all
	build/Release/Nally.app/Contents/MacOS/Nally

release: all
	python package.py build/Release/Nally.app http://nally.googlecode.com/files
