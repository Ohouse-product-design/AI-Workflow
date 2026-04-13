# 데이터 인사이트 측정 (funnel-check)

프로덕트 디자이너가 자기 오너십 화면의 데이터를 **정확하게** 측정하는 skill입니다. PD가 PO와 차별화된 데이터 근거를 들고, 화면 내 element들의 실제 사용 패턴을 **랭킹으로 파악**할 수 있게 돕는 게 이 skill의 미션입니다.

"X 화면 분석해줘" 같은 요청은 page_id/object_* 해석이 매번 달라져 데이터가 오염되는데, 이 skill은 **사용자가 직접 폰으로 걸어본 로그를 정답지로** 삼거나 **로그센터 명세와 실제 로그를 교차검증**해서 정의를 고정한 뒤 athena 쿼리를 생성/실행합니다.

관련 스킬: `log-explore`(로그 탐색), `log-query`(쿼리 실행), `log-spec`(명세 조회) — 이 스킬들의 규칙(테이블, 파티션, 필터)을 그대로 준수합니다.

## 원칙 (mode 무관 공통, 절대 어기지 말 것)

1. **자동 실행 금지.** 각 단계는 사용자에게 물어보고 확정받은 뒤 다음 단계로 간다. 한 번에 여러 스텝을 건너뛰지 않는다.
2. **자의적 추론 금지.** 페이지 연결, element 의미, 카테고리 분류 — 어느 것도 AI가 멋대로 결정하지 않는다. 후보만 제시하고 사용자가 확정한다.
3. **Athena 쿼리는 전문을 보여주고 승인받은 뒤 실행.** 쿼리는 정답지다. 사람 눈으로 검증 가능해야 한다.
4. **명세와 교차검증.** `get_page_spec`이 있는 page_id는 항상 명세를 같이 본다. 명세에 없는 object는 경고.
5. **MD가 정본, HTML은 매번 재생성.** 모든 산출물의 정본은 MD 파일이고, HTML은 MD가 갱신될 때마다 자동 재생성한다.
6. **세그먼트(신규/활성/부활)는 MVP에서 제외.** 전체 유저 대상만 측정. v2에서 BA팀 표준 마트(`ba_preserved.user_seg_rfd_v2`) 기반 추가 예정.

## Mode 개념

이 skill은 두 가지 측정 mode를 가진다:

| Mode | 핵심 질문 | 단위 | 산출물 폴더 |
|------|----------|------|-------------|
| **flow** | 이 플로우의 어디서 떨어지나? | 페이지 시퀀스 | `./flows/` |
| **audit** | 이 화면 element들의 클릭률 랭킹은? | 단일 페이지 | `./screens/` |

### 향후 추가 예정 mode (현재 미구현)
- **peer-compare**: 같은 카테고리의 다른 화면과 비교
- **trend**: 시계열 변화 추적

## 입력
$ARGUMENTS (자연어 또는 명시적 이름. 예: `commerce-pdp-to-cart`, `상품 상세에서 장바구니까지 전환률 보고싶어`, `pdp 화면 element 클릭률 랭킹 보여줘`)

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

3개 모두 어느 위치에든 있으면 ✅ 통과. 빠진 게 있으면 안내:

```
⚠️ funnel-check이 의존하는 스킬이 없어:
{누락된 스킬 리스트}

설치 방법 (택 1):

옵션 1 — 자동 발동 (권장, 자연어로 호출 가능):
  1. AI-Skill 레포 clone:
     git clone https://github.com/Ohouse-product-design/AI-Skill.git ~/claude-skills
  2. ~/.claude/CLAUDE.md 에 skill path 등록 (Skills 섹션에 한 줄씩):
     - funnel-check: ~/claude-skills/skills/funnel-check/SKILL.md
     - log-explore: ~/claude-skills/skills/log-explore/SKILL.md
     - log-query: ~/claude-skills/skills/log-query/SKILL.md
     - log-spec: ~/claude-skills/skills/log-spec/SKILL.md
  3. Claude Code 재시작
  4. "이 화면 audit 해줘" 같은 자연어로 사용

옵션 2 — 슬래시 커맨드 (수동 호출):
  1. 위 1번 clone
  2. 파일 복사:
     cp ~/claude-skills/skills/funnel-check/SKILL.md ~/.claude/commands/funnel-check.md
     cp ~/claude-skills/skills/log-explore/SKILL.md ~/.claude/commands/log-explore.md
     cp ~/claude-skills/skills/log-query/SKILL.md ~/.claude/commands/log-query.md
     cp ~/claude-skills/skills/log-spec/SKILL.md ~/.claude/commands/log-spec.md
  3. /funnel-check 으로 호출

자세한 가이드:
https://github.com/Ohouse-product-design/AI-Skill/blob/main/skills/funnel-check/README.md

지금 의존성 없이 진행하려면 page_id 도메인 매핑/명세 조회 단계에서 막힐 수 있어.
계속 진행할까? (계속 / 중단)
```

