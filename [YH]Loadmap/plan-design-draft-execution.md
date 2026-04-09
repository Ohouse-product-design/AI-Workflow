# Plan: Design-draft 상세 실행 계획

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

**산출물**: `/design-workflow/DESIGN.md` + `/design-workflow/.claude/skills/design-draft.md`

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

1. **새로 생성**: `/design-workflow/DESIGN.md` — ODS 디자인 시스템 문서
2. **새로 생성**: `/design-workflow/.claude/skills/design-draft.md` — Skill 프롬프트
3. **수정**: `/design-workflow/ai-workflow-map.html` — Design-draft 카드에 Step 1~4 진행률 표시 추가
4. **수정**: `/design-workflow/ai-workflow.md` — Design-draft 상세 계획 업데이트

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
