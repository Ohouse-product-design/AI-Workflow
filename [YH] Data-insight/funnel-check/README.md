# funnel-check 🎯

> **PD가 자기 오너십 화면의 element 전환률과 페이지 간 funnel을 정량 근거 위에서 이해하게 도와주는 Claude Code 스킬**

매번 "X 화면 분석해줘"라고 하면 결과가 다르게 나오는 게 답답했죠. 이 스킬은 page_id를 자동으로 찾아주고, 로그센터 명세와 실제 athena 로그를 교차검증해서 항상 같은 정답으로 데이터를 뽑아줍니다.

---

## ✨ 이 스킬이 해주는 일

### 1️⃣ 단일 화면 분석 (`single`)
한 page_id의 모든 element CTR/IR/click_per_pv 를 한눈에. 통합(ALL) 지표가 메인이고 ANDROID/IOS는 보조.

```
"PDP element 전환률 보고 싶어"
"쇼핑홈 모듈별 CTR 알려줘"
```

→ `./screens/{page_id}.html` 1개 생성, 자동 브라우저 오픈

### 2️⃣ 플로우 분석 (`flow`)
여러 page_id를 순서대로 보고, 페이지 간 전환률(funnel)도 같이.

```
"쇼핑홈 → PDP → 장바구니 → 주문 결제 전환률"
"카테고리 진입부터 구매까지"
```

→ 각 page_id마다 HTML 생성. 첫 entry HTML 최상단에 전체 funnel이 시각화되고, 노드/trigger 버튼 클릭하면 다음 page HTML로 이동. 자동 브라우저 오픈.

### 3️⃣ 갱신 (refresh)
HTML 안의 date picker로 기간 바꾸고 `[📋 갱신 명령 복사]` 누르면 클립보드에 명령어가 복사돼요. Claude에 붙여넣으면 같은 분석을 새 기간으로 다시 돌려줍니다 (Step 1-3 건너뛰고 쿼리만 재실행).

---

## 🚀 사용법

### 1️⃣ 설치 (1번만)

#### 1-1. zip 다운로드 후 Claude Code에 드래그
이 zip 파일을 다운받아서 Claude Code 채팅창에 드래그앤드롭하거나 첨부합니다. 그 다음 한 줄만:

```
이 zip 풀어서 funnel-check 스킬 설치해줘
```

Claude Code가 알아서 처리하는 단계 (확인용):

1. zip을 `~/claude-skills/` 에 압축 해제 (없으면 폴더 생성)
2. 4개 스킬(`funnel-check`, `log-explore`, `log-query`, `log-spec`)을 `~/claude-skills/skills/` 아래에 배치
3. `~/.claude/CLAUDE.md` 의 `## Skills` 섹션에 4줄 추가:
   ```
   - funnel-check: ~/claude-skills/skills/funnel-check/SKILL.md
   - log-explore: ~/claude-skills/skills/log-explore/SKILL.md
   - log-query: ~/claude-skills/skills/log-query/SKILL.md
   - log-spec: ~/claude-skills/skills/log-spec/SKILL.md
   ```
4. **Claude Code 재시작** (메뉴 → Reload Window 또는 ⌘⇧P → "Developer: Reload Window")

설치가 끝나면 자연어 호출이 자동 발동돼요. 슬래시 커맨드만 쓰고 싶으면:
```bash
mkdir -p ~/.claude/commands
cp ~/claude-skills/skills/funnel-check/SKILL.md ~/.claude/commands/funnel-check.md
cp ~/claude-skills/skills/log-explore/SKILL.md ~/.claude/commands/log-explore.md
cp ~/claude-skills/skills/log-query/SKILL.md ~/.claude/commands/log-query.md
cp ~/claude-skills/skills/log-spec/SKILL.md ~/.claude/commands/log-spec.md
```

#### 1-2. 사전 요구사항 확인
스킬이 동작하려면 athena/log-center MCP 가 설정돼 있어야 합니다. `~/.claude/.mcp.json` 을 열어서 다음이 있는지 확인:
- `mcp__ohouse-athena-mcp` (athena mcp)
- `mcp__log-center-mcp` (로그센터 mcp)

없으면 사내 표준 MCP 설정 가이드를 따라 추가. Athena `log.analyst_log_table` SELECT 권한도 필요해요. 사내망 접근 시 VPN 연결도 확인.