사용자가 "중단" 선택 시 종료. "계속" 선택 시 진행 (단 막힘이 예상되는 단계에서 다시 사용자에게 알림).

### -1-2. MCP 도구 확인 (시도 기반)
athena mcp / log center mcp는 사전 검사를 하지 않고 실제 호출 시점에 시도한다. 호출이 실패(`tool not found` 또는 권한 에러)하면 친절한 메시지로 변환:

```
⚠️ {도구명} 도구를 사용할 수 없어. 다음을 확인해줘:

1. ~/.claude/.mcp.json 또는 사내 MCP 설정에 다음이 있는가:
   - athena mcp (execute_athena_query)
   - log center mcp (get_page_spec, get_log_spec_by_id)
2. 오늘의집 athena 권한이 있는가 (log.analyst_log_table SELECT)
3. 사내 권한이 필요한 경우 VPN 연결 상태

설정 가이드:
https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check#사전-요구사항
```

### -1-3. 점검 통과 시
한 줄로 알리고 Step 0으로 진행:
```
✅ 환경 점검 완료. funnel-check v1.2 시작.
```

부족한 게 있어도 사용자가 "계속"을 선택했으면 위 메시지에 경고 추가:
```
⚠️ 환경 점검 부분 통과 (의존 스킬 {N}개 누락). funnel-check v1.2 시작.
```

## Step 0: Mode 추론 (모든 호출의 첫 단계)

자연어에서 mode를 추론한다:

| 키워드 패턴 | 추론 mode |
|------------|-----------|
| "전환률", "전환", "퍼널", "이탈", "플로우", "...에서 ...까지" | **flow** |
| "사용도", "클릭률", "랭킹", "audit", "이 화면의" | **audit** |
| 명시적 플래그 `--mode=flow` 또는 `--mode=audit` | 그 mode |
| 둘 다 / 모호 / 입력 없음 | 사용자에게 확인 |

추론 결과를 사용자에게 알리고 시작한다:
```
"입력을 보니 audit mode로 진행하면 될 것 같아. (이 화면 element들의 클릭률 랭킹 분석)
다른 mode가 필요하면 알려줘. 아니면 진행할게."
```

명시 응답 없으면 추론된 mode로 진행. 사용자가 정정하면 그 mode로 변경.

### 입력이 없을 때 (예: `/funnel-check`만 호출)
자동 추론할 근거가 없으면 자의적으로 mode를 고르지 말고 아래 안내를 그대로 제시한다:

```
/funnel-check만 호출하고 별도 입력이 없어서 mode를 자동 추론할 수 없어. 어떤 분석을 할지 알려줘.

| Mode   | 언제 쓰나                   | 예시 질문                              |
|--------|------------------------------|----------------------------------------|
| flow   | 전환/이탈 플로우 분석        | "PDP에서 장바구니까지 전환률 보고싶어" |
| audit  | 단일 화면의 element 사용도 분석 | "이 화면 element 클릭률 랭킹 보여줘"   |

다음 정보를 알려주면 바로 시작할게:
- 분석할 도메인/화면 (또는 플로우)
- 측정 기간 (기본: 최근 7일)
```

audit 예시 문구에 "안 쓰이는", "제거", "낭비" 같은 가치판단 단어는 절대 쓰지 않는다. 사용/비사용 판단은 데이터를 보고 사용자가 한다.

이후 워크플로우는 mode에 따라 분기한다.

---

# Mode A: Flow 분석

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

## Flow mode 워크플로우

