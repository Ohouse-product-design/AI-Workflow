---
name: funnel-check
description: >
  오늘의집 PD가 자기 오너십 화면의 데이터를 정확하게 측정하는 팀 공용 스킬.
  "전환률 알려줘", "퍼널 보여줘", "이 플로우 어디서 떨어지나",
  "이 버튼/모듈 얼마나 눌리나", "element 전환률", "click 비율", "funnel-check"
  같은 표현이 나오면 반드시 이 스킬을 사용할 것.
  HTML 산출물의 단위는 항상 page_id — 단일 화면 분석이면 1개 page_id, 플로우 분석이면
  플로우의 각 page_id마다 하나씩 HTML이 생성되고 서로 링크된다.
  플로우의 첫 HTML(entry page) 최상단에는 페이지 간 전환률 funnel이 표시되고
  그 funnel의 각 노드와 element 차트의 trigger element를 클릭하면 해당 page_id의 HTML이 열린다.
  사용자에게 한 단계씩 물어가며 정답을 함께 만들고 athena 쿼리는 항상 전문 보여주고
  승인 후 실행. element는 항상 로그센터 명세(log-center mcp)의
  title + object_section_id + object_type 세 필드로 표기해 PD가 어느 화면 요소인지
  바로 알 수 있게 한다. PD가 정량 근거를 들고 더 나은 디자인 의사결정을 하게 돕는 것이 미션.
  의존: log-explore / log-query / log-spec 스킬과 athena mcp / log-center mcp.
---

# 데이터 인사이트 측정 (funnel-check)

프로덕트 디자이너가 자기 오너십 화면의 데이터를 **정확하게** 측정하는 skill입니다. page_id 안 element들이 실제로 얼마나 쓰이고 어디서 전환이 일어나는지 **정량적으로 이해**해서, 디자인 의사결정을 정성적 감이 아닌 데이터 근거 위에 세우는 게 이 skill의 미션입니다.

## 핵심 아키텍처: HTML 단위 = page_id

이 skill의 모든 산출물은 **page_id 하나당 HTML 한 개** 로 떨어진다.

- **단일 화면 분석**: 한 page_id의 element 분석 HTML 1개 (`./screens/{page_id}.html`)
- **플로우 분석**: 플로우에 포함된 각 page_id마다 HTML 1개. 모든 HTML은 서로 링크되어 페이지 간 클릭 이동 가능. **첫 HTML(entry page)** 최상단에는 전체 플로우 funnel이 시각적으로 표시되고, funnel 노드를 클릭하면 그 page_id의 HTML이 열린다. 각 page_id 안의 element 차트에서 trigger element(다음 페이지로 가는 버튼/링크)를 클릭해도 다음 page_id HTML이 열린다.

이 구조 덕에 PD는 하나의 분석 결과 안에서 화면→화면을 자유롭게 오가며 element 사용도와 페이지 간 전환률을 함께 본다.

"X 화면 분석해줘" 같은 요청은 page_id/object_* 해석이 매번 달라져 데이터가 오염되는데, 이 skill은 **사용자가 직접 폰으로 걸어본 로그를 정답지로** 삼거나 **로그센터 명세와 실제 로그를 교차검증**해서 정의를 고정한 뒤 athena 쿼리를 생성/실행합니다.

관련 스킬: `log-explore`(로그 탐색), `log-query`(쿼리 실행), `log-spec`(명세 조회) — 이 스킬들의 규칙(테이블, 파티션, 필터)을 그대로 준수합니다.

## 원칙 (mode 무관 공통, 절대 어기지 말 것)

