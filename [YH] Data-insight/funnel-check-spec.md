# funnel-check 스킬 관리 문서

> 이 문서는 `/funnel-check` 스킬의 **설계 의도와 히스토리**를 관리한다. 스킬 파일 자체는 런타임 지시문(how)이고, 이 문서는 그 배경(why)이다. 스킬을 수정하기 전에 이 문서부터 읽어라.

## 개요

| 항목 | 내용 |
|------|------|
| 팀 공용 스킬 | `~/claude-skills/skills/funnel-check/SKILL.md` (frontmatter 포함, [Ohouse-product-design/AI-Skill](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check)) |
| 개인 슬래시 커맨드 | `~/.claude/commands/funnel-check.md` (yohan 로컬용) |
| 호출 | 자동 발동 ("이 화면 사용도 분석") 또는 `/funnel-check [...]` |
| 목적 | PD가 PO와 차별화된 데이터 인사이트로 화면에 "넣기만" 하지 않고 사용도 낮은 element를 **뺄 수** 있게 돕는 측정 만능 스킬 |
| 버전 | **v1.2.1** (Step -1 환경 점검 + 팀 패키지화) |
| 최초 작성 | 2026-04-10 |
| 마지막 갱신 | 2026-04-10 |

## 왜 만들었나 (문제 정의)

### 기존 방식의 문제
기존에 athena mcp로 "X 화면 분석해줘"라고 요청하면 매번 다른 결과가 나왔다. 원인은:

1. **page_id 해석의 모호함** — "상품 상세"라는 말이 PDP인지 PDP_STYLINGSHOT인지, 관련 모든 PDP_*인지 요청자마다 다르게 해석
2. **분석 단위/시작점의 자의적 선정** — "어디서부터 어디까지가 전환"인지, "어떤 element가 분석 대상인지"가 쿼리 작성자 판단에 달림
3. **object 필터의 부정확** — element를 `object_section_id` / `object_type` 어떻게 잡을지가 매번 달라짐

데이터는 정확성이 생명이고, 정확성이 흔들리면 분석 결과가 설득력을 잃는다. PD가 PO와의 토론에서 데이터로 의견을 제시하려면 그 데이터 자체가 흔들림 없어야 한다.

### 해결 방향
1. AI가 추측으로 쿼리를 짜지 말고 **사용자가 직접 폰으로 걸어본 로그** 또는 **로그센터 명세 ↔ 실로그 교차검증**을 정답지로 삼는다.
2. **자동 실행하지 않는다.** 한 단계씩 물어가며 사용자와 함께 정답을 만든다.
3. 측정의 단위(unit of analysis)에 따라 **mode를 분기**하지만, 위 두 원칙은 모든 mode에 공통.

## Mode 개념

| Mode | 핵심 질문 | 단위 | 산출물 폴더 | 상태 |
|------|----------|------|-------------|------|
| **flow** | 이 플로우의 어디서 떨어지나? | 페이지 시퀀스 | `./flows/` | v1 완료 |
| **audit** | 이 화면의 어떤 element가 안 쓰이나? | 단일 페이지 | `./screens/` | **v1.2 신규** |
| peer-compare (장기) | 같은 카테고리의 다른 화면 대비 우리는? | 페이지 그룹 | 미정 | v2 후보 |
| trend (장기) | 이 element/플로우의 시간 변화는? | 시계열 | 미정 | v2 후보 |

## 핵심 원칙 (mode 무관 공통)

1. **자동 실행 금지.** 각 단계는 사용자 확정 후에만 다음으로 진행.
2. **자의적 추론 금지.** 페이지 연결, element 분류, 카테고리 — 모두 사용자 확정 필요. AI는 후보만 제시.
3. **쿼리는 전문을 보여주고 승인 후 실행.** 쿼리가 정답지이므로 사람 눈으로 검증 가능해야 한다.
4. **명세 교차검증.** `get_page_spec`이 있는 page_id는 항상 명세와 실로그를 같이 본다.
5. **MD가 정본, HTML 매번 재생성.** 모든 산출물의 정본은 MD, HTML은 보조 시각화.
6. **세그먼트(신규/활성/부활)는 MVP에서 제외.** v2에서 BA팀 표준 마트 기반 추가 예정.

## 워크플로우 요약

### Step 0: Mode 추론 (모든 호출 공통)
자연어/플래그에서 mode 결정. 모호하면 사용자에게 확인.

### Mode A: Flow

