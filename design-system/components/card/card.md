# Card 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Bordered** | 기본 카드 (보더로 영역 구분) |
| **Elevated** | 그림자로 영역 구분 (hover 시) |
| **Selected** | 선택된 상태 (파란 테두리) |
| **Content** | 이미지 없는 텍스트 카드 |

## States
- **Default**: 기본 표시
- **Hover**: PC에서 그림자 level2 (`@media (hover: hover)`)
- **Selected**: `border: 2px solid #228BE6`
- **Skeleton**: 로딩 중 shimmer 애니메이션

## 구성 요소
| 요소 | 필수 | 설명 |
|---|---|---|
| Image | 선택 | 4:3 비율, `object-fit: cover` |
| Title | 필수 | Heading 3 (17px Semibold) |
| Description | 선택 | Body 2 (14px Regular) |
| Price | 선택 | Heading 2 (20px Bold) + 할인율 |
| Meta | 선택 | Caption 1 (12px) — 리뷰, 스크랩 등 |

## 규칙
1. 이미지 비율은 **4:3** 또는 **1:1** 통일
2. 타이틀은 **2줄 이내** (넘으면 `...` 처리)
3. 카드 내부 여백은 `16px` (inset.md)
4. 카드 간 간격은 `16px` (inline.lg)
5. 그리드에서 카드 크기는 동일하게 유지
6. `loading="lazy"` 이미지 지연 로딩 적용

## 접근성
- `<article>` 시맨틱 태그 사용
- 이미지에 의미 있는 `alt` 텍스트
- 카드 전체가 클릭 가능하면 `<a>` 또는 `role="link"` 사용
