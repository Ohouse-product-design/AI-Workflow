# Plan: AI Workflow Map v3 재정비

> v2(4그룹 17과업) → v3(4 Phase 16과업 + Platform)로 구조 재정비.
> 이해관계자가 한눈에 스캔할 수 있도록 그룹핑을 단순화하고, Discovery 단계 추가 + 카드 병합.
> 마지막 업데이트: 2026-04-21

---

## Context

v2 워크플로우는 이해관계자 입장에서 아래 문제가 있었음:

- Discovery(문제 정의·가설) 단계가 없어 "왜 이걸 하는가"가 빠져 있음
- Design & Prototype 단계가 5개 카드를 단일 그룹으로 나열해 의도 파악 어려움
- Handoff & QA에 중복 성격의 카드가 여럿 (Spec-policy-handoff + Design-handoff-doc, Edge-case-simulator + State-verifier)
- AI 산출물(HTML 프로토타입) → Figma 정제 루프가 워크플로우에 명시돼 있지 않음
- Platform Layer의 Reference-analyzer는 실질 활용도가 낮고, 정작 필요한 "디자인 패턴 라이브러리(화면 HTML + ODS + 정책·실험 히스토리)" 피드백 루프 부재

o2o PD AI Workflow Map(`Ref/o2o-pd-ai-workflow-map.html`)의 "Discovery & 가설 → Design & Prototype(2 subgroup) → Handoff" 구조를 참고해 재조정.

---

## 변경 사항 (v2 → v3)

### 구조 개편

| 구분 | v2 | v3 |
|---|---|---|
| Phase 수 | 3 + Platform | 4 + Platform |
| 총 과업 | 17 (+부가 2) | 16 |
| Design & Prototype 그룹 | 2 (Generate / Playbook) | 2 (DS 생성 / 상태·Figma 정제) |
| Handoff & QA 카드 | 6 (2 subgroup) | 4 (flat) |

### 신규 추가 (5)
- **Initiative-prioritizer** (Discovery, P0) — 이니셔티브 임팩트/노력/리스크 스코어링
- **Hypothesis-builder** (Discovery, P0) — 가설 + 목표 지표 초안 자동 생성
- **Data-interpreter** (Discovery, P1) — 지표 수치 해석 + 다음 액션 제안
- **HTML-to-Figma-refiner** (Design & Prototype, P1) — AI HTML → Figma UI 정제
- **Design-pattern-library** (Platform, P0) — 화면 HTML + ODS 매핑 + 실험/정책 히스토리 피드백 루프

### 리네이밍 (1)
- Design-draft → **DS-prototype**

### 병합 (2건)
- Edge-case-simulator + State-verifier → **State-edge-simulator** (Design & Prototype의 "상태 검토 & Figma 정제" 그룹)
- Spec-policy-handoff + Design-handoff-doc → **Complete-handoff-doc** (Handoff & QA)
- Data-insight + Insight-archive → **Insight-archive** (Platform, 실시간 쿼리 + 큐레이션 허브)
- Design-knowledge-playbook + DS-logic-builder → **Design-pattern-library**로 흡수

### 제거 (4)
- ODS-checker (Slack QnA 봇 가치 낮음)
- Reference-analyzer (실질 활용도 낮음)
- Design-principles (DESIGN.md로 원칙 내용 이관)
- DS-logic-builder / Design-knowledge-playbook (Design-pattern-library에 흡수)

### Design-principles → DESIGN.md 전환
- Platform Layer에 DESIGN.md 신규 추가 (P1)
- 9-section 포맷 (Visual / Color / Typography / Component / Layout / Depth / Do's & Don'ts / Responsive / Agent Prompt)
- Design-principles의 디자인 원칙 내용을 Do's & Don'ts 섹션에 흡수
- Claude Project 컨텍스트로 주입하여 DS-prototype / HTML-to-Figma-refiner / Design-critique에 자동 참조

---

## v3 최종 구조

```
Phase 1: Discovery & 가설
  [그룹] Problem framing
    - Initiative-prioritizer (P0)
    - Hypothesis-builder (P0)
    - Data-interpreter (P1)

Phase 2: Design & Prototype
  [그룹 A] Design system 기반 생성
    - DS-prototype (P0)
    - UT-prototyping (P1)
  [그룹 B] 상태 검토 & Figma 정제
    - State-edge-simulator (P0)
    - HTML-to-Figma-refiner (P1)

Phase 3: Review & Critique
  - Design-critique (P1, Quick Win)

Phase 4: Handoff & QA
  - Complete-handoff-doc (P0)
  - Design-QA (P1)
  - UX-writing (P2)
  - Responsive-support (P2)

Platform Layer
  - Design-pattern-library (P0)
  - Insight-archive (P1, Quick Win)
  - Team-toolkit (P1)
  - DESIGN.md (P1)

외부 협업
  - DS-code-bridge (DS 팀 주도)
```

