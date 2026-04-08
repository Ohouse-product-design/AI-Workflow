# 컬러 시스템 가이드

## 구조: Primitive → Semantic

ODS 컬러는 2레이어 구조로 관리됩니다.

### Primitive (원시 컬러)
브랜드에서 사용하는 모든 색상의 원본 팔레트. 직접 사용하지 않고, Semantic 토큰을 통해 참조합니다.

- **Gray**: 50~900 (10단계) — 텍스트, 배경, 보더
- **Blue**: 50~900 — 브랜드 Primary
- **Red**: 50~900 — 에러, 삭제
- **Green**: 50~900 — 성공, 완료
- **Orange**: 50~900 — 경고
- **Teal**: 50~900 — 보조 액센트

### Semantic (역할 기반 컬러)
UI 요소의 **역할**에 따라 매핑된 토큰. 코드에서는 항상 Semantic 토큰을 사용합니다.

#### Background
| 토큰 | 값 | 사용처 |
|---|---|---|
| `background.primary` | white | 기본 배경 |
| `background.secondary` | gray.50 | 섹션 구분 배경 |
| `background.tertiary` | gray.100 | 인풋 필드, 카드 내 영역 |
| `background.inverse` | gray.900 | 다크 배경 (스낵바 등) |
| `background.brand` | blue.50 | 브랜드 하이라이트 영역 |

#### Text
| 토큰 | 값 | 사용처 |
|---|---|---|
| `text.primary` | gray.900 | 주 텍스트 (제목, 본문) |
| `text.secondary` | gray.700 | 보조 텍스트 (설명, 부제) |
| `text.tertiary` | gray.500 | 힌트, 플레이스홀더 |
| `text.disabled` | gray.400 | 비활성 텍스트 |
| `text.inverse` | white | 다크 배경 위 텍스트 |
| `text.brand` | blue.700 | 링크, 강조 텍스트 |
| `text.error` | red.700 | 에러 메시지 |

#### Action
| 토큰 | 값 | 사용처 |
|---|---|---|
| `action.primary` | blue.600 | CTA 버튼 |
| `action.primaryHover` | blue.700 | 호버 |
| `action.primaryActive` | blue.800 | 프레스 |
| `action.danger` | red.600 | 삭제/위험 액션 |
| `action.secondary` | gray.100 | 보조 버튼 배경 |

## 사용 규칙

### 명암비 (Contrast Ratio)
- 일반 텍스트: **4.5:1** 이상 (WCAG AA)
- 큰 텍스트 (18px Bold 이상): **3:1** 이상
- UI 컴포넌트: **3:1** 이상

### 조합 가이드
```
좋은 조합:
  text.primary + background.primary     → 15.4:1 ✅
  text.secondary + background.primary   → 9.7:1  ✅
  text.inverse + action.primary         → 5.2:1  ✅

나쁜 조합:
  text.tertiary + background.tertiary   → 2.8:1  ❌ (대비 부족)
  status.warning + background.primary   → 2.9:1  ❌ (경고색 단독 사용)
```

### Status 컬러 조합
상태 색상은 항상 **텍스트 + 배경** 쌍으로 사용합니다:
- Error: `red.700` (텍스트) + `red.50` (배경)
- Success: `green.700` (텍스트) + `green.50` (배경)
- Warning: `orange.700` (텍스트) + `orange.50` (배경)
- Info: `blue.700` (텍스트) + `blue.50` (배경)

> 토큰 파일: `../tokens/colors.json`
