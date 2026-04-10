# Plan: AI Workflow Map 재정비 + Design-draft 실행

> 두 개의 plan 문서를 통합한 기록.
> Part 1 — 전체 워크플로우 맵을 26개 → 4그룹 17과업으로 재구성한 planning rationale
> Part 2 — 17과업 중 가장 높은 임팩트(연간 10,944h, 56%)를 가진 Design-draft의 4단계 실행 계획

---

# Part 1 · AI Workflow Map 4그룹 17과업 재구성

## Context
오늘의집 PD팀(19명)의 AI 워크플로우 맵을 만들어왔는데, 초기 25개 항목이 과다하고 솔루션 타입이 비현실적인 부분이 있음. 해외 사례(Spotify, Figma, Vercel)를 참조하여 4그룹 17과업으로 재구성하고, 각 항목에 문제 진단 / 솔루션 검증 / 구체적 액션아이템 / 성공 지표를 추가함.

핵심 인사이트: **"지식 구조화(Design-knowledge-playbook)가 모든 것의 기반"** — Spotify가 디자인 시스템을 MCP 서버로 노출하여 AI 품질을 올린 것과 동일한 접근.

## 변경 사항 요약

### 26개 → 4그룹 17과업 (그룹핑은 묶되 과업은 분리)

그룹으로 묶어 전체 진행률을 보되, 각 과업은 독립 오너를 두어 명확한 목적과 책임을 부여.

**P0 — 핵심 인프라 / 킬러 기능 (4과업, 즉시 시작)**

[그룹 A] **Design & Generate**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 1 | Design-draft | PRD → HTML 결론안 자동 생성 | 5/5 |

[그룹 B] **Design-knowledge-playbook**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 3 | Design-knowledge-playbook | 화면 패턴/규칙/히스토리 → HTML 플레이북 | 5/5 |

[그룹 C] **Complete-handoff**
| # | 과업 | 한줄 목적 | 심각도 |
|---|---|---|---|
| 8 | Spec-policy-handoff | 정책/비즈니스 규칙 스펙 문서 자동 생성 | 5/5 |
| 9 | State-verifier | 상태별 UI 누락 자동 체크 | 4/5 |

**P1 — 높은 임팩트 (9과업, P0와 병행)**

[그룹 A] Design & Generate
| # | 과업 | 한줄 목적 |
|---|---|---|
| 2 | UT-prototyping | UT 시나리오 + 태스크 플로우 자동 생성 |

[그룹 B] Design-knowledge-playbook
| # | 과업 | 한줄 목적 |
|---|---|---|
| 4 | DS-logic-builder | 컴포넌트 네이밍/속성 정규화 |
| 5 | ODS-checker | ODS 컴포넌트 검색 + QnA 자동 응답 |

[그룹 C] Complete-handoff
| # | 과업 | 한줄 목적 |
|---|---|---|
| 10 | Design-handoff-doc | Figma Dev Mode 기반 핸드오프 문서 템플릿 |

[그룹 D] **Quality & Verification**
| # | 과업 | 한줄 목적 |
|---|---|---|
| 11 | Edge-case-simulator | 엣지 케이스 데이터 자동 생성 + 텍스트 오버플로 검증 |
| 12 | Design-QA | 디자이너가 Claude Code로 개발 화면 직접 수정 → GitHub 커밋 |

Phase 2 — Review & Critique
| # | 과업 | 한줄 목적 |
|---|---|---|
| 6 | Design-critique `Quick Win` | AI 다각도 크리틱 (이미 운영 중) |

Platform Layer
| # | 과업 | 한줄 목적 |
|---|---|---|
| 13 | Data-insight `Quick Win` | 자연어 데이터 조회 (MCP 이미 완성) |
| 14 | Team-toolkit | 스킬 저장소 + 온보딩 키트 |

**P2 — 중기 (5과업 + 부가, 3~6개월)**
| # | 과업 | 한줄 목적 |
|---|---|---|
| 7 | Design-principles `NEW` | 보편 디자인 원칙 → 구조화된 참조 + Skill |
| 15 | Insight-archive | 실험 결과/인사이트/AI 팁 축적 |
| 16 | Reference-analyzer | 경쟁사 리서치 + 패턴 분석 |
| 17 | UX-writing | 브랜드 가이드 기반 카피 (Design-draft 부가) |
| 18 | Responsive-support | 반응형 가이드 (Design-draft HTML에 미디어쿼리) |

