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


**ChatList&Chat screens**:
| <img width="416" alt="Снимок экрана 2023-06-06 в 16 43 10" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/c3248ff3-a54f-40b4-9f4d-f41661141aaf">  | <img width="411" alt="Снимок экрана 2023-06-06 в 16 43 32" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/caf3b89f-b74a-44e9-a40f-cfb2b1c82633"> | 
| ------------- | ------------- | 

**Profile&EditProfile screenss**:

| <img width="414" alt="Снимок экрана 2023-06-06 в 16 34 04" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/6ef8d84b-21e1-4162-a295-c538cccee3d5">  | <img width="414" alt="Снимок экрана 2023-06-06 в 16 34 24" src="https://github.com/lyaskovetsiv/TinkoffChatApp/assets/100786077/db11fb2f-3e39-4334-8c35-6b676887baa0"> | 
| ------------- | ------------- | 