| Step | 작업 | 결과물 |
|------|------|--------|
| 0-A | 기존 Flow Definition 확인 | `./flows/{플로우명}.md` |
| 1-A | 맥락 수집 (도메인, 전환 목표, 측정 기간) | MD §1 |
| 2-A | 내 로그 그라운딩 → 정규화 → 사용자 확정 | MD §2 |
| 3-A | CLICK 추출 + `get_page_spec` 교차검증 + Flow Definition | MD §3 |
| 4-A | 느슨한 퍼널 쿼리 승인/실행 | MD §4 |
| 5-A | HTML 시각화 (퍼널 카드 + 플로우차트) | `.html` |

### Mode B: Audit

| Step | 작업 | 결과물 |
|------|------|--------|
| 0-B | 기존 audit 정의 확인 | `./screens/{화면명}.md` |
| 1-B | 맥락 수집 (분석 목적, 측정 기간) | MD §1 |
| 2-B | page_id 확정 (Hybrid: 명확하면 바로, 모호하면 그라운딩 fallback) | MD §2 |
| 3-B | Element 인벤토리 (명세 ∩ 로그 / 명세 only / 로그 only 대조) | MD §3 |
| 4-B | Element CTR + Page Health 두 쿼리 승인/실행 | MD §4 |
| 5-B | 인터랙티브 HTML (막대 차트 + Figma mapper) | `.html` |

## 사용 도구

| 도구 | flow | audit | 용도 |
|------|:-:|:-:|------|
| `execute_athena_query` | ✅ | ✅ | 로그 추출 + 측정 쿼리 |
| `get_page_spec` | ✅ | ✅ | 명세 ↔ 실로그 교차검증 |
| `get_log_spec_by_id` | 필요시 | 필요시 | 개별 spec 조회 |
| Recharts (CDN) | ✅ | ✅ | HTML 차트 |
| Figma embed iframe | ❌ | ✅ | audit mode 인터랙티브 매핑 |
| localStorage | ❌ | ✅ | audit Figma mapping 영속화 |

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

### 산출물 (스킬 호출 시 호출 디렉토리에 생성)

```
./flows/                              ← flow mode 산출물
  ├── {플로우명}.md
  └── {플로우명}.html

./screens/                            ← audit mode 산출물 (v1.2 신규)
  ├── {화면명}.md
  ├── {화면명}.html                   ← 인터랙티브 (Figma mapper 포함)
  └── {화면명}-mapping-{YYYYMMDD}.json ← Figma 매핑 export
```

## 이름 규칙

### Flow mode
형식: `{domain}-{from_page}-to-{to_page}[-{variant}]`
- 예: `commerce-pdp-to-cart`, `content-clp_project-to-cdp_project`

### Audit mode
형식: `{domain}-{page_id}[-{variant}]`
- 예: `commerce-pdp`, `commerce-pdp-202604-renewal`, `content-cdp_project`

공통:
- kebab-case, 소문자
- `{domain}`: `commerce` / `content` / `o2o` / `common`
- page_id 내부 underscore 유지
- variant는 같은 대상의 다른 시점/조건 비교가 있을 때만

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

### 2026-04-10 v1.2 audit mode 추가

**⑨ 새 mode 추가 vs 별도 스킬 분리: 확장 선택**
- 대안 A: screen-audit이라는 별도 스킬을 자매로 추가
- 대안 B: funnel-check 안에 audit mode를 추가 (Mode 분기)
- 결정: B. 사용자 의사("funnel-check 확장"). 한 곳에 모든 측정 use case를 모아두는 것이 PD가 도구를 학습하기에 단순하고, 산출물 폴더 분리만으로도 unit of analysis는 명확히 구분됨.

**⑩ Audit mode 그라운딩: Hybrid (page_id 우선, 모호하면 내 로그)**
- 대안 A: flow mode와 동일하게 항상 그라운딩 (정확하지만 느림)
- 대안 B: page_id만 받고 바로 분석 (빠르지만 식별 모호성)
- 결정: Hybrid. 사용자가 page_id 명확히 알면 그대로, 화면명만 알고 page_id 변형이 많으면(PDP/PDP_STYLINGSHOT/...) 후보 제시 → 모르겠다고 하면 flow mode의 그라운딩 메커니즘 호출.

**⑪ Audit 인벤토리: 명세 ∩ 로그 / 명세 only / 로그 only 3분류**
- 핵심 통찰: "디자인은 했는데 안 클릭됨"이 가장 강력한 제거 후보
- `get_page_spec` 결과와 athena 실로그를 set 연산으로 대조
- 각 분류는 사용자 확인 후 확정. AI가 자동으로 "이건 빼" 하지 않음.

