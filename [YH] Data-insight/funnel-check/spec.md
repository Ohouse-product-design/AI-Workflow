# funnel-check 스킬 관리 문서

> 이 문서는 `/funnel-check` 스킬의 **설계 의도와 히스토리**를 관리한다. 스킬 파일 자체는 런타임 지시문(how)이고, 이 문서는 그 배경(why)이다. 스킬을 수정하기 전에 이 문서부터 읽어라.

## 개요

| 항목 | 내용 |
|------|------|
| 팀 공용 스킬 | `~/claude-skills/skills/funnel-check/SKILL.md` (frontmatter 포함, [Ohouse-product-design/AI-Skill](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check)) |
| 개인 슬래시 커맨드 | `~/.claude/commands/funnel-check.md` (yohan 로컬용) |
| 호출 | 자동 발동 ("PDP element 전환률 분석", "쇼핑홈 → PDP → 장바구니 전환률") 또는 `/funnel-check [...]` |
| 목적 | PD가 page_id 안 element들의 전환률과 페이지 간 funnel을 정량적으로 이해해, 디자인 의사결정을 데이터 근거 위에 세우게 돕는 스킬 |
| 버전 | **v1.5** (인터랙션 축소 — 결정 종류 2단 분리, 디폴트 자동 적용, page_id fuzzy 확장, 통합 쿼리, user_id 캐싱, HTML CDN 0 의존) |
| 최초 작성 | 2026-04-10 |
| 마지막 갱신 | 2026-04-11 |

## 왜 만들었나 (문제 정의)

### 기존 방식의 문제
기존에 athena mcp로 "X 화면 분석해줘"라고 요청하면 매번 다른 결과가 나왔다. 원인은:

1. **page_id 해석의 모호함** — "상품 상세"라는 말이 PDP인지 PDP_STYLINGSHOT인지, 관련 모든 PDP_*인지 요청자마다 다르게 해석
2. **분석 단위/시작점의 자의적 선정** — "어디서부터 어디까지가 전환"인지, "어떤 element가 분석 대상인지"가 쿼리 작성자 판단에 달림
3. **object 필터의 부정확** — element를 `object_section_id` / `object_type` 어떻게 잡을지가 매번 달라짐
4. **element 식별의 가독성 부재** — `cart_button (BUTTON)` 같은 ID만 보면 PD가 어느 화면 요소인지 즉시 파악 불가

데이터는 정확성이 생명이고, 정확성이 흔들리면 분석 결과가 설득력을 잃는다. PD가 PO와의 토론에서 데이터로 의견을 제시하려면 그 데이터 자체가 흔들림 없어야 한다.

### 해결 방향
1. AI가 추측으로 쿼리를 짜지 말고 **사용자가 직접 폰으로 걸어본 로그** 또는 **로그센터 명세 ↔ 실로그 교차검증**을 정답지로 삼는다.
2. **핵심 결정만 사용자 확정.** mode/page_id/쿼리 승인 3개만 묻고, 나머지는 announce 후 자동 진행 (속도와 정확성의 균형).
3. **HTML 단위는 page_id.** 단일 화면이든 플로우든 `./screens/{page_id}.html` 단일 형태. 같은 page_id면 재사용.
4. **Element 표기는 항상 삼중**: `{title} (object_section_id, object_type)` — title은 로그센터 명세에서 가져와 PD가 즉시 인지 가능.

## 핵심 아키텍처: HTML 단위 = page_id

이 스킬의 모든 산출물은 **page_id 하나당 HTML 한 개** 로 떨어진다.

- **단일 화면 분석 (scope=single)**: 한 page_id의 element 분석 HTML 1개 (`./screens/{page_id}.html`)
- **플로우 분석 (scope=flow)**: 플로우의 각 page_id마다 HTML 1개. 모든 HTML이 서로 링크되어 페이지 간 클릭 이동 가능. **첫 entry page** HTML 최상단에는 페이지 간 funnel이 시각화되고, funnel 노드 클릭 시 그 page_id HTML이 열린다. element 차트의 trigger element(다음 페이지로 가는 버튼/링크)도 클릭 시 다음 page_id HTML로 이동.

이 구조 덕분에:
- 같은 page_id가 여러 플로우에 포함되어도 HTML은 1개만 (재사용)
- PD는 한 분석 결과 안에서 화면→화면을 자유롭게 오가며 element 사용도와 페이지 간 전환률을 함께 본다

## Scope 개념

| Scope | page_id 개수 | 추가 산출물 | 산출물 위치 |
|-------|--------------|-------------|-------------|
| **single** | 1개 | (없음) | `./screens/{page_id}.html` |
| **flow** | N개 (시퀀스) | 페이지 간 funnel 데이터 + flow header inject | `./screens/{page_id}.html` × N + `./flows/{flow_name}.md` |

**핵심**: scope가 single이든 flow든 **per-page HTML 구조와 element 분석 로직은 동일**하다. flow scope는 추가로:
1. 각 페이지 간 전환률 계산 (funnel 쿼리 1개)
2. 각 page_id HTML의 최상단에 flow header section을 inject (다른 page_id HTML로의 링크 포함)
3. 첫 entry page_id HTML을 자동으로 브라우저에 띄움

### 향후 추가 예정 scope (현재 미구현)
- **peer-compare**: 같은 카테고리의 다른 화면과 비교
- **trend**: 시계열 변화 추적

## 핵심 원칙 (mode/scope 무관 공통)

1. **속도 원칙 — 핵심 결정만 확인하고, 나머지는 announce 후 진행.**
   - 반드시 사용자 확정이 필요한 결정 (3개): scope 선택, page_id 확정, athena 쿼리 실행 승인
   - 나머지는 default 추정 → announce → 사용자 명시 정정 없으면 그대로 진행
   - 관련 질문은 한 번에 묶어서. 단계마다 하나씩 묻지 않는다.
2. **자의적 추론 금지 (단, 핵심 결정에 한정).** 페이지 연결, element 분류, 카테고리 — 핵심 결정이면 후보만 제시. 그 외는 best-guess + 사용자 정정.
3. **쿼리는 전문을 보여주고 승인 후 실행.** 여러 쿼리는 한 번에 모아서 한 번의 yes/no로 묶는다.
4. **로그센터 명세와 교차검증.** `mcp__log-center-mcp__get_page_spec`이 있는 page_id는 항상 명세를 같이 본다.
5. **Element는 반드시 삼중 표기.** `{title} (object_section_id, object_type)` — `cart_button (BUTTON)` 같은 ID만 표기 금지. title은 log-center mcp에서 가져온다.
6. **MD가 정본, HTML 매번 재생성.** 모든 산출물의 정본은 MD, HTML은 보조 시각화.
7. **마지막에 HTML을 자동으로 브라우저에 띄운다.** Step 5 끝에서 `open ./screens/{page_id}.html` 자동 실행 (사용자 승인 X). flow scope면 첫 entry page HTML 1개만.
8. **세그먼트(신규/활성/부활)는 MVP에서 제외.** v2에서 BA팀 표준 마트 기반 추가 예정.

## 통합 워크플로우 (single + flow)

scope에 상관없이 동일한 큰 흐름:

```
Step -1  환경 점검 (silent on success)
Step 0   갱신(refresh) 의도 감지 → 있으면 Step 1-3 건너뛰고 Step 4부터
         scope 선택 [a] 단일 화면 / [b] 플로우
Step 1   맥락 수집 (한 메시지에 묶어서: 도메인/목적/측정기간)
Step 2   page_id 확정
           - single: 후보 메뉴에서 1개 확정
           - flow:   플로우 그라운딩 (라이브 워크스루 / 텍스트) → 시퀀스 확정
Step 3   각 page_id 루프 — element 인벤토리 (명세 ∩ 로그)
           + (flow scope만) 페이지 간 trigger 추정/확정
Step 4   쿼리 일괄 승인
           - 각 page_id의 [Element CTR + Page Health] × N
           - (flow scope만) 페이지 간 funnel 쿼리 1개
           - 한 번의 yes/no로 모두 승인 → 순차 실행
Step 5   각 page_id의 HTML 생성 (loop)
           - per-page detail (element CTR / inventory / page health / figma mapper / query / date refresh)
           - (flow scope만) 모든 HTML 최상단에 flow header section inject
           - 첫 entry page_id HTML을 `open` 으로 새 창
```

## 사용 도구

| 도구 | single | flow | 용도 |
|------|:-:|:-:|------|
| `mcp__ohouse-athena-mcp__execute_athena_query` | ✅ | ✅ | 로그 추출 + 측정 쿼리 |
| `mcp__log-center-mcp__get_page_spec` | ✅ | ✅ | 명세 ↔ 실로그 교차검증, title 매핑 확보 |
| `mcp__log-center-mcp__get_log_spec_by_id` | 필요시 | 필요시 | 개별 spec 조회 |
| `mcp__log-center-mcp__get_log_spec_from_url` | 필요시 | 필요시 | 로그센터 URL → spec |
| `mcp__log-center-mcp__get_enum` | 필요시 | 필요시 | enum 조회 |
| Recharts (CDN) | ✅ | ✅ | HTML 차트 |
| Figma embed iframe | ✅ | ✅ | per-page HTML의 인터랙티브 매핑 |
| localStorage | ✅ | ✅ | Figma mapping + flow header inject 영속화 |
| `open` (macOS Bash) | ✅ | ✅ | Step 5 끝 entry HTML 자동 오픈 |

**redash mcp는 런타임에 사용하지 않는다.** (결정 로그 ③ 참조)

## 파일 구조

### 스킬 본체 (Ohouse-product-design/AI-Skill 레포)

```
~/claude-skills/                                     ← 권장 clone 위치
├── skills/funnel-check/                             ← 안정 (팀 설치용)
│   ├── SKILL.md                                     ← frontmatter + 본문
│   ├── cursor.yaml
│   └── README.md                                    ← 설치 가이드 + 트러블슈팅
├── skills/log-explore/                              ← 의존 스킬
│   ├── SKILL.md, cursor.yaml, README.md
├── skills/log-query/
│   ├── SKILL.md, cursor.yaml, README.md
├── skills/log-spec/
│   ├── SKILL.md, cursor.yaml, README.md
└── [YH] Data-insight/funnel-check/                  ← yohan WIP namespace
    ├── SKILL.md                                     ← 작업 사본 (안정화 후 promotion)
    └── README.md                                    ← WIP 안내
```

### 개인 슬래시 커맨드 (yohan 로컬)

```
~/.claude/commands/funnel-check.md                   ← 슬래시 커맨드용 사본
~/.claude/commands/log-explore.md, log-query.md, log-spec.md
```

### 산출물 (스킬 호출 시 호출 디렉토리에 생성, page_id 단위로 통합)

```
{호출한 디렉토리}/
├── screens/                                         ← per-page 산출물 (single + flow 둘 다)
│   ├── {page_id}.md                                 ← per-page 분석 정본
│   ├── {page_id}.html                               ← per-page HTML (인터랙티브, 자동 재생성)
│   ├── {page_id}-mapping-{YYYYMMDD}.json            ← Figma 매핑 export
│   ├── pdp.md / pdp.html
│   ├── cart.md / cart.html
│   └── ...
└── flows/                                           ← flow scope에서만 생성
    └── {flow_name}.md                               ← 플로우 정의 + funnel 쿼리 결과
                                                     (별도 flow.html은 없음 — funnel 시각화는
                                                      각 page_id html의 flow-header section에 inject)
```

**핵심 원칙**:
- HTML은 항상 page_id 단위 (`./screens/{page_id}.html`)
- 같은 page_id가 여러 플로우에 포함되어도 HTML은 1개 (재사용)
- flow scope면 `./flows/{flow_name}.md` 가 추가로 생기고, 거기 정의된 funnel 데이터가 그 플로우에 포함된 모든 page_id HTML 의 flow-header section에 inject됨

## 이름 규칙

### per-page 파일명 (single + flow 공통)
형식: `{page_id_lowercase}[__{variant}]`
- `pdp.md` / `pdp.html`
- `shoppinghome.md` / `shoppinghome.html`
- `pdp__202604-renewal.md` (variant suffix는 `__` 두 underscore로 구분)

### Flow 정의 파일명 (flow scope에서만)
형식: `{domain}-{from_page}-to-{to_page}[-{variant}]`
- `commerce-pdp-to-cart.md`
- `content-clp_project-to-cdp_project.md`

공통:
- kebab-case, 소문자
- `{domain}`: `commerce` / `content` / `o2o` / `common`
- page_id 내부 underscore 유지
- 같은 page_id면 같은 파일 재사용 → 여러 플로우에서 PDP가 공통으로 참조 가능

## Element 표기 규칙

오늘의집 로그센터(`mcp__log-center-mcp`)의 모든 element는 세 가지 식별 필드를 가진다:

| 필드 | 출처 | 예시 | 역할 |
|------|------|------|------|
| **title** | 로그센터 명세의 한국어 이름 | `주문 상품` / `장바구니 담기 버튼` / `리뷰 더보기` | 사람이 읽고 바로 어느 요소인지 아는 라벨 |
| **object_section_id** | analyst_log_table 컬럼 | `ORDER_PRODUCT` / `cart_button` | 쿼리 필터/그룹의 키 |
| **object_type** | analyst_log_table 컬럼 | `BUTTON` / `MODULE` / `IMPRESSION` | 요소 타입 |

### 표기 포맷
- **Verbose** (목록·후보·인벤토리·표): `주문 상품 (ORDER_PRODUCT, BUTTON)`
- **Compact** (인라인): `**주문 상품** (`ORDER_PRODUCT`/`BUTTON`)`
- **표** 안에서는 title을 별도 컬럼으로

### title 확보 방법
1. page_id 확정 직후 `mcp__log-center-mcp__get_page_spec(page_id={확정_page_id})` 호출
2. 응답에서 element별 `{title, object_section_id, object_type}` 매핑 추출
3. 이후 모든 사용자 대화·인벤토리·쿼리 결과 표·HTML 라벨에서 매핑 참조

### 예외 처리
- 명세에 title 없음: `{title 없음} (ORDER_PRODUCT, BUTTON)` + 명세 정비 안내
- 로그 only (명세 자체 없음): `(명세 누락) (exp_recommendation_v3, MODULE)`
- 사용자 직접 입력: title 한 번 묻고 빈 값이면 `{사용자 입력}`