**외부 협업 (PD 맵 외부)**
| # | 과업 | 비고 |
|---|---|---|
| - | DS-code-bridge | DS 팀/엔지니어링 주도. PD는 요구사항 전달 |

**삭제 (4개)**
- VOC-collector (PM/리서치 팀 과업)
- Usecase-mapper (기획/PM 과업)
- Design-share (범용 미팅 노트 도구로 대체)
- Feedback-tracker (Jira/Linear로 대체)

**Design-QA 재정의**: 기존 "픽셀 비교 QA"가 아닌, **디자이너가 Claude Code로 개발된 화면의 CSS/HTML을 직접 수정하고 GitHub에 커밋**하는 워크플로우. PD가 코드에 직접 손대는 새로운 역할. Spotify 사례(시니어 엔지니어가 AI 생성 코드만 리뷰)의 디자이너 버전.

### 수정 파일
1. `[YH]Loadmap/ai-workflow-map.html`
   - 카드: 4그룹 헤더 + 17개 과업 카드 (그룹 안에 하위 카드 배치)
   - 과업 테이블: 그룹 구분선 + 17개 행
   - 각 카드 클릭 모달에 문제 진단/액션아이템/해외 사례/성공 지표 추가
   - 상단 Stats 업데이트
   - workflowData JS 객체 재작성 (각 과업별 독립 데이터)

2. `[YH]Loadmap/ai-workflow.md`
   - 17개 과업으로 재작성 (그룹 구조 포함)
   - 각 과업에 한줄 정의 / 문제 진단 / 솔루션 설계(v1·v2) / 만드는 방법(액션아이템) / 해외 사례 / 성공 지표 포함

### Phase 구조 변경 (그룹 기반)
```
Phase 1: Design & Prototype
  [그룹 A] Design & Generate
    - Design-draft (P0)
    - UT-prototyping (P1)
  [그룹 B] Design-knowledge-playbook
    - Design-knowledge-playbook (P0)
    - DS-logic-builder (P1)
    - ODS-checker (P1)

Phase 2: Review & Critique
  - Design-critique (P1, Quick Win)
  - Design-principles (P2, NEW)

Phase 3: Handoff & QA
  [그룹 C] Complete-handoff
    - Spec-policy-handoff (P0)
    - State-verifier (P0)
    - Design-handoff-doc (P1)
  [그룹 D] Quality & Verification
    - Edge-case-simulator (P1)
    - Design-QA (P1)

Platform Layer
  - Data-insight (P1, Quick Win)
  - Team-toolkit (P1)
  - Insight-archive (P2)
  - Reference-analyzer (P2)

부가 기능 (P2)
  - UX-writing
  - Responsive-support
```

### 카드 UI 구현
- 그룹 헤더: 그룹명 + 진행률 표시 (예: "Complete-handoff 1/3")
- 하위 카드: 기존 카드와 동일하되 왼쪽에 그룹 색상 바 표시
- 과업 테이블: 그룹별 구분 행 (배경색) + 각 과업 독립 행 (오너 개별 지정)

### 모달 상세 구조 (각 과업)
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
- Month 1: Quick Win (Data-insight + Design-critique 고도화 + Team-toolkit v1)
- Month 1~2: 핵심 인프라 (Design-knowledge-playbook + Complete-handoff v1)
- Month 2~3: 킬러 기능 (Design-draft + Edge-case-simulator + UT-prototyping + Design-QA)
- Month 3~6: P2 확장 (Design-principles, Insight-archive, Reference-analyzer)

## 검증
- 브라우저에서 ai-workflow-map.html 열어서 확인
- 모든 카드 클릭 → 모달에 새 구조(액션아이템, 성공 지표) 표시 확인
- 오너 멀티 드롭다운 기존 localStorage 호환성 확인
- GitHub 푸시 후 Pages 배포 확인

