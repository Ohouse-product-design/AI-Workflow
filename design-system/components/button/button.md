# Button 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Primary** | 주요 CTA. 섹션당 1개만 사용 |
| **Secondary** | 보조 액션 (취소, 이전 등) |
| **Outline** | 덜 중요한 액션 (더보기, 필터 등) |
| **Ghost** | 최소 강조 (건너뛰기, 링크형 버튼) |
| **Danger** | 삭제, 탈퇴 등 위험 액션 |

## Sizes
| Size | 높이 | 용도 |
|---|---|---|
| Small | 36px | 테이블 내, 인라인 액션 |
| Medium (기본) | 44px | 일반 버튼 |
| Large | 52px | 풀스크린 CTA, 결제 등 |

## States
- **Default**: 기본 상태
- **Hover**: PC에서만 (`@media (hover: hover)`)
- **Active**: 눌린 상태 (배경 진하게)
- **Disabled**: `opacity: 0.4`, 클릭 불가
- **Loading**: 레이블 숨기고 스피너 표시

## 규칙
1. Primary 버튼은 한 섹션에 **1개만** 배치
2. 버튼 레이블은 **동사형** ("저장하기", "구매하기")
3. 아이콘만 있는 버튼은 반드시 `aria-label` 추가
4. 최소 터치 영역 **44px** 확보
5. Loading 중에는 반복 클릭 방지 (`pointer-events: none`)
6. Danger 버튼은 반드시 **확인 모달**과 함께 사용

## 조합
- Primary + Secondary: 확인/취소 쌍
- Primary + Ghost: 메인 액션 + 건너뛰기
- Outline 여러 개: 필터, 정렬 옵션 그룹

## 접근성
- `role="button"` (비 button 요소 사용 시)
- `aria-disabled="true"` (disabled 상태)
- `aria-busy="true"` (loading 상태)
- 키보드 포커스 가능 (`tabindex="0"`)
- Enter/Space 키로 활성화