**⑫ Audit 시각화: 막대 차트 + 인터랙티브 Figma Mapper**
- 영감: DA 분의 산출물 — 화면 스크린샷에 element별 CTR을 직접 overlay (예: 글쓰기 버튼 0.15%/0.18%, 마이페이지 12.26%/26.22%)
- v1.2 구현: 기본 막대 차트 + 표 + 별도 섹션에 Figma URL 입력란. 사용자가 URL 붙여넣으면 iframe embed + draggable label chip을 화면 위로 끌어다 매핑. localStorage에 위치 영속화 + JSON export.
- v2 비전: Figma MCP로 element 좌표 자동 추출 → 매핑 자동화
- 제약: Figma iframe은 cross-origin이므로 iframe 내부 인터랙션은 못 가로챔. label overlay는 iframe **위에** 별도 div로 배치, overlay 위 클릭/드래그만 처리.

**⑬ Audit 플랫폼 분리: ANDROID vs IOS 항상 분리**
- 영감: DA 산출물에서 마이페이지 진입률 ANDROID 12% vs IOS 26% 같은 결정적 차이 발견
- 결정: audit mode의 모든 쿼리는 `GROUP BY platform` 기본. HTML도 두 컬럼으로 나란히. 합계가 필요한 경우는 사용자가 별도 요청.

**⑭ Audit Page Health Metric 동봉: 스크롤률 + 평균 체류시간**
- element CTR만 보면 페이지 단위의 engagement를 놓침. 같이 봐야 "이 화면 자체가 안 쓰이는지, 아니면 화면은 진입하는데 element가 안 쓰이는지" 구분 가능.
- SCROLL 카테고리가 명세에 있으면 scroll_rate, 없으면 dwell time만.
- 별도 쿼리로 분리해서 element 쿼리와 독립 실행 (실패 시 부분 결과라도 확보).

**⑮ ut-prototype-dist 데이터 풀 reference**
- `/Users/yohan.lee/Downloads/ut-prototype-dist/data/data.js`에 실제 product/content/user 샘플 ID가 정적 JS로 보관됨
- audit mode가 특정 product_id 기반 분석이 필요한 경우 보조 그라운딩 소스로 활용 가능
- 메모리: `ut_prototype_data_reference.md`

### 2026-04-10 v1.2.1 환경 점검 + 팀 패키지화

**⑯ Step -1 환경 점검 추가 (의존성 누락 시 친절한 안내)**
- 동기: 동료가 처음 받아 쓸 때 막연한 "tool not found" 에러 대신 명확한 설치 안내가 필요
- 동작: 스킬 호출 직후 자동으로 의존 스킬(log-explore/query/spec)을 Glob으로 확인하고 빠진 게 있으면 두 가지 설치 방법(CLAUDE.md skill path / 슬래시 커맨드)을 보여줌
- MCP는 사전 검사 없이 실제 호출 시점에 시도하고, 실패하면 친절 메시지로 변환

**⑰ 팀 패키지화: Ohouse-product-design/AI-Skill 레포에 등록**
- 동기: 동료가 funnel-check을 쓰려면 funnel-check.md + log-* 3개 + MCP 설정이 모두 필요한데, 이 4개 스킬을 한 번에 받을 수 있어야 함
- 결정: AI-Skill 레포의 기존 컨벤션(`skills/{name}/SKILL.md` + `cursor.yaml`)을 따름. yohan 개인 슬래시 커맨드 형식과는 별도로, 팀 공용 사본은 frontmatter를 추가해 자동 발동도 지원
- 두 설치 방식:
  - 옵션 1 (권장): CLAUDE.md skill path 등록 → 자연어로 자동 발동
  - 옵션 2: `~/.claude/commands/`에 복사 → 슬래시 커맨드 호출
- frontmatter description은 description matching의 정확도를 위해 트리거 키워드를 명시
- yohan WIP는 `[YH] Data-insight/funnel-check/`, 안정화 후 `skills/funnel-check/`로 promotion

**⑱ Path 컨벤션 통일: `~/claude-skills` (AI-Skill 레포 README와 일치)**
- AI-Skill 레포 README가 clone을 `~/claude-skills`로 권장함
- funnel-check Step -1의 설치 안내도 같은 path를 사용하도록 통일
- 실제 yohan 로컬 clone은 `/Users/yohan.lee/Desktop/Claude_Study/AI-Skill`이지만, 동료에게 안내하는 권장 path는 `~/claude-skills`

## 알려진 제한 / 미해결 질문

