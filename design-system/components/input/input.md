# Input 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Text** | 일반 텍스트 입력 |
| **Password** | 비밀번호 (마스킹) |
| **Search** | 검색 (돋보기 아이콘) |
| **Textarea** | 여러 줄 텍스트 |

## States
- **Default**: 빈 입력 필드 + 플레이스홀더
- **Focus**: 파란 테두리 + 포커스 링
- **Filled**: 값이 입력된 상태
- **Error**: 빨간 테두리 + 에러 메시지
- **Disabled**: 회색 배경 + 수정 불가

## 구성 요소
| 요소 | 필수 | 설명 |
|---|---|---|
| Label | 필수 | 인풋 위 라벨 (Body 2 Strong) |
| Input | 필수 | 44px 높이, 16px 내부 여백 |
| Placeholder | 권장 | 입력 안내 (`text.tertiary`) |
| Helper text | 선택 | 입력 안내 메시지 (Caption 1) |
| Error text | 조건부 | 에러 시 표시 (Caption 1, red) |

## 규칙
1. 라벨은 **반드시** 표시 (숨기려면 `aria-label` 필수)
2. 플레이스홀더는 라벨을 대체하지 않음
3. 에러 메시지는 **구체적**으로 ("입력해주세요" X → "이메일 형식이 올바르지 않습니다" O)
4. 모바일에서 `font-size: 16px` 이상 (iOS 줌 방지)
5. Textarea는 `resize: vertical`만 허용

## 접근성
- `<label>` + `for` 연결 필수
- 에러 시 `aria-invalid="true"` + `aria-describedby` 연결
- 필수 입력: `aria-required="true"`
