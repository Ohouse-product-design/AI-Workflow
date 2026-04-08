# List 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Basic** | 텍스트만 있는 리스트 |
| **Thumbnail** | 썸네일 + 텍스트 |
| **Action** | 우측에 액션 버튼/값 표시 |

## States
- **Default**: 데이터 있는 기본 상태
- **Loading**: 스켈레톤 2~3개 표시
- **Empty**: 일러스트 + 안내 + CTA
- **Error**: 에러 메시지 + 재시도 버튼

## 구성 요소
| 요소 | 필수 | 설명 |
|---|---|---|
| Title | 필수 | 1줄 (넘으면 ellipsis) |
| Description | 선택 | 보조 정보 |
| Thumbnail | 선택 | 56x56, border-radius 8px |
| Trailing | 선택 | 가격, 화살표, 스위치 등 |

## 규칙
1. 아이템 간 구분: `border-bottom: 1px solid gray.100`
2. 아이템 높이: 최소 56px (터치 타겟 확보)
3. 썸네일 크기 통일 (56x56 또는 48x48)
4. Empty 상태는 **행동 유도 CTA** 포함
5. Loading은 스켈레톤 사용 (전체 화면 스피너 X)