1. **결정 종류 2단 분리 — 데이터 의미는 사용자 확정, 워크플로우 옵션은 스마트 디폴트.**

   | 결정 종류 | 처리 방식 | 예시 |
   |-----------|-----------|------|
   | **데이터 의미 결정** (자의 추론 금지) | 후보 제시 + 사용자 확정 | scope 선택, page_id 확정, element 분류, 페이지 연결, trigger 확정, athena 쿼리 실행 승인 |
   | **워크플로우 옵션 결정** (스마트 디폴트) | 디폴트 자동 적용 + "변경 원하면 알려줘" 한 줄 안내, 별도 턴 없이 진행 | 측정 기간, 인벤토리 컷오프 N, 명세 only 처리, 인벤토리 범위, 그라운딩 파티션(어제/오늘) |

   - **반드시 사용자 확정이 필요한 결정 (3개)**: scope 선택, page_id 확정, athena 쿼리 실행 승인. 이건 절대 우회 금지.
   - 워크플로우 옵션은 [디폴트 값](#디폴트-값) 섹션을 따라 자동 적용. 사용자가 결과를 본 뒤 "기간 다시", "컷오프 20으로", "명세 only도 포함"이라고 말하면 즉시 재실행.
   - **관련 질문은 한 번에 묶어서 묻는다.** 맥락 수집(도메인/목적/측정기간)은 한 메시지에 한꺼번에, 비어 있으면 디폴트로 채워서 진행.
2. **자의적 추론 금지 — 단, 데이터 의미 결정에 한정.** 페이지 연결, element 분류, 카테고리 분류, trigger 확정 같은 **데이터 의미** 는 후보만 제시하고 사용자가 확정한다. 워크플로우 옵션(컷오프, 측정 기간, 인벤토리 범위)은 디폴트 자동 적용 + 사후 조정.
3. **Athena 쿼리는 전문을 보여주고 승인받은 뒤 실행.** 쿼리는 정답지다. **여러 쿼리를 만들지 말고 한 쿼리에 통합**한다 — per-page 루틴은 **단일 source CTE + ROLLUP(platform)** 기반 **1개 쿼리**로 element 집계(impression/click) + page 집계(pv/scroll) + ANDROID/IOS/ALL 플랫폼 rollup을 한 번에 처리한다. 같은 테이블을 CTE 여러 개에 나눠 각각 스캔하면 Trino optimizer 의존도가 높아지고 비용이 튄다. flow scope의 funnel 쿼리는 별도이므로 element 통합 쿼리와 한 번에 모아 한 번의 yes/no로 승인받는다.
4. **로그센터 명세와 교차검증.** `mcp__log-center-mcp__get_page_spec`이 있는 page_id는 항상 명세를 같이 본다. 명세에 없는 object는 경고.
5. **Element는 반드시 "삼중 표기"로 보여준다.** 어느 단계에서든 사용자에게 element를 노출할 때는 **`{title} (object_section_id, object_type)`** 형태로 세 필드를 함께 보여준다. `cart_button (BUTTON)` 처럼 ID만 보여주는 건 금지 — PD가 어느 요소인지 즉시 알 수 없다. title은 로그센터 명세(log-center mcp)의 한국어 title 필드에서 그대로 가져온다. 명세에 title이 없으면 `{title 없음}` 로 표시하고 사용자에게 명세 정비가 필요하다고 안내. 자세한 표기 규칙은 아래 [Element 표기 규칙](#element-표기-규칙) 참고.
6. **MD가 정본, HTML은 매번 재생성.** 모든 산출물의 정본은 MD 파일이고, HTML은 MD가 갱신될 때마다 자동 재생성한다.
7. **마지막에 HTML을 자동으로 브라우저에 띄운다.** Step 5 끝에서 Bash `open ./flows/{...}.html` 또는 `open ./screens/{...}.html` 을 실행해 새 창으로 결과물을 보여준다 (macOS 기본). 이건 사용자 승인 없이 자동.
8. **세그먼트(신규/활성/부활)는 MVP에서 제외.** 전체 유저 대상만 측정. v2에서 BA팀 표준 마트(`ba_preserved.user_seg_rfd_v2`) 기반 추가 예정.

## 디폴트 값

워크플로우 옵션은 사용자에게 묻지 않고 다음 디폴트로 자동 진행한다. 사용자가 결과를 본 뒤 명시 정정하면 즉시 재실행:

| 옵션 | 디폴트 | 이유 |
|------|--------|------|
| 측정 기간 | **최근 14일** | 주간 변동 1사이클 + 주요 element 표본 안정. 30일은 스캔 비용이 2배인데 증분 정합성 이득 작음. 롱테일 element가 필요하면 사용자가 명시 확장 |
| 분석 목적 | "유저 행동 패턴 파악" | 사용자가 안 적으면 자동 채움 |
| 그라운딩 파티션 | **어제(date - 1일) 우선** | 당일 파티션 인입 지연이 잦음 |
| 인벤토리 범위 | **명세 ∩ 로그 + 로그 only** (uv ≥ 1) | 명세 only는 별도 표로 분리 (디폴트 분석 대상 아님) |
| 명세 only 처리 | **별도 표로 분리** | 명세 정비 이슈로 노출, 자동 제외 X |
| 컷오프 N (결과 표시) | **상위 16개** | 차트/표 가독성 + 핵심 파악 균형 |
| **`object_section_idx` 스캔 컷오프** | **`< 10`** | 스크롤 안 한 유저가 보지 못한 하단 element를 IR 분모에서 제거 → 정합성 개선. **결과 컷오프와 달리 스캔 단계**에서 적용돼서 비용도 줄어. 3으로 좁히면 "첫 화면만", null은 전체. 사용자가 "전체 idx로" 요청 시 조건 제거 |
| 정렬 기준 | 통합(ALL) click_per_pv 내림차순 | element 랭킹의 single source of truth |
| 플랫폼 | ANDROID + IOS 통합 메인, 분리는 보조 | 통합이 의사결정 기준선 |
| Athena `user_id > 0` | 항상 적용 | 비회원 제외 |
| Athena `platform IN ('IOS','ANDROID')` | 항상 적용 | 앱 한정 |

**비용 원칙** — Athena 스캔은 기간 × 컬럼 수 × 이벤트 카테고리 수로 선형 증가하고 반복 호출될수록 누적된다. 디폴트는 **"정합성을 확보할 수 있는 최소 스캔"** 기준으로 잡는다. 기간 확장, idx 컷오프 해제, engagement 카테고리 확장 같은 옵션은 사용자가 명시 요청할 때만 적용한다.

**사후 조정 안내 (Step 5 끝에 한 줄):**
```
범위/컷오프/기간 변경하려면 "기간 30일로", "N=20으로", "idx 3까지만", "전체 idx", "명세 only도 포함" 처럼 말해줘.
```

이 안내는 쿼리 실행 전 매번 묻지 않기 위한 것. 사용자가 안내를 보고 사후 정정하면 그때 변경.

## HTML 작성 규칙

per-page HTML은 **외부 CDN 의존 0** 으로 작성한다. 차트 라이브러리 import 실패로 빈 화면이 뜨는 것을 막기 위해.

| 항목 | 규칙 |
|------|------|
| 외부 라이브러리 | **금지**. React, Recharts, D3, Chart.js, Tailwind CDN 등 일체 import 금지 |
| 차트 | 순수 HTML/CSS bar (`<div>` + `width: %`) 또는 inline SVG. 색은 [원칙 5의 통합 강조색](#원칙-mode-무관-공통-절대-어기지-말-것) (`#10B981`) |
| 스타일 | inline `<style>` 블록 (CDN 0 의존 원칙 준수) |
| 데이터 | inline `<script>const DATA = {...}</script>` 블록 |
| 렌더 순서 | (1) 표/리스트/카드 → (2) 차트 → (3) Figma mapper. 의존성 적은 것부터 |
| Fail-safe | 차트 렌더 코드는 `try/catch`로 감싸고, fail해도 표/리스트는 살아남게 |
| Date picker | `<input type="date">` 네이티브 (외부 라이브러리 X) |
| Click navigation | `<a href="./{next_page_id}.html">` 표준 링크 |
| 가로폭 | `max-width: 1024px; margin: 0 auto` |
| 다크 테마 | 배경 `#141414`, 카드 `#1a1a1a`, 텍스트 `#EAEAEA` |

이 규칙 덕분에 HTML 파일 한 개만 있으면 어디서든 (CDN 차단된 사내망 포함) 동작한다.

## Element 표기 규칙

오늘의집 로그센터(log-center mcp)의 모든 element는 세 가지 식별 필드를 가진다:

| 필드 | 출처 | 예시 | 역할 |
|------|------|------|------|
| **title** | 로그센터 명세의 한국어 이름 | `주문 상품` / `장바구니 담기 버튼` / `리뷰 더보기` | 사람이 읽고 바로 어느 요소인지 아는 라벨 |
| **object_section_id** | analyst_log_table 컬럼 | `ORDER_PRODUCT` / `cart_button` / `review_more` | 쿼리 필터/그룹의 키 |
| **object_type** | analyst_log_table 컬럼 | `BUTTON` / `MODULE` / `IMPRESSION` | 요소 타입 (버튼인지 모듈인지) |

### 표기 포맷 (mode 무관 공통)

상황에 따라 두 가지 포맷을 쓴다:

**Verbose (목록·후보·인벤토리·표):**
```
주문 상품 (ORDER_PRODUCT, BUTTON)
장바구니 담기 버튼 (cart_button, BUTTON)
리뷰 모듈 (review_module, MODULE)
```

**Compact (인라인·짧은 문장):**
```
**주문 상품** (`ORDER_PRODUCT`/`BUTTON`)
```

**표 안에 들어갈 때는 title 컬럼을 별도로 분리:**
```
| title | object_section_id | object_type | ...metric... |
| 주문 상품 | ORDER_PRODUCT | BUTTON | ... |
```

### title을 가져오는 방법

1. page_id 확정 직후 `mcp__log-center-mcp__get_page_spec(page_id={확정된_page_id})` 호출
2. 응답에서 element별 `{title, object_section_id, object_type}` 매핑을 확보해 메모리(또는 MD §2 주석)에 저장
3. 이후 모든 사용자 대화·인벤토리·쿼리 결과 표·HTML 라벨에서 이 매핑을 참조해 title 동봉

### 예외 처리

- **명세에 title이 없는 경우**: `{title 없음} (ORDER_PRODUCT, BUTTON)` 로 표기하고, "이 element는 명세에 title이 비어있어. log-center에서 보강 필요" 라고 한 줄 안내
- **로그 only element (명세 자체가 없는 경우)**: title 자리에 `(명세 누락)` 표기 → `(명세 누락) (exp_recommendation_v3, MODULE)`
- **사용자가 직접 입력한 후보**: 사용자에게 "이 element의 title 알면 알려줘. 모르면 비워둬도 돼" 한 번 묻고 빈 값이면 `{사용자 입력}` 표기

## 분석 범위 (scope)

이 skill은 두 가지 분석 범위를 지원하며, 둘 다 **동일한 per-page 분석 루틴**을 사용한다. 차이는 page_id 개수와 추가 funnel 계산 여부뿐:

| Scope | page_id 개수 | 추가 산출물 | 산출물 위치 |
|-------|--------------|-------------|-------------|
| **single** | 1개 | (없음) | `./screens/{page_id}.html` |
| **flow** | N개 (시퀀스) | 페이지 간 funnel 데이터 + flow header inject | `./screens/{page_id}.html` × N + `./flows/{flow_name}.md` |

**핵심**: scope가 single이든 flow든 **per-page HTML 구조와 element 분석 로직은 동일**하다. flow scope는 추가로:
1. 각 페이지 간 전환률 계산 (funnel 쿼리 1개)
2. 각 page_id HTML의 최상단에 flow header section을 inject (다른 page_id HTML로의 링크 포함)
3. 첫 entry page_id HTML을 자동으로 브라우저에 띄움

이 통합 구조 덕분에 단일 화면 분석을 한 다음에 같은 page_id를 다른 플로우에 끼워넣어도 HTML이 재사용된다.

### 향후 추가 예정 scope (현재 미구현)
- **peer-compare**: 같은 카테고리의 다른 화면과 비교
- **trend**: 시계열 변화 추적

## 입력
$ARGUMENTS (자연어 또는 명시적 이름. 예: `commerce-pdp-to-cart`, `상품 상세에서 장바구니까지 전환률 보고싶어`, `pdp 화면 사용도 분석해줘`)

## Step -1: 환경 점검 (스킬 호출 직후 자동, 본격 진행 전)

본격 워크플로우 시작 전 다음을 자동으로 점검한다. 동료가 처음 받아 쓸 때 막연한 에러 대신 명확한 안내를 받게 한다.

### -1-1. 의존 스킬 파일 확인
Glob으로 다음 위치 중 한 곳에라도 의존 스킬이 있는지 확인:

**slash command 위치:**
- `~/.claude/commands/log-explore.md`
- `~/.claude/commands/log-query.md`
- `~/.claude/commands/log-spec.md`

**또는 CLAUDE.md skill path 등록 위치:**
- `~/claude-skills/skills/log-explore/SKILL.md`
- `~/claude-skills/skills/log-query/SKILL.md`
- `~/claude-skills/skills/log-spec/SKILL.md`
- 또는 사용자가 직접 등록한 다른 경로

3개 모두 어느 위치에든 있으면 silent 통과. 빠진 게 있으면 **한 줄 경고만** 출력하고 즉시 다음 단계로 진행 (컨펌 X):

```
⚠️ {누락 스킬 N개} 누락 — {막힐 가능성 있는 단계} 에서 막힐 수 있어. 그대로 진행할게.
```

자세한 설치 방법은 README 링크 한 줄로:
```
설치: https://github.com/Ohouse-product-design/AI-Skill/blob/main/skills/funnel-check/README.md
```

**컨펌 turn 없음 — 자동 계속.** 막힐 가능성이 있는 단계에 도달하면 그때 한 번 더 알린다.

### -1-2. MCP 도구 확인 (시도 기반)
athena mcp / log-center mcp는 사전 검사를 하지 않고 실제 호출 시점에 시도한다. 호출이 실패(`tool not found` 또는 권한 에러)하면 친절한 메시지로 변환:

```
⚠️ {도구명} 도구를 사용할 수 없어. 다음을 확인해줘:

1. ~/.claude/.mcp.json 또는 사내 MCP 설정에 다음이 있는가:
   - athena mcp: mcp__ohouse-athena-mcp__execute_athena_query
   - log-center mcp: mcp__log-center-mcp__get_page_spec
                     mcp__log-center-mcp__get_log_spec_by_id
                     mcp__log-center-mcp__get_log_spec_from_url
                     mcp__log-center-mcp__get_enum
2. 오늘의집 athena 권한이 있는가 (log.analyst_log_table SELECT)
3. 사내 권한이 필요한 경우 VPN 연결 상태

설정 가이드:
https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check#사전-요구사항
```

### -1-3. 점검 통과 시 (silent)
**아무 메시지 없이** 바로 Step 0으로 진행. 잘 동작 중인 환경에서 한 줄이라도 띄우면 사용자 시간 낭비.

부족한 게 있을 때만 명시적으로 알린다:
```
⚠️ 환경 점검 부분 통과 (의존 스킬 {N}개 누락). 그대로 funnel-check 시작할게.
```

## Step 0: Mode 선택 + 갱신 의도 감지 (모든 호출의 첫 단계)

### 0-0. 갱신(refresh) 의도 먼저 감지

자연어 입력에서 다음 패턴이 보이면 **새 분석이 아니라 기존 분석의 데이터 갱신 요청**이다 — fast path로 진입:

| 트리거 패턴 | 예시 |
|------------|------|
| `갱신` / `refresh` / `다시 돌려` / `재실행` + 기존 page_id/플로우명 | "PDP 갱신해줘", "commerce-pdp-to-cart 다시 돌려" |
| 명시적 갱신 명령 (HTML 날짜 picker가 만들어준 형식) | `funnel-check refresh {page_id_또는_플로우명} from {YYYY-MM-DD} to {YYYY-MM-DD}` |
| `기간 바꿔서` / `기간만 바꿔` / `다른 날짜로` + 기존 분석 참조 | "어제 만든 PDP 분석 기간만 바꿔서 4월 1-7일로" |

감지되면:
1. `./flows/{이름}.md` 또는 `./screens/{이름}.md` 가 있는지 확인 (없으면 신규 분석으로 안내하고 일반 흐름)
2. 있으면 기존 MD에서 page_id / Flow Definition / element 인벤토리를 그대로 로드
3. **Step 1~3 전부 건너뛰고 바로 Step 4 (쿼리 단계) 로 점프** — 새 측정 기간만 갈아끼워 쿼리 재실행
4. Step 5 HTML 재생성 → auto-open

이 fast path는 사용자가 분석을 한 번 만들어둔 뒤 주/월 단위로 데이터만 새로 보고 싶을 때의 핵심 경로다. 매번 page_id 확정/인벤토리 검토를 다시 시키지 말 것.

### 0-1. (신규 호출이면) 분석 범위 선택

자연어 입력에서 scope를 추론할 수 있더라도, **항상 사용자에게 명시적으로 선택지를 제시**한다. 잘못 추론한 scope로 워크플로우를 타면 page_id 개수와 추가 funnel 계산이 어긋나기 때문.

#### 0-1-1. 키워드 기반 prior (참고용)

| 키워드 패턴 | 추론 scope |
|------------|-----------|
| 단일 page_id 언급 ("PDP", "쇼핑홈"), "이 화면", "이 버튼", "이 모듈" | **single** |
| 시퀀스 표기 ("A → B → C", "A에서 C까지"), "퍼널", "이탈", "여정", "플로우" | **flow** |
| 명시적 플래그 `--scope=single` 또는 `--scope=flow` | 그 scope (메뉴 생략) |
| 둘 다 / 모호 | 추론 없이 메뉴 제시 |

#### 0-1-2. 사용자에게 scope 선택지 제시

명시적 플래그가 없으면 **항상** 아래 메뉴를 보여주고 사용자 확정을 받는다:

```
funnel-check를 시작할게. 분석 범위가 어떻게 돼?

[a] 단일 화면 — 한 page_id의 element 전환률만 보고 싶어
    예: "PDP의 각 버튼/모듈이 얼마나 눌리는지"
        "홈 화면의 모듈별 CTR"
    → 산출물: ./screens/{page_id}.html (1개)

[b] 플로우 — 여러 page_id를 순서대로, 페이지 간 전환률도 같이 보고 싶어
    예: "쇼핑홈 → PDP → 장바구니 → 주문 결제"
        "카테고리 진입부터 구매까지"
    → 산출물: 플로우의 각 page_id마다 ./screens/{page_id}.html
              + 첫 entry page HTML 최상단에 전체 플로우 funnel 시각화
              + 각 page_id 노드/trigger element 클릭 시 다음 page_id HTML로 이동

어느 걸로 갈까? (a / b)
```

키워드 prior가 강하면 추천을 덧붙인다 — 예: `"(입력에 'PDP → CART'가 있는 걸 보니 [b] 플로우가 맞아 보이는데 맞아?)"` — 하지만 사용자 확정 없이 진행하지 않는다.

이후 워크플로우는 scope에 따라 분기한다 — single이면 page_id 1개, flow면 page_id N개에 대해 같은 per-page 루틴을 loop로 돌린다.

---

# 통합 워크플로우 (single + flow)

scope에 상관없이 동일한 큰 흐름:

```
Step 1   맥락 수집 (한 메시지에 묶어서)
Step 2   page_id 확정
           - single: 후보 메뉴에서 1개 확정
           - flow:   플로우 그라운딩 (라이브 워크스루 / 텍스트) → 시퀀스 확정
Step 3   각 page_id 루프 — element 인벤토리 (명세 ∩ 로그)
           + (flow scope만) 페이지 간 trigger 추정/확정
Step 4   쿼리 일괄 승인
           - 각 page_id의 [Element CTR + Page Health] × N
           - (flow scope만) 페이지 간 funnel 쿼리 1개
           - 한 번의 yes/no로 모두 승인 → 순차 실행
Step 5   각 page_id의 HTML 생성
           - per-page detail (element CTR / inventory / page health / figma mapper / query)
           - (flow scope만) 모든 HTML 최상단에 flow header section inject
           - 첫 entry page_id HTML을 `open` 으로 새 창
```

flow scope 전용 산출물:
- `./flows/{flow_name}.md` — 플로우 정의 (page_id 시퀀스, trigger 매핑, funnel 쿼리 결과)
- 각 `./screens/{page_id}.html` 안에 inject되는 flow header section

아래 섹션은 "flow scope 전용" 단계 → "공통 per-page 루틴" 순으로 정리되어 있다.

---

# Flow scope 전용: 플로우 그라운딩 + funnel 정의

scope=single이면 이 섹션은 건너뛴다. scope=flow이면 page_id 시퀀스 확정 → 페이지 간 trigger 매핑 → funnel 쿼리 정의를 먼저 한 뒤, 각 page_id에 대해 per-page 루틴을 돌린다.

## 플로우명 규칙

형식: `{domain}-{from_page}-to-{to_page}[-{variant}]`

- **kebab-case**, 전부 **소문자**
- `{domain}`: `commerce` / `content` / `o2o` / `common` 중 하나 (log-explore 도메인 구분과 일치)
- `{from_page}` / `{to_page}`: 플로우의 첫/마지막 page_id를 소문자로. page_id 내부 underscore(`_`)는 유지
- 중간 페이지는 파일명에 넣지 않는다. 전체 경로는 MD 안의 `## 3. Flow Definition`에서 관리
- `{variant}`: 같은 start/end를 공유하는 다른 플로우가 있을 때만 붙인다 (예: `-mobile`, `-review`, `-v2`, `-exp-a`)

**예시:**
- `commerce-pdp-to-cart`
- `commerce-pdp-to-order_checkout`
- `content-clp_project-to-cdp_project`
- `o2o-rmd_discovery_home-to-rmd_easyapply_form`

**명명 시점:** Step 1 맥락 수집이 끝나고 from/to 페이지가 드러났을 때 자동 생성 → 사용자에게 "이 이름으로 저장할까?" 확정 → `./flows/{플로우명}.md` 생성.

## Flow scope 워크플로우

### Step 0-A: 기존 Flow Definition 확인
1. `./flows/{플로우명}.md`가 이미 있으면 읽어서 상태(`수집중|플로우확정|쿼리확정|결과확보`) 파악
2. 사용자에게 "기존 정의 이어서 진행할까, 처음부터 다시 할까? (a/b)" 물어보기
3. 없으면 Step 1부터 시작. 폴더가 없으면 `./flows/` 생성

### Step 1-A: 맥락 수집 (한 메시지에 묶어서)

세 항목을 한 번에 묻고, 측정 기간은 default를 announce:

```
flow 분석을 시작할게. 다음 정보 한 번에 알려줘:

  1. 오너십 도메인/화면: (예: 커머스 / PDP)
  2. 측정할 전환 행동: (예: "PDP → 장바구니 담기")
  3. 측정 기간: (기본 = 최근 7일, 다른 기간 원하면 적어줘)

(2번 답에서 from/to 페이지가 명확하면 다음 단계 자동 진행)
```

답변 받으면 MD의 `## 1. 맥락` 섹션에 기록하고 HTML 재생성. 사용자가 측정 기간을 안 적으면 7일로 진행 (재확인 X).

### Step 2-A: 플로우 페이지 그라운딩 방식 선택

플로우 페이지를 확정하는 방식이 두 가지 있다. 사용자에게 먼저 어느 방식으로 갈지 고르게 한다:

```
플로우 페이지를 어떻게 확정할까?

[a] 라이브 워크스루 — 지금 바로 폰으로 플로우 타보기
    - 내가 user_id랑 시간 알려주면 그 구간 PAGEVIEW 로그를 뽑아
      실제 이동한 page_id 시퀀스로 플로우를 확정
    - 가장 정확. 새로운/복잡한 플로우면 이걸 추천

[b] 텍스트 입력 — 플로우를 말로 적기
    - 예: "쇼핑홈 > PDP > 장바구니 > 주문 결제"
    - 내가 각 단계를 page_id 후보로 매핑해서 하나씩 확인
    - 빠름. 이미 잘 아는 표준 플로우면 이걸 추천

어느 걸로 갈까? (a / b)
```

사용자 선택에 따라 Step 2-A-live (라이브) 또는 Step 2-A-text (텍스트) 로 분기. `[b]` 를 시도하다 매핑이 자꾸 막히면 중간에 **`[a]` 로 fallback 제안**한다 — "텍스트로는 page_id 확정이 어려워 보여. 라이브 워크스루로 전환할까? (y/n)"

---

### Step 2-A-live: 라이브 워크스루 그라운딩

#### 2-A-live-1. 시각 구간 수집
하나씩 묻는다:
- 직접 폰으로 이 플로우를 타봤어?
  - 안 타봤으면: "그럼 지금 타보고 시작시각/종료시각 알려줘. 로그 반영까지 몇 분 걸려."
- 언제 타봤어? (예: "오늘 오후 2시쯤")
- 어떤 user_id로 로그인되어 있었어?

**좁은 시간 구간이 핵심.** 노이즈를 줄이려면 ±30분 내외로 수렴. 사용자가 범위를 못 좁히면 후보 세션 여러 개를 보여주고 고르게 한다.

#### 2-A-live-2. 로그 추출 (PAGEVIEW만)
쿼리 전문을 보여주고 승인 후 `execute_athena_query` 실행:

```sql
SELECT server_access_time, page_id, page_params, category,
       object_section_id, object_type, object_id
  FROM log.analyst_log_table
 WHERE date = '{YYYY-MM-DD}'
   AND user_id = {내_user_id}
   AND server_access_time BETWEEN TIMESTAMP '{start}' AND TIMESTAMP '{end}'
   AND category = 'PAGEVIEW'
 ORDER BY server_access_time
;
```

#### 2-A-live-3. 정규화 (자동)
원본 시퀀스에서 다음을 거른다:
- 연속 중복 page_id (A→A→A는 A 하나로)
- 같은 page_id 재진입 (첫 진입만 남김, 사용자 선택권 제공)
- 뒤로가기 패턴 (A→B→A에서 B는 되돌아간 페이지)

원본과 정규화 결과를 나란히 보여준다.

#### 2-A-live-4. 사용자 확정 (자의적 연결 금지)
**반드시 사용자에게 묻는다. 선택지는 번호/알파벳으로 제시:**

```
추출된 페이지 시퀀스 (정규화 후):
  [1] SHOPPINGHOME
  [2] PDP
  [3] CART
  [4] ORDER_CHECKOUT
  [5] ORDER_DONE

이 중 측정할 플로우에 포함할 step을 골라줘.
  [a] 전부 포함 (1-5)
  [b] 일부만 — 포함할 번호를 콤마로 (예: "1,2,3,4")
  [c] 순서 수정 필요 — 순서를 다시 적어줘

선택: 
```

확정한 페이지 리스트만 `## 2. 플로우 페이지`에 기록.

---

### Step 2-A-text: 텍스트 입력 그라운딩

#### 2-A-text-1. 플로우 텍스트 받기
```
측정할 플로우를 화살표 구분으로 적어줘.

예시:
  - "쇼핑홈 > PDP > 장바구니 > 주문 결제 > 주문 완료"
  - "카테고리 진입 → 검색결과 → PDP → 장바구니"

입력:
```

구분자는 `>`, `→`, `->`, `,` 모두 허용. 공백 기준 분리도 대응.

#### 2-A-text-2. page_id 후보 매핑 (단계마다 사용자 확정)
각 자연어 단계에 대해 log-explore 도메인 매핑 가이드를 참고해 page_id 후보를 1~3개 추출. **한 번에 여러 단계를 한꺼번에 확정하지 말고 하나씩 확인**한다:

```
[1/4] "쇼핑홈" → 어떤 page_id야?
  [a] SHOPPINGHOME (메인 쇼핑 홈)
  [b] CONTENT_HOME (콘텐츠 홈)
  [c] 직접 입력 — 내가 page_id 적을게
  [d] 모르겠어 → 라이브 워크스루로 전환 (2-A-live)

선택:
```

하나 확정되면 다음 단계:
```
[2/4] "PDP" → 어떤 page_id야?
  [a] PDP (상품 상세 메인)
  [b] PDP_STYLINGSHOT (스타일링샷 상세)
  [c] PDP_INQUIRY (Q&A 탭)
  [d] 직접 입력
  [e] 모르겠어 → 라이브 워크스루로 전환

선택:
```

#### 2-A-text-3. Fallback to live
아래 조건 중 하나라도 걸리면 사용자에게 라이브 워크스루 전환을 제안:
- 한 단계에서 후보가 5개 이상이라 고르기 어려움
- 사용자가 `모르겠어` / `직접 입력`도 못 하겠다고 함
- 2개 이상 단계에서 매핑 실패

```
텍스트만으로는 page_id 확정이 어려워 보여.
라이브 워크스루(직접 폰으로 타고 그 로그 뽑기)로 전환할까?
  [a] 전환 — 지금 바로 타보고 user_id/시간 알려줄게
  [b] 계속 텍스트로 — 나머지 단계 더 시도해보기
  [c] 중단

선택:
```

#### 2-A-text-4. 최종 확정
모든 단계가 확정되면 요약해서 한 번 더 확인:
```
최종 플로우:
  1. SHOPPINGHOME
  2. PDP
  3. CART
  4. ORDER_CHECKOUT

이 순서로 진행할게. 맞아? (y / n / 수정할 번호)
```

확정되면 `## 2. 플로우 페이지`에 기록하고 (그라운딩 방식: text) 주석 남긴다.

### Step 3-A: 화면 요소(Object) 확정

플로우 페이지가 확정됐으면 각 페이지 → 다음 페이지로의 전이 트리거(어떤 element 클릭으로 넘어가는지)를 확정한다.

#### 3-A-1. CLICK 로그 추출 (그라운딩 방식에 따라 분기)

**live 그라운딩이면:** 2-A-live에서 쓴 user_id/시간 구간을 그대로 써서 CLICK 로그 추출.

```sql
SELECT page_id, object_section_id, object_type, object_id, server_access_time
  FROM log.analyst_log_table
 WHERE date = '{YYYY-MM-DD}'
   AND user_id = {내_user_id}
   AND server_access_time BETWEEN TIMESTAMP '{start}' AND TIMESTAMP '{end}'
   AND category = 'CLICK'
   AND page_id IN ({확정된_페이지_리스트})
 ORDER BY server_access_time
;
```

**text 그라운딩이면:** 개별 사용자 로그가 없으므로 로그센터 명세(`mcp__log-center-mcp__get_page_spec`)와 최근 기간의 CLICK 분포를 활용해 전이 트리거 후보를 추정한다. 각 페이지의 최근 7일 CLICK UV 상위 object_section_id를 뽑은 뒤, **명세에서 가져온 title과 매칭해서 사용자에게 제시**한다:

```sql
SELECT page_id, object_section_id, object_type,
       COUNT(DISTINCT user_id) AS click_uv
  FROM log.analyst_log_table
 WHERE date BETWEEN date_add('day', -7, current_date) AND current_date
   AND page_id IN ({확정된_페이지_리스트})
   AND category = 'CLICK'
   AND user_id > 0
   AND platform IN ('IOS', 'ANDROID')
   AND object_section_id IS NOT NULL
 GROUP BY 1, 2, 3
 ORDER BY page_id, click_uv DESC
;
```

#### 3-A-2. 명세 교차검증
각 page_id에 대해 `mcp__log-center-mcp__get_page_spec` 호출 → 명세 element(title + object_section_id + object_type 매핑)와 실제 로그 object 대조. 매핑은 이후 모든 단계에서 element 표기에 재사용.

#### 3-A-3. Trigger 추정 + announce (한 번에 묶어서)

각 페이지 → 다음 페이지로의 전이 트리거를 페이지마다 하나씩 묻지 말고, **전체 step의 best-guess를 한 번에 announce**하고 사용자가 정정할 게 있으면 한 메시지로 받는다. best-guess는 명세 ∩ 로그 상위 element 중 click_uv 1위:

```
각 step의 전이 트리거 추정해봤어. 정정할 거 있으면 알려줘 (없으면 진행):

  step 1. PDP → CART
    → 장바구니 담기 버튼 (cart_button, BUTTON)  ← click_uv 1위

  step 2. CART → ORDER_CHECKOUT
    → 주문하기 버튼 (order_button, BUTTON)  ← click_uv 1위

  step 3. ORDER_CHECKOUT → ORDER_DONE
    → 결제 버튼 (payment_button, BUTTON)  ← click_uv 1위

정정하려면: "step 2를 buy_now_button으로 바꿔줘" 처럼 알려줘.
없으면 그대로 쿼리 단계로 갈게.
```

후보가 강하게 갈리는 step (1위와 2위 click_uv가 비슷)만 별도로 묻는다. 그 외는 announce 후 자동 진행.

#### 3-A-4. Flow Definition 완성
`## 3. Flow Definition` 섹션에 YAML로 기록. **trigger도 title 동봉:**
```yaml
- step: 1
  page_id: PDP
  page_title: 상품 상세                    # log-center mcp get_page_spec.title
  category: 커머스
  trigger:
    title: 장바구니 담기 버튼              # log-center mcp 명세의 element title
    object_section_id: cart_button
    object_type: BUTTON
  next: CART
```

### Step 4-A: 느슨한 퍼널 쿼리

```sql
WITH flow_events AS (
  SELECT user_id,
         MIN(CASE WHEN page_id = '{step1.page_id}' AND category = 'PAGEVIEW'
                  THEN server_access_time END) AS step1_at,
         MIN(CASE WHEN page_id = '{step1.page_id}' AND category = 'CLICK'
                    AND object_section_id = '{step1.trigger.object_section_id}'
                  THEN server_access_time END) AS step1_click_at,
         MIN(CASE WHEN page_id = '{step2.page_id}' AND category = 'PAGEVIEW'
                  THEN server_access_time END) AS step2_at
         -- ... 나머지 스텝
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
     AND page_id IN ({플로우_전체_페이지})
   GROUP BY user_id
)
SELECT COUNT(DISTINCT CASE WHEN step1_at IS NOT NULL THEN user_id END) AS step1_uv,
       COUNT(DISTINCT CASE WHEN step1_click_at > step1_at THEN user_id END) AS step1_click_uv,
       COUNT(DISTINCT CASE WHEN step2_at > step1_click_at THEN user_id END) AS step2_uv
       -- ... 나머지 스텝
  FROM flow_events
;
```

쿼리 전문을 한 번에 보여주고 한 번의 yes/no로 승인:

```
이 쿼리 실행할게. 진행할까? (y / n)

[쿼리 전문]
...
```

`y` 면 즉시 `mcp__ohouse-athena-mcp__execute_athena_query` 실행. 결과를 MD `## 4. 쿼리 결과`에 기록.

### Step 5-A: 플로우 funnel 결과를 MD에 기록 (HTML 생성은 per-page 루틴에서)

Step 4-A에서 실행한 funnel 쿼리 결과를 `./flows/{플로우명}.md` 의 `## 4. 쿼리 결과` 섹션에 기록한다. **flow scope에서는 별도의 flow.html 을 만들지 않는다** — funnel 시각화는 각 page_id HTML 최상단에 inject되는 flow header section에 들어간다.

이후 흐름:
1. 플로우의 각 page_id에 대해 [공통 per-page 루틴](#공통-per-page-루틴)을 loop로 실행한다.
2. per-page 루틴이 각 page_id의 HTML을 생성할 때, `./flows/{플로우명}.md` 에서 funnel 데이터를 읽어 flow header section을 inject한다.
3. 모든 page_id HTML 생성이 끝나면 **첫 entry page_id의 HTML만** 자동으로 브라우저에 띄운다 (`open ./screens/{entry_page_id}.html`). 사용자는 거기서 다른 page_id로 클릭 이동.

```
✅ 플로우 분석 완료. 첫 페이지 HTML을 새 창으로 띄웠어.
   ./screens/{entry_page_id}.html
   
   다른 페이지: {나머지 page_id 리스트}
   상단 funnel이나 element 차트의 trigger를 클릭하면 해당 페이지로 이동돼.
```

## Flow mode MD 템플릿

```markdown
# {플로우명}

- 생성일: {YYYY-MM-DD}
- 마지막 업데이트: {YYYY-MM-DD HH:MM}
- mode: flow
- 상태: 수집중 | 플로우확정 | 쿼리확정 | 결과확보

## 1. 맥락
- 오너십 도메인:
- 전환 목표:
- 측정 기간:

## 2. 플로우 페이지 (사용자 확정)
- 확정 일시:
- 그라운딩 세션: user_id={id}, {YYYY-MM-DD HH:MM ~ HH:MM}
- 페이지 리스트:

## 3. Flow Definition
```yaml
- step: 1
  page_id: PDP
  ...
```

## 4. 쿼리 결과
### 실행 쿼리
```sql
-- 쿼리 전문
```
### 결과 (실행: {YYYY-MM-DD HH:MM})
| step | page_id | trigger | UV | 전환률 | 이탈률 |
|------|---------|---------|-----|--------|--------|

## 5. 의사결정 로그
- {timestamp} ...
```

---

# 공통 per-page 루틴

이 섹션이 **per-page 분석의 단일 source of truth** 다. scope에 상관없이 한 page_id를 분석할 때 항상 이 루틴을 돌린다.

- scope=single: 이 루틴을 1번 호출
- scope=flow: 이 루틴을 플로우의 page_id 개수만큼 loop 호출, 끝나면 첫 entry HTML auto-open

핵심은 두 source 대조:

- **명세 ∩ 로그**: 디자인도 됐고 실제 로그에도 잡히는 element — CTR/IR 수치로 클릭률 랭킹 산출
- **명세 only**: 디자인은 됐는데 측정 기간 내 클릭 0회 — 참고용 분리 표
- **로그 only**: 비공식 element (명세 누락 또는 임시 추가) — 명세 정비 트리거

플랫폼 간 차이가 결정적인 인사이트가 되는 경우가 많아 (예: 마이페이지 진입률 ANDROID 12% vs IOS 26%) **통합(ALL) 지표를 메인으로, ANDROID/IOS를 보조로** 보여준다.

## 파일명 규칙 (page_id 단위)

per-page 산출물의 파일명은 **page_id 그대로** (소문자):

- `./screens/{page_id_lowercase}.md` ← per-page 분석 정본
- `./screens/{page_id_lowercase}.html` ← per-page HTML (자동 재생성)

variant가 필요하면 (같은 page_id의 시점/조건 다른 분석) suffix를 붙인다:
- `./screens/pdp.md`
- `./screens/pdp__202604-renewal.md` (variant suffix는 `__` 두 underscore로 구분)

**핵심 원칙**: 같은 page_id면 같은 파일을 재사용한다. 한 PDP 분석이 여러 플로우(`commerce-pdp-to-cart`, `commerce-pdp-to-wishlist`)에서 동시에 참조될 수 있도록.

**예시:**
- `./screens/pdp.html`
- `./screens/shoppinghome.html`
- `./screens/cdp_project.html`
- `./screens/order_detail.html`

## per-page 루틴 단계

이 루틴은 한 page_id를 받아서 element 인벤토리/쿼리/HTML을 만든다. flow scope면 page_id 시퀀스를 받아 이 루틴을 loop로 호출.

### Step 0-B: 기존 정의 확인
1. `./screens/{page_id}.md`가 이미 있으면 읽어서 상태 파악 (page_id 단위로 캐시)
2. 사용자에게 "기존 {page_id} 분석 이어서 진행할까, 처음부터 다시 할까? (a/b)" 묻기 — flow scope에서는 page_id마다 묻지 말고 한 번에: "다음 page_id 중 기존 분석이 있는 게 N개야: {리스트}. 전부 재사용할까, 전부 다시 할까? (a/b)"
3. 없으면 Step 1부터 시작. 폴더 없으면 `./screens/` 생성

### Step 1-B: 맥락 수집 (single scope일 때만; flow scope는 Flow Step 1-A에서 이미 함)

scope=single이면 한 메시지로 묶어 묻는다. **분석 대상만 필수**, 나머지는 [디폴트 값](#디폴트-값)으로 자동 채움:

```
분석 대상만 알려주면 진행할게. 더 적고 싶은 정보가 있으면 같이 적어줘.

  필수: 분석 대상 화면 (자연어 OK, 예: "PDP", "쇼핑 홈", "주문 상세")
  선택: 분석 목적 (default: "유저 행동 패턴 파악")
  선택: 측정 기간 (default: 최근 30일)
```

사용자가 분석 대상만 적어도 즉시 다음 단계로. 답변 받으면 MD `## 1. 맥락` 섹션에 기록.

### Step 2-B: page_id 확정 (single scope일 때만; flow scope는 Flow Step 2-A에서 이미 함)

#### 2-B-1. 자동 fuzzy 확장 + 병렬 명세 조회 (사용자에게 묻기 전)

사용자 입력에서 page_id 후보를 **자동 생성** 후 `mcp__log-center-mcp__get_page_spec` 으로 **병렬 조회**한다.

**Variant 생성 규칙** (자연어 → 영문 page_id 후보):
1. 한국어 → 영문 매핑 사전 (홈 → HOME, 쇼핑홈 → SHOPPINGHOME / SHOPPING_HOME, 상품상세 → PDP, 장바구니 → CART, ...)
2. underscore on/off 양버전 (`SHOPPING_HOME` ↔ `SHOPPINGHOME`)
3. 도메인 prefix 변형 (`COMMERCE_HOME`, `CONTENT_HOME`)
4. suffix 변형 (`_HOME`, `_TAB_HOME`)
5. 결과 후보 5~10개 (top-N)

**예시:**
- `"쇼핑홈"` → `[SHOPPINGHOME, SHOPPING_HOME, SHOPPING_TAB_HOME, COMMERCE_HOME, HOME, STORE_HOME]`
- `"PDP"` → `[PDP, PDP_STYLINGSHOT, PDP_INQUIRY, PDP_REVIEW, COMMERCE_PDP]`

**병렬 조회**: 후보 N개를 한 번의 메시지 안에서 동시에 `get_page_spec` 호출 (각각 try, 200 응답만 채택).

**자동 confirm 규칙**:
- 후보 중 명세가 존재하는 게 1개뿐: **자동 확정**, 사용자에게 한 줄 안내 — `"SHOPPINGHOME 으로 진행할게 — 명세 description: '쇼핑홈'"`
- 명세가 존재하는 후보 중 description에 사용자 키워드가 정확히 포함된 게 1개: **자동 확정** + 한 줄 안내
- 매칭이 여러 개거나 모호: 비로소 사용자에게 번호 선택지 제시 (아래 2-B-2)

#### 2-B-2. 모호 케이스 — 사용자에게 선택 요청

자동 confirm이 실패하고 매칭 후보가 여러 개일 때만 묻는다:

```
"PDP" 후보가 4개 있어. 어떤 걸로 분석할까?
  [a] PDP (메인 상품 상세)
  [b] PDP_STYLINGSHOT (스타일링샷 상세)
  [c] PDP_INQUIRY (Q&A 탭)
  [d] PDP_REVIEW (리뷰 탭)
  [e] 모르겠어 → 라이브 워크스루로 그라운딩

선택:
```

#### 2-B-3. 명세 fail 케이스 — 라이브 그라운딩 fallback

자동 fuzzy 확장 후보가 모두 명세에 없거나 사용자가 `[e]` 를 고르면 **Flow scope의 Step 2-A-live 메커니즘 호출**:
- user_id는 [캐싱된 값](#user_id-캐싱-규칙) 자동 사용 (없으면 한 번만 묻기)
- **그라운딩 파티션 default = 어제(date - 1일)** ([디폴트 값](#디폴트-값) 참고). 당일 인입 지연 우회.
- 시각도 모르면 어제 전체 파티션 스캔 (스코프 한정이라 OK)
- 단일 질문: "어제 {분석 대상} 들어왔어? 들어왔다면 내 user_id로 PAGEVIEW 추출할게."

single scope는 단일 page_id만 필요하므로, 그라운딩 결과에서 사용자가 한 개를 고른다.

#### 2-B-4. get_page_spec 응답 사이즈 회피

`get_page_spec` 응답이 100k+ 토큰으로 거대해서 컨텍스트를 잡아먹는 케이스가 자주 발생한다. 호출 직후 다음 패턴으로 page_info만 우선 추출:

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

`log_specifications`(element 리스트, 거대한 부분)는 **Step 3-B 인벤토리 구성 시점에만** 따로 추출. 그 전까지는 메모리에 들고 있지 않는다.

#### 2-B-5. page_id 확정 후 기록
`## 2. 분석 대상` 섹션에 기록:
```yaml
page_id: PDP
title: 상품 상세
category: 커머스
domain: commerce
확정_일시: {YYYY-MM-DD HH:MM}
확정_방식: auto-fuzzy | user-select | live-grounding
```

## user_id 캐싱 규칙

라이브 그라운딩에 쓰는 user_id는 매번 묻지 말고 캐시한다.

- **저장 위치**: `~/.claude/projects/{project}/memory/reference_funnel_check.md`
- **저장 내용**:
  ```markdown
  ---
  name: funnel-check user_id 캐시
  description: 라이브 그라운딩에 쓸 사용자 user_id (매 호출 자동 사용)
  type: reference
  ---

  user_id: {숫자}
  마지막 사용: {YYYY-MM-DD}
  자주 쓰는 측정 기간: 30일
  ```
- **첫 호출**: 그라운딩 단계에서 처음 한 번만 묻는다. 답변 즉시 위 파일에 저장.
- **이후 호출**: 자동 사용 + 한 줄 안내 (`"user_id={숫자}로 진행할게 (캐시됨)"`)
- **사용자 정정**: "다른 user_id로" 라고 말하면 새 값을 묻고 캐시 갱신.

### Step 3-B: Element 인벤토리 (per-page 루틴 핵심)

두 source를 동시에 가져와 대조한다. **Step 3-B-2 인벤토리 쿼리와 Step 4-B-1 CTR 쿼리는 통합 CTE 1개로 합쳐서 풀스캔을 1회로 줄인다** (아래 [4-B-1 통합 쿼리](#4-b-1-element-ctr--ir-쿼리-통합-인벤토리--ctr-page_id별) 참고).

#### 3-B-1. Source A — 로그센터 명세 (`mcp__log-center-mcp__get_page_spec`)
Step 2-B-1에서 이미 명세 호출이 끝났으면 캐싱된 응답을 재사용한다. 응답에서 모든 element의 `{title, object_section_id, object_type, category}` 매핑을 추출. CLICK / IMPRESSION 카테고리에 해당하는 것만 필터링. 이 매핑을 이후 단계 element 표기에 재사용 (원칙 5번 [Element 표기 규칙](#element-표기-규칙) 참고).

#### 3-B-2. Source B — 실제 로그 (Step 4-B-1과 통합)
**별도 쿼리를 만들지 않는다.** Step 4-B-1의 통합 쿼리에서 element 인벤토리(uv 분포)와 CTR/IR/click_per_pv 를 한 번에 산출한다. 아래 통합 쿼리 참고.

(레퍼런스 — 옛 분리 쿼리, 더 이상 사용 안 함)
```sql
SELECT object_section_id, object_type, category, platform, COUNT(DISTINCT user_id) AS uv
  FROM log.analyst_log_table
 WHERE date BETWEEN '{시작일}' AND '{종료일}'
   AND page_id = '{확정_page_id}'
   AND category IN ('CLICK', 'IMPRESSION')
   ...
```

#### 3-B-2-LEGACY. Source B 옛 쿼리 (참고용)

쿼리 전문 보여주고 승인 후 실행:

```sql
SELECT object_section_id,
       object_type,
       category,
       platform,
       COUNT(DISTINCT user_id) AS uv
  FROM log.analyst_log_table
 WHERE date BETWEEN '{시작일}' AND '{종료일}'
   AND page_id = '{확정_page_id}'
   AND category IN ('CLICK', 'IMPRESSION')
   AND user_id > 0
   AND platform IN ('IOS', 'ANDROID')
   AND object_section_id IS NOT NULL
 GROUP BY 1, 2, 3, 4
 ORDER BY uv DESC
;
```

#### 3-B-3. 대조 결과 자동 분류 + 디폴트 적용 (별도 컨펌 X)

[디폴트 값](#디폴트-값) 섹션의 워크플로우 옵션을 자동 적용하고 한 번에 진행한다.

**자동 적용 디폴트**:
- 분석 범위: **명세 ∩ 로그 + 로그 only** (명세 only는 별도 표로 분리 — 명세 정비 이슈)
- 컷오프: **상위 16개** (click_uv 기준)
- uv 컷: **uv ≥ 1**
- 명세 only 처리: **별도 표로 분리** (자동 분석 대상 아님, 명세 정비 참고용)
- osid 변경 패턴 자동 감지 시 (예: `cart_btn` → `cart_button` 같은 rename) 더 강하게 분리

**사용자에게는 결과를 한 번에 보여주고 사후 조정 안내만 한 줄 덧붙임**. 별도 컨펌 turn 없음:

```
✅ 명세 ∩ 로그 (정상 element, 12개) — 자동 분석 대상
  [1] 주문 상품 (ORDER_PRODUCT, BUTTON) — uv 12,341
  [2] 장바구니 담기 버튼 (cart_button, BUTTON) — uv 8,902
  [3] 바로 구매 버튼 (buy_now_button, BUTTON) — uv 5,431
  ... (상위 16개까지)

⚡ 로그 only (비공식 element, 4개) — 자동 분석 대상
  [13] {title 없음} (exp_recommendation_v3, MODULE) — uv 1,203
  ...

⚠️ 명세 only (측정 기간 내 클릭 0회, 3개) — 별도 표로만 분리
  • 옛 프로모션 배너 (old_promo_banner, MODULE)
  • 푸터 레거시 링크 (footer_link_legacy, LINK)
  • ...

분류 변경하려면 "명세 only도 포함", "로그 only는 빼", "1, 4 제외" 처럼 알려줘.
별도 답 안 하면 이대로 쿼리 단계로 진행할게.
```

**announce 후 즉시 다음 단계로**. 사용자 답변을 기다리지 않는다. 사용자가 다음 메시지에 정정 지시를 주면 그때 인벤토리 수정 후 쿼리 재실행. 확정된 인벤토리는 `## 3. Element 인벤토리`에 기록 — title 함께 기록.

### Step 4-B: Athena 통합 쿼리 (Element CTR + Page Health 한 번에)

per-page 루틴은 **단일 통합 쿼리 1개**만 만든다 (v1.5.2부터). 과거엔 Element CTR 쿼리와 Page Health 쿼리가 분리돼 있었고 각각 여러 CTE가 원본 테이블을 각자 스캔해서 실질 스캔이 4~8회로 늘어났는데, 이번 버전에서 `src` CTE 1개 + `ROLLUP(platform)` 으로 **테이블 접근을 1회로 고정**한다. flow scope의 funnel 쿼리가 있는 경우 그것만 별도이고, element 통합 쿼리와 한 번의 yes/no로 같이 승인받는다.

#### 4-B-1. 통합 쿼리 (Element metrics + Page Health, page_id별)

**이 쿼리 1개가 반환하는 것:**
- **per-element 지표**: `impression_uv`, `click_uv`, `click_sessions`, `ctr`, `ir`, `click_per_pv`, `click_per_session`
- **per-page 지표**: `pv_uv`, `pv_sessions`, `scroll_uv`, `scroll_rate`
- **플랫폼 축**: ANDROID / IOS / **ALL** (ROLLUP으로 한 쿼리에서 산출)

분석 대상 element는 사전에 명세 + 로그 양쪽에서 후보 리스트를 얻은 뒤 IN clause로 한정한다 (안 그러면 명세 only/로그 only 분류 불가).

```sql
WITH src AS (
  SELECT platform,
         user_id,
         session_id,
         category,
         object_section_id,
         object_type
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND page_id = '{page_id}'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
     AND category IN ('PAGEVIEW', 'IMPRESSION', 'CLICK', 'SCROLL')
     AND (object_section_idx IS NULL
          OR TRY_CAST(object_section_idx AS BIGINT) < {idx_cutoff})
),
page_rollup AS (
  SELECT COALESCE(platform, 'ALL') AS platform,
         COUNT(DISTINCT CASE WHEN category = 'PAGEVIEW' THEN user_id END)    AS pv_uv,
         COUNT(DISTINCT CASE WHEN category = 'PAGEVIEW' THEN session_id END) AS pv_sessions,
         COUNT(DISTINCT CASE WHEN category = 'SCROLL'   THEN user_id END)    AS scroll_uv
    FROM src
   GROUP BY ROLLUP(platform)
),
em_rollup AS (
  SELECT COALESCE(platform, 'ALL') AS platform,
         object_section_id,
         object_type,
         COUNT(DISTINCT CASE WHEN category = 'IMPRESSION' THEN user_id END)    AS impression_uv,
         COUNT(DISTINCT CASE WHEN category = 'CLICK'      THEN user_id END)    AS click_uv,
         COUNT(DISTINCT CASE WHEN category = 'CLICK'      THEN session_id END) AS click_sessions
    FROM src
   WHERE object_section_id IN ({분석_대상_리스트})
   GROUP BY ROLLUP(platform), object_section_id, object_type
)
SELECT e.platform,
       e.object_section_id,
       e.object_type,
       e.impression_uv,
       e.click_uv,
       e.click_sessions,
       p.pv_uv,
       p.pv_sessions,
       p.scroll_uv,
       CAST(e.click_uv       AS DOUBLE) / NULLIF(e.impression_uv, 0) AS ctr,
       CAST(e.impression_uv  AS DOUBLE) / NULLIF(p.pv_uv, 0)         AS ir,
       CAST(e.click_uv       AS DOUBLE) / NULLIF(p.pv_uv, 0)         AS click_per_pv,
       CAST(e.click_sessions AS DOUBLE) / NULLIF(p.pv_sessions, 0)   AS click_per_session,
       CAST(p.scroll_uv      AS DOUBLE) / NULLIF(p.pv_uv, 0)         AS scroll_rate
  FROM em_rollup e
  JOIN page_rollup p USING (platform)
 WHERE e.object_section_id IS NOT NULL
 ORDER BY (CASE e.platform WHEN 'ALL' THEN 0 WHEN 'ANDROID' THEN 1 ELSE 2 END),
          click_per_pv DESC
;
```

**핵심 지표:**
- **IR (Impression Rate)** = 노출 UV / 페이지 PV UV — element가 얼마나 보였나
- **CTR** = 클릭 UV / 노출 UV — 보인 사람 중 누른 비율
- **click_per_pv** = 클릭 UV / 페이지 PV UV — 페이지 진입자 중 결국 누른 비율. **디자인 의사결정의 메인 기준선이자 element 랭킹의 기본 정렬키**.
- **click_per_session** = 클릭 session 수 / PV session 수 — session 단위 사용 빈도. 같은 유저가 여러 session에 걸쳐 반복 클릭하는지 보조 신호.
- **scroll_rate** = SCROLL UV / PAGEVIEW UV — 페이지 진입자 중 스크롤 한 번이라도 한 비율.

**플랫폼 처리 (ROLLUP):**
- `GROUP BY ROLLUP(platform), ...` 가 per-platform 행과 NULL platform 행(ALL) 을 **한 번의 집계**로 산출. `COALESCE(platform, 'ALL')` 로 라벨링.
- `ALL` 의 UV/session 수는 합산이 아닌 unique distinct count (한 유저가 두 OS 쓰는 케이스 dedup) — ROLLUP 동작이 정확히 이것을 보장.
- `ALL` 이 HTML의 메인 뷰이자 랭킹 기준, `ANDROID` / `IOS` 는 보조 뷰.

**`object_section_idx` 스캔 컷오프 (v1.5.2 신설):**
- `src` CTE의 WHERE 에 `object_section_idx < {idx_cutoff}` 조건이 들어간다 (기본 10).
- 스크롤 안 한 유저에게 로딩조차 안 된 하단 element가 IR 분모/분자에 섞여들지 않게 함 → **정합성 개선**.
- 또한 스캔 bytes에 영향 (Parquet row group 통계가 잘 잡혀 있으면 pruning).
- 사용자가 "전체 idx로" 요청하면 이 조건만 제거, "첫 화면만" 요청하면 `< 3` 으로 조정.

**SCROLL 카테고리가 없는 page_id인 경우:**
- `scroll_uv` / `scroll_rate` 가 0 으로 나온다 (쿼리 자체는 에러 없이 돈다).
- Step 5 결과 표시 시 사용자에게 한 줄 안내 — "이 page_id는 SCROLL 로그가 없어서 scroll_rate는 0이야. 명세 정비가 필요하면 log-center에서 확인해줘."

**v1.5.2 설계 결정 (dwell 제거):**
- 이전 버전에 있던 `avg_dwell_seconds` 는 `log.analyst_log_table` 에 duration 컬럼이 없어서 LEAD 윈도우로 계산했는데, 이 계산은 **해당 기간 전체 유저의 모든 이벤트**를 필요로 해서 비용 대비 정합성 이득이 작았음. v1.5.2 에서 제거. click_per_pv + scroll_rate + click_per_session 조합으로 engagement 신호는 충분히 표현 가능.
- 사용자가 "체류시간도 보고 싶어"라고 명시 요청 시에만 별도 옵션으로 dwell 쿼리를 추가 작성 (기본 워크플로우는 아님).

#### 4-B-2. 사용자 승인 & 실행

통합 쿼리 전문 1개를 보여주고 **한 번의 yes/no**로 승인:

```
이 통합 쿼리 실행할게. 진행할까? (y / n)

[통합 쿼리 — element metrics + page health, ROLLUP per-platform]
[쿼리 전문]
```

flow scope 이면 Step 4-A 의 funnel 쿼리도 같이 묶어서 보여준다:

```
이 쿼리들 실행할게. 진행할까? (y / n)

[1] Flow funnel (page_id 시퀀스 간 전환률)
[쿼리 전문]

[2] 각 page_id 통합 쿼리 (element + page health)
[쿼리 전문 N개 — 각 page_id당 1개, 모양은 동일]
```

`y` 면 순서대로 `mcp__ohouse-athena-mcp__execute_athena_query` 로 실행. **Step 4-A 의 funnel 쿼리와 per-page 통합 쿼리를 여러 개로 쪼개지 말 것** — 한 번의 yes/no 로 묶는다.

#### 4-B-3. 결과 기록

MD `## 4. 쿼리 결과` 섹션에 통합 쿼리 전문 + 결과 표 + 실행 일시 기록 → HTML 재생성.

### Step 5-B: per-page HTML 시각화

`./screens/{page_id}.html` 재생성. 같은 page_id면 같은 파일을 덮어쓴다 (재사용).

#### Auto-open 정책

- **scope=single**: 이 단일 page_id의 HTML을 즉시 `open` 으로 띄운다.
- **scope=flow**: per-page 루틴 loop가 끝난 뒤 **첫 entry page_id의 HTML만** 띄운다 (loop 안에서 매번 띄우지 않음).

```bash
# single
open ./screens/{page_id}.html

# flow (loop 끝난 후 entry 1개만)
open ./screens/{entry_page_id}.html
```

사용자 보고:
```
# single
✅ 결과 HTML을 새 창으로 띄웠어 — ./screens/{page_id}.html

   사후 조정: "기간 14일로", "N=20으로", "명세 only도 포함" 처럼 말해주면 즉시 재실행할게.

# flow
✅ 플로우 분석 완료. 첫 페이지 HTML을 새 창으로 띄웠어.
   ./screens/{entry_page_id}.html
   다른 페이지: {나머지 page_id 리스트}
   상단 funnel이나 element 차트의 trigger를 클릭하면 해당 페이지로 이동돼.

   사후 조정: "기간 14일로", "N=20으로" 처럼 말해주면 즉시 재실행할게.
```

#### 5-B-1. 기본 산출 (Step 4 완료 시)

per-page HTML 섹션 구조 (위에서 아래 순서로 렌더):

```
<header>
  page_id (큰 글자) / page_title / 측정 기간 / 상태 배지 / 마지막 업데이트
</header>

<section id="flow-header">                ← flow scope에서만 렌더, single은 생략
  현재 page_id가 어떤 플로우의 어느 step인지 + 전체 플로우 funnel 시각화
  (이 섹션은 같은 플로우의 모든 page_id HTML에 동일하게 inject됨)

  - 플로우명: commerce-pdp-to-checkout
  - 현재 위치: step 2/4 (PDP) — 시각적으로 강조
  - Funnel 시각화 (가로 가로 막대 + 노드):
      [SHOPPINGHOME] 100% UV
        ↓ (장바구니 담기 버튼 click_uv → CART pv_uv)
      [PDP] ← 현재 (강조 테두리)
        ↓
      [CART]
        ↓
      [ORDER_CHECKOUT]
        ↓
      [ORDER_DONE]
  - 각 노드는 클릭 가능: <a href="./{node_page_id}.html"> 로 이동
  - 노드 옆에 step UV / 전환률 / 이탈률 숫자
  - 전환률은 통합(ALL) 기준 (강조색)

  스타일:
  - 배경 카드 색을 살짝 다르게 (#1c1c1c)
  - 현재 page_id 노드만 #10B981 강조
  - 다른 노드는 hover 시 강조 + cursor pointer
</section>

<section id="context">                    ← MD §1
  분석 목적 + page_id + 측정 기간 카드
</section>

<section id="date-refresh">               ← 갱신 명령 생성기 (인터랙티브)
  현재 측정 기간 표시 + date range picker:
    [from: YYYY-MM-DD] ~ [to: YYYY-MM-DD]
    [퀵: 7일 / 14일 / 30일 / 지난 주 / 지난 달]

  [📋 갱신 명령 복사] 버튼 →
    클릭 시 다음 텍스트를 클립보드에 복사:
      `funnel-check refresh {page_id} from {from} to {to}`
    그리고 토스트:
      "복사됐어. Claude에 붙여넣으면 같은 분석을 새 기간으로 다시 돌려줘."

  툴팁: "HTML은 직접 athena를 호출하지 못해. 갱신 명령을 Claude에 붙여넣으면
        skill이 Step 1-3 건너뛰고 새 기간으로 쿼리만 다시 돌려."
</section>

<section id="page-health">                ← MD §4-B-2 (있을 때)
  ANDROID / IOS 두 컬럼:
    - PV UV (큰 숫자)
    - 스크롤률 % (없으면 회색 처리)
    - 평균 체류시간 (초)
</section>

<section id="inventory">                  ← MD §3
  3개 카드:
    ✅ 명세 ∩ 로그 (개수 + 리스트)
    ⚠️ 명세 only (개수 + 리스트, 노란 강조)
    ⚡ 로그 only (개수 + 리스트, 노란 강조)
</section>

<section id="ctr-charts">                 ← MD §4-B-1
  메인 막대 차트 (통합, 강조):
    - Y축: title + (object_section_id) — title이 큰 글자, object_section_id 작게 회색
    - X축: click_per_pv (ALL platform 기준)
    - 정렬: ALL click_per_pv 내림차순 = element 랭킹
    - 막대 색: 강조색 (#10B981 가장 진하게 또는 #2563EB) — "통합" 임을 시각적으로 강조
    - 호버 시 IR / CTR / click_per_pv / impression_uv / click_uv 툴팁

  ⭐ Click-through navigation (flow scope에서만 활성):
    - flow scope의 현재 page_id가 next page_id를 가지면, flow definition의 trigger
      element(예: PDP의 cart_button → CART)에 해당하는 막대는 클릭 가능 표시
    - 막대 옆에 작은 → 아이콘 + "다음 페이지로" 라벨
    - 클릭 시 <a href="./{next_page_id}.html"> 로 이동
    - cursor pointer + hover 시 강조 outline
    - DATA 객체에 trigger 매핑 inline:
      window.FLOW_TRIGGERS = {
        "cart_button": { "next_page_id": "CART", "title": "장바구니 담기 버튼" }
      }

  보조 차트 (플랫폼 비교, 작게 / 접기):
    - 같은 element 순서로 ANDROID / IOS 막대 두 줄 stacked or grouped
    - 색: 회색 톤 (#94A3B8 / #64748B) — 보조임을 강조
    - 메인 차트에서 element hover 시 보조 차트의 같은 element 하이라이트

  토글 컨트롤:
    - 지표: click_per_pv (default) / CTR / IR
    - 보기: 통합만 / 통합+플랫폼 비교 / 플랫폼만
    - 정렬: 내림차순(default) / 오름차순

  정렬 기준은 항상 ALL platform — 플랫폼별 토글로 바꿔도 element 순서는 유지 (랭킹 일관성).
</section>

<section id="lower-ranking-elements">     ← MD §5
  Element 클릭률 랭킹 — 하위 구간 참고표:
    | title | object_section_id | object_type | 통합 click/PV | ANDROID | IOS | 명세 여부 |
    - 통합 click/PV 컬럼이 메인, 굵은 글자 + 강조색
    - ANDROID / IOS 컬럼은 보조 (회색)
    - 명세 only는 별도 섹션으로 분리 (측정 기간 내 로그 없음, 명세 정비 참고)
    - 통합 click_per_pv 오름차순 정렬 (하위 랭킹 한눈에)
    - 이 표는 click_per_pv 하위 element를 모아보는 참고 섹션. 판단(유지/개선/리디자인/제거)은 전적으로 사용자 몫.
</section>

<section id="figma-mapper">               ← 인터랙티브 (5-B-2)
  Figma URL 입력 + iframe embed + drag-drop label 매핑
  (아래 5-B-2 상세 명세 참조)
</section>

<section id="query">
  실행된 두 쿼리 (Element CTR, Page Health) 접기/펼치기
</section>
```

**스타일 가이드** (flow mode와 동일 + element 추가):
- 배경 `#141414`
- **통합(ALL) 강조색**: `#10B981` (메인 막대, 메인 표 강조 컬럼) — per-page HTML의 시각적 주인공
- 보조 (플랫폼별): ANDROID `#64748B`, IOS `#94A3B8` (회색 톤, 보조 의도를 시각적으로 전달)
- 일반 텍스트/카드: `#2563EB` (action), `#EAEAEA` (텍스트)
- 폰트 `-apple-system, ..., 'Noto Sans KR'`
- 레이아웃 `max-w-6xl mx-auto`
- 카드 `bg-[#1a1a1a] rounded-2xl border border-white/[0.06] p-6`
- 차트 라이브러리: **Recharts via CDN**
- 데이터: 별도 inline `<script>const DATA = {...}</script>` 블록 (element 결과 JSON, ALL/ANDROID/IOS 행 모두 포함)

#### 5-B-2. Figma Mapper (인터랙티브 영역, per-page HTML의 차별점)

**목적:** 사용자가 Figma 화면 링크를 붙여넣으면 그 위에 element CTR 라벨을 직접 매핑할 수 있게 한다. DA 분의 annotated screenshot 산출물 형태를 이 도구 안에서 직접 만들 수 있게 한다.

**UI 명세:**

```html
<section id="figma-mapper">
  <h2>Figma 화면에 매핑하기</h2>
  <p class="hint">Figma 프레임 URL을 붙여넣으면 그 위에 element 라벨을 드래그해서 배치할 수 있어.</p>
  
  <div class="figma-input">
    <input type="url" id="figma-url" placeholder="https://www.figma.com/file/... 또는 /design/..."/>
    <button id="figma-load">불러오기</button>
  </div>
  
  <div class="mapper-stage" style="position: relative;">
    <iframe id="figma-embed" 
            src=""
            style="width: 100%; aspect-ratio: 9/16; max-width: 420px;"
            allowfullscreen></iframe>
    
    <div id="label-overlay" 
         style="position: absolute; inset: 0; pointer-events: auto;">
      <!-- 사용자가 배치한 라벨이 절대 위치로 추가됨 -->
    </div>
  </div>
  
  <div class="label-pool">
    <h3>매핑 대기 중인 element</h3>
    <p class="hint">아래 라벨을 위 화면의 해당 위치로 드래그해. 한 번 배치한 라벨은 다시 드래그해서 위치 조정 가능.</p>
    <div id="label-list">
      <!-- DATA에서 각 element를 draggable chip으로 렌더 -->
      <!-- chip: object_section_id + ANDROID% / IOS% -->
    </div>
  </div>
  
  <div class="mapper-actions">
    <button id="export-mapping">매핑 JSON 내보내기</button>
    <button id="reset-mapping">초기화</button>
  </div>
</section>
```

**동작 명세 (JS):**

1. **Figma URL 임베드:**
   - 입력된 URL을 검증 (`figma.com/file/`, `figma.com/design/`, `figma.com/proto/` 패턴)
   - Figma embed URL로 변환: `https://www.figma.com/embed?embed_host=share&url={encoded}`
   - iframe `src`에 설정

2. **Label Pool:**
   - DATA의 각 element를 draggable `<div class="chip">` 으로 렌더
   - chip 표시: `{object_section_id}` 위에 작게, `🤖 ANDROID 5.4% · 📱 IOS 8.1%` 아래에 라벨
   - chip 색상: click_per_pv 분포에 따라 회색/파랑/초록 (위 3번 항목 참고)

3. **Drag & Drop:**
   - chip을 mapper-stage 위로 드래그하면 그 위치에 절대 위치로 배치
   - 배치된 chip은 다시 드래그 가능 (위치 조정)
   - 위치는 stage 상대 좌표 (% 단위, 반응형)

   chip 색상은 click_per_pv 분포 기준 하위 구간이면 회색(`#94A3B8`), 상위면 초록(`#10B981`), 중간이면 파랑(`#2563EB`).

4. **Persistence:**
   - 모든 위치 변경은 즉시 `localStorage[`funnel-check-mapping-${page_id}`]`에 저장
   - 페이지 새로고침해도 매핑 유지

5. **Export:**
   - "매핑 JSON 내보내기" 클릭 시 다음 형태의 JSON 다운로드:
   ```json
   {
     "page_id": "PDP",
     "figma_url": "...",
     "mapped_at": "2026-04-10T15:30:00Z",
     "labels": [
       {
         "object_section_id": "cart_button",
         "object_type": "BUTTON",
         "x_pct": 78.4,
         "y_pct": 92.1,
         "android_click_per_pv": 0.054,
         "ios_click_per_pv": 0.081
       },
       ...
     ]
   }
   ```
   - 파일명: `{page_id}-mapping-{YYYYMMDD}.json`
   - 사용자가 이 파일을 `./screens/` 폴더에 저장하면, 다음 호출 시 funnel-check이 읽어서 자동 복원

6. **Reload (다음 세션):**
   - Step 0-B에서 `./screens/{page_id}-mapping-*.json`이 있으면 가장 최근 것 읽기
   - HTML 재생성 시 localStorage 초기값으로 주입 → 사용자 매핑 그대로 복원

**제약/주의:**
- Figma iframe은 cross-origin이라 iframe 내부 클릭/스크롤 이벤트를 직접 가로챌 수 없음
- 라벨 overlay는 iframe **위에** 별도 div로 깔리며, overlay에서 발생한 클릭/드래그만 처리
- 라벨이 iframe 클릭을 가로막으면 안 되니 chip 배치 시 chip 영역만 `pointer-events: auto`, 나머지는 `pointer-events: none`
- 좌표 정밀도는 사용자가 눈으로 맞추는 수준이면 충분 (자동 매핑은 v2 Figma MCP)

## per-page MD 템플릿 (`./screens/{page_id}.md`)

```markdown
# {page_id}

- page_title: {title from log-center}
- 생성일: {YYYY-MM-DD}
- 마지막 업데이트: {YYYY-MM-DD HH:MM}
- 상태: 수집중 | page_id확정 | 인벤토리확정 | 쿼리확정 | 결과확보
- 참조 플로우: (flow scope에서 이 page가 포함된 플로우 리스트, 여러 개 가능)
  - commerce-pdp-to-cart
  - commerce-pdp-to-wishlist

## 1. 맥락
- 분석 목적: (예: "각 모듈 사용도를 정량 근거로 파악해 리뉴얼 의사결정에 활용")
- 측정 기간:

## 2. 분석 대상
- page_id:
- title:
- category:
- domain:
- 확정 일시:
- (그라운딩으로 확정한 경우) 그라운딩 세션: user_id={id}, {시작 ~ 끝}

## 3. Element 인벤토리
### ✅ 명세 ∩ 로그 (정상)
- 장바구니 담기 버튼 (cart_button, BUTTON)
- 주문 상품 (ORDER_PRODUCT, BUTTON)
- ...

### ⚠️ 명세 only (측정 기간 클릭 0)
- 옛 프로모션 배너 (old_promo_banner, MODULE)

### ⚡ 로그 only (명세 정비 필요)
- {title 없음} (exp_recommendation_v3, MODULE)

## 4. 쿼리 결과 (통합 쿼리 1개, v1.5.2)
실행 쿼리 (element metrics + page health, ROLLUP per-platform):
```sql
-- 통합 쿼리 전문
```

**4-1. Per-element × per-platform 지표 (실행: {YYYY-MM-DD HH:MM})**
| platform | title | object_section_id | object_type | impression_uv | click_uv | click_sessions | IR | CTR | click/PV | click/session |
|----------|-------|-------------------|-------------|---------------|----------|----------------|-----|-----|----------|---------------|
| **ALL**  | **장바구니 담기 버튼** | **cart_button** | **BUTTON** | **...** | **...** | **...** | **...** | **...** | **...** | **...** |
| ANDROID  | 장바구니 담기 버튼 | cart_button | BUTTON | ... | ... | ... | ... | ... | ... | ... |
| IOS      | 장바구니 담기 버튼 | cart_button | BUTTON | ... | ... | ... | ... | ... | ... | ... |

(ALL 행은 통합 지표. element 랭킹은 ALL.click_per_pv 내림차순.)

**4-2. Per-platform page health (같은 쿼리에서 JOIN으로 붙음)**
| platform | pv_uv | pv_sessions | scroll_uv | scroll_rate |
|----------|-------|-------------|-----------|-------------|
| **ALL** | **...** | **...** | **...** | **...** |
| ANDROID  | ...   | ...         | ...       | ...         |
| IOS      | ...   | ...         | ...       | ...         |

(v1.5.2: `avg_dwell_seconds` 제거. `log.analyst_log_table` 에 duration 컬럼이 없고 LEAD 기반 계산이 전체 유저 이벤트 스캔을 필요로 해서 비용 대비 정합성 이득이 작음 — click_per_pv + scroll_rate + click_per_session 조합으로 engagement 신호 충분히 표현됨.)

## 5. Element 클릭률 랭킹 — 하위 구간 참고표
| title | object_section_id | object_type | **통합 click/PV** | ANDROID | IOS | 명세 |
|-------|-------------------|-------------|-------------------|---------|-----|------|
| 옛 프로모션 배너 | old_promo_banner | MODULE | **0%** | 0% | 0% | ✓ |
| 푸터 레거시 링크 | footer_link_legacy | LINK | **0.35%** | 0.3% | 0.4% | ✓ |
| ... | ... | ... | ... | ... | ... | ... |

(통합 컬럼이 메인 정렬키, 오름차순. 이 표는 click_per_pv 하위 element를 모아 보는 참고 섹션이고 판단(유지/개선/리디자인/제거)은 사용자 몫)

## 6. Figma 매핑
- Figma URL: (사용자가 HTML에서 입력 후 export한 JSON 경로)
- 매핑 파일: ./screens/{page_id}-mapping-{YYYYMMDD}.json
- 마지막 매핑 일시:

## 7. 의사결정 로그
- {timestamp} ...
```

## 파일 구조 (전체)

스킬을 호출한 디렉토리 아래에 다음이 생긴다 (page_id 단위 + flow definition 별도):

```
{호출한 디렉토리}/
  ├── screens/                                ← per-page 산출물 (single + flow 둘 다 여기)
  │   ├── {page_id}.md                        ← per-page 분석 정본
  │   ├── {page_id}.html                      ← per-page HTML (인터랙티브, 자동 재생성)
  │   ├── {page_id}-mapping-{YYYYMMDD}.json   ← Figma 매핑 export (사용자 저장)
  │   ├── pdp.md
  │   ├── pdp.html
  │   ├── cart.md
  │   ├── cart.html
  │   └── ...
  │
  └── flows/                                  ← flow scope에서만 생성
      └── {flow_name}.md                      ← 플로우 정의 + funnel 쿼리 결과
                                              (별도 flow.html은 없음 — funnel 시각화는
                                               각 page_id html의 flow-header section에 inject)
```

**핵심 원칙**:
- HTML은 항상 page_id 단위 (`./screens/{page_id}.html`)
- 같은 page_id가 여러 플로우에 포함되어도 HTML은 1개만 (재사용)
- flow scope면 `./flows/{flow_name}.md` 가 추가로 생기고, 거기 정의된 funnel 데이터가 그 플로우에 포함된 모든 page_id HTML 의 flow-header section에 inject됨

---

# 공통 주의사항 (mode 무관)

- **자의적 추론 금지.** 페이지 연결, element 분류, 카테고리 분류 — 모두 사용자 확정 필요. 자동은 정규화/대조까지만.
- **쿼리는 승인 전 실행 금지.** 전문을 보여주고 "실행할까?" 명시 확인.
- **쿼리는 통합 1개가 원칙.** per-page 루틴은 element + page health 를 `src` CTE 1개 + ROLLUP(platform) 으로 한 번의 스캔에 처리. 같은 테이블을 CTE 여러 개에 나눠 각자 WHERE를 복제하지 말 것 — Trino optimizer 의존도와 비용이 모두 올라간다.
- **비용 원칙.** Athena 스캔은 기간 × 컬럼 수 × 카테고리 수로 선형 증가하고 반복 호출될수록 누적된다. 디폴트는 "정합성을 확보할 수 있는 최소 스캔"을 기준선으로 잡고, 기간 확장 / idx 컷오프 해제 / engagement 카테고리 확장 / dwell 도입 같은 비용을 키우는 옵션은 사용자가 명시 요청할 때만 적용.
- **명세 교차검증 필수.** `get_page_spec`이 있는 page_id는 반드시 명세와 실로그 대조.
- **파티션 필수.** `date` 필터 없는 쿼리 금지 (비용).
- **비회원 제외.** `user_id > 0` 필수.
- **앱 한정.** `platform IN ('IOS', 'ANDROID')` 필수.
- **enum 대문자.** page_id, category, object_type 등은 전부 대문자.
- **단계 건너뛰기 금지.** "다 건너뛰고 쿼리만 돌려"라는 요청에도 최소한 mode 결정과 page_id/Flow Definition 확정은 거친다.
- **매 단계 끝에 HTML 재생성.** MD 파일 쓴 직후 HTML도 갱신.
- **boilerplate 폴더 자동 생성.** 처음 호출 시 `./flows/` 또는 `./screens/`가 없으면 만든다.

# 향후 mode 추가 시 가이드

새 mode를 추가할 때 (예: peer-compare, trend):
1. "Mode 개념" 표에 한 줄 추가
2. Step 0의 키워드 매핑 표에 트리거 키워드 추가
3. `# Mode {X}: {이름}` 섹션을 새로 추가
4. 해당 mode의 워크플로우, MD 템플릿, 산출물 폴더 정의
5. 공통 원칙은 건드리지 말고 mode-specific만 추가

이 skill의 강점은 mode 분리에도 불구하고 **공통 원칙(정확성/사용자 확정/쿼리 승인)이 깨지지 않는 것**. 새 mode 도입 시 이 원칙을 우회하는 단축경로를 만들지 말 것.
