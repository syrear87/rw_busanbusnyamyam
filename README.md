# busanbusnyamyam

부산 버스 정보를 제공하는 Flutter 앱입니다.

## 개발 환경 설정

### 플랫폼별 local.properties 설정

이 프로젝트는 Windows와 macOS에서 모두 개발할 수 있도록 설정되어 있습니다. 각 플랫폼에서 처음 프로젝트를 클론한 후 다음 단계를 따라주세요:

#### Windows에서 설정하기
```bash
# Windows용 템플릿을 local.properties로 복사
cp android/local.properties.windows.template android/local.properties

# 실제 사용자명과 Flutter SDK 경로로 수정
# android/local.properties 파일을 열어서 [사용자명]을 실제 사용자명으로 변경
```

#### macOS에서 설정하기
```bash
# macOS용 템플릿을 local.properties로 복사
cp android/local.properties.macos.template android/local.properties

# 실제 사용자명과 Flutter SDK 경로로 수정
# android/local.properties 파일을 열어서 [사용자명]을 실제 사용자명으로 변경
```

### API 키 설정

Google Maps API 키는 이미 템플릿에 포함되어 있습니다. 필요시 `android/local.properties` 파일에서 `MAPS_ANDROID_KEY` 값을 수정하세요.

### 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# Android 빌드
flutter build apk --debug

# 앱 실행
flutter run
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
