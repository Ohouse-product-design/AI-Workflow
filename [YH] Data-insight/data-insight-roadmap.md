# Data-insight 스킬군 로드맵

> 프로덕트 디자이너가 PO와 차별화된 데이터 인사이트로 화면에 "넣기만" 하지 않고 "뺄 수" 있게 만드는 도구 군의 큰 그림.

## 미션

오늘의집 PD가 디자인 결정을 할 때, 화면에 무언가를 추가하는 것만큼 **빼는 결정**도 데이터로 정당화할 수 있어야 한다. 클릭률이 낮은 버튼, 사용도 낮은 모듈을 식별하고 제거 후보로 올리는 것은 PO의 기능 추가 본능과 균형을 맞추는 PD의 핵심 역할이다.

이 미션은 [ai-workflow.md](/Users/yohan.lee/Desktop/Claude_Study/AI-Workflow/[YH]Loadmap/ai-workflow.md) #13 "Data-insight" 과업(P1 Quick Win)에 속한다. 한줄 정의는 "자연어로 핵심 지표 즉시 조회"이고, 그 안에 PD 특화의 use case들을 채워 넣는 것이 이 스킬군의 역할이다.

## 핵심 원칙 (모든 data-insight 스킬 공통)

1. **정확성이 설득력**. 데이터가 흔들리면 결정도 흔들린다. AI가 추측해서 채우는 영역을 최소화한다.
2. **사용자가 정답지를 확정**. 자동 추론이 닿는 곳까지만 자동으로 하고, 그 이상은 사용자에게 물어본다.
3. **MD 정본 + HTML 보조 시각화**. 결과는 항상 MD에 기록되고 HTML은 매번 재생성된다.
4. **mode 분기로 unit of analysis 분리**. 같은 스킬 안에서도 측정 단위가 다르면 mode를 나눈다.
5. **PD 친화적 출력**. 결과는 디자이너가 화면 공간감각으로 이해할 수 있어야 한다 (단순 표/숫자보다 시각적 매핑).

## 스킬 구성

### 1. funnel-check (현재, 측정 만능 스킬)

데이터 측정의 모든 use case가 모이는 지점. mode로 분기.

| Mode | 질문 | 단위 | 상태 |
|------|------|------|------|
| **flow** | 이 플로우의 어디서 떨어지나? | 페이지 시퀀스 | ✅ v1 완료 |
| **audit** | 이 화면의 어떤 element가 안 쓰이나? | 단일 페이지 | ✅ **v1.2 신규** |
| peer-compare | 같은 카테고리 다른 화면 대비 우리는? | 페이지 vs 페이지 그룹 | 📋 v2 후보 |
| trend | 이 element/플로우의 시간 변화는? | 시계열 | 📋 v2 후보 |

상세 설계: [funnel-check-spec.md](funnel-check-spec.md)