설치 검증 (선택):
```bash
ls ~/claude-skills/skills/funnel-check/SKILL.md   # → 파일 있으면 OK
grep funnel-check ~/.claude/CLAUDE.md             # → 한 줄 매칭되면 OK
```

---

### 2️⃣ 작업 폴더 만들기

스킬은 호출한 디렉토리 아래에 `./screens/` `./flows/` 폴더를 만듭니다. 분석 결과를 한 곳에 모으려면 작업 폴더를 따로 만들어두는 게 좋아요:

```bash
mkdir -p ~/data-insight
cd ~/data-insight
```

이후로 funnel-check은 항상 `~/data-insight/` 안에서 호출하면, 모든 page_id 분석이 이 폴더 한 군데에 누적됩니다 (같은 PDP를 두 번 분석하면 같은 파일 재사용).

---

### 3️⃣ 호출 — 자연어 vs 슬래시

#### 3-1. 자연어 호출 (권장)
설치가 끝났다면 그냥 일상적인 말로 시작하면 됩니다. Claude가 description matching으로 자동 발동해요:

```
PDP element 전환률 분석해줘
쇼핑홈에서 클릭률 많은 순으로 보여줘
HOME 모듈별 CTR 보고 싶어
```

#### 3-2. 슬래시 커맨드
명시적으로 호출하고 싶으면:

```
/funnel-check PDP element 전환률
/funnel-check 쇼핑홈 → PDP → 장바구니 전환률
```

---

### 4️⃣ 진행 — 스킬이 무엇을 묻고 어떻게 답해야 하나

호출하면 다음 순서로 진행됩니다. **사용자가 답해야 하는 핵심 결정은 3개뿐**:

#### Step 1: scope 선택 (1턴)
스킬이 물어봅니다:
```
funnel-check를 시작할게. 분석 범위가 어떻게 돼?

[a] 단일 화면 — 한 page_id의 element 전환률만
[b] 플로우 — 여러 page_id 순서로, 페이지 간 전환률도

어느 걸로 갈까? (a / b)
```
→ `a` 또는 `b` 답변. (자연어에 `→` 가 있으면 자동으로 [b] 추정해서 추천하기도 함)

#### Step 2: 맥락 수집 (1턴)
**분석 대상만 필수**, 나머지는 디폴트로 자동 채움:
```
분석 대상만 알려주면 진행할게. 더 적고 싶은 정보가 있으면 같이 적어줘.

  필수: 분석 대상 화면 (예: "PDP", "쇼핑 홈", "주문 상세")
  선택: 분석 목적 (default: "유저 행동 패턴 파악")
  선택: 측정 기간 (default: 최근 30일)
```
→ 분석 대상만 한 줄로 답변해도 OK. 측정 기간을 다르게 하려면 `"PDP, 14일"` 처럼.

#### Step 3: page_id 자동 확정 (보통 1턴, 모호하면 1~2턴 추가)
스킬이 fuzzy 자동 확장으로 page_id 후보 5~10개를 동시에 조회하고:
- 명세 매칭이 1개면 → **자동 확정**, "SHOPPINGHOME 으로 진행할게" 한 줄 안내만 (사용자 응답 X)
- 매칭이 여러 개면 → 번호 선택지로 묻습니다 (`[a] PDP / [b] PDP_STYLINGSHOT / ...`)
- 매칭이 0이면 → 라이브 그라운딩으로 fallback (`"어제 쇼핑홈 들어왔어?"` 한 줄)

**user_id 캐싱**: 라이브 그라운딩에 쓰는 user_id는 첫 호출에서 한 번만 묻고 `~/.claude/projects/{project}/memory/reference_funnel_check.md` 에 저장. 이후 호출부터 자동 사용.