---

## 실행 로드맵

- **Month 1 — Quick Win**: Insight-archive · Design-critique · Team-toolkit · DESIGN.md
- **Month 1~2 — 핵심 인프라**: Design-pattern-library · Initiative-prioritizer · Hypothesis-builder · Complete-handoff-doc
- **Month 2~3 — 킬러 기능**: DS-prototype · State-edge-simulator · HTML-to-Figma-refiner · Design-QA · UT-prototyping · Data-interpreter
- **Month 3~6 — P2 확장**: UX-writing · Responsive-support

---

## 수정 파일

1. `[YH]Loadmap/ai-workflow-map.html`
   - 4 Phase 구조로 마크업 재배치
   - 카드 병합·삭제·신규 추가에 맞춰 `workflowData` JS 객체 재작성
   - 오너십 테이블을 Phase 기준으로 재구성

2. `[YH]Loadmap/ai-workflow.md`
   - 16개 과업으로 재작성 (4 Phase + Platform 구조)
   - 각 과업에 한줄 정의 / 문제 진단 / 솔루션 설계(v1·v2) / 만드는 방법 / 해외 사례 / 성공 지표 포함

3. `[YH]Loadmap/plan.md` (이 문서)
   - v2 → v3 변경 근거 및 최종 구조 기록

---

## DESIGN.md 작성 계획 (별도 실행 트랙)

Design-pattern-library와 DESIGN.md는 서로 보완적:
- **DESIGN.md** — 원칙과 규칙(프로세스 문서)
- **Design-pattern-library** — 실제 패턴 스냅샷(데이터)

### Step 1: DESIGN.md 작성 (1주)
해외 검증된 9-section 포맷으로 ODS를 LLM이 읽을 수 있게 정리.
- Figma MCP로 ODS 파일에서 컬러/타이포/컴포넌트 정보 추출
- `.claude/` 디렉토리에 저장하여 Claude Code가 자동 참조

### Step 2: Claude Project 세팅 + 프롬프트 (3일)
Notion 3단계 루프 참조: PRD 파싱 → HTML 생성 → 검증 루프(렌더링 → 스크린샷 비교 → 수정, 최대 3회)

### Step 3: 파일럿 테스트 (1주)
PRD 3건(간단/중간/복잡)으로 DS-prototype 검증.
성공 기준: 생성 시간 2h 이내, 리뷰어가 "수정하면 쓸 수 있다" 수준, PO 이해도 확보.

### Step 4: 팀 확산 + Figma 파이프라인 (2주)
Katherine Yeh 3-Layer 아키텍처:
- Layer 1: DESIGN.md (Knowledge)
- Layer 2: DS-prototype Skill (Workflow)
- Layer 3: Figma MCP (Tool)

---

## 현재 인프라 상태

| 항목 | 상태 | 비고 |
|---|---|---|
| Figma MCP | ✅ 연결됨 | TalkToFigma + figma-desktop MCP |
| Athena/Redash MCP | ✅ 활성 | Insight-archive 즉시 사용 가능 |
| Claude Code | ✅ 활성 | 현 프로젝트에서 사용 중 |
| ODS 컴포넌트 문서화 | ❌ 없음 | **병목 — DESIGN.md와 함께 선행 필요** |
| DESIGN.md | ❌ 없음 | Platform 항목으로 신규 작성 |
| Design-pattern-library | ❌ 없음 | P0, 3~4주 소요 |

---

## 검증

1. 브라우저에서 `ai-workflow-map.html` 열어 4 Phase + Platform 5개 섹션 렌더링 확인
2. 모든 카드 클릭 → 모달에 goal / implementation / successMetric 정상 표시
3. 오너 멀티 드롭다운 localStorage 호환성 확인 (v2 ID가 삭제·병합된 경우 재할당 필요)
4. Grid column 수가 각 Phase에 맞게 적용되는지 확인
5. GitHub 푸시 후 GitHub Pages 배포 확인

---

## 리스크 & 대응

| 리스크 | 대응 |
|---|---|
| v2 오너십 localStorage가 v3 ID와 불일치 | 팀 회의에서 v3 기준으로 1회 재할당. `State-verifier`, `Edge-case-simulator`, `Spec-policy-handoff` 등은 자동 초기화됨 |
| DESIGN.md가 Design-pattern-library와 역할 중복 | 원칙(DESIGN.md)과 데이터(Pattern-library) 분리 유지. DESIGN.md는 "왜", Pattern-library는 "예시" |
| Design-principles 제거로 검색 기능 공백 | DESIGN.md 내 9-section 구조 자체가 검색 가능한 문서로 동작 + /principles Skill을 DESIGN.md 기반으로 재구성 |
| AI HTML → Figma 변환 기술적 난이도 | v1은 수동 전환 + Skill 보조, v2에서 Figma MCP 자동 매핑 실험 |