## 통합(ALL) 지표 + 메인 랭킹

per-page HTML의 element CTR 차트는 ANDROID/IOS를 분리하지 않고 **통합(ALL) 행을 메인**으로 보여준다.

- **메인 차트**: 통합 click_per_pv 기준 막대 차트, 강조색 `#10B981`
- **정렬**: 항상 ALL.click_per_pv 내림차순 (플랫폼 토글로 바꿔도 element 순서는 유지)
- **보조 차트**: ANDROID/IOS 분리, 회색 톤 (`#94A3B8`/`#64748B`), 토글로 표시
- **랭킹 일관성**: 통합 기준이 element 순서의 single source of truth

SQL은 platform별 행과 ALL 행을 UNION ALL로 함께 출력. ALL 행은 합산이 아닌 unique distinct user count로 별도 CTE에서 재계산 (한 유저가 두 OS 쓰는 케이스 dedup).

## 갱신(refresh) Fast Path + HTML Date Picker

PD가 같은 분석을 주/월 단위로 데이터만 새로 보고 싶을 때를 위한 fast path.

### 동작
- 자연어 트리거: `갱신`/`refresh`/`다시 돌려`/`재실행`/`기간 바꿔서` + 기존 page_id/플로우명
- 명시적 명령: `funnel-check refresh {page_id_또는_플로우명} from {YYYY-MM-DD} to {YYYY-MM-DD}`
- 감지 시: 기존 MD에서 page_id / Flow Definition / element 인벤토리 그대로 로드 → **Step 1~3 전부 건너뛰고 Step 4 (쿼리 단계) 로 점프** → 새 측정 기간만 갈아끼워 쿼리 재실행 → Step 5 HTML 재생성 → auto-open

### HTML 안에서 갱신 명령 생성
- per-page HTML에 `#date-refresh` 섹션 (date picker + 퀵 선택 7일/14일/30일/지난 주/지난 달)
- `[📋 갱신 명령 복사]` 버튼 → `funnel-check refresh {page_id} from {from} to {to}` 를 클립보드로 복사
- 사용자가 Claude에 붙여넣으면 fast path 발동 → 새 기간 데이터로 같은 HTML 갱신 후 다시 open
- HTML이 직접 athena를 호출할 수 없는 제약을 사용자-Claude 왕복 1회로 우회

## 결정 로그

설계 과정에서 내린 결정과 그 이유. 나중에 "왜 이렇게 됐지?" 싶을 때 참고.

### 2026-04-10 v1 최초 설계

**① "내 로그" 소스: user_id + 좁은 시간 구간**
- 대안: 세션 ID 기반 후보 여러 개 제시
- 결정: 노이즈 최소화가 정확성의 핵심. 사용자가 언제 테스트했는지 기억한다는 가정.

**② Flow Definition 저장: MD 파일**
- 대안: JSON, Notion, Confluence
- 결정: 사용자가 직접 열어서 읽고 수정할 수 있어야 함. 버전관리 친화.

**③ 런타임 MCP: athena mcp only**
- 대안: redash mcp 병용
- 결정: 단일 실행 경로가 디버깅/재현성에 유리. redash는 설계 단계 참조용.

**④ 세그먼트 정의: MVP에서 제외**
- 당초 계획: redash에서 신규/활성/부활 표준 SQL을 찾아 스킬에 상수로 박기
- 조사 결과: 전사 표준 SQL 정의가 **존재하지 않음**. 각 팀(BA, CRM, 글린다, 집페이)이 자체 정의 사용. `ba_preserved.user_seg_rfd_v2`가 BA팀 유지 공용 마트로 확인되나 스키마(세그먼트 라벨 컬럼 유무) 미확인.
- 결정: MVP에서는 전체 유저 대상으로만. 세그먼트는 v2로 미룸.

**⑤ Detour 처리: 2층 분리, 층 1은 정규화 후 사용자 확정**
- 초기안: 층 1 정규화 후 AI가 자동으로 플로우 연결
- 수정: AI가 자의적으로 연결하면 또 다른 오염원이 됨. 정규화 결과를 후보로 제시하고 연결은 사용자가 확정.