---

# Part 2 · Design-draft 상세 실행 계획

## Context
AI Workflow 전체 임팩트의 56%(연간 10,944h)를 차지하는 Design-draft를 구체적으로 실행하기 위한 계획. "PRD → HTML 결론안 자동 생성"이 핵심이며, 이것의 성패가 전체 AI 워크플로우 전환의 가치를 증명한다.

해외 사례 리서치 결과, 2026년 성공 팀들의 공통 패턴:
- **DESIGN.md** (구조화된 마크다운)를 컨텍스트로 사용
- **Figma MCP** 서버로 디자인 시스템 실시간 접근
- **검증 루프** (스크린샷 비교 → 수정 → 재검증) 반드시 포함
- **디자이너 인더루프** — 첫 결과는 항상 제너릭, 리뷰 필수

## 현재 인프라 상태

| 항목 | 상태 | 비고 |
|---|---|---|
| Figma MCP | ✅ 연결됨 | TalkToFigma + figma-desktop MCP |
| Athena/Redash MCP | ✅ 활성 | Data-insight 즉시 사용 가능 |
| Claude Code | ✅ 활성 | 현 프로젝트에서 사용 중 |
| ODS 컴포넌트 문서화 | ❌ 없음 | **병목 — 이것부터 해야 함** |
| DESIGN.md | ❌ 없음 | 새로 작성 필요 |

## 실행 계획: 4단계

### Step 1: DESIGN.md 작성 (1주)
> ODS를 LLM이 읽을 수 있는 형태로 정리

**해외 검증된 포맷** (DESIGN.md 9섹션):
```
1. Visual Theme & Atmosphere — 오늘의집 브랜드 톤
2. Color Palette & Roles — ODS 컬러 토큰 (시맨틱 이름 + HEX)
3. Typography Rules — 타이포 위계 테이블
4. Component Stylings — 주요 컴포넌트 (버튼, 카드, 인풋 + 상태별)
5. Layout Principles — 간격 스케일, 그리드, 여백 규칙
6. Depth & Elevation — 그림자 시스템, 레이어 위계
7. Do's and Don'ts — 안티패턴 명시 ("드롭쉐도우 금지" 등)
8. Responsive Behavior — 브레이크포인트, 터치 타겟
9. Agent Prompt Guide — 색상 코드 레퍼런스, 자주 쓰는 프롬프트
```

**작업**:
1. Figma MCP로 ODS 파일에서 컬러/타이포/컴포넌트 정보 추출
2. 위 9섹션 포맷으로 DESIGN.md 작성
3. 주요 컴포넌트 10개의 HTML snippet 작성 (버튼, 카드, 리스트, 네비게이션 등)
4. `.claude/` 디렉토리에 저장하여 Claude Code가 자동 참조

**산출물**: `DESIGN.md` + `.claude/skills/design-draft.md`

### Step 2: Claude Project 세팅 + 프롬프트 (3일)
> 시스템 프롬프트 + 검증 루프 설계

**Notion 사례 참조 — 3단계 루프**:
```
1. PRD 파싱 → 핵심 요구사항 추출
2. HTML 생성 (DESIGN.md 컨텍스트 기반)
3. 검증 루프 (렌더링 → 스크린샷 비교 → 수정, 최대 3회)
```

**시스템 프롬프트 구조**:
```markdown
# Role
오늘의집 프로덕트 디자이너. ODS(오늘의집 디자인 시스템) 기반 UI 생성.

# Context
- DESIGN.md 참조 (자동 로드)
- Figma MCP로 현재 디자인 시스템 실시간 접근

# Input
PRD 문서 (Notion 또는 텍스트)

# Output
- 반응형 HTML (모바일 퍼스트, CSS 미디어쿼리 포함)
- ODS 컴포넌트 활용
- 3가지 방향성(A/B/C안) 제안

# Rules
- Primary 버튼은 섹션당 1개
- 최소 터치 영역 44px
- 명암비 4.5:1
- (DESIGN.md의 Do's and Don'ts 참조)
```

**산출물**: `.claude/skills/design-draft.md` (Skill 프롬프트)