#### Step 4: element 인벤토리 자동 표시 (0턴)
스킬이 `mcp__log-center-mcp__get_page_spec` 으로 명세를 가져와서 실제 로그와 대조한 결과를 한 번에 보여줍니다 (디폴트 자동 적용, 컨펌 X):
```
✅ 명세 ∩ 로그 (정상 element, 12개) — 자동 분석 대상
  [1] 주문 상품 (ORDER_PRODUCT, BUTTON) — uv 12,341
  [2] 장바구니 담기 버튼 (cart_button, BUTTON) — uv 8,902
  ... (상위 16개까지)

⚡ 로그 only (비공식 element, 4개) — 자동 분석 대상

⚠️ 명세 only (측정 기간 내 클릭 0회, 3개) — 별도 표로만 분리

분류 변경하려면 "명세 only도 포함", "1, 4 제외" 처럼 알려줘.
별도 답 안 하면 이대로 쿼리 단계로 진행할게.
```
→ **답 안 해도 OK**. 자동으로 다음 단계로 넘어갑니다.

#### Step 5: 쿼리 승인 (1턴)
스킬이 통합 CTE 쿼리 1개(인벤토리 + CTR + Page Health)를 보여주고 한 번만 yes/no:
```
이 쿼리 실행할게. 진행할까? (y / n)

[쿼리 전문]
WITH page_uv AS (...), element_metrics AS (...), ...
```
→ `y` 답변하면 athena 실행 → 결과 자동 정리.

#### Step 6: HTML 자동 생성 + 새 창 (0턴)
스킬이 `./screens/{page_id}.html` 을 생성하고 `open` 명령으로 자동 새 창. 사용자 추가 액션 없음.

```
✅ 결과 HTML을 새 창으로 띄웠어 — ./screens/pdp.html
   사후 조정: "기간 14일로", "N=20으로", "명세 only도 포함" 처럼 말해주면 즉시 재실행할게.
```

---

### 5️⃣ 사후 조정 — 결과를 보고 마음에 안 들면

HTML이 뜬 다음에 그냥 말하면 즉시 재실행됩니다:

```
기간 14일로                     # 측정 기간 변경
N=20으로                        # 컷오프 변경 (default 16)
명세 only도 포함                # 인벤토리 범위 확장
1, 4 제외                       # 특정 element 제거
다른 user_id로                  # 그라운딩 user_id 갱신
```

또는 HTML 안의 **date picker 사용**:
1. HTML 상단의 `#date-refresh` 섹션에서 from/to 날짜 선택
2. `[📋 갱신 명령 복사]` 버튼 클릭 → 클립보드에 `funnel-check refresh pdp from 2026-03-15 to 2026-04-11` 복사됨
3. Claude Code에 붙여넣기
4. 스킬이 fast path로 진입 — Step 1-3 건너뛰고 새 기간으로 쿼리만 다시 돌려서 HTML 갱신 + 자동 새 창

**1회 호출당 평균 4~5턴이면 끝납니다.** ("물어보는 게 너무 많다"는 피드백 반영해서 v1.5에서 ~30턴 → 4~5턴으로 축소했어요.)

---

### 6️⃣ 플로우 분석 — 추가로 알아둘 것

`flow` scope를 골랐다면 Step 2-A에서 플로우 그라운딩 방식을 묻습니다:

```
플로우 페이지를 어떻게 확정할까?

[a] 라이브 워크스루 — 지금 바로 폰으로 플로우 타보기
    내가 user_id랑 시간 알려주면 그 구간 PAGEVIEW 로그를 뽑아 시퀀스 확정
    (가장 정확. 새로운/복잡한 플로우면 추천)

[b] 텍스트 입력 — 플로우를 말로 적기
    예: "쇼핑홈 > PDP > 장바구니 > 주문 결제"
    (빠름. 잘 아는 표준 플로우면 추천)

어느 걸로 갈까? (a / b)
```

`[b]` 텍스트 입력이 매핑이 자꾸 막히면 스킬이 알아서 `[a]` 라이브로 fallback 제안합니다.

플로우 분석 결과:
- **각 page_id 마다 HTML 1개씩** 생성 (`./screens/shoppinghome.html`, `./screens/pdp.html`, `./screens/cart.html`, ...)
- 모든 HTML 최상단에 동일한 **flow header section** inject — 현재 위치 강조 + 다른 page 클릭하면 그 HTML로 이동
- element 차트의 **trigger element 막대** (예: cart_button) 클릭하면 다음 page (CART) HTML로 이동
- 첫 entry page HTML 1개만 자동 새 창. 다른 페이지는 거기서 클릭으로 이동.

---

## 📦 산출물

스킬을 호출한 디렉토리 아래에 생깁니다:

```
{호출한 디렉토리}/
├── screens/                              ← per-page HTML (single + flow 둘 다)
│   ├── pdp.html                          ← 인터랙티브 (date picker, Figma mapper, 차트)
│   ├── pdp.md                            ← MD 정본
│   ├── cart.html
│   └── ...
└── flows/                                ← flow scope에서만 생성
    └── {flow_name}.md                    ← 플로우 정의 + funnel 결과
```

작업 폴더 하나 만들어두고 거기서 호출하는 걸 추천:
```bash
mkdir -p ~/data-insight && cd ~/data-insight
# 그 다음 funnel-check 호출
```

---

## 🎨 HTML 안에 뭐가 들어있나요?

per-page HTML 1개 안에:

- **(flow scope만) Flow header** — 전체 플로우 funnel 시각화. 다른 page 노드 클릭하면 그 page HTML로 이동
- **Date picker** — 기간 바꿔서 갱신 명령 클립보드 복사
- **Page Health** — PV UV / 스크롤률 / 평균 체류시간 (통합 + ANDROID/IOS)
- **Element 인벤토리** — 명세 ∩ 로그 / 명세 only / 로그 only 분류
- **Element CTR 메인 차트** — 통합(ALL) 기준, 강조색. ANDROID/IOS 토글 가능
- **사용도 낮은 element 표** — 통합 click/PV 정렬
- **Figma Mapper** — Figma 화면 URL 붙여넣고 element 라벨 드래그 매핑 (DA 산출물 같은 거 본인이 직접 만들 수 있음)
- **실행된 쿼리** — 접기/펼치기

**외부 CDN 의존 0**. 사내망/CDN 차단 환경에서도 동작합니다.

---

## ⚠️ 사전 요구사항

스킬이 동작하려면 다음이 필요합니다:

- **Claude Code** 설치
- **athena mcp** (`mcp__ohouse-athena-mcp__execute_athena_query`) — `~/.claude/.mcp.json` 에 사내 표준 설정
- **log-center mcp** (`mcp__log-center-mcp__get_page_spec` 등) — 사내 표준 설정
- **오늘의집 Athena 권한** — `log.analyst_log_table` SELECT
- 사내망 접근 시 VPN

설정 방법은 사내 표준 MCP 설정 가이드 참고. 의존 스킬 (`log-explore`, `log-query`, `log-spec`) 은 zip 안에 같이 들어있어서 자동 설치됩니다.

---

## 🛠 트러블슈팅

| 증상 | 원인 / 해결 |
|------|-------------|
| `tool not found: execute_athena_query` | `~/.claude/.mcp.json` 에 athena mcp 설정 확인 → Claude Code 재시작 |
| `permission denied` | Athena `log.analyst_log_table` SELECT 권한 신청 필요 |
| 스킬이 자동 발동 안됨 | `~/.claude/CLAUDE.md` 의 Skills 섹션에 4개 스킬 path 등록됐는지 확인. 또는 `/funnel-check`로 슬래시 호출 |
| HTML 차트가 깨져 보임 | v1.5부터 외부 CDN 의존 0이라 발생 안 함. 만약 그래도 깨지면 슬랙 #team-product-design 으로 알려주세요 |
| 결과가 의심스러움 | HTML/MD 안에 실행된 쿼리 전문이 같이 저장돼 있어요. redash에 그대로 붙여서 검증 가능 |

---

## 📚 더 알아보기

- **상세 워크플로우 / 디자인 의도 / 결정 로그**: [funnel-check-spec.md](https://github.com/Ohouse-product-design/AI-Workflow/blob/main/%5BYH%5D%20Data-insight/funnel-check-spec.md)
- **스킬 본체 (frontmatter + 본문)**: [Ohouse-product-design/AI-Skill](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check)
- **최신 버전**: v1.5 (2026-04-11)

---

## 💬 문의 / 피드백

- 슬랙: `#team-product-design` 또는 yohan에게 DM
- 이메일: yohan.lee@bucketplace.net
- 이슈: [Ohouse-product-design/AI-Skill/issues](https://github.com/Ohouse-product-design/AI-Skill/issues)

피드백 주면 빠르게 반영합니다 — 이번에 ~30턴 → 4~5턴 축소도 사용자 피드백 한 번에서 나왔어요.

---

만든 사람: yohan.lee@bucketplace.net