### Step 0-A: 기존 Flow Definition 확인
1. `./flows/{플로우명}.md`가 이미 있으면 읽어서 상태(`수집중|플로우확정|쿼리확정|결과확보`) 파악
2. 사용자에게 "기존 정의 이어서 진행할까, 처음부터 다시 할까?" 물어보기
3. 없으면 Step 1부터 시작. 폴더가 없으면 `./flows/` 생성

### Step 1-A: 맥락 수집 (한 번에 묻지 말고 하나씩)
- 네가 오너십 갖는 도메인/화면이 뭐야?
- 이번에 측정할 전환 행동이 뭐야? (예: "상품 상세 → 장바구니 담기")
- 측정 기간은? (기본: 최근 7일)

답변 받으면 MD의 `## 1. 맥락` 섹션에 기록하고 HTML 재생성.

### Step 2-A: 내 로그 그라운딩

#### 2-A-1. 시각 구간 수집
- 직접 폰으로 이 플로우를 타본 적 있어?
- 언제 타봤어? (예: "오늘 오후 2시쯤")
- 어떤 user_id로 로그인되어 있었어?

**좁은 시간 구간이 핵심.** 노이즈를 줄이려면 ±30분 내외로 수렴. 사용자가 범위를 못 좁히면 후보 세션 여러 개를 보여주고 고르게 한다.

#### 2-A-2. 로그 추출 (PAGEVIEW만)
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

#### 2-A-3. 정규화 (자동)
원본 시퀀스에서 다음을 거른다:
- 연속 중복 page_id (A→A→A는 A 하나로)
- 같은 page_id 재진입 (첫 진입만 남김, 사용자 선택권 제공)
- 뒤로가기 패턴 (A→B→A에서 B는 이탈 후보)

원본과 정규화 결과를 나란히 보여준다.

#### 2-A-4. 사용자 확정 (자의적 연결 금지)
**반드시 사용자에게 묻는다:**
- "이 5개 페이지 중 측정할 플로우에 포함할 건 뭐야?"
- "순서는 이게 맞아?"
- "빼야 할 페이지 있어?"

확정한 페이지 리스트만 `## 2. 플로우 페이지`에 기록.

### Step 3-A: 화면 요소(Object) 확정

#### 3-A-1. 각 페이지의 CLICK 로그 추출
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

#### 3-A-2. 명세 교차검증
각 page_id에 대해 `get_page_spec` 호출 → 명세 object와 실제 로그 object 대조.

#### 3-A-3. Trigger 확정
각 페이지 → 다음 페이지로의 "전이 트리거"를 하나씩 확인:
- "PDP에서 CART로 넘어갈 때 누른 게 `cart_button`/`BUTTON` 이거 맞아?"

#### 3-A-4. Flow Definition 완성
`## 3. Flow Definition` 섹션에 YAML로 기록:
```yaml
- step: 1
  page_id: PDP
  title: 상품 상세
  category: 커머스
  trigger:
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

쿼리 전문을 보여주고 승인 후 실행. 실행 후 결과를 MD `## 4. 쿼리 결과`에 기록.

### Step 5-A: HTML 시각화 (flow mode)

`./flows/{플로우명}.html` 재생성. 섹션 구조:
- `<header>`: 플로우명 / 측정 기간 / 상태 배지
- `#context`: 오너십, 전환 목표, 측정 기간 카드
- `#flow`: 페이지 시퀀스 플로우차트 (가로, 화살표 + trigger 라벨)
- `#funnel`: 스텝별 전환률 카드 + 전체 퍼널 바 차트 (Recharts)
- `#query`: 실행된 쿼리 (접기/펼치기)

진행 단계별 부분 렌더링: Step 1만 끝났으면 context까지, Step 4까지 끝났으면 funnel + query까지.

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

# Mode B: Audit 분석

audit mode는 **"이 화면에 있는 모든 element의 클릭률을 랭킹으로 보여준다"**. 판단(유지/수정/리디자인/제거)은 데이터를 본 사용자 몫이고, 스킬은 중립적인 데이터 제공에 집중한다. 핵심은 두 source 대조:

- **명세 ∩ 로그**: 디자인도 됐고 실제 로그에도 잡히는 element
- **명세 only**: 디자인은 됐는데 측정 기간 내 로그 없음 (노출·클릭 0)
- **로그 only**: 로그는 있는데 명세에 없음 → 명세 정비 트리거

