# BottomSheet 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Default** | 콘텐츠 + 하단 버튼 (옵션 선택, 필터 등) |
| **Action List** | 액션 목록 (더보기 메뉴) |
| **Scroll** | 긴 콘텐츠 (스크롤 가능) |

## 구성 요소
| 요소 | 필수 | 설명 |
|---|---|---|
| Handle bar | 필수 | 드래그 인디케이터 (36x4px) |
| Title | 필수 | Heading 2 (20px Semibold) |
| Close button | 선택 | 우측 X 버튼 |
| Body | 필수 | 콘텐츠 영역 (스크롤 가능) |
| Footer | 선택 | 하단 고정 버튼 영역 |

## 규칙
1. 최대 높이: **85vh** (화면의 85%)
2. 바텀시트 안에 바텀시트 금지 (**1 depth**)
3. Backdrop 클릭 시 닫힘
4. 하단 스와이프로 닫기 지원
5. Safe area 하단 패딩 적용 (`env(safe-area-inset-bottom)`)
6. 진입: 아래에서 위로 슬라이드 (0.3s)
7. Danger 액션은 **빨간 텍스트**로 구분

## 접근성
- `role="dialog"` + `aria-modal="true"`
- `aria-labelledby`로 타이틀 연결
- 포커스 트랩 (Tab 키 시트 내부에서 순환)
- ESC 키로 닫기
- Action List에서 `role="menu"` + `role="menuitem"` 사용
