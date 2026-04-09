# Plan: AI Workflow Map 최종 재정비

## Context
오늘의집 PD팀(19명)의 AI 워크플로우 맵을 만들어왔는데, 현재 25개 항목이 과다하고 솔루션 타입이 비현실적인 부분이 있음. 해외 사례(Spotify, Figma, Vercel)를 참조하여 7그룹 17과업으로 재구성하고, 각 항목에 문제 진단 / 솔루션 검증 / 구체적 액션아이템 / 성공 지표를 추가함.

핵심 인사이트: "지식 구조화(Design-knowledge-playbook)가 모든 것의 기반" — Spotify가 디자인 시스템을 MCP 서버로 노출하여 AI 품질을 올린 것과 동일한 접근.

## 변경 사항 요약

### 26개 → 7그룹 19과업 (그룹핑은 묶되 과업은 분리)

그룹으로 묶어 전체 진행률을 보되, 각 과업은 독립 오너를 두어 명확한 목적과 책임을 부여.

**Tier 1: 핵심 그룹 (4그룹 12과업, 즉시 시작)**

[그룹 A] **Design & Generate**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 1 | Design-draft | PRD → HTML 결론안 자동 생성 | 5/5 |
| 2 | UT-prototyping | UT 시나리오 + 프로토타입 제작 | 3/5 |

[그룹 B] **Design-knowledge-playbook**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 3 | Design-knowledge-playbook | 화면 패턴/규칙/히스토리 → HTML 플레이북 | 5/5 |
| 4 | DS-logic-builder | 컴포넌트 네이밍/속성 정규화 | 4/5 |
| 5 | ODS-checker | ODS 컴포넌트 검색 + QnA 자동 응답 | 3/5 |

[그룹 C] **Complete-handoff**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 6 | Spec-policy-handoff | 정책/비즈니스 규칙 스펙 문서 자동 생성 | 5/5 |
| 7 | State-verifier | 상태별 UI 누락 자동 체크 | 4/5 |
| 8 | Design-handoff-doc | Figma Dev Mode 기반 핸드오프 문서 템플릿 | 4/5 |

[그룹 D] **Quality & Verification**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 9 | Edge-case-simulator | 엣지 케이스 데이터 자동 생성 + 텍스트 오버플로 검증 | 4/5 |
| 10 | Design-QA | 디자이너가 Claude Code로 개발 화면 직접 수정 → GitHub 커밋 | 4/5 |

**Tier 2: Quick Win (3과업, 1~2주)**
| # | 과업 | 한줄 목적 |
|---|---|---|
| 11 | Data-insight | 자연어 데이터 조회 (MCP 이미 완성) |
| 12 | Design-critique | AI 크리틱 고도화 (이미 운영 중) |
| 13 | Team-toolkit | 스킬 저장소 + 온보딩 키트 |

**Tier 3: 중기 (4과업, 3~6개월)**
| # | 과업 | 한줄 목적 |
|---|---|---|
| 14 | Insight-archive | 실험 결과/인사이트/AI 팁 축적 |
| 15 | Reference-analyzer | 경쟁사 리서치 + 패턴 분석 |
| 16 | UX-writing | 브랜드 가이드 기반 카피 (Design-draft 부가 기능) |
| 17 | Responsive-support | 반응형 가이드 (Design-draft HTML에 CSS 미디어쿼리) |

**외부 협업 (PD 맵 외부)**
| # | 과업 | 비고 |
|---|---|---|
| 18 | DS-code-bridge | DS 팀/엔지니어링 주도. PD는 요구사항 전달 |

**삭제 (4개)**
- VOC-collector (PM/리서치 팀 과업)
- Usecase-mapper (기획/PM 과업)
- Design-share (범용 미팅 노트 도구로 대체)
- Feedback-tracker (Jira/Linear로 대체)

**Design-QA 재정의**: 기존 "픽셀 비교 QA"가 아닌, **디자이너가 Claude Code로 개발된 화면의 CSS/HTML을 직접 수정하고 GitHub에 커밋**하는 워크플로우. PD가 코드에 직접 손대는 새로운 역할. Spotify 사례(시니어 엔지니어가 AI 생성 코드만 리뷰)의 디자이너 버전.

### 수정 파일
1. `/Users/yohan.lee/Desktop/Claude_Study/design-workflow/ai-workflow-map.html`
   - 카드: 4그룹 헤더 + 17개 과업 카드 (그룹 안에 하위 카드 배치)
   - 과업 테이블: 그룹 구분선 + 17개 행
   - 각 카드 클릭 모달에 문제 진단/액션아이템/해외 사례/성공 지표 추가
   - 상단 Stats 업데이트
   - workflowData JS 객체 17개로 재작성 (각 과업별 독립 데이터)

2. `/Users/yohan.lee/Desktop/Claude_Study/design-workflow/ai-workflow.md`
   - 17개 과업으로 재작성 (그룹 구조 포함)
   - 각 과업에 한줄 정의/문제 진단/솔루션 설계(v1·v2)/만드는 방법(액션아이템)/해외 사례/성공 지표 포함

### Phase 구조 변경 (그룹 기반)
```
Phase 1: Design & Prototype
  [그룹 A] Design & Generate
    - Design-draft
    - UT-prototyping
  [그룹 B] Design-knowledge-playbook
    - Design-knowledge-playbook
    - DS-logic-builder
    - ODS-checker

Phase 2: Review & Critique
  - Design-critique (독립)

Phase 3: Handoff & QA
  [그룹 C] Complete-handoff
    - Spec-policy-handoff
    - State-verifier
    - Design-handoff-doc
  [그룹 D] Quality & Verification
    - Edge-case-simulator
    - Design-QA

Platform Layer
  - Data-insight, Team-toolkit
  - (Tier 3: Insight-archive, Reference-analyzer, UX-writing, Responsive-support)
```

### 카드 UI 구현
- 그룹 헤더: 그룹명 + 진행률 표시 (예: "Complete-handoff 1/3")
- 하위 카드: 기존 카드와 동일하되 왼쪽에 그룹 색상 바 표시
- 과업 테이블: 그룹별 구분 행 (배경색) + 각 과업 독립 행 (오너 개별 지정)

### 모달 상세 구조 변경 (각 17개 과업)
```
목표 (한줄)
문제 진단 (심각도 1~5 + 근거)
솔루션 설계
  - 접근 방식 (v1 = 지금 가능한 것 / v2 = 이상적)
  - 만드는 방법 (팀원용 3~5단계 액션아이템)
해외 사례 참조
성공 지표 (어떻게 측정할 것인가)
선행 조건
```

### 실행 로드맵
- Month 1: Data-insight + Design-critique 고도화 + Team-toolkit v1
- Month 1~2: Design-knowledge-playbook + Complete-handoff v1
- Month 2~3: Design-draft + Edge-case-simulator + UT-prototyping + Design-QA
- Month 3~6: Tier 3 항목

## 검증
- 브라우저에서 ai-workflow-map.html 열어서 확인
- 모든 카드 클릭 → 모달에 새 구조(액션아이템, 성공 지표) 표시 확인
- 오너 멀티 드롭다운 기존 localStorage 호환성 확인
- GitHub 푸시 후 Pages 배포 확인
