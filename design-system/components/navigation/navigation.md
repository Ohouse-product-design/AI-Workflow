# Navigation 사용 규칙

## Variants
| Variant | 용도 | 디바이스 |
|---|---|---|
| **Bottom Nav** | 메인 네비게이션 (최대 5개 탭) | Mobile |
| **Top Bar** | 페이지 타이틀 + 뒤로가기 + 액션 | Mobile |
| **Side Nav** | 사이드 메뉴 | Desktop/Tablet |

## Bottom Navigation
- 탭 수: **3~5개** (5개 초과 금지)
- 아이콘 + 라벨 조합 (아이콘만 사용 금지)
- 현재 탭: `color: gray.900` (진하게)
- 비활성 탭: `color: gray.600`
- 뱃지: 알림 수 표시 (빨간 원형)
- Safe area 하단 패딩 (`env(safe-area-inset-bottom)`)

## Top Bar
- 높이: **56px**
- 뒤로가기: 좌측 (24px 아이콘)
- 타이틀: 중앙 정렬 (Heading 3)
- 액션: 우측 (공유, 검색, 더보기 등)
- `position: sticky` + `z-index: 200`

## 규칙
1. Bottom Nav는 앱 전체에서 **동일한 구조** 유지
2. 현재 페이지 탭에 `aria-current="page"` 추가
3. Top Bar 타이틀은 화면 목적을 명확히 전달
4. 뒤로가기 버튼에 `aria-label="뒤로 가기"` 필수
5. 스크롤 시 Top Bar는 sticky, Bottom Nav는 고정

## 접근성
- `<nav>` + `aria-label` 사용
- 현재 탭에 `aria-current="page"`
- 키보드 좌우 방향키로 탭 이동 가능