플랫폼 간 차이가 결정적인 인사이트가 되는 경우가 많아 (예: 마이페이지 진입률 ANDROID 12% vs IOS 26%) **ANDROID/IOS는 항상 분리해서 보여준다.**

## 화면명 규칙

형식: `{domain}-{page_id}[-{variant}]`

- **kebab-case**, 전부 **소문자**
- `{domain}`: `commerce` / `content` / `o2o` / `common`
- `{page_id}`: 분석 대상 page_id를 소문자로 (underscore 유지)
- `{variant}`: 같은 page_id의 다른 시점/조건 분석이 있을 때 (예: `-202604-renewal`, `-mobile-only`)

**예시:**
- `commerce-pdp`
- `commerce-shoppinghome`
- `commerce-pdp-202604-renewal`
- `content-cdp_project`

## Audit mode 워크플로우

### Step 0-B: 기존 audit 정의 확인
1. `./screens/{화면명}.md`가 이미 있으면 읽어서 상태 파악
2. 사용자에게 "기존 audit 이어서 진행할까, 처음부터 다시 할까?" 묻기
3. 없으면 Step 1부터 시작. 폴더 없으면 `./screens/` 생성

### Step 1-B: 맥락 수집 (한 번에 묻지 말고 하나씩)
- 분석 대상 화면이 뭐야? (자연어 OK, 다음 Step에서 page_id로 확정)
- 분석 목적은? (예: "element 클릭률 랭킹 파악", "리뉴얼 전 사용 패턴 확인")
- 측정 기간은? (기본: 최근 7일)

답변 받으면 MD의 `## 1. 맥락` 섹션에 기록 + HTML 재생성.

### Step 2-B: page_id 확정 (Hybrid 그라운딩)

#### 2-B-1. 명확 케이스 (사용자가 page_id를 알거나 화면명이 unique)
사용자 입력에서 page_id 추출. log-explore.md의 도메인별 매핑 가이드 참고:

```
사용자: "PDP audit 해줘"
스킬:
  → page_id 후보 추출: PDP, PDP_STYLINGSHOT, PDP_INQUIRY, PDP_REVIEW...
  → "PDP 후보가 N개 있어. 어떤 거 분석할까?
     [a] PDP (메인 상품 상세)
     [b] PDP_STYLINGSHOT (스타일링샷 상세)
     [c] PDP_INQUIRY (Q&A 탭)
     [d] 모르겠어 → 내 로그로 그라운딩"
```

#### 2-B-2. 모호 케이스 (fallback to 그라운딩)
사용자가 [d]를 고르거나 화면명이 모호하면 **flow mode의 Step 2-A 그라운딩 메커니즘을 호출**한다:
- 시각 구간 수집 → 내 로그 추출 → 정규화 → 사용자가 분석할 page_id 확정

이 메커니즘은 flow mode와 동일하다. audit mode는 단일 page_id만 필요하므로, 그라운딩 결과 페이지 리스트에서 사용자가 한 개를 고른다.

#### 2-B-3. page_id 확정 후 기록
`## 2. 분석 대상` 섹션에 기록:
```yaml
page_id: PDP
title: 상품 상세
category: 커머스
domain: commerce
확정_일시: {YYYY-MM-DD HH:MM}
```

### Step 3-B: Element 인벤토리 (audit mode 핵심)

두 source를 동시에 가져와 대조한다.

#### 3-B-1. Source A — 명세 (`get_page_spec`)
`get_page_spec`을 호출해 해당 page_id의 모든 object_section_id / object_type 리스트를 확보. CLICK / IMPRESSION 카테고리에 해당하는 것만 필터링.

#### 3-B-2. Source B — 실제 로그
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

#### 3-B-3. 대조 결과 사용자에게 제시 (절대 자의적 분류 금지)

```
✅ 명세 ∩ 로그 (정상 element, N개)
- cart_button (BUTTON)
- buy_now_button (BUTTON)
- ...

⚠️ 명세 only (측정 기간 내 로그 없음, M개)
- old_promo_banner (MODULE)
- ...

⚡ 로그 only (명세 누락, K개) ← 명세 정비 필요
- exp_recommendation_v3 (MODULE)
- ...

이 분류 맞아? 분석 대상에서 제외할 element 있어?
(예: '명세 only'에 있는 게 사실은 다른 화면 element면 알려줘)
```