### Step 3: 파일럿 테스트 (1주)
> 실제 PRD 3건으로 검증

**파일럿 대상 선정 기준**:
- 복잡도 다양: 간단한 화면 1건 + 중간 1건 + 복잡한 1건
- 이미 완료된 프로젝트 (결과물 비교 가능)
- 팀원 3명이 각 1건씩 담당

**검증 방법**:
1. PRD 입력 → HTML 생성 (소요 시간 측정)
2. 기존 디자인과 비교 (일치도 평가)
3. Figma Code-to-Canvas로 변환 테스트
4. PO에게 보여주고 "이해 가능한지" 피드백

**성공 기준**:
- 생성 시간: 2시간 이내 (기존 3~8일 대비)
- 디자인 방향성: 리뷰어가 "수정하면 쓸 수 있다" 수준
- PO 이해도: HTML 프로토타입만으로 화면 의도 파악 가능

### Step 4: 팀 확산 + Figma 파이프라인 (2주)
> 파일럿 성공 후 팀 전체 적용

**확산 단계**:
1. 파일럿 결과 팀 공유 (성공/실패 패턴)
2. DESIGN.md + Skill 프롬프트를 Team-toolkit Git repo에 등록
3. 팀원 대상 30분 워크숍 (실습 포함)
4. Figma Code-to-Canvas 파이프라인 공식 가이드 작성

**Figma 연동 (Katherine Yeh 3-Layer 아키텍처 참조)**:
```
Layer 1: DESIGN.md (Knowledge) — 디자인 시스템 컨텍스트
Layer 2: design-draft Skill (Workflow) — PRD → HTML 생성
Layer 3: Figma MCP (Tool) — HTML → Figma 반영
```

## 의존성 관계

```
DESIGN.md 작성 (Step 1)
    ↓
Claude Skill 세팅 (Step 2) ← Design-knowledge-playbook과 병렬 가능
    ↓
파일럿 테스트 (Step 3)
    ↓
팀 확산 (Step 4)
```

Design-knowledge-playbook은 DESIGN.md의 확장판. Step 1과 병렬로 진행 가능.

## 수정 파일

1. **새로 생성**: `DESIGN.md` — ODS 디자인 시스템 문서
2. **새로 생성**: `.claude/skills/design-draft.md` — Skill 프롬프트
3. **수정**: `[YH]Loadmap/ai-workflow-map.html` — Design-draft 카드에 Step 1~4 진행률 표시 추가
4. **수정**: `[YH]Loadmap/ai-workflow.md` — Design-draft 상세 계획 업데이트

## 검증

1. DESIGN.md 작성 후 → Claude Code에서 "ODS 버튼 컴포넌트 HTML 생성" 테스트
2. Skill 프롬프트 → 간단한 PRD(예: "상품 상세 페이지 리디자인") 입력하여 HTML 생성 확인
3. 생성된 HTML을 브라우저에서 열어 반응형 동작 확인
4. Figma Code-to-Canvas로 변환 가능 여부 확인
5. 팀원 1명에게 전체 플로우 시연 → 피드백

## 타임라인

| 주 | 작업 | 산출물 |
|---|---|---|
| Week 1 | DESIGN.md 작성 | DESIGN.md, HTML snippet 10개 |
| Week 2 | Skill 프롬프트 + 파일럿 준비 | design-draft.md, PRD 3건 선정 |
| Week 3 | 파일럿 실행 | HTML 결과물 3건, 비교 리포트 |
| Week 4 | 팀 확산 | 워크숍, Git repo 등록, Figma 가이드 |

## 리스크 & 대응

| 리스크 | 대응 |
|---|---|
| ODS 정보 추출 어려움 | Figma MCP get_design_context로 자동 추출 시도. 실패 시 수동 정리 |
| HTML 품질 부족 | 검증 루프 3회 반복. "수정하면 쓸 수 있다" 수준이면 성공 |
| Figma 변환 실패 | Code-to-Canvas가 안 되면 v1은 수동 반영. v2에서 해결 |
| 팀원 학습 거부감 | 파일럿 성공 사례로 동기부여. 강제 아닌 선택적 도입 |
