# ODS (Ohouse Design System) — DESIGN.md

> 이 문서는 AI 에이전트(Claude Code, Claude Projects)가 오늘의집 디자인 시스템을 이해하고 일관된 UI를 생성하기 위한 컨텍스트입니다.
> 마지막 업데이트: 2026-04-08

---

## 1. Visual Theme & Atmosphere

오늘의집은 **"집에서 시작되는 라이프스타일"** 브랜드입니다.

- **톤**: 따뜻하고 신뢰감 있으며, 깔끔한 모던 미니멀
- **분위기**: 밝은 화이트 기반 + 블루 포인트. 과하지 않은 절제된 디자인
- **이미지**: 실제 인테리어 사진 중심, 고해상도 라이프스타일 이미지
- **느낌**: 편안한 집 → 신뢰 → 구매/참여로 이어지는 자연스러운 경험

### 브랜드 키워드
`따뜻한` `깔끔한` `신뢰감` `실용적` `라이프스타일`

### 절대 하지 않는 것
- 과도한 그라디언트, 네온 컬러
- 복잡한 3D 효과나 과한 모션
- 텍스트 위에 반투명 이미지 오버레이 (가독성 저해)

---

## 2. Color Palette & Roles

### Primary (브랜드 블루)
| 토큰 | HEX | 용도 |
|---|---|---|
| `action.primary` | #228BE6 | CTA 버튼, 주요 액션 |
| `action.primaryHover` | #1C7ED6 | 호버 상태 |
| `action.primaryActive` | #1971C2 | 눌린 상태 |
| `action.primaryDisabled` | #A5D8FF | 비활성 상태 |

### Gray Scale (중립색)
| 토큰 | HEX | 용도 |
|---|---|---|
| `text.primary` | #212529 | 주 텍스트 |
| `text.secondary` | #495057 | 보조 텍스트 |
| `text.tertiary` | #ADB5BD | 힌트, 플레이스홀더 |
| `border.default` | #DEE2E6 | 기본 구분선 |
| `background.secondary` | #F8F9FA | 섹션 배경 |

### Status Colors (상태색)
| 토큰 | HEX | 용도 |
|---|---|---|
| `status.error` | #FF6B6B | 에러, 삭제 |
| `status.success` | #51CF66 | 성공, 완료 |
| `status.warning` | #FD7E14 | 주의, 경고 |
| `status.info` | #339AF0 | 정보, 안내 |

### 사용 규칙
- Primary 컬러는 화면당 **1개 CTA**에만 사용
- Status 컬러는 텍스트+배경 쌍으로 사용 (예: red.700 텍스트 + red.50 배경)
- 배경색은 white/gray.50/gray.100 3단계 이내로 제한
- 명암비 최소 **4.5:1** (WCAG AA 기준)

> 상세: `tokens/colors.json` 참조

---

## 3. Typography Rules

### 타이포 위계
| 스타일 | 크기 | 무게 | 행간 | 용도 |
|---|---|---|---|---|
| Display 1 | 32px | Bold (700) | 40px | 히어로 타이틀 |
| Display 2 | 28px | Bold (700) | 36px | 섹션 대제목 |
| Heading 1 | 24px | Bold (700) | 32px | 페이지 타이틀 |
| Heading 2 | 20px | Semibold (600) | 28px | 서브 섹션 |
| Heading 3 | 17px | Semibold (600) | 24px | 소제목 |
| Body 1 | 16px | Regular (400) | 24px | 본문 (기본) |
| Body 2 | 14px | Regular (400) | 20px | 보조 텍스트 |
| Caption 1 | 12px | Regular (400) | 16px | 캡션, 타임스탬프 |
| Caption 2 | 11px | Medium (500) | 14px | 최소 텍스트 |

### 규칙
- 폰트: **Pretendard** (한글+영문 통합)
- 최소 크기: 11px (caption2) 미만 사용 금지
- 한글 본문: 최대 40자/줄 권장
- Heading은 한 화면에 3단계 이내로 사용 (예: H1 → H2 → H3)

