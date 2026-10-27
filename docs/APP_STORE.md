# App Store 제출 자료

iOS 출시에 필요한 값과 문구를 한곳에 모았습니다. App Store Connect에 그대로 붙여 넣으면 됩니다.

## 0. 이미 준비된 것

| 항목 | 상태 |
|---|---|
| 번들 ID | `com.tabatatimer.tabataTimer` — Xcode 자동 서명으로 개발자 계정(팀 `88PAJW7HTT`)에 등록됨 |
| 서명 | Apple Distribution 인증서 + App Store 프로필(자동 관리) |
| 빌드 | 1.5.0 (11), iPhone 전용, iOS 15.0 이상, 세로 화면 |
| 수출 규정 | `ITSAppUsesNonExemptEncryption = NO` (업로드 때 암호화 질문 없음) |
| 개인정보 매니페스트 | `ios/Runner/PrivacyInfo.xcprivacy` — 추적 없음, 수집 데이터 없음 |
| 앱 이름 | App Store·홈 화면·앱 안 모두 **Spark Timer** (스토어 이름과 기기 이름을 맞춤, 가이드라인 2.3.8) |
| 스크린샷 | 6.9" (1320×2868) 한국어·영어 각 7장 — `store/screenshots/ios/{ko,en}/` |
| 업로드 | `tool/ios_release.sh` (앱 레코드가 생기면 실행) |

## 1. 웹에서 할 일 (App Store Connect)

