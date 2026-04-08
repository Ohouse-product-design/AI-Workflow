# Tab 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Line** | 기본 탭 (하단 인디케이터 라인) |
| **Pill** | 둥근 필터형 탭 |

## States
- **Default**: 비활성 (`gray.600`)
- **Active**: 활성 (`gray.900` + 하단 라인)
- **Disabled**: 비활성 (`gray.400`, 클릭 불가)

## 규칙
1. 탭 수: **2~7개** (초과 시 가로 스크롤)
2. 활성 탭은 **한 번에 1개만**
3. 탭 라벨은 **2~4글자** 권장 (간결하게)
4. 뱃지는 숫자가 있을 때만 표시
5. 가로 스크롤 시 스크롤바 숨김
6. 탭 전환 시 페이지 이동 X, 콘텐츠 영역만 변경

## 접근성
- `role="tablist"` (컨테이너)
- `role="tab"` (각 탭)
- `aria-selected="true/false"`
- `aria-controls`로 패널 연결
- 좌우 방향키로 탭 이동
- `role="tabpanel"` (콘텐츠 패널)