- **세그먼트 미지원**: v2에서 해결 예정. 선결 과제는 `ba_preserved.user_seg_rfd_v2` 스키마 확인.
- **Figma mapping은 수동 좌표**: 사용자가 눈으로 보고 드래그. v2에서 Figma MCP로 자동 좌표 매핑 목표.
- **Figma iframe cross-origin**: iframe 내부 클릭은 우리가 못 잡음. label overlay는 iframe 위 별도 레이어. 라벨이 iframe 클릭을 가리지 않도록 pointer-events 관리 필요.
- **SCROLL 카테고리 존재 여부 미검증**: 명세에 SCROLL이 없는 page_id가 다수일 가능성. audit mode가 런타임에 `log-explore`로 검증하고 없으면 dwell time만 fallback.
- **HTML 재생성 방식**: 매번 전체 재작성. 플로우/element가 많아지면 느려질 수 있음. 성능 이슈 발생 시 섹션별 부분 갱신.
- **다중 플로우/화면 비교 미지원**: 한 호출에 한 대상. v2 후보.
- **시간대 처리**: 사용자가 말하는 "오후 2시쯤"이 KST인지 UTC인지 모호. 스킬이 KST로 가정하고 변환 필요.
- **"내 로그"를 못 찾는 케이스**: 사용자가 시각을 잘못 기억하면 그라운딩 실패. 폴백 플로우 없음.
- **localStorage 격리**: audit HTML을 다른 환경(다른 PC)에서 열면 매핑이 보이지 않음. JSON export로 회피하지만 사용자 작업 필요.

## 로드맵

### v2 후보 (우선순위 순)

1. **세그먼트 지원**
   - 선결 과제: `ba_preserved.user_seg_rfd_v2` 스키마 확인
   - 스키마에 라벨 컬럼 있으면: 런타임 LEFT JOIN
   - 없으면: BA팀과 정의 합의 후 임계값 상수화

2. **Figma MCP 자동 좌표 매핑 (audit mode)**
   - 현재 v1.2는 사용자 수동 드래그
   - Figma MCP로 frame의 child element 좌표를 자동 추출
   - object_section_id ↔ Figma layer name 매핑 규칙 필요 (DS팀과 협의)

3. **peer-compare mode**
   - 같은 카테고리의 다른 화면 평균과 비교
   - 예: "PDP의 cart_button click_per_pv가 같은 커머스 detail page들의 평균보다 낮음"

4. **trend mode**
   - 시계열 변화 추적
   - 리뉴얼 전후 비교 (audit/flow 결과의 시점 간 diff)

5. **다중 비교 (cross-mode)**
   - audit 결과와 flow 결과를 한 HTML에 묶어보기
   - "이 화면의 element 사용도 + 이 화면을 거치는 플로우 전환률"

6. **세션 후보 선택 기능**
   - 사용자가 테스트 시각 모를 때, 최근 N일치 세션 요약 보여주고 고르기

7. **엄격 퍼널 명시적 옵션화**
   - 호출 시점에 `--strict` 플래그로 받기

### 유지보수 체크포인트

- **분기마다**: 실제로 몇 번 썼는지, 어디서 막혔는지 돌아보기
- **로그 스키마 변경 시**: `log.analyst_log_table` 스키마 변경이나 새 enum 추가 시 쿼리 템플릿 갱신
- **log-query 스킬 변경 시**: funnel-check는 log-query의 규칙(파티션, 필터)을 승계하므로 상호 체크
- **Figma embed URL 형식 변경**: Figma가 embed URL 스펙을 바꾸면 audit Step 5-B-2 코드 갱신
- **DA 산출물 형식 변화**: 영감의 원천이 더 발전하면 여기 align (예: heat map, click distribution 등)

## 변경 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|----------|
| 2026-04-10 | v1 | 최초 스킬 작성 (MVP: 세그먼트 제외, flow mode only) |
| 2026-04-10 | v1.1 | 플로우명 규칙 추가 (`{domain}-{from}-to-{to}`) |
| 2026-04-10 | v1.2 | **audit mode 추가**. Mode 개념 도입, 화면 단위 element 사용도 분석, ANDROID/IOS 분리, page health metric, 인터랙티브 Figma mapper, `./screens/` 산출물 폴더 |
| 2026-04-10 | v1.2.1 | **Step -1 환경 점검 + 팀 패키지화**. 의존 스킬(log-*) 자동 감지 및 설치 안내. Ohouse-product-design/AI-Skill 레포에 frontmatter 포함 SKILL.md + cursor.yaml + README.md 형태로 등록. 두 설치 방식(CLAUDE.md skill path / 슬래시 커맨드) 지원. clone path 컨벤션을 `~/claude-skills`로 통일 |
