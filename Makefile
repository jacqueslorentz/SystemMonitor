NAME	= SystemMonitor
PROJECT	= $(NAME).xcodeproj
SCHEME	= $(NAME)Tests

all:
	xcodebuild -project $(PROJECT)

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME)

clean:
	rm -rf ./build