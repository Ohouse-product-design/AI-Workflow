# 타이포그래피 시스템 가이드

## 폰트 패밀리

### Primary: Pretendard
한글과 영문을 모두 커버하는 통합 폰트. Apple SF Pro와 유사한 깔끔한 산세리프.

```css
font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

### Mono: JetBrains Mono
코드, 숫자 강조 등 모노스페이스가 필요한 경우.

```css
font-family: 'JetBrains Mono', 'SF Mono', Consolas, monospace;
```

## 타이포 위계

### Display (히어로/대제목)
- **Display 1**: 32/40, Bold — 히어로 영역 메인 타이틀
- **Display 2**: 28/36, Bold — 섹션 대제목

### Heading (제목)
- **Heading 1**: 24/32, Bold — 페이지 타이틀
- **Heading 2**: 20/28, Semibold — 서브 섹션 헤딩, 카드 타이틀
- **Heading 3**: 17/24, Semibold — 리스트 아이템 타이틀, 소제목

### Body (본문)
- **Body 1**: 16/24, Regular — 기본 본문
- **Body 1 Strong**: 16/24, Medium — 본문 강조
- **Body 2**: 14/20, Regular — 보조 텍스트, 설명
- **Body 2 Strong**: 14/20, Medium — 보조 강조, 버튼 레이블

### Caption (캡션)
- **Caption 1**: 12/16, Regular — 캡션, 타임스탬프, 뱃지
- **Caption 2**: 11/14, Medium — 최소 텍스트

## 사용 규칙

### 위계 제한
한 화면에서 Heading은 **최대 3단계**까지만 사용합니다.
```
✅ H1 → H2 → H3
✅ H2 → H3 → Body
❌ H1 → H2 → H3 → H4 (4단계 금지)
```

### 줄 길이
- 한글: 한 줄에 **최대 40자** 권장
- 영문: 한 줄에 **최대 80자** 권장
- 이보다 길어지면 컨테이너 너비를 줄이거나 컬럼 분할

### 문단 간격
- 같은 문단 내: `line-height`로 충분
- 문단 사이: `line-height`의 50% 추가 (Body 1 기준 12px)

### 텍스트 정렬
- 본문: **좌측 정렬** (기본)
- 숫자/가격: **우측 정렬**
- 헤딩: 좌측 정렬 (중앙 정렬은 히어로 영역에서만)
- 버튼: **중앙 정렬**

### 접근성
- 최소 폰트 크기: **11px** (Caption 2)
- 본문 최소 권장: **14px** (Body 2)
- `font-size` 단위는 `px` 또는 `rem` 사용 (1rem = 16px)

> 토큰 파일: `../tokens/typography.json`