확정된 인벤토리만 `## 3. Element 인벤토리`에 기록.

### Step 4-B: Athena 쿼리 (Element CTR + Page Health)

audit mode는 두 종류의 쿼리를 만든다. 각각 사용자 승인을 받고 실행한다.

#### 4-B-1. Element CTR / IR 쿼리 (platform 분리)

```sql
WITH page_uv AS (
  SELECT platform,
         COUNT(DISTINCT user_id) AS pv_uv
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND page_id = '{page_id}'
     AND category = 'PAGEVIEW'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
   GROUP BY 1
),
element_metrics AS (
  SELECT platform,
         object_section_id,
         object_type,
         COUNT(DISTINCT CASE WHEN category = 'IMPRESSION' THEN user_id END) AS impression_uv,
         COUNT(DISTINCT CASE WHEN category = 'CLICK' THEN user_id END) AS click_uv
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND page_id = '{page_id}'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
     AND object_section_id IN ({분석_대상_리스트})
   GROUP BY 1, 2, 3
)
SELECT e.platform,
       e.object_section_id,
       e.object_type,
       e.impression_uv,
       e.click_uv,
       p.pv_uv,
       CAST(e.click_uv AS DOUBLE) / NULLIF(e.impression_uv, 0) AS ctr,
       CAST(e.impression_uv AS DOUBLE) / NULLIF(p.pv_uv, 0) AS ir,
       CAST(e.click_uv AS DOUBLE) / NULLIF(p.pv_uv, 0) AS click_per_pv
  FROM element_metrics e
  JOIN page_uv p ON e.platform = p.platform
 ORDER BY e.platform, click_per_pv ASC
;
```

**핵심 지표:**
- **IR (Impression Rate)** = 노출 UV / 페이지 PV UV — element가 얼마나 보였나
- **CTR** = 클릭 UV / 노출 UV — 보인 사람 중 누른 비율
- **click_per_pv** = 클릭 UV / 페이지 PV UV — **element 클릭률 랭킹의 주요 지표**. 페이지 진입자 중 결국 누른 비율.

#### 4-B-2. Page Health 쿼리 (스크롤률 + 평균 체류시간)

먼저 SCROLL 카테고리가 존재하는지 `log-explore`로 확인. 존재하면:

```sql
WITH visits AS (
  SELECT user_id, platform, server_access_time
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND page_id = '{page_id}'
     AND category = 'PAGEVIEW'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
),
scrolls AS (
  SELECT DISTINCT user_id, platform
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND page_id = '{page_id}'
     AND category = 'SCROLL'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
),
dwell AS (
  SELECT user_id, platform,
         server_access_time AS pv_time,
         LEAD(server_access_time) OVER (
           PARTITION BY user_id ORDER BY server_access_time
         ) AS next_event_time
    FROM log.analyst_log_table
   WHERE date BETWEEN '{시작일}' AND '{종료일}'
     AND user_id > 0
     AND platform IN ('IOS', 'ANDROID')
     -- 같은 user의 모든 이벤트로 다음 이벤트 시각 구함
)
SELECT v.platform,
       COUNT(DISTINCT v.user_id) AS pv_uv,
       COUNT(DISTINCT s.user_id) AS scroll_uv,
       CAST(COUNT(DISTINCT s.user_id) AS DOUBLE) / NULLIF(COUNT(DISTINCT v.user_id), 0) AS scroll_rate,
       AVG(CASE
             WHEN d.next_event_time IS NOT NULL
              AND DATE_DIFF('second', d.pv_time, d.next_event_time) BETWEEN 1 AND 600
             THEN DATE_DIFF('second', d.pv_time, d.next_event_time)
           END) AS avg_dwell_seconds
  FROM visits v
  LEFT JOIN scrolls s ON v.user_id = s.user_id AND v.platform = s.platform
  LEFT JOIN dwell d ON v.user_id = d.user_id AND v.platform = d.platform
                    AND v.server_access_time = d.pv_time
 GROUP BY v.platform
;
```

**SCROLL 카테고리가 없으면**: `scroll_rate` 컬럼은 빼고 dwell time만 계산. 사용자에게 알린다 — "SCROLL 로그가 명세에 없어 스크롤률은 측정 불가. dwell time만 보여줄게."