> 상세: `tokens/typography.json` 참조

---

## 4. Component Stylings

### 주요 컴포넌트 10종

| 컴포넌트 | 상태 | 파일 |
|---|---|---|
| **Button** | Default, Hover, Active, Disabled, Loading | `components/button/` |
| **Card** | Default, Hover, Selected, Skeleton | `components/card/` |
| **Input** | Default, Focus, Filled, Error, Disabled | `components/input/` |
| **Navigation** | Default, Active, Badge | `components/navigation/` |
| **List** | Default, Loading, Empty, Error | `components/list/` |
| **Modal** | Default, Confirm, Alert | `components/modal/` |
| **Tab** | Default, Active, Disabled | `components/tab/` |
| **Toast** | Info, Success, Error, Warning | `components/toast/` |
| **Chip** | Default, Selected, Disabled | `components/chip/` |
| **BottomSheet** | Default, Scroll, Actions | `components/bottomsheet/` |

### 공통 규칙
- 모든 인터랙티브 요소는 **최소 44px 터치 타겟** 확보
- Disabled 상태는 `opacity: 0.4` + `pointer-events: none`
- Loading 상태는 인라인 스피너 사용 (전체 화면 로더 X)
- hover 효과는 **PC에서만** 적용 (`@media (hover: hover)`)

> 상세: `components/` 디렉토리의 각 컴포넌트별 HTML/MD 참조

---

## 5. Layout Principles

### 간격 스케일 (4px 기반)
```
4 → 8 → 12 → 16 → 20 → 24 → 32 → 40 → 48 → 64
```

### 그리드 시스템
| 디바이스 | 컬럼 | 거터 | 마진 | 브레이크포인트 |
|---|---|---|---|---|
| Mobile | 4 | 16px | 16px | < 768px |
| Tablet | 8 | 20px | 24px | 768px ~ 1023px |
| Desktop | 12 | 24px | 40px | >= 1024px |

### 간격 사용 원칙
- 같은 그룹 내 요소: `8px` (stack.sm)
- 요소 그룹 간: `16px` (stack.md)
- 섹션 간: `32px~48px` (sectionGap)
- 페이지 패딩: `16px` (mobile), `24px` (tablet), `40px` (desktop)
- 최대 콘텐츠 너비: `1200px`

> 상세: `tokens/spacing.json` 참조

---

## 6. Depth & Elevation

### 그림자 레벨
| 레벨 | 값 | 용도 |
|---|---|---|
| Level 0 | none | 기본 상태 |
| Level 1 | `0 1px 3px rgba(0,0,0,0.08)` | 카드, 호버 |
| Level 2 | `0 4px 6px rgba(0,0,0,0.07)` | 드롭다운, FAB |
| Level 3 | `0 10px 20px rgba(0,0,0,0.08)` | 모달, 바텀시트 |
| Level 4 | `0 20px 40px rgba(0,0,0,0.1)` | 토스트 |

### Border Radius
| 토큰 | 값 | 용도 |
|---|---|---|
| `sm` | 4px | 칩, 뱃지 |
| `md` | 8px | 카드, 인풋 |
| `lg` | 12px | 모달, 바텀시트 |
| `xl` | 16px | 큰 카드 |
| `full` | 9999px | 원형 버튼, 아바타 |

### 규칙
- 커스텀 그림자 값 금지 — 반드시 Level 0~4 토큰 사용
- z-index는 토큰 값만 사용 (임의의 `999`, `10000` 금지)
- 모달 위에 모달 금지 (최대 1 depth)
- 바텀시트 내부에 바텀시트 금지

> 상세: `tokens/elevation.json` 참조

---

## 7. Do's and Don'ts