**⑥ 시각화: Figma 대신 HTML**
- 초기안: Figma MCP의 `generate_diagram`
- 수정: HTML로 충분. MD가 갱신될 때마다 자동 재생성.
- 스타일 레퍼런스: [omtm_review_260302](https://static-contents.datapl.datahou.se/v2/contents/omtm/omtm_review_260302.html)

**⑦ 스킬 파일 위치: `~/.claude/commands/`**
- 기존 log-* 스킬과 동일한 위치.

**⑧ 플로우명 규칙: `{domain}-{from_page}-to-{to_page}[-{variant}]`**

### 2026-04-10 v1.2 audit mode 추가 (이후 v1.4에서 element scope로 통합)

**⑨ 새 mode 추가 vs 별도 스킬 분리: 확장 선택**
- 대안 A: screen-audit이라는 별도 스킬을 자매로 추가
- 대안 B: funnel-check 안에 element 분석 mode를 추가 (Mode 분기)
- 결정: B. 한 곳에 모든 측정 use case를 모아두는 것이 PD가 도구를 학습하기에 단순.

**⑩ Element mode 그라운딩: Hybrid (page_id 우선, 모호하면 내 로그)**
- 결정: Hybrid. 사용자가 page_id 명확히 알면 그대로, 화면명만 알고 page_id 변형이 많으면(PDP/PDP_STYLINGSHOT/...) 후보 제시 → 모르겠다고 하면 flow mode의 그라운딩 메커니즘 호출.

**⑪ Element 인벤토리: 명세 ∩ 로그 / 명세 only / 로그 only 3분류**
- `mcp__log-center-mcp__get_page_spec` 결과와 athena 실로그를 set 연산으로 대조
- 각 분류는 사용자 확인 후 확정. AI가 자동 결정 안 함.

**⑫ Element 시각화: 막대 차트 + 인터랙티브 Figma Mapper**
- 영감: DA 분의 산출물 — 화면 스크린샷에 element별 CTR을 직접 overlay
- 구현: 기본 막대 차트 + 별도 섹션에 Figma URL 입력란. 사용자가 URL 붙여넣으면 iframe embed + draggable label chip을 화면 위로 끌어다 매핑. localStorage에 위치 영속화 + JSON export.
- v2 비전: Figma MCP로 element 좌표 자동 추출 → 매핑 자동화
- 제약: Figma iframe은 cross-origin이므로 iframe 내부 인터랙션은 못 가로챔. label overlay는 iframe **위에** 별도 div로 배치.

**⑬ Page Health Metric 동봉: 스크롤률 + 평균 체류시간**
- element CTR만 보면 페이지 단위의 engagement를 놓침. 같이 봐야 "이 화면 자체가 안 쓰이는지, 아니면 화면은 진입하는데 element가 안 쓰이는지" 구분 가능.
- SCROLL 카테고리가 명세에 있으면 scroll_rate, 없으면 dwell time만.
- 별도 쿼리로 분리해서 element 쿼리와 독립 실행 (실패 시 부분 결과라도 확보).

### 2026-04-10 v1.2.1 환경 점검 + 팀 패키지화

**⑭ Step -1 환경 점검 추가**
- 동기: 동료가 처음 받아 쓸 때 막연한 "tool not found" 에러 대신 명확한 설치 안내가 필요
- 동작: 의존 스킬(log-explore/query/spec) Glob 확인, 빠지면 두 가지 설치 방법(CLAUDE.md skill path / 슬래시 커맨드) 안내. MCP는 사전 검사 없이 호출 시점에 시도하고 실패하면 친절 메시지로 변환.
- (이후 v1.4에서 통과 시 silent로 변경)

**⑮ 팀 패키지화: Ohouse-product-design/AI-Skill 레포에 등록**
- AI-Skill 레포 컨벤션(`skills/{name}/SKILL.md` + `cursor.yaml`)을 따름
- 두 설치 방식: CLAUDE.md skill path (자동 발동) / `~/.claude/commands/` 복사 (슬래시)
- yohan WIP는 `[YH] Data-insight/funnel-check/`, 안정화 후 `skills/funnel-check/`로 promotion

### 2026-04-10 v1.3 리프레이밍 + UX 다듬기

**⑯ "제거" 키워드 전면 삭제 + 미션 재정의**
- 동기: 스킬 description과 본문에 "사용도 낮은 element를 빼는 결정" 같은 표현이 많았는데, 이건 도입 동기였지 스킬 자체의 목적은 아님. 사용자(PD)가 명시적으로 지적: "내가 이 스킬을 왜 만들었는지 배경이지 이 스킬이 제거를 위한 게 아니야. element 전환률을 알아야 좋은 디자인 의사결정을 한다고 생각했던 거야."
- 결정: "제거", "안 쓰이는", "audit", "낭비" 등 키워드를 description/원칙/MD 템플릿/HTML 섹션에서 모두 삭제. 미션을 **"element 전환률을 정량적으로 이해해서 더 나은 디자인 의사결정을 한다"** 로 재정의.
- Mode B 이름: `audit` → **`element`** (이후 v1.4에서 다시 per-page 루틴으로 통합)

**⑰ 모든 사용자 질문에 [a]/[b]/[c] 번호 선택지**
- 동기: 자유 입력으로 받으면 사용자 답변이 다양해서 파싱 어렵고 페이스가 느려짐
- 결정: 핵심 결정 질문에는 항상 알파벳 선택지를 명시. 직접 입력은 별도 옵션으로.

**⑱ Flow scope 그라운딩 [a] 라이브 / [b] 텍스트 분기**
- 동기: 라이브 워크스루가 가장 정확하지만, 잘 아는 표준 플로우면 텍스트로 빠르게 입력하고 싶음
- 결정: 두 방식을 명시 선택. 텍스트 매핑이 막히면 라이브로 fallback 제안.
- 텍스트 입력 예: `"쇼핑홈 > PDP > 장바구니 > 주문 결제"` → 단계마다 page_id 후보 제시

**⑲ Element 표기 삼중 규칙 도입 (`title (object_section_id, object_type)`)**
- 동기: PD가 element 인벤토리를 봤을 때 `cart_button (BUTTON)` 만으론 어느 화면 요소인지 인지 불가. 로그센터에 한국어 title이 있는데도 활용 안 하고 있었음.
- 결정: 모든 element 표기에서 **반드시** title을 함께 보여줌. log-center mcp의 `get_page_spec` 응답에서 매핑 추출 후 메모리에 저장, 이후 모든 사용자 대화/표/HTML에서 재사용.

**⑳ 속도 원칙 — 핵심 결정만 확인, 나머지는 announce**
- 동기: 사용자 피드백 "물어보는 게 너무 많아서 결과까지 도달이 너무 느려"
- 결정: 핵심 결정(scope/page_id/쿼리 승인) 3개만 확인. 나머지(맥락 수집, 트리거, 인벤토리)는 announce 후 자동 진행. 한 메시지에 묶어서 묻기.
- Step -1 환경 점검: 통과 시 silent. 실패 시에만 알림.

**㉑ Step 5 끝에 HTML 자동 오픈 (`open ./...html`)**
- 동기: 최종 산출물이 HTML인데, 사용자가 매번 파일 경로 클릭해서 열어야 했음
- 결정: Step 5 끝에 macOS `open` 명령으로 자동 새 창. 사용자 승인 X.

**㉒ HTML 통합(ALL) 지표 + 메인 랭킹**
- 동기: 사용자 피드백 "iOS/Android 통합으로 보는 것도 필요하고, 통합 기준으로 랭킹 잡아주는 게 필요해. 통합 지표는 색을 더 강조해도 좋고."
- 결정: SQL에 `ALL` platform 행을 별도 CTE로 재계산 (UV dedup 보장) UNION ALL. HTML 메인 차트는 통합, 강조색 `#10B981`. ANDROID/IOS는 회색 톤 보조.
- 정렬은 항상 ALL.click_per_pv 기준 — 플랫폼 토글로 바꿔도 element 순서 유지 (랭킹 일관성).

**㉓ HTML Date Picker + 갱신 명령 클립보드 복사 + Fast Path**
- 동기: 사용자 피드백 "유저가 직접 날짜 선택해서 데이터 다시 갱신할 수 있는 기능이 필요할 거 같아"
- 제약: HTML은 athena를 직접 호출 못함 (MCP 없음)
- 결정: HTML 안에 `#date-refresh` 섹션 (date picker + 퀵 선택). `[📋 갱신 명령 복사]` 버튼이 `funnel-check refresh {이름} from {from} to {to}` 텍스트를 클립보드에 복사. 사용자가 Claude에 붙여넣으면 스킬이 fast path로 진입 — 기존 MD 로드 → Step 1-3 건너뛰고 Step 4부터 재실행 → HTML 갱신 → auto-open.
- 사용자-Claude 왕복 1회로 갱신 UX 완성. 매번 처음부터 page_id 확정/인벤토리 검토 안 시킴.

### 2026-04-10 v1.4 per-page_id HTML 아키텍처 (대규모 재구조화)

**㉔ HTML 단위 = page_id 로 통일**
- 동기: 사용자 피드백 "page_id마다 html을 생성해주고, 플로우는 page_id 안에 그래프에 포함된 클릭률 랭킹 등을 누르면 그 누른 page_id가 열리면 어떨까?"
- 기존 구조: flow mode = `./flows/{flow}.html` 1개, element mode = `./screens/{screen}.html` 1개 — 두 mode가 별개 산출물
- 새 구조: **단위가 page_id**. single이든 flow든 산출물은 항상 `./screens/{page_id}.html`. 같은 page_id면 같은 파일 재사용.
- 효과:
  - 한 PDP를 분석한 다음, PDP가 포함된 다른 플로우를 분석할 때 PDP HTML이 그대로 재사용됨
  - 화면→화면 click navigation 가능 (HTML 간 `<a href>` 링크)
  - "이 화면 분석 + 이 화면이 속한 플로우" 가 자연스럽게 한 산출물로 합쳐짐

**㉕ Mode A/B 분리 폐지 → scope (single | flow) + 공통 per-page 루틴**
- 동기: ㉔의 결과로 두 mode의 per-page 분석 로직이 동일해짐 (둘 다 element 인벤토리 + CTR + Page Health). 분리 유지할 이유가 없음.
- 결정: scope를 `single` (page_id 1개) 또는 `flow` (page_id N개)로 정의. 둘 다 동일한 **per-page 루틴**(인벤토리/쿼리/HTML)을 호출. flow는 추가로 페이지 간 funnel + flow header inject.
- Step 0 메뉴 재작성: "element vs flow" → "단일 화면 [a] / 플로우 [b]" — 사용자가 직관적으로 이해하는 질문

**㉖ Flow header section을 각 page_id HTML에 inject**
- 동기: 사용자 피드백 "처음에 유저가 요청했던 전체 플로우에서 넘어가는 전환률을 시각적으로 최상단에 보여주는 거야. 거기서도 page_id 클릭하면 html 나오는 건 마찬가지야."
- 대안 A: 별도 `flow-{name}.html` 을 만들어 funnel을 거기 두기
- 대안 B: 각 page_id HTML 최상단에 flow header section을 inject
- 결정: B. 이유는 사용자가 어느 page_id를 보고 있어도 항상 자기 위치를 funnel 안에서 인지할 수 있음. 별도 index를 거치지 않고 바로 page를 봄.
- 구현: flow scope에서 funnel 데이터 계산 → 각 page_id HTML 생성 시 flow header section을 inject. 현재 page는 강조, 다른 page 노드는 클릭 시 `<a href="./{node_page_id}.html">`.

**㉗ Click-through navigation: trigger element 막대 클릭 시 다음 page_id HTML 열기**
- 동기: ㉖의 자연스러운 확장. element 차트에서 trigger element(다음 페이지로 가는 버튼)를 누르면 그 페이지로 가는 게 직관적
- 결정: flow scope에서만 활성. flow definition의 trigger 매핑을 inline JS로 주입 (`window.FLOW_TRIGGERS = {...}`). 매핑된 element 막대는 `→ 다음 페이지로` 라벨 + cursor pointer + 클릭 시 `<a href="./{next_page_id}.html">`.

**㉘ Step 5 entry HTML auto-open: flow scope면 첫 페이지 1개만**
- 결정: per-page 루틴 loop가 끝난 뒤 첫 entry page_id의 HTML만 `open` 으로 새 창. loop 안에서 매번 띄우면 N개 창이 떠서 사용자 경험 최악.
- 사용자 보고: "✅ 플로우 분석 완료. 첫 페이지 HTML을 새 창으로 띄웠어. 다른 페이지: {리스트}. 상단 funnel이나 element 차트의 trigger를 클릭하면 해당 페이지로 이동돼."

**㉙ 파일명 단순화: 화면명/플로우명 기반 → page_id 기반**
- 기존 v1.2/1.3: `commerce-pdp.md` (domain + page_id) — variant도 prefix 형태
- 새 v1.4: `pdp.md` (page_id 그대로 소문자), variant는 `__` suffix (`pdp__202604-renewal.md`)
- 이유: 같은 page_id면 같은 파일을 공유해야 여러 플로우에서 재사용 가능. domain은 page_id에 이미 함의되어 있음 (PDP→커머스, CDP→콘텐츠).

**㉚ flow 정의는 `./flows/{flow_name}.md` 에 별도 보관 (HTML 없음)**
- flow name은 여전히 `{domain}-{from}-to-{to}` 형식 유지 — 여러 플로우가 한 page_id를 공유할 수 있어서 page_id ≠ 플로우명
- flow 정의 MD에는 page_id 시퀀스, trigger 매핑, funnel 쿼리 결과만. 별도 HTML은 없고 funnel 시각화는 각 page_id HTML 의 flow-header section에 inject됨.

**㉛ MD 템플릿에 `참조 플로우` 필드**
- 한 page_id가 여러 플로우에 동시 포함될 수 있음을 명시
- 예: `./screens/pdp.md` 의 frontmatter에 `참조 플로우: [commerce-pdp-to-cart, commerce-pdp-to-wishlist]`

### 2026-04-11 v1.5 인터랙션 축소 (실측 피드백 기반)

**㉜ 동기: 다른 터미널에서 실측한 audit 호출 ~30턴 / 47턴 max**
- 사용자가 commerce-shoppinghome 분석을 1회 실행했을 때 실제 인터랙션이 ~30턴 발생, 시간이 너무 오래 걸린다는 피드백
- 분석 결과: page_id 확정만 10턴 이상 (첫 후보 `SHOPPING_HOME` underscore 추측 miss → 그라운딩 → 빈 결과 → 어제 파티션 재시도 → 정답 `SHOPPINGHOME` 발견 등)
- 원칙 "자의적 추론 금지" 가 워크플로우 옵션 결정(컷오프, 측정 기간, 인벤토리 범위)에까지 너무 광범위하게 적용되어 사용자에게 떠넘김
- **목표: 1회 호출당 인터랙션을 ~30턴 → 4~5턴으로 축소**

**㉝ 결정 종류 2단 분리 — 새 1번 원칙으로 격상**
- **데이터 의미 결정** (자의 금지 유지): scope 선택, page_id 확정, element 분류, 페이지 연결, trigger 확정, athena 쿼리 실행 승인 → 후보 제시 + 사용자 확정
- **워크플로우 옵션 결정** (스마트 디폴트): 측정 기간, 컷오프 N, 명세 only 처리, 인벤토리 범위, 그라운딩 파티션 → 디폴트 자동 적용 + "변경 원하면 알려줘" 한 줄 안내
- 이 분리 덕분에 매 호출마다 묻는 질문이 본질적으로 줄어듦. 사용자는 결과를 본 뒤 사후 정정만 하면 됨.

**㉞ # 디폴트 값 섹션 신설**
- 측정 기간: 7일 → **30일** (audit에는 7일이 표본 노이즈 너무 큼)
- 그라운딩 파티션: **어제(date - 1일) 우선** (당일 인입 지연 우회)
- 인벤토리 범위 default: **명세 ∩ 로그 + 로그 only** (명세 only는 별도 표로 분리)
- 컷오프 default: **상위 16개**
- uv 컷: **uv ≥ 1**
- 정렬: 통합 click_per_pv 내림차순 (v1.3 유지)
- 모든 디폴트는 한 곳에 모아서 관리, 사후 조정으로 변경 가능

**㉟ # HTML 작성 규칙 섹션 신설 — 외부 CDN 의존 0**
- 동기: Recharts CDN 의존 실패로 차트가 빈 화면 뜨는 사고가 실측 세션에서 발생
- 결정: HTML은 외부 라이브러리 import 일체 금지. 차트는 순수 HTML/CSS bar (`<div>` + `width: %`) 또는 inline SVG. inline `<style>` + inline `<script>` + inline DATA.
- 렌더 순서: 표/리스트/카드 먼저 → 차트 마지막. 차트 fail해도 표/리스트는 살아남게 try/catch.
- 효과: HTML 파일 한 개만 있으면 어디서든 (사내망 CDN 차단 모드 포함) 동작
- v1.3에서 도입한 Recharts via CDN 명시는 폐지 (스타일 가이드 갱신 필요)

**㊱ Step 1-B 맥락 수집: 디폴트 적용으로 1턴**
- 기존: 분석 대상/목적/기간을 한 메시지에 묶어 묻기 (v1.3에서 이미 묶음)
- 추가: **분석 대상만 필수**, 나머지는 빈칸이면 디폴트로 자동 채움
- 사용자가 분석 대상만 적어도 즉시 다음 단계로

**㊲ Step 2-B page_id 자동 fuzzy 확장 + 병렬 명세 조회**
- 동기: 사용자가 "쇼핑홈" 이라고만 하면 SHOPPINGHOME / SHOPPING_HOME / SHOPPING_TAB_HOME 등 6+가지 변형 중 정답을 찾는 데 5~10턴 소요
- 결정:
  - **Variant 자동 생성** — 한국어 → 영문 매핑 사전, underscore on/off, 도메인 prefix, suffix 변형 (5~10개)
  - **병렬 명세 조회** — 후보를 한 메시지 안에서 동시에 `get_page_spec` 호출 (각각 try, 200만 채택)
  - **자동 confirm** — 명세 존재 후보가 1개거나, description에 사용자 키워드가 정확히 포함된 게 1개면 별도 컨펌 없이 진행, 한 줄 안내만
  - 매칭이 모호할 때만 사용자에게 번호 선택지 제시
  - 명세 fail이면 라이브 그라운딩 fallback
- 효과: page_id 확정 5~10턴 → 1~2턴

**㊳ 그라운딩 파티션 default = 어제**
- 동기: 당일 파티션 인입 지연(0건)을 만나서야 어제로 fallback하던 reactive 패턴
- 결정: 처음부터 어제 파티션을 기본 사용. 시각도 모르면 어제 전체 파티션 스캔 (스코프 한정이라 cost OK).

**㊴ user_id 캐싱 (`memory/reference_funnel_check.md`)**
- 동기: 매 호출마다 그라운딩 시 user_id 다시 묻기
- 결정: 첫 호출 시 `~/.claude/projects/{project}/memory/reference_funnel_check.md` 에 저장, 이후 자동 사용 + "user_id={N}로 진행할게 (캐시됨)" 한 줄 안내. "다른 user_id로" 정정 시 재캐시.
- 자주 쓰는 측정 기간 등 단골 정보도 같은 파일에 함께 저장.

**㊵ Step 3-B + Step 4-B 통합 쿼리**
- 동기: 기존에 인벤토리 쿼리(Step 3-B-2)와 CTR 쿼리(Step 4-B-1)가 분리되어 같은 30일 풀스캔을 2번. 사용자 컨펌도 2번.
- 결정: 1개 통합 CTE 쿼리로 (a) element 인벤토리 (b) PV UV (c) CTR/IR/click_per_pv 를 한 번에 산출. 풀스캔 1회. 쿼리 승인도 1번.
- Step 3-B-2 옛 인벤토리 쿼리는 LEGACY 표시로 참고만 남김.

**㊶ 인벤토리 분류/컷오프 자동 적용 (별도 컨펌 X)**
- 기존: 인벤토리 범위 [A/B/C], 명세 only 처리 [1/2], 컷오프 N → 별도 turn 3개
- 결정: 디폴트 값 자동 적용 후 결과를 한 번에 보여주고 사후 조정 안내만 한 줄 ("범위/컷오프/기간 변경하려면 'N=20으로', '명세 only도 포함' 처럼 말해줘"). 사용자 답변 기다리지 않고 즉시 다음 단계 (쿼리 승인)로 진행.
- 사용자가 사후에 정정하면 그때 인벤토리 수정 + 쿼리 재실행

**㊷ Step -1 환경 점검 — 컨펌 turn 제거**
- 기존: 통과 시 silent (v1.3에서 도입), 부분 통과 시 "계속/중단" 컨펌 turn
- 결정: 부분 통과 시에도 컨펌 turn 제거. 한 줄 경고만 출력하고 자동 계속. 막힐 가능성이 있는 단계에 도달하면 그때 한 번 더 알림.

**㊸ get_page_spec 응답 사이즈 회피 — python3 helper 패턴화**
- 동기: `get_page_spec` 응답이 100k+ 토큰으로 컨텍스트를 통째로 잡아먹음
- 결정: 호출 직후 python3 한 줄로 page_info만 먼저 추출 (page_id, description, category). `log_specifications`(element 리스트, 거대한 부분)는 Step 3-B 인벤토리 시점에만 따로 추출.
- 예시 패턴:
  ```bash
  python3 -c "
  import json
  with open('/tmp/page_spec.json') as f:
      data = json.load(f)
  print(json.dumps({
      'page_id': data.get('page_id'),
      'description': data.get('description'),
      'category': data.get('category'),
  }, ensure_ascii=False, indent=2))
  "
  ```

**㊹ 변경 후 예상 turn 수**

| 단계 | 기존 (v1.3/v1.4) | v1.5 | 비고 |
|------|---|---|---|
| Step -1 환경 점검 | 1 (부분통과 시 컨펌) | 0 | silent + 컨펌 제거 |
| Step 0 scope 선택 | 1 | 1 | 핵심 결정 — 유지 |
| Step 1 맥락 수집 | 1 (묶음) | 1 | 분석 대상만 필수 |
| Step 2 page_id 확정 | 5~10 | 1~2 | fuzzy 확장 + 자동 confirm |
| Step 3 인벤토리 분류 | 3 | 0 | 디폴트 자동 적용 |
| Step 4 쿼리 승인 | 2 | 1 | 통합 CTE 1개 |
| Step 5 HTML | 0~1 | 0 | 자동 생성 + auto open |
| **합계** | **15~20+** | **4~5** | **약 75% 축소** |

**㊺ 명시적 비범위 (의도적으로 안 바꾼 것)**
- v1.4의 per-page_id HTML 아키텍처 — 그대로 유지 (실측 피드백은 옛 audit mode 가정이었지만, 우리가 이미 v1.4에서 더 큰 재구조화를 했음)
- "audit mode" 용어 폐지 — v1.4에서 이미 폐지, 되살리지 않음
- "자의적 추론 금지" 원칙 폐기 안 함 — 데이터 의미 결정에는 그대로 유지
- MCP 도구 변경 안 함 — `get_page_spec` 응답 사이즈는 도구 측 문제, 우회만 함
- flow scope 변경 안 함 — 인터랙션 축소 동일 원칙은 적용하지만 페이지 시퀀스 정의 자체는 사용자 확정 필수 (본질적으로 줄이기 어려움)

## 알려진 제한 / 미해결 질문

- **세그먼트 미지원**: v2에서 해결 예정. 선결 과제는 `ba_preserved.user_seg_rfd_v2` 스키마 확인.
- **Figma mapping은 수동 좌표**: 사용자가 눈으로 보고 드래그. v2에서 Figma MCP로 자동 좌표 매핑 목표.
- **Figma iframe cross-origin**: iframe 내부 클릭은 못 가로챔. label overlay는 iframe 위 별도 레이어. 라벨이 iframe 클릭을 가리지 않도록 pointer-events 관리 필요.
- **SCROLL 카테고리 존재 여부 미검증**: 명세에 SCROLL이 없는 page_id가 다수일 가능성. 런타임에 `log-explore`로 검증하고 없으면 dwell time만 fallback.
- **HTML 재생성 방식**: 매번 전체 재작성. 플로우/element가 많아지면 느려질 수 있음. 성능 이슈 발생 시 섹션별 부분 갱신.
- **시간대 처리**: 사용자가 말하는 "오후 2시쯤"이 KST인지 UTC인지 모호. 스킬이 KST로 가정하고 변환 필요.
- **"내 로그"를 못 찾는 케이스**: 사용자가 시각을 잘못 기억하면 그라운딩 실패. 폴백 플로우 없음.
- **localStorage 격리**: HTML을 다른 환경(다른 PC)에서 열면 매핑이 보이지 않음. JSON export로 회피하지만 사용자 작업 필요.
- **Flow header inject 동기화**: 같은 page_id가 여러 플로우에 참조될 때, 어느 플로우의 flow header를 우선 inject할지 결정 필요. 현재는 `참조 플로우` 필드의 첫 항목을 default로 가정. 사용자가 명시 선택할 수 있어야 함 (v1.5 후보).
- **갱신 fast path와 inventory 변화**: 갱신은 기존 인벤토리를 그대로 재사용하는데, 측정 기간 사이에 새 element가 추가되었으면 누락됨. 사용자가 명시적으로 "인벤토리도 다시"를 요청해야 함.

## 로드맵

### v1.5 후보
1. **Flow header inject 우선순위 선택**: 한 page_id가 여러 플로우에 참조될 때 사용자가 어느 flow header를 메인으로 보일지 선택
2. **Inventory 자동 diff**: 갱신 시 명세/로그가 변했는지 감지하고 알림
3. **HTML 부분 재생성**: 변경된 섹션만 갱신해서 대형 플로우 성능 개선

### v2 후보 (우선순위 순)

1. **세그먼트 지원**
   - 선결 과제: `ba_preserved.user_seg_rfd_v2` 스키마 확인
   - 스키마에 라벨 컬럼 있으면: 런타임 LEFT JOIN
   - 없으면: BA팀과 정의 합의 후 임계값 상수화

2. **Figma MCP 자동 좌표 매핑**
   - 현재 v1.4는 사용자 수동 드래그
   - Figma MCP로 frame의 child element 좌표를 자동 추출
   - object_section_id ↔ Figma layer name 매핑 규칙 필요 (DS팀과 협의)

3. **peer-compare scope**
   - 같은 카테고리의 다른 화면 평균과 비교
   - 예: "PDP의 cart_button click_per_pv가 같은 커머스 detail page들의 평균보다 낮음"

4. **trend scope**
   - 시계열 변화 추적 — 리뉴얼 전후 비교

5. **세션 후보 선택 기능**
   - 사용자가 테스트 시각 모를 때, 최근 N일치 세션 요약 보여주고 고르기

6. **엄격 퍼널 명시적 옵션화**
   - 호출 시점에 `--strict` 플래그로 받기

### 유지보수 체크포인트

- **분기마다**: 실제로 몇 번 썼는지, 어디서 막혔는지 돌아보기
- **로그 스키마 변경 시**: `log.analyst_log_table` 스키마 변경이나 새 enum 추가 시 쿼리 템플릿 갱신
- **log-query 스킬 변경 시**: funnel-check는 log-query의 규칙(파티션, 필터)을 승계하므로 상호 체크
- **Figma embed URL 형식 변경**: Figma가 embed URL 스펙을 바꾸면 Figma mapper 코드 갱신
- **로그센터 명세 스키마 변경**: title 필드명/응답 형식 변경 시 element 표기 규칙 코드 갱신
- **DA 산출물 형식 변화**: 영감의 원천이 더 발전하면 여기 align (예: heat map, click distribution 등)

## 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| 2026-04-10 | v1 | 최초 스킬 작성 (MVP: 세그먼트 제외, flow mode only) |
| 2026-04-10 | v1.1 | 플로우명 규칙 추가 (`{domain}-{from}-to-{to}`) |
| 2026-04-10 | v1.2 | **audit mode 추가**. Mode 개념 도입, 화면 단위 element 사용도 분석, ANDROID/IOS 분리, page health metric, 인터랙티브 Figma mapper, `./screens/` 산출물 폴더 |
| 2026-04-10 | v1.2.1 | **Step -1 환경 점검 + 팀 패키지화**. 의존 스킬(log-*) 자동 감지 및 설치 안내. Ohouse-product-design/AI-Skill 레포에 frontmatter 포함 SKILL.md + cursor.yaml + README.md 형태로 등록 |
| 2026-04-10 | v1.3 | **리프레이밍 + UX 다듬기**. "제거" 키워드 전면 삭제, 미션 재정의 (element 전환률 이해 → 디자인 의사결정), Mode B `audit` → `element` 리네임. 모든 질문에 [a]/[b]/[c] 선택지. Flow scope 그라운딩 [a] 라이브 / [b] 텍스트 분기 + fallback. **Element 삼중 표기 규칙** (`title (object_section_id, object_type)`) — log-center mcp `get_page_spec` 응답에서 매핑. **속도 원칙** — 핵심 결정만 확인, 나머지 announce. 한 메시지에 묶어서 묻기. Step -1 silent on success. **Step 5 끝 HTML 자동 오픈** (`open ./...html`). **HTML 통합(ALL) 지표** + 메인 랭킹 + 강조색 (`#10B981`). **HTML date picker + 갱신 명령 클립보드 복사 + Fast Path** (Step 1-3 건너뛰고 Step 4부터 재실행) |
| 2026-04-10 | v1.4 | **per-page_id HTML 아키텍처 (대규모 재구조화)**. HTML 단위를 page_id로 통일 — single이든 flow든 산출물은 `./screens/{page_id}.html`, 같은 page_id면 재사용. **Mode A/B 분리 폐지** → scope (single \| flow) + 공통 per-page 루틴. Flow scope는 page_id 시퀀스 확정 + funnel 정의 → 각 page_id에 per-page 루틴 loop. **Flow header section을 각 page_id HTML에 inject** — 현재 page 강조, 다른 page는 클릭 가능 (`<a href="./{node_page_id}.html">`). **Click-through navigation** — element 차트의 trigger element 막대 클릭 시 다음 page_id HTML 열림 (`window.FLOW_TRIGGERS = {...}` inline). Step 5 entry HTML auto-open — flow scope면 첫 페이지 1개만. **파일명 단순화** — 화면명/플로우명 기반 → page_id 기반 (`pdp.html`, variant는 `__` suffix). flow 정의는 `./flows/{flow_name}.md` 에 별도 (HTML 없음). MD 템플릿에 `참조 플로우` 필드 — 한 page_id가 여러 플로우에 동시 포함 가능 |
| 2026-04-11 | v1.5 | **인터랙션 축소 (실측 피드백 기반)**. 1회 호출당 ~30턴 → 4~5턴 목표. **결정 종류 2단 분리** — 데이터 의미(scope/page_id/쿼리 승인)는 사용자 확정, 워크플로우 옵션(측정기간/컷오프/인벤토리 범위/그라운딩 파티션)은 디폴트 자동 적용 + 사후 조정. **# 디폴트 값** 섹션 신설 (측정기간 30일, 어제 파티션 default, 컷오프 16, 명세 only 분리). **# HTML 작성 규칙** 신설 — 외부 CDN 의존 0 (Recharts 등 import 금지), 순수 HTML/CSS bar + inline SVG, 표/리스트 우선 렌더 + 차트 try/catch fallback. **page_id fuzzy 자동 확장** — 한국어→영문 매핑 사전 + underscore on/off + 도메인 prefix/suffix 변형 → 5~10개 후보 병렬 `get_page_spec` 호출 → description 매칭 자동 confirm (1개면 무컨펌 진행). **그라운딩 default = 어제 파티션** (당일 인입 지연 우회). **user_id 캐싱** (`memory/reference_funnel_check.md`) — 첫 호출 후 자동 사용. **Step 3-B + 4-B 통합 쿼리** — 인벤토리/CTR/Page Health 한 CTE 1개로 풀스캔 1회. **인벤토리 분류/컷오프 자동 적용** — 별도 컨펌 turn 제거, 결과 announce + 사후 조정 한 줄. **Step -1 컨펌 turn 제거** — 부분 통과도 한 줄 경고 후 자동 계속. **`get_page_spec` 응답 사이즈 회피** python3 helper 패턴화 — page_info만 우선 추출, log_specifications는 인벤토리 시점에만. **Step 1-B 분석 대상만 필수**, 나머지 디폴트로 자동 채움 |
| 2026-04-13 | v1.5.1 | **"제거" 맥락 잔존 표현 중립화 + 슬래시 커맨드 동기화 + 패키지 재정리**. v1.3 리프레이밍(⑯)에서 SKILL.md 본문은 대부분 바뀌었으나 몇 곳에 잔존 표현이 남아있던 것을 정리. (a) **SKILL.md**: line 891 "(제거 후보 아님, 자동 제외 X)" → "(자동 분석 대상 아님, 명세 정비 참고용)". HTML 섹션 `low-usage-elements` → `lower-ranking-elements`, 라벨 "사용도 낮은 element 표" → "Element 클릭률 랭킹 — 하위 구간 참고표". MD §5도 같은 프레이밍으로 재작성 (오름차순, 판단은 사용자 몫 명시). 명세 ∩ 로그/명세 only 설명에서 "왜 안 눌리는지" 등 가치판단성 표현 제거. (b) **cursor.yaml**: 구버전 description (`audit`, `안 쓰이는 버튼 찾아줘`, `element를 빼는 결정` 문구)을 최신 SKILL.md frontmatter와 일관되게 재작성. (c) **README.md**: HTML 섹션 설명 "사용도 낮은 element 표" → "Element 클릭률 랭킹 — 하위 구간 참고표". skills/funnel-check/README.md 버전 히스토리에 v1.5.1 항목 추가. (d) **중대한 정리**: `~/.claude/commands/funnel-check.md` 로컬 슬래시 커맨드는 이번에 처음으로 zip 배포본 v1.5와 동기화 — 이전엔 v1.3 이전 구조(Mode A/B 분리, "audit mode" 등)가 슬래시 커맨드에 남아있었고 `/funnel-check` 자동 추론 실패 시 사용자에게 구버전 프롬프트가 노출됐음. (e) **AI-Workflow 레포 구조 정리**: `[YH] Data-insight/` 아래 평탄하게 있던 `funnel-check-spec.md` / `funnel-check_README.md` / `funnel-check.md`(직전 커밋에 잘못 올라간 구버전) / `funnel-check_v1.5.zip`을 `funnel-check/` 하위 폴더로 재배치. `spec.md`, `README.md`, `SKILL.md`, `funnel-check_v1.5.1.zip` 구조. 직전 커밋 `2643c0a`에서 실수로 올라간 구버전 `funnel-check.md`는 폐기 |
| 2026-04-13 | v1.5.2 | **Athena 비용 최적화 — 쿼리 통합 + 디폴트 재조정 + dwell 제거**. 배경: 요한님 지적 "쿼리 작성/확인이 느리고, 긴 기간 반복 호출 시 요금 폭탄 우려". `describe_table`로 `log.analyst_log_table` 확인 결과 파티션은 `date` 하나뿐(`page_id` 파티션 없음), `duration_ms` 계열 컬럼 없음. 이를 전제로 세 가지 동시 변경. (a) **per-page 통합 쿼리 1개로 합체** — 기존 Element CTR 쿼리(4개 CTE: `page_uv`/`page_uv_all`/`element_metrics`/`element_metrics_all`) + Page Health 쿼리(3개 CTE: `visits`/`scrolls`/`dwell`) 를 **`src` CTE 1개 + `ROLLUP(platform)` 기반 2 aggregation + JOIN** 단일 쿼리로 재작성. per-element metrics(impression_uv/click_uv/ctr/ir/click_per_pv) + per-page metrics(pv_uv/pv_sessions/scroll_uv/scroll_rate) + `click_per_session` 신규 지표를 한 번의 스캔으로 산출. 플랫폼 rollup(ANDROID/IOS/ALL)은 `GROUP BY ROLLUP(platform)`이 담당. scan 실질 1회로 고정. 원칙 3 "여러 쿼리 만들지 말고 한 쿼리에 통합"으로 강화. (b) **디폴트 측정 기간 30일 → 14일** — 주요 element 표본 정합성은 14일에 충분, 30일은 스캔 비용 2배에 증분 정합성 이득 작음. 롱테일 element/월 단위 비교 필요 시 사용자 명시 요청. (c) **`object_section_idx` 스캔 단계 컷오프 도입, 디폴트 < 10** — 영감 쿼리(요한님 동료 작성)에서 차용. 스크롤 안 한 유저에게 로딩조차 안 된 하단 element가 IR 분모/분자에 섞이지 않도록 스캔 단계에서 제거 → 정합성 + 비용 동시 개선. 3으로 좁히면 "첫 화면만", 사용자가 "전체 idx로" 요청 시 조건 제거. (d) **`avg_dwell_seconds` 제거** — `log.analyst_log_table`에 duration 컬럼 없어 LEAD 기반 계산이 page_id 필터 없이 전체 유저 이벤트 스캔 필요. 비용 대비 정합성 이득 작음. click_per_pv + scroll_rate + click_per_session 조합으로 engagement 신호 충분. 필요 시 v1.6에서 옵션으로 재도입 가능. (e) **`session_id` 축 추가** — `pv_sessions` / `click_sessions` / `click_per_session` 신규 메트릭. 같은 src 스캔에 얹혀서 추가 비용 거의 없음, session 단위 사용 빈도 파악. (f) **#디폴트 값 섹션 갱신** — 측정 기간 14일, `object_section_idx` 스캔 컷오프 10, 비용 원칙 설명 추가. (g) **공통 주의사항에 "쿼리는 통합 1개가 원칙", "비용 원칙" 2줄 추가**. (h) **MD §4 쿼리 결과 표 재작성** — 통합 쿼리 1개 + 4-1 per-element 표(click_sessions/click_per_session 컬럼 추가) + 4-2 per-platform page health 표(pv_sessions 추가, avg_dwell_seconds 제거) |