**핵심 지표:**
- **scroll_rate** = SCROLL UV / PAGEVIEW UV — 페이지 진입자 중 스크롤 한 번이라도 한 비율
- **avg_dwell_seconds** = 페이지 PV → 다음 이벤트까지 평균 시간 (1초 미만, 10분 초과는 outlier로 제외)

#### 4-B-3. 사용자 승인 & 실행
두 쿼리 전문을 모두 보여주고 "이 두 쿼리 실행해도 될까?" 묻는다. 예상 스캔량/비용도 함께. 승인 후 `execute_athena_query`로 각각 실행.

#### 4-B-4. 결과 기록
MD `## 4. 쿼리 결과` 섹션에 두 쿼리 전문 + 결과 표 + 실행 일시 기록 → HTML 재생성.

### Step 5-B: HTML 시각화 (audit mode)

`./screens/{화면명}.html` 재생성. 단계별 부분 렌더링은 flow mode와 동일.

#### 5-B-1. 기본 산출 (Step 4 완료 시)

섹션 구조:

```
<header>
  화면명 / page_id / 측정 기간 / 상태 배지 / 마지막 업데이트
</header>

<section id="context">                    ← MD §1
  분석 목적 + page_id + 측정 기간 카드
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
    ⚠️ 명세 only (개수 + 리스트, 빨간 강조)
    ⚡ 로그 only (개수 + 리스트, 노란 강조)
</section>

<section id="ctr-charts">                 ← MD §4-B-1
  ANDROID / IOS 두 막대 차트 side-by-side:
    - Y축: object_section_id (click_per_pv 높은 순 정렬, 랭킹)
    - X축: click_per_pv (또는 토글로 CTR / IR / click_per_pv 선택)
    - 호버 시 IR / CTR / click_per_pv / impression_uv / click_uv 툴팁
  토글 컨트롤: 보고싶은 지표 선택, 정렬 방향 (높은 순 / 낮은 순)
</section>

<section id="ranking-table">              ← MD §5
  element 클릭률 랭킹 표 (중립):
    | rank | element | object_type | ANDROID click/PV | IOS click/PV | 명세 여부 |
    - 전체 element를 click_per_pv 순으로 정렬 (기본: 높은 순)
    - 명세 only (로그 없음)은 표 하단에 별도 섹션으로 표기
    - 제거/유지 판단은 사용자 몫 — 스킬은 데이터만 제공
</section>

<section id="figma-mapper">               ← 인터랙티브 (5-B-2)
  Figma URL 입력 + iframe embed + drag-drop label 매핑
  (아래 5-B-2 상세 명세 참조)
</section>

<section id="query">
  실행된 두 쿼리 (Element CTR, Page Health) 접기/펼치기
</section>
```

**스타일 가이드** (flow mode와 동일 + audit 추가):
- 배경 `#141414`, 주색 `#2563EB` (기본) / `#10B981` (상위 랭킹 강조) / 무채색 (하위 랭킹 — 가치판단 색상 쓰지 않음)
- 폰트 `-apple-system, ..., 'Noto Sans KR'`
- 레이아웃 `max-w-6xl mx-auto`
- 카드 `bg-[#1a1a1a] rounded-2xl border border-white/[0.06] p-6`
- 차트 라이브러리: **Recharts via CDN**
- 데이터: 별도 inline `<script>const DATA = {...}</script>` 블록 (audit 결과 JSON, ut-prototype `window.DATA` 패턴 참고)

#### 5-B-2. Figma Mapper (인터랙티브 영역, audit mode 핵심 차별점)

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
   - chip 스타일: 중립 — 랭킹 순위만 표시하고 색으로 가치판단하지 않음

3. **Drag & Drop:**
   - chip을 mapper-stage 위로 드래그하면 그 위치에 절대 위치로 배치
   - 배치된 chip은 다시 드래그 가능 (위치 조정)
   - 위치는 stage 상대 좌표 (% 단위, 반응형)

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
   - 파일명: `{화면명}-mapping-{YYYYMMDD}.json`
   - 사용자가 이 파일을 `./screens/` 폴더에 저장하면, 다음 호출 시 funnel-check이 읽어서 자동 복원

