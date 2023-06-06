[![CI](https://github.com/TFS-iOS/chat-app-lyaskovetsiv/actions/workflows/.github.yml/badge.svg?branch=dz-cicd)](https://github.com/TFS-iOS/chat-app-lyaskovetsiv/actions/workflows/.github.yml)

**APP**: Messenger

**Description**: An application for communication between users

**Tech Stack**: UIKit, Filemanager, CoreData, UserDefaults, Keychain,  URLSession, Figma, Combine, SOA, MVP+Coordinator, UnitTests, UITests, TestPlans, SwiftLint, GCD, SSE, CICD, Fastlane, CoreAnimation

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

| <img width="303" alt="Снимок экрана 2023-06-06 в 16 29 23" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/3dbfd511-135f-4056-b14a-9102daa8900a">  | <img width="301" alt="Снимок экрана 2023-06-06 в 16 30 43" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/5cc551de-0a04-4529-91e6-b992655b770e"> | <img width="414" alt="Снимок экрана 2023-06-06 в 16 34 04" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/c870feb9-a1d2-4531-a360-26f1a223e41d">  | <img width="414" alt="Снимок экрана 2023-06-06 в 16 34 24" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/f5ee66b3-e715-4686-9667-a4d71892f98c">  |
| ------------- | ------------- | ------------- | ------------- |