### Do's
- Primary 버튼은 섹션당 **1개**만 사용
- 명암비 **4.5:1** 이상 유지 (WCAG AA)
- 터치 타겟 최소 **44px** 확보
- 상태별 UI 모두 디자인 (Default, Loading, Empty, Error, Success, Disabled)
- 텍스트는 시맨틱 컬러 토큰 사용 (`text.primary`, `text.secondary`)
- 여백은 4px 배수 스케일만 사용

### Don'ts
- 드롭쉐도우 커스텀 값 사용 금지
- `!important` 남용 금지
- 인라인 스타일 금지 (토큰/클래스 사용)
- 텍스트에 순수 검정(#000) 사용 금지 → `gray.900` (#212529) 사용
- 아이콘만 있는 버튼에 라벨 생략 금지 → `aria-label` 필수
- 스크롤 내부에 스크롤 중첩 금지
- 무한스크롤 + 하단 푸터 동시 사용 금지

---

## 8. Responsive Behavior

### 브레이크포인트
```css
/* Mobile First */
@media (min-width: 768px)  { /* Tablet */ }
@media (min-width: 1024px) { /* Desktop */ }
```

### 반응형 원칙
- **Mobile First** — 모바일부터 디자인, 큰 화면으로 확장
- 이미지 비율 유지 (`object-fit: cover`)
- 모바일 네비게이션: 바텀 내비게이션 바
- 데스크톱 네비게이션: 사이드 내비게이션 또는 탑 바
- 그리드 컬럼 축소: 12 → 8 → 4
- 터치 디바이스: hover 효과 제거 (`@media (hover: hover)`)

### 터치 타겟
| 요소 | 최소 크기 | 권장 크기 |
|---|---|---|
| 버튼 | 44 x 44px | 48 x 48px |
| 링크/탭 | 44 x 44px | 48 x 48px |
| 체크박스/라디오 | 44 x 44px | 48 x 48px |

---

## 9. Agent Prompt Guide

### AI에게 디자인 요청 시 포함할 정보
```
1. 화면 목적 (무엇을 하는 화면인가?)
2. 사용자 시나리오 (누가, 언제, 왜 이 화면을 보는가?)
3. 핵심 데이터 (어떤 데이터를 보여주는가?)
4. 주요 액션 (사용자가 할 수 있는 행동은?)
5. 상태 (Loading, Empty, Error 등 고려할 상태는?)
```

### 자주 쓰는 프롬프트 패턴
```
[화면명] 화면을 ODS 기반으로 HTML로 만들어줘.
- 모바일 퍼스트, 반응형
- Primary CTA: [버튼명]
- 데이터: [데이터 설명]
- 상태: Default, Loading, Empty, Error 포함
```

### CSS 변수 매핑 (HTML 생성 시 사용)
```css
:root {
  /* Colors */
  --color-primary: #228BE6;
  --color-primary-hover: #1C7ED6;
  --color-text-primary: #212529;
  --color-text-secondary: #495057;
  --color-text-tertiary: #ADB5BD;
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F8F9FA;
  --color-border: #DEE2E6;
  --color-error: #FF6B6B;
  --color-success: #51CF66;
  --color-warning: #FD7E14;

  /* Typography */
  --font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;

  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;

  /* Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;

  /* Shadow */
  --shadow-1: 0 1px 3px rgba(0,0,0,0.08);
  --shadow-2: 0 4px 6px rgba(0,0,0,0.07);
  --shadow-3: 0 10px 20px rgba(0,0,0,0.08);
}
```

### 컴포넌트 참조 경로
```
components/button/button.html    — 버튼 (5가지 상태)
components/card/card.html        — 카드 (4가지 상태)
components/input/input.html      — 인풋 (5가지 상태)
components/navigation/navigation.html — 네비게이션
components/list/list.html        — 리스트 (4가지 상태)
components/modal/modal.html      — 모달 (3가지)
components/tab/tab.html          — 탭
components/toast/toast.html      — 토스트 (4가지)
components/chip/chip.html        — 칩 (3가지 상태)
components/bottomsheet/bottomsheet.html — 바텀시트
```
