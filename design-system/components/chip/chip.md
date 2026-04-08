# Chip 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Filter** | 필터 선택/해제 (토글) |
| **Removable** | 적용된 필터 표시 (X 버튼으로 제거) |
| **Display** | 태그 표시 (클릭 불가) |

## States
- **Default**: 흰 배경 + 회색 보더
- **Selected**: 파란 배경 + 파란 보더 + 파란 텍스트
- **Disabled**: `opacity: 0.4` + 클릭 불가

## 규칙
1. 높이: **32px** (고정)
2. 모서리: **fully rounded** (9999px)
3. 라벨: **1~6글자** 권장
4. 칩 간격: **8px**
5. 가로 넘침 시: `flex-wrap` (줄바꿈) 또는 가로 스크롤
6. 멀티 선택 시 `aria-pressed` 사용

## 접근성
- 토글형: `aria-pressed="true/false"`
- 제거 버튼: `aria-label="[라벨] 필터 제거"`
- 키보드 Tab으로 포커스 이동
