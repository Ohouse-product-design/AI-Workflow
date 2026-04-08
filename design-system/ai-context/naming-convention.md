# ODS 네이밍 컨벤션

> Figma 레이어, CSS 클래스, 토큰 이름 모두 이 컨벤션을 따릅니다.

---

## 컴포넌트 네이밍 구조

```
Category / Component / Variant / State
```

### 예시
```
Button / Primary / Large / Default
Button / Primary / Large / Hover
Button / Primary / Large / Disabled
Card / Product / Bordered / Skeleton
Input / Text / Default / Error
Navigation / Bottom / Default / Active
```

## 레이어 이름 (Figma)

### 규칙
1. **의미 있는 이름** 사용 — "Frame 124" 금지
2. **영문** 사용 — 한글 레이어 이름 금지
3. **PascalCase** — 컴포넌트: `ProductCard`, `PrimaryButton`
4. **kebab-case** — 속성: `bg-primary`, `text-secondary`
5. **슬래시(/)로 계층 구분** — `Button/Primary/Large`

### Do's
```
✅ Button/Primary/Large
✅ Card/Product/Default
✅ Icon/Heart/Filled
✅ Text/Heading1
✅ Input/TextField/Error
```

### Don'ts
```
❌ Frame 124
❌ Group 3
❌ 버튼/기본
❌ btn-primary-lg (축약 금지)
❌ Button (너무 모호 — Variant 필수)
```

## CSS 클래스 네이밍

### BEM-like Convention
```
.ods-{component}__{element}--{modifier}
```

### 예시
```css
.ods-btn                    /* Component */
.ods-btn__label             /* Element */
.ods-btn--primary           /* Modifier: variant */
.ods-btn--lg                /* Modifier: size */
.ods-btn--disabled          /* Modifier: state */
.ods-btn--loading           /* Modifier: state */

.ods-card                   /* Component */
.ods-card__image            /* Element */
.ods-card__title            /* Element */
.ods-card--bordered         /* Modifier */
.ods-card--skeleton         /* Modifier: state */
```

### 규칙
1. 접두사 `ods-` 필수 (충돌 방지)
2. Component: `ods-{name}` (kebab-case)
3. Element: `__{name}` (더블 언더스코어)
4. Modifier: `--{name}` (더블 하이픈)
5. 축약은 널리 알려진 것만: `btn`, `img`, `nav`
6. 상태: `--active`, `--disabled`, `--loading`, `--error`, `--selected`

## 디자인 토큰 네이밍

### 구조
```
{category}.{property}.{variant}
```

### 예시
```json
"semantic.text.primary"       // 주 텍스트 색상
"semantic.action.primary"     // 주요 액션 색상
"semantic.background.secondary" // 보조 배경 색상
"scale.heading1.fontSize"     // Heading 1 폰트 크기
"spacing.inset.md"            // 중간 내부 여백
"elevation.shadow.level2"     // 그림자 레벨 2
```

### 카테고리
| 카테고리 | 설명 | 예시 |
|---|---|---|
| `primitive` | 원시 색상값 | `primitive.blue.600` |
| `semantic` | 역할 기반 | `semantic.text.primary` |
| `scale` | 타이포 위계 | `scale.body1` |
| `spacing` | 간격 | `spacing.stack.md` |
| `elevation` | 깊이 | `elevation.shadow.level1` |

## 파일/폴더 네이밍

```
design-system/
├── tokens/
│   └── colors.json          # kebab-case, 복수형 금지 X → 복수형 OK (토큰 모음)
├── components/
│   └── button/              # 단수형, 소문자
│       ├── button.html      # 컴포넌트명 반복
│       └── button.md
├── foundations/
│   └── color-system.md      # kebab-case
└── ai-context/
    └── system-prompt.md     # kebab-case
```

## 상태(State) 이름 통일

| 상태 | CSS Modifier | Figma Layer | 설명 |
|---|---|---|---|
| 기본 | (없음) | Default | 기본 상태 |
| 호버 | `:hover` / `--hover` | Hover | PC에서만 |
| 활성 | `:active` / `--active` | Active/Pressed | 눌린 상태 |
| 포커스 | `:focus` / `--focus` | Focus | 키보드 포커스 |
| 비활성 | `--disabled` / `:disabled` | Disabled | 조작 불가 |
| 에러 | `--error` | Error | 유효성 오류 |
| 로딩 | `--loading` | Loading | 비동기 처리 중 |
| 선택됨 | `--selected` | Selected | 다중 선택 |
| 스켈레톤 | `--skeleton` | Skeleton | 로딩 플레이스홀더 |
