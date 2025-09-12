# API 키 설정 가이드

이 프로젝트를 실행하기 위해 다음 API 키들이 필요합니다.

## 1. 부산시 버스정보시스템(BIS) 서비스 키

### 발급 방법
1. [공공데이터포털](https://data.go.kr/) 접속
2. 회원가입 후 로그인
3. "부산시 버스정보시스템(BIS)" 검색
4. API 신청 및 승인 대기
5. 승인 후 서비스 키 확인

### 설정 방법
`lib/core/config/api_keys.dart` 파일에서 `bisServiceKey` 값을 설정하세요.

```dart
static const String bisServiceKey = '실제_서비스_키_입력';
```

## 2. Google Maps API 키

### 발급 방법
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 생성 또는 선택
3. "APIs & Services" > "Credentials" 이동
4. "Create Credentials" > "API Key" 선택
5. 필요한 API 활성화:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (선택사항)

### 설정 방법

#### Android
`android/local.properties` 파일에서 `MAPS_ANDROID_KEY` 값을 설정하세요.

```properties
MAPS_ANDROID_KEY=실제_Android_API_키_입력
```

#### iOS
`ios/Runner/Config.xcconfig` 파일에서 `GOOGLE_MAPS_IOS_KEY` 값을 설정하세요.

```
GOOGLE_MAPS_IOS_KEY = 실제_iOS_API_키_입력
```

## 보안 주의사항

- API 키는 절대 공개 저장소에 커밋하지 마세요
- `.gitignore` 파일에 다음 항목들이 포함되어 있습니다:
  - `lib/core/config/api_keys.dart`
  - `android/local.properties`
  - `ios/Runner/Config.xcconfig`

## 대안: 환경 변수 사용

더 안전한 방법으로 환경 변수를 사용할 수 있습니다:

```bash
# 실행 시 환경 변수로 전달
flutter run --dart-define=BIS_SERVICE_KEY=실제_서비스_키
```

이 경우 `lib/core/config/api_keys.dart`의 설정은 무시되고 환경 변수가 우선 사용됩니다.
