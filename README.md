[![CI](https://github.com/TFS-iOS/chat-app-lyaskovetsiv/actions/workflows/.github.yml/badge.svg?branch=dz-cicd)](https://github.com/TFS-iOS/chat-app-lyaskovetsiv/actions/workflows/.github.yml)

**APP**: Messenger

**Description**: An application for communication between users

**What was done**:

- I made up the application layout with the code from Figma, used UIAppearance to create internal themes
- Broke the application architecture according to SOA + used MVP for presentation layer
- Connected external dependencies via CocoaPods, linter SwiftLint and TFSChatTransport
- Used Combine to demonstrate asynchronous programming skills
- Used GCD to demonstrate the skill of using multithreading
- Implemented asynchronous loading of images using the API pixabay.com
- Set up SSE communication with the server, subscribed to events
- Implemented saving user information in Filemanager, storing sensitive data in KeyChain, storing a copy of data from the server (cache) via CoreData
- Implemented several types of animations in the application
- Covered several managers from the service layer with Unit tests using mock data, and also wrote a couple of UI tests + used TestPlans
- Configured work with FastLine, added several configuration files, configured the build in GitHub Actions
- Sent a notification to the discord channel at the end of the project build on the CI server


