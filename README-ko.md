# Gray

<div align="center">

[![CI Status](https://travis-ci.com/zenangst/Gray.svg?branch=master)](https://travis-ci.com/zenangst/Gray)
![Swift](https://img.shields.io/badge/%20in-swift%204.2-orange.svg)
[![macOS](https://img.shields.io/badge/macOS-10.14-green.svg)](https://www.apple.com/macos/mojave/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

<img src="https://github.com/zenangst/Gray/blob/master/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png?raw=true" alt="Gray Icon" align="right" />

현재 버전: 0.15.0 [[내려받기](https://github.com/zenangst/Gray/releases/download/0.15.0/Gray.zip)]

라이트 모드와 다크 모드로 설정된 앱이 조화롭게 공존하는 것을 원해 본 적이 있나요? 이제 할 수 있답니다. **Gray**를 사용하면 버튼 클릭 한 번으로 앱마다 라이트 모드와 다크 모드 중에 하나가 표시되게끔 할 수 있습니다.

마이클 잭슨:
> 검은 색이든 하얀 색이든 그런 건 중요하지 않아

### 지침

`시스템 환경설정 > 일반`에서 Mac의 화면 모드가 다크 모드로 되게끔 설정하세요.

변경하려는 응용 프로그램을 다시 시작해야 변경 내용으로 표시된다는 것을 **참고**하세요. 이 작업은 현재 **Gray**에서 처리되지만 macOS 환경을 조정하기 전에 저장되지 않은 변경 사항이 없는지 확인해야 합니다.

<img alt="Gray" src="https://github.com/zenangst/Gray/blob/master/Images/Screenshot.png">

### 작동 방식

**Gray**는 겉으로 드러나지 않게 라이트 모드를 강제로 사용해야 하는 앱을 구성합니다. 터미널 명령을 실행하면 굳이 **Gray**를 설치하지 않고도 이 작업을 수행할 수 있습니다.

```fish
defaults write com.apple.dt.Xcode NSRequiresAquaSystemAppearance -bool YES
```

이 명령은 특정 응용 프로그램에 대한 사용자의 구성 파일에 새 항목을 생성합니다. 따라서 어떤 식으로도 시스템을 변경하지 않습니다. 그래서 구성이 끝나고 나면, 원한다면 **Gray**를 휴지통에 버릴 수 있습니다. (그러지는 않았으면 좋겠네요 :) )

## 빌드

Xcode를 사용하여 `Gray`를 빌드하고 싶다면 다음 지침을 따르세요.

```fish
git clone git@github.com:zenangst/Gray.git
cd Gray
pod install
open Gray.xcworkspace
```

즐거운 코딩하세요!

## 제작

Christoffer Winterkvist, christoffer@winterkvist.com

## 라이선스

**Gray**는 MIT 라이센스 하에 이용 가능합니다. 자세한 내용은 [라이선스](https://github.com/zenangst/Gray/blob/master/LICENSE.md) 파일을 참고하세요.
