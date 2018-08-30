NAME	= SystemMonitor
PROJECT	= $(NAME).xcodeproj
SCHEME	= $(NAME)

all:
	xcodebuild -project $(PROJECT)

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME)

clean:
	rm -rf ./build