**위치:**
- 팀 공용 (안정): [Ohouse-product-design/AI-Skill `skills/funnel-check/`](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/funnel-check)
- yohan WIP: [Ohouse-product-design/AI-Skill `[YH] Data-insight/funnel-check/`](https://github.com/Ohouse-product-design/AI-Skill/tree/main/%5BYH%5D%20Data-insight/funnel-check)
- yohan 개인 슬래시 커맨드: `~/.claude/commands/funnel-check.md` (로컬)

**의존 인프라 (같은 레포 `skills/`):**
[log-explore](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/log-explore) / [log-query](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/log-query) / [log-spec](https://github.com/Ohouse-product-design/AI-Skill/tree/main/skills/log-spec)

### 2. insight-archive (계획, [ai-workflow.md](/Users/yohan.lee/Desktop/Claude_Study/AI-Workflow/[YH]Loadmap/ai-workflow.md) #15)

funnel-check이 만든 모든 산출물(`./flows/`, `./screens/`)을 인덱싱하고 자연어로 검색.

**역할:**
- 과거 측정 결과의 검색/회상
- 같은 화면을 여러 번 분석한 이력 추적
- 팀 단위 인사이트 공유 (다른 PD가 분석한 화면 참고)

**예시 호출:**
- "예전에 PDP 관련 분석한 거 있어?"
- "리뉴얼 전 cart_button CTR이 얼마였지?"
- "지난 분기에 가장 사용도 낮은 버튼 top 5는?"

**상태:** 미착수. funnel-check이 어느 정도 사용 데이터를 쌓은 후 착수.

### 3. data-insight-onboard (제안, 신규)

PD가 처음 데이터 측정을 시작할 때 "어떤 질문을 던질지" 가이드하고, 적절한 funnel-check mode로 라우팅.

**역할:**
- 막연히 "데이터 보고 싶어"인 PD에게 구체 질문 셋을 제시
- 질문 ↔ funnel-check mode 매핑 안내
- 측정 결과를 디자인 결정으로 어떻게 연결할지 가이드

**예시 흐름:**
```
사용자: "내 화면 데이터 보고싶어"
스킬: 
  "어떤 종류로 시작할까?
  [a] 전환 경로 분석 → /funnel-check flow
  [b] 화면 element 사용도 → /funnel-check audit
  [c] 페이지별 진입/이탈 추이 → (v2 trend mode)
  [d] 다른 비슷한 화면과 비교 → (v2 peer-compare mode)
  
  처음이라면 (b)부터 추천해. 가장 즉시 결정에 도움 됨."
```

**상태:** 제안. funnel-check audit mode가 안정화된 후 검토.

## 미션 매핑

각 스킬/mode가 미션의 어느 부분을 담당하는가:

| 미션 | 담당 |
|------|------|
| 화면에서 사용도 낮은 element를 식별 | funnel-check audit mode |
| 어떤 element가 다른 화면 대비 약한가 | (v2) funnel-check peer-compare mode |
| 플로우의 어디서 사용자가 떨어지나 | funnel-check flow mode |
| 리뉴얼 전후 효과 측정 | (v2) funnel-check trend mode |
| 과거 측정 인사이트 검색 | (계획) insight-archive |
| 어떤 질문부터 던져야 할지 가이드 | (제안) data-insight-onboard |

## 영감 / 레퍼런스

### DA 분의 annotated screenshot
오늘의집 DA가 만든 홈 화면 분석 산출물 — 화면 스크린샷 위에 element별 click rate를 직접 overlay. 카테고리별 색 분류, ANDROID vs IOS 분리, 페이지 단위 스크롤률까지 포함. funnel-check audit mode의 시각화 north star.

핵심 발견 예시 (영감 자료에서):
- 글쓰기 버튼 ANDROID 0.15% / IOS 0.18% — 거의 안 쓰임 → 명백한 제거 검토
- 마이페이지 진입률 ANDROID 12.26% / IOS 26.22% — 플랫폼 격차가 큼 → IA 검토
- 가드닝 게임 22.39% / 12.71% — 의외로 높은 사용도

### 외부 사례
- **omtm_review_260302** (datapl): 다크모드 + Recharts + 퍼널 카드 — funnel-check HTML 톤의 기준
- **product_attribute_coverage** (owen_test): KPI 카드 레이아웃 보조 참고

### 기존 사내 자산
- **ut-prototype-dist** ([reference](../../../../.claude/projects/-Users-yohan-lee-Desktop-Claude-Study-AI-Workflow/memory/ut_prototype_data_reference.md)): 실제 product/content/user 샘플 ID. audit mode가 특정 ID 기반 분석할 때 보조 그라운딩 소스.
- **log-explore / log-query / log-spec** 스킬: funnel-check의 토대 도구. 모든 쿼리 규칙, page_id 매핑, 명세 조회를 이 스킬들에서 승계.

## 우선순위

### 즉시 (~1주)
- ✅ funnel-check v1.2 audit mode 작성 완료
- ✅ funnel-check v1.2.1 Step -1 환경 점검 추가
- ✅ Ohouse-product-design/AI-Skill 레포에 4개 스킬(funnel-check + log-*) 패키지화 등록
- 🔄 실제 화면(예: HOME, PDP)으로 audit mode end-to-end 테스트 (yohan 진행)
- 🔄 동료 1명 베타 테스트 (옵션 1 자동 발동 방식)
- 🔄 결과 보고 스킬 보완 (막힘 발견 시)

### 단기 (1~2개월)
- BA팀 협의: `ba_preserved.user_seg_rfd_v2` 스키마 확인 → 세그먼트 v2 설계 시작
- DS팀 협의: Figma layer name ↔ object_section_id 매핑 규칙 정립 → audit Figma MCP 자동화 가능 여부 평가
- audit mode v1.2 실제 사용 후기 수집 → v1.3 개선

### 중기 (2~4개월)
- funnel-check peer-compare mode (v2)
- insight-archive 스킬 착수 — funnel-check 산출물이 어느 정도 쌓인 후
- data-insight-onboard 스킬 (선택)

### 장기 (4~6개월)
- funnel-check trend mode
- Figma MCP 자동 좌표 매핑 (audit mode 시각화 north star)
- 다중 화면/플로우 cross-comparison

## 알려진 제약 (스킬군 전체)

- **세그먼트 미지원**: 신규/활성/부활 분리 분석 불가. 전사 표준 정의 부재가 원인. v2에서 BA팀 마트 활용으로 해결.
- **PD 개인 환경 의존**: HTML 매핑 데이터가 localStorage에 저장되므로 다른 PC에서 열면 매핑 안 보임. JSON export로 회피.
- **자동 좌표 추출 미지원**: audit mode Figma mapping은 v1.2에서 사용자 수동 드래그. v2에서 Figma MCP 자동화 목표.
- **시간대 처리 모호**: 사용자 시각 입력이 KST/UTC 모호. 스킬이 KST 가정 후 변환.

## 책임 / 오너

- 스킬 설계/유지보수: Yohan (PD Lead)
- v2 세그먼트 협의: BA팀 (Sophie Cho 또는 `ba_preserved` 오너)
- v2 Figma MCP 협의: DS팀 (Tyler 또는 ODS 오너)
- 사용 사례 피드백: 오늘의집 PD 전체

## 변경 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-04-10 | 최초 작성. funnel-check v1.2 audit mode 추가에 맞춰 스킬군 큰 그림 정립 |
| 2026-04-10 | funnel-check v1.2.1 + 팀 패키지화 반영. AI-Skill 레포에 4개 스킬(funnel-check + log-*) 등록. 스킬 위치/링크 갱신 |