1. **앱 만들기** — [App Store Connect](https://appstoreconnect.apple.com) › 앱 › ＋ › 신규 앱
   - 플랫폼: iOS
   - 이름: `Spark Timer` ✅ (생성됨)
   - 기본 언어: 한국어
   - 번들 ID: `com.tabatatimer.tabataTimer`
   - SKU: `tabata-timer-ios`
   - 사용자 액세스: 전체 액세스
2. **빌드 업로드** — 앱을 만든 뒤 알려 주시면 `tool/ios_release.sh`로 올립니다(Transporter 앱에 `build/ios/ipa/tabata_timer.ipa`를 끌어다 놓아도 됨). 업로드 후 10~30분 뒤 TestFlight 탭에 빌드가 보입니다.
3. **앱 정보** — 부제, 카테고리(건강 및 피트니스), 개인정보 처리방침 URL, 연령 등급(아래 4장)
4. **영어 현지화 추가** — 앱 정보 상단의 언어 메뉴에서 English (U.S.) 추가 → 영어 이름·부제·설명·키워드·스크린샷
5. **가격 및 사용 가능 여부** — 무료, 국가 선택
6. **앱 개인정보 보호** — "데이터를 수집하지 않음" 선택 후 게시
7. **버전 1.5.0 페이지** — 스크린샷(6.9"), 프로모션 텍스트, 설명, 키워드, 지원 URL, 저작권, 빌드 선택, 앱 심사 정보(연락처 + 아래 심사 메모)
8. **심사에 제출** — 출시 방식은 "승인 후 자동 출시" 또는 "수동 출시"

## 2. 문구

### 한국어 (기본)

**이름** (30자): `Spark Timer`

**부제** (30자, 검색에 반영 — 이름에 없는 '타바타'·'HIIT'를 여기에): `타바타·HIIT 음성 인터벌 타이머`

**프로모션 텍스트** (170자):
```
20초 운동, 10초 휴식. 화면을 보지 않아도 매초 신호음과 음성 안내로 다음 동작을 알려줘요. 음악을 들으면서, 화면이 꺼져도 계속 동작합니다.
```

**설명**:
```
모드를 고르고, 숫자 두어 개만 바꾸고, 시작. 타바타부터 인터벌(HIIT), EMOM, AMRAP, For Time, 세트 사이 휴식까지 한 앱에서.

■ 6가지 타이머
• 타바타 — 20초 운동 + 10초 휴식 × 8라운드
• 인터벌(HIIT) — 웜업·세트·세트 간 휴식·쿨다운까지 자유롭게
• EMOM — 매 간격마다 새 라운드
• AMRAP — 제한 시간 안에 최대한 많은 라운드, 탭으로 라운드 카운트
• For Time — 최대한 빨리, 랩 기록과 타임캡
• 휴식 — 세트 사이 휴식, +15초 연장

■ 멀리서도 보이는 운동 화면
단계마다 화면 전체가 색으로 바뀌어요(운동 파랑 · 휴식 청록 · 준비 보라). 큰 숫자, 원형 진행 링, 전체 타임라인, 다음 단계 미리보기.

■ 보지 않아도 아는 안내
매초 짧은 신호음, 마지막 3-2-1, 구간이 끝나면 긴 신호음과 함께 "운동 시작", "휴식. 다음은 버피"처럼 음성으로 알려줘요. 기기에서 가장 자연스러운 목소리를 자동으로 고르고, 설정에서 미리 듣고 바꿀 수 있어요.

■ 음악과 함께, 화면이 꺼져도
듣던 음악 위에 안내음이 겹쳐 나오고, 화면이 꺼지거나 다른 앱으로 넘어가도 타이머가 계속 동작합니다.

■ 루틴과 기록
• 기본 루틴 9가지, 라운드마다 운동 이름(서킷)
• 시작 전 예상 강도, 운동 뒤 체감 강도 기록
• 주간 운동 시간 차트, 연속 운동일, 칼로리 추정

■ 눈이 편한 화면
다크 모드와 눈부시지 않은 라이트 모드. 한국어와 영어 지원.

회원가입도, 광고도, 데이터 수집도 없습니다. 모든 기록은 기기 안에만 저장돼요.
```

**키워드** (100바이트, 이름에 있는 단어 제외):
```
EMOM,AMRAP,홈트,서킷,크로스핏,운동,휴식,스톱워치,라운드,세트,피트니스
```

### English (U.S.)

**Name** (30): `Spark Timer`

**Subtitle** (30, searchable — carries 'Tabata' and 'HIIT'): `Tabata & HIIT voice interval`

**Promotional text** (170):
```
20 seconds on, 10 off. A beep every second and spoken cues tell you what is next, so you never have to look. Keeps going over your music, even with the screen off.
```

**Description**:
```
Pick a mode, adjust a number or two, tap Start. Tabata, intervals (HIIT), EMOM, AMRAP, For Time and rest between sets — all in one app.

■ Six timers
• Tabata — 20s work + 10s rest × 8 rounds
• Interval (HIIT) — warm-up, sets, rest between sets and cool-down, your way
• EMOM — a new round at the top of every interval
• AMRAP — as many rounds as possible, tap to count rounds
• For Time — as fast as you can, with laps and a time cap
• Rest — rest between sets, +15s when you need it

■ Readable from across the room
The whole screen takes the color of each phase (work blue, rest teal, get-ready violet), with a huge countdown, a progress ring, the full timeline and what's next.

■ Cues you don't have to look at
A short beep every second, a 3-2-1 countdown, then a long beep and a spoken cue like "Go" or "Rest. Next up, burpees". The most natural voice on your device is picked for you; preview and change it in Settings.

■ With your music, even with the screen off
Cues play over the music you're listening to, and the timer keeps running when the screen locks or you switch apps.

■ Routines and history
• Nine built-in routines, exercise names per round (circuits)
• Expected intensity before you start, how it felt after
• Weekly chart, streaks and calorie estimates

■ Easy on the eyes
Dark mode and a soft light mode. English and Korean.

No sign-up, no ads, no data collection. Everything stays on your device.
```

**Keywords** (100):
```
emom,amrap,workout,circuit,crossfit,fitness,round,rest,stopwatch,gym,training,exercise,boxing
```

### 공통

| 항목 | 값 |
|---|---|
| 카테고리 | 건강 및 피트니스 (보조: 스포츠) |
| 지원 URL | `https://github.com/sionhyeop/tabata-timer/issues` |
| 마케팅 URL (선택) | `https://github.com/sionhyeop/tabata-timer` |
| 개인정보 처리방침 URL | `https://github.com/sionhyeop/tabata-timer/blob/main/docs/PRIVACY.md` |
| 저작권 | `2026 SANGHYEOP LEE` |
| 가격 | 무료 |

## 3. 앱 심사 정보

- 로그인 필요 없음 (데모 계정 칸 비움)
- 연락처: 이름·전화번호·이메일은 직접 입력

**심사 메모** (영어로 제출):
```
No account is needed. Tap Start on the Timer tab to run a workout.

Background audio: this is a workout interval timer. During a workout it plays audible cues — a beep every second, countdown beeps and spoken announcements ("Go", "Rest. Next up, burpees") — so the user can follow the workout without looking at the screen, including when the screen is locked or another app such as a music player is in front. Audio mixes with the user's music. Background audio is active only while a workout is running and stops when it ends.

To test: start the Tabata timer, lock the device, and listen to the cues continue.
```

## 4. 연령 등급 설문

모든 항목 "없음" / "아니요" → **4+**
(폭력·성적 콘텐츠·도박·의료 정보·웹 접근·사용자 생성 콘텐츠·메시징 모두 없음)

## 5. 앱 개인정보 보호 (영양 라벨)

"데이터를 수집하지 않음(Data Not Collected)" — 개인정보 처리방침과 `PrivacyInfo.xcprivacy`와 일치합니다.

## 6. 스크린샷 순서

`store/screenshots/ios/{ko,en}/` 파일 이름 순서대로 올립니다.

1. 운동 중 (운동 · 스쿼트)
2. 타이머 설정
3. 내 루틴
4. 휴식 (다음 · 푸시업)
5. 기록 (주간 차트)
6. 운동 완료
7. 라이트 모드

다시 만들기: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/store_screenshots_test.dart --dart-define=STORE_LANG=ko -d <iPhone 17 Pro Max 시뮬레이터>` (영어는 `STORE_LANG=en`) → `build/screenshots/store_*`.

## 7. 다음 버전 올리기

1. `pubspec.yaml`의 `version`을 올림 (예: `1.5.1+12` — 빌드 번호는 매번 커져야 함)
2. `tool/ios_release.sh` — IPA 빌드 + App Store Connect 업로드
3. App Store Connect에서 새 버전 만들고 "이 버전의 새로운 기능" 입력 → 빌드 선택 → 심사 제출
