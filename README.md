https://apps.apple.com/kr/app/id6741587531

# Minesweeper - 지뢰찾기 게임

## 프로젝트 개요
SwiftUI와 MVVM 패턴을 활용하여 개발한 지뢰찾기 게임입니다.  
게임 내 기록 저장 및 Game Center 연동을 통해 플레이어의 순위를 확인할 수 있으며, 깃발 뽑기 시스템을 도입하여 사용자 경험을 향상시켰습니다.

---

## 기술 스택
- **언어:** Swift 5.0
- **UI 프레임워크:** SwiftUI
- **아키텍처:** MVVM (Model-View-ViewModel)
- **데이터 관리:** UserDefaults
- **게임 서비스 연동:** Game Center
- **다국어 지원:** Localization (한국어, 영어, 일본어, 중국어(간체/번체), 러시아어, 베트남어)

---

## 주요 기능
- **지뢰찾기 게임:** 사용자가 쉽게 플레이할 수 있도록 직관적인 UI 제공
- **깃발 뽑기 시스템:** 게임 내 포인트를 활용한 깃발 컬렉션 기능
- **게임 기록 통계:** 클리어 시간, 뽑기 횟수, 찾은 지뢰 수 등의 데이터 저장 및 시각화
- **Game Center 연동:** 개인 및 글로벌 랭킹 시스템 제공
- **다국어 지원:** `Localizable.strings`을 활용하여 다국어 인터페이스 제공

---

## 📂 프로젝트 구조 (MVVM)
```
Minesweeper/
├─ Model           // 게임 데이터 및 로직
├─ View            // SwiftUI 기반 화면 구성
├─ ViewModel       // UI와 Model을 연결하는 비즈니스 로직
├─ Utilities       // 햅틱 관련, 광고 배너, 다국어 지원(Localizable.strings)
└─ App Entry Point // 앱 진입점

```

---

## 다국어 지원 (Localization)
- **지원 언어:** 한국어, 영어, 일본어, 중국어(간체/번체), 러시아어, 베트남어
- `Localizable.strings` 파일을 활용하여 언어별 UI 지원

---

## 프로젝트 목적 및 성과
이 프로젝트는 **SwiftUI 및 MVVM 패턴을 활용한 iOS 앱 개발 경험을 확장**하고,  
**Game Center 연동 및 다국어 지원을 적용한 프로젝트**로서 의미가 있습니다.  
이를 통해 **사용자 친화적인 UI/UX 설계**, **데이터 관리**, **외부 API(Game Center) 연동 경험**을 쌓았습니다.

---

## 
- **SwiftUI를 활용한 UI 개발 경험**
- **MVVM 아키텍처를 기반으로 한 상태 관리 및 데이터 연동**
- **Game Center를 활용한 게임 순위 시스템 구축**
- **UserDefaults를 활용한 로컬 데이터 저장 및 관리**
- **다국어(Localization) 적용 및 글로벌 사용자 대응 경험**
- **앱스토어 배포 및 운영 경험**

---
