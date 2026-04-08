# Modal 사용 규칙

## Variants
| Variant | 용도 |
|---|---|
| **Default** | 제목 + 본문 + 버튼 2개 (확인/취소) |
| **Confirm** | 단순 확인 (버튼 1개) |
| **Alert** | 아이콘 중심 경고/알림 |

## 구성 요소
| 요소 | 필수 | 설명 |
|---|---|---|
| Backdrop | 필수 | `rgba(0,0,0,0.5)` 딤 처리 |
| Title | 필수 | Heading 2 (20px Semibold) |
| Body | 필수 | 본문 설명 |
| Footer | 필수 | 버튼 영역 |
| Close button | 선택 | 우측 상단 X 버튼 |

## 규칙
1. 모달 위에 모달 금지 (**최대 1 depth**)
2. Backdrop 클릭 시 닫힘 (Danger 액션 모달 제외)
3. ESC 키로 닫기 가능
4. 열릴 때 포커스가 모달 내부로 이동
5. 닫힐 때 포커스가 트리거 요소로 복귀
6. Danger 액션(삭제 등)은 반드시 확인 모달 사용
7. 최대 너비: **400px**
8. 본문은 간결하게 (3줄 이내 권장)

## 접근성
- `role="dialog"` + `aria-modal="true"`
- 위험 액션: `role="alertdialog"`
- `aria-labelledby`로 제목 연결
- 포커스 트랩 (Tab 키 모달 내부에서만 순환)