6. **Reload (다음 세션):**
   - Step 0-B에서 `./screens/{화면명}-mapping-*.json`이 있으면 가장 최근 것 읽기
   - HTML 재생성 시 localStorage 초기값으로 주입 → 사용자 매핑 그대로 복원

**제약/주의:**
- Figma iframe은 cross-origin이라 iframe 내부 클릭/스크롤 이벤트를 직접 가로챌 수 없음
- 라벨 overlay는 iframe **위에** 별도 div로 깔리며, overlay에서 발생한 클릭/드래그만 처리
- 라벨이 iframe 클릭을 가로막으면 안 되니 chip 배치 시 chip 영역만 `pointer-events: auto`, 나머지는 `pointer-events: none`
- 좌표 정밀도는 사용자가 눈으로 맞추는 수준이면 충분 (자동 매핑은 v2 Figma MCP)

## Audit mode MD 템플릿

```markdown
# {화면명} audit

- 생성일: {YYYY-MM-DD}
- 마지막 업데이트: {YYYY-MM-DD HH:MM}
- mode: audit
- 상태: 수집중 | page_id확정 | 인벤토리확정 | 쿼리확정 | 결과확보

## 1. 맥락
- 분석 목적: (예: "element 클릭률 랭킹 파악", "리뉴얼 전 사용 패턴 확인")
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
- cart_button (BUTTON)
- ...

### ⚠️ 명세 only (측정 기간 내 로그 없음)
- old_promo_banner (MODULE)

### ⚡ 로그 only (명세 정비 필요)
- exp_recommendation_v3 (MODULE)

## 4. 쿼리 결과
### 4-1. Element CTR / IR (실행: {YYYY-MM-DD HH:MM})
실행 쿼리:
```sql
-- 쿼리 전문
```
| platform | object_section_id | object_type | impression_uv | click_uv | IR | CTR | click/PV |
|----------|-------------------|-------------|---------------|----------|-----|-----|----------|
| ANDROID  | cart_button       | BUTTON      | ...           | ...      | ... | ... | ...      |
| IOS      | cart_button       | BUTTON      | ...           | ...      | ... | ... | ...      |

### 4-2. Page Health (실행: {YYYY-MM-DD HH:MM})
실행 쿼리:
```sql
-- 쿼리 전문
```
| platform | pv_uv | scroll_rate | avg_dwell_seconds |
|----------|-------|-------------|-------------------|
| ANDROID  | ...   | ...         | ...               |
| IOS      | ...   | ...         | ...               |

## 5. Element 클릭률 랭킹
정렬: click_per_pv 높은 순 (기본). 사용자가 방향/기준 지표 토글 가능.
| rank | element | object_type | ANDROID click/PV | IOS click/PV | 명세 여부 |
|------|---------|-------------|------------------|--------------|-----------|
| 1    | cart_button     | BUTTON | ... | ... | ✓ |
| 2    | buy_now_button  | BUTTON | ... | ... | ✓ |
| ...  |                 |        |     |     |   |

### 참고: 측정 기간 내 로그 없음 (명세 only)
- old_promo_banner: 명세에는 있는데 측정 기간 내 노출/클릭 0회
- ...

판단(유지/개선/리디자인/제거)은 사용자 몫. 이 스킬은 데이터만 제공한다.

## 6. Figma 매핑
- Figma URL: (사용자가 HTML에서 입력 후 export한 JSON 경로)
- 매핑 파일: ./screens/{화면명}-mapping-{YYYYMMDD}.json
- 마지막 매핑 일시:

## 7. 의사결정 로그
- {timestamp} 임계값 1%로 확정
- {timestamp} ...
```

## 파일 구조 (audit mode)

```
./screens/
  ├── {화면명}.md                              ← Audit 결과 정본
  ├── {화면명}.html                            ← 매 MD 갱신마다 자동 재생성 (인터랙티브)
  └── {화면명}-mapping-{YYYYMMDD}.json         ← Figma 매핑 export (사용자 저장)
```

---

# 공통 주의사항 (mode 무관)

- **자의적 추론 금지.** 페이지 연결, element 분류, 카테고리 분류 — 모두 사용자 확정 필요. 자동은 정규화/대조까지만.
- **쿼리는 승인 전 실행 금지.** 전문을 보여주고 "실행할까?" 명시 확인.
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
