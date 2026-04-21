# 오늘의집 PD AI Workflow Map v3

> 4단계(Discovery → Design → Review → Handoff) + Platform Layer, 총 16과업.
> 이해관계자가 한눈에 스캔 가능한 구조로 재정비.
> 마지막 업데이트: 2026-04-21

---

## 우선순위 기준
- **P0** — 핵심 인프라 / 킬러 기능. 즉시 시작
- **P1** — 높은 임팩트. P0와 병행 가능
- **P2** — 중기. 핵심 과업 안정화 후 확장
- **Quick Win** — 1~2주 내 즉시 산출 가능한 가속 과업

## 실행 로드맵
- Month 1: Quick Win (Insight-archive, Design-critique, Team-toolkit)
- Month 1~2: 핵심 인프라 (Design-pattern-library, DESIGN.md, Complete-handoff-doc)
- Month 2~3: 킬러 기능 (DS-prototype, State-edge-simulator, HTML-to-Figma-refiner, Design-QA)
- Month 3~6: P2 확장 (UX-writing, Responsive-support)

---

## Phase 1: Discovery & 가설

### [그룹] Problem framing

#### 1. Initiative-prioritizer `P0`
**한줄 정의**: 이니셔티브 우선순위 스코어링 테이블 산출
**문제 심각도**: ★★★★★ (5/5)
- PD가 '무엇을 할지'를 직관/선착순으로 결정 → 임팩트 낮은 이니셔티브가 라인업 차지
- 예상 임팩트를 수치화하지 않고 착수 → 분기 회고 시 비교 어려움
- 과거 유사 이니셔티브의 결과가 기억에만 의존

**솔루션 설계**
- v1: 이니셔티브 리스트 입력 → 임팩트/노력/리스크 스코어 + 우선순위 테이블 자동 생성
- v2: Insight-archive와 연계하여 과거 유사 이니셔티브의 실제 지표 자동 참조

**만드는 방법**
1. 스코어링 기준 정의 (임팩트=타깃 지표/영향 규모, 노력=공수, 리스크=의존성/불확실성)
2. Skill 프롬프트 작성 (이니셔티브 리스트 → 표 산출)
3. 샘플 이니셔티브 10건으로 파일럿
4. Insight-archive MCP 연동 (유사 사례 자동 조회)
5. 분기 플래닝에 정식 도입

**해외 사례**: RICE / ICE 스코어링 프레임워크

**성공 지표**
- 라인업 결정 회의 시간 단축
- 분기 회고 시 '왜 이걸 했는지' 근거가 항상 남음

**선행 조건**: 스코어링 기준 합의

---

#### 2. Hypothesis-builder `P0`
**한줄 정의**: 기능 컨텍스트 → 가설 + 목표 지표 초안
**문제 심각도**: ★★★★☆ (4/5)
- '이 기능을 왜 만드는가'가 문서 없이 구두로만 공유됨
- 성공 지표가 착수 후에 급조되어 검증이 애매함
- PO 사이클에 의존해 PD 단독 의사결정 어려움

**솔루션 설계**
- v1: 기능 컨텍스트 입력 → 가설 문장(If/Then) + 타깃 지표 초안 생성
- v2: Data-interpreter와 연계해 기존 지표 베이스라인 자동 첨부

**만드는 방법**
1. 가설 템플릿(If/Then/Because) 정의
2. 지표 가이드 문서 작성 (핵심/보조/가드레일)
3. Skill 프롬프트 작성
4. 파일럿 3건
5. 팀 프로세스에 통합

**해외 사례**: o2o-pd-ai-workflow-map의 Hypothesis-builder

**성공 지표**: 모든 이니셔티브에 문서화된 가설 존재, 성공 지표를 착수 전에 정의
**선행 조건**: 지표 가이드 문서

---

#### 3. Data-interpreter `P1`
**한줄 정의**: Redash/Athena 수치 → 해석 + 다음 액션 제안
**문제 심각도**: ★★★☆☆ (3/5)
- 지표 변화의 원인 해석에 DA 의존
- 수치만 보고는 '그래서 무엇을 할지'가 안 나옴
- 비교 대상/기간/세그먼트 선택이 비일관

**솔루션 설계**
- v1: 수치 + 컨텍스트 붙여넣기 → 해석 + 다음 액션 제안
- v2: Athena MCP로 추가 쿼리를 자동 제안·실행

**만드는 방법**
1. 해석 프레임(Trend/Compare/Segment/Anomaly) 정의
2. Skill 프롬프트 작성
3. 실제 지표 리포트 5건으로 파일럿
4. Athena/Redash MCP 연동

**해외 사례**: Athena MCP, Redash MCP

**성공 지표**: DA 의존 없이 1차 해석 가능, 해석 → 액션 연결 비율 상승
**선행 조건**: Athena/Redash MCP 세팅

---

## Phase 2: Design & Prototype

### [그룹 A] Design system 기반 생성

#### 4. DS-prototype `P0`
**한줄 정의**: PRD + ODS → HTML 프로토타입 자동 생성
**문제 심각도**: ★★★★★ (5/5)
- 모든 PD의 핵심 업무. 3~8일 소요
- 잭: "초안보다 결론안", 스텔라: "HTML 다 만들어두고 아이데이션"
- ODS 컴포넌트를 매번 수동으로 찾아 조합

**솔루션 설계**
- v1: Claude Project에 ODS 컨텍스트 세팅 → PRD 입력 → HTML 생성 → Figma 수동 반영
- v2: Figma MCP + Code-to-Canvas로 자동 반영

**만드는 방법**
1. ODS 컴포넌트를 HTML snippet + 사용 규칙 MD로 정리
2. Claude Project 시스템 프롬프트 작성 (ODS 컨텍스트 포함)
3. 실제 PRD 3건으로 파일럿 테스트 (A/B/C안 병렬)
4. 팀원 피드백 → 프롬프트 개선
5. Figma Code-to-Canvas 파이프라인 연결

**해외 사례**: Spotify MCP 서버, Vercel v0, Figma Code Connect

**성공 지표**
- 디자인 초안 시간 50%+ 단축
- PO가 HTML 프로토타입으로 직접 아이데이션 가능

**선행 조건**: ODS 컴포넌트 정비, Design-pattern-library 선행

---

#### 5. UT-prototyping `P1`
**한줄 정의**: 유저 개인화 UT 프로토타입 (HTML 프로토타입 + user id 기반 정보 교체 반영)
**문제 심각도**: ★★★☆☆ (3/5)
- UT 준비에 2~3일 소요, 프로토타입과 유저별 맞춤 상품 및 콘텐츠 셋업 교체가 수작업으로 이뤄짐
- PD: UT를 위한 프로토타이핑 과업을 주기적으로 수행함

**솔루션 설계**
- v1: (스킬1) MCP 최적화 프레임명 교체 · (스킬2) Flow 연결된 피그마 링크 첨부 시 HTML 프로토타입 생성 · (스킬3) user id 첨부 시 맞춤 정보 셋업 교체
- v2: 세 Skill을 결합한 에이전트로 프레임 링크 + user id만 주면 한번에 수행

**만드는 방법**
1. MCP 최적화 프레임명 교체 스킬 제작
2. Flow 연결된 피그마 첨부 시, HTML 프로토타입 생성 스킬 제작
3. user id 첨부 시, 맞춤 정보 셋업 교체
4. 스킬이 결합된 에이전트 생성 (flow 연결 프레임 링크 + user id 제공 시 한 번에 수행)

**해외 사례**: Maze, UserTesting 시나리오 구조

**성공 지표**: UT 준비 시간 50% 이상 단축, UT 실행 빈도 증가
**선행 조건**: 화면 Flow 연결된 프레임 링크 준비 완료 / Figma MCP · Athena MCP 연결 완료

---

### [그룹 B] 상태 검토 & Figma 정제

#### 6. State-edge-simulator `P0`
**한줄 정의**: 상태 누락 탐지 + 엣지 케이스 데이터 자동 생성
**문제 심각도**: ★★★★★ (5/5)
- 공디: "쏟아내는 것은 쉬운데 챙기지 못한 거 챙기는" - 상태 UI 누락과 텍스트 오버플로가 개발/QA 단계에서야 발견됨
- Loading, Empty, Error 상태 빠뜨리고 핸드오프
- 빈 값, 최대 길이, 특수문자 등 엣지 케이스 사전 검증 못함

**솔루션 설계**
- v1: Skill이 화면 컨텍스트 → 필요한 상태 목록 + 엣지 케이스 데이터(빈값/최대길이/특수문자/다국어)를 동시에 생성
- v2: Figma 파일 자동 스캔 → 누락 상태 탐지 + Content Reel로 엣지 데이터 자동 주입

**만드는 방법**
1. 상태 체크리스트(기본 8~10가지) + 엣지 데이터 시나리오 정의
2. 두 기능을 하나의 Skill 프롬프트로 통합
3. Content Reel 연동으로 Figma에 바로 적용
4. 파일럿 3건(핸드오프 직전 화면)으로 검증
5. 팀 표준 프로세스에 통합

**해외 사례**: 기존 Edge-case-simulator + State-verifier 병합 (o2o 워크플로우 레퍼런스)

**성공 지표**
- 상태 누락으로 인한 개발 중 추가 요청 제로화
- 텍스트 관련 QA 이슈 50%+ 감소

**선행 조건**: 상태 체크리스트 및 엣지 데이터 시나리오 정의

---

#### 7. HTML-to-Figma-refiner `P1`
**한줄 정의**: AI HTML 프로토타입 → Figma UI 정제
**문제 심각도**: ★★★★☆ (4/5)
- AI 생성 HTML은 빠르지만 타이포/간격/상태 표현 디테일이 부족
- HTML 결과물은 대략적이고, 핸드오프 원본은 여전히 Figma에 있어야 함
- 디자이너의 최종 판단(타이포 크기, 간격, 컬러 미세 조정)이 반영될 지점이 없음

**솔루션 설계**
- v1: HTML → Figma 변환 Skill + 디자이너가 Figma에서 최종 디테일 다듬기
- v2: Figma MCP 연동으로 HTML 구조를 ODS 컴포넌트 인스턴스로 자동 매핑

**만드는 방법**
1. HTML → Figma 변환 프로세스/Skill 정의
2. ODS 컴포넌트 인스턴스 매핑 가이드 작성
3. 파일럿 3건 (HTML 프로토타입 → Figma 정제)
4. Figma MCP 연동 실험
5. DS-prototype → HTML-to-Figma-refiner 파이프라인 공식화

**해외 사례**: Figma Code Connect, html.to.design

**성공 지표**: HTML → Figma 재작성 시간 감소, 핸드오프 원본 품질 표준화
**선행 조건**: DS-prototype HTML 결과물, ODS Figma 라이브러리

---

## Phase 3: Review & Critique

#### 8. Design-critique `P1` `Quick Win`
**한줄 정의**: AI 다각도 크리틱 자동 제공
**문제 심각도**: ★★★★☆ (4/5)
- 리뷰어 관점 편중, 체크포인트 누락
- 이미 운영 중인 #des_pd_design_critique 기반

**솔루션 설계**
- v1: 기존 봇에 DESIGN.md의 원칙 컨텍스트 추가
- v2: Figma 시안 자동 캡처 + 멀티모달 분석

**만드는 방법**
1. 현재 크리틱 봇 피드백 품질 평가 (10건 샘플링)
2. DESIGN.md 원칙을 크리틱 컨텍스트에 추가
3. 접근성/DS 적용 여부 체크 강화
4. 2주 운영 후 피드백 품질 재평가

**해외 사례**: Nielsen 휴리스틱 평가, AI peer review

**성공 지표**: 리뷰 대기 시간 제거, 체크포인트 누락 방지, 원칙 기반 객관적 피드백으로 전환
**선행 조건**: 기존 크리틱 봇 운영 중

---

## Phase 4: Handoff & QA

#### 9. Complete-handoff-doc `P0`
**한줄 정의**: 정책 스펙 + Figma Dev Mode 통합 핸드오프 문서
**문제 심각도**: ★★★★★ (5/5)
- 셀라: "디자인 handoff보다 정책 handoff가 더 중요"
- 핸드오프 후 "왜 이렇게?" 질문 왕복 5~10회
- 정책 스펙과 디자인 핸드오프 문서가 별도로 관리되어 싱크 안 맞음

**솔루션 설계**
- v1: Skill이 디자인 파일 + 기획 문서를 입력받아 정책 체크리스트 + Figma Dev Mode 스펙이 통합된 단일 문서 생성
- v2: PRD + 디자인 파일 자동 분석 → 누락 항목 자동 탐지 + 개발팀 Confluence 직접 발행

**만드는 방법**
1. 기존 핸드오프 반복 질문 패턴 + 핸드오프 문서 포맷 분석
2. 통합 템플릿 설계 (정책/비즈니스 규칙/엣지 케이스/컴포넌트 스펙/상태 UI)
3. Skill 프롬프트 작성
4. 파일럿 3건으로 검증
5. 개발팀 피드백 반영 및 Figma Dev Mode 연동

**해외 사례**: Figma Dev Mode + Code Connect. 기존 Spec-policy-handoff + Design-handoff-doc 병합

**성공 지표**
- 핸드오프 후 질문 왕복: 5~10회 → 1~2회
- 핸드오프 문서 작성: 2~3h → 30분

**선행 조건**: 정책 문서 구조 정의, Figma Dev Mode 활용 프로세스

---

#### 10. Design-QA `P1`
**한줄 정의**: 디자이너가 Claude Code로 개발 화면 직접 수정 → GitHub 커밋
**문제 심각도**: ★★★★☆ (4/5)
- 디자이너가 CSS/HTML 수정을 개발자에게 요청 → 왕복 비용
- PD의 새로운 역할: 코드에 직접 참여

**솔루션 설계**
- v1: Claude Code로 CSS/HTML 수정 → PR 생성. 개발자가 리뷰 후 머지
- v2: Figma Dev Mode + Claude Code 연동으로 diff 자동 생성

**만드는 방법**
1. GitHub 기본 워크플로우 가이드 작성 (clone, branch, commit, PR)
2. Claude Code 활용 CSS 수정 실습
3. 실제 QA 건 3개로 파일럿
4. 성공 패턴 정리 → 팀 전체 확산

**해외 사례**: Spotify(시니어 엔지니어가 AI 생성 코드만 리뷰)의 디자이너 버전

**성공 지표**: QA 이슈 수정 사이클: 1~2일 → 수시간
**선행 조건**: Claude Code 환경, GitHub 권한

---

#### 11. UX-writing `P2`
**한줄 정의**: 브랜드 가이드 기반 카피 자동 작성 + 맞춤법 검사
- 버튼 텍스트, 에러 메시지, 빈 상태 문구 자동 작성
- v1: /ux-writing Skill 단독 호출 가능
- 선행 조건: 브랜드 가이드, 용어 사전

#### 12. Responsive-support `P2`
**한줄 정의**: DS-prototype HTML에 CSS 미디어쿼리 포함 → 반응형 자동 해결
- DS-prototype HTML 생성 단계에 자동 포함
- v1: 브레이크포인트 가이드 + Figma 플러그인 활용
- 선행 조건: 브레이크포인트 가이드

---

## Platform Layer

#### 13. Design-pattern-library `P0`
**한줄 정의**: 주요 화면 HTML 스냅샷 + ODS 매핑 + 실험/정책 히스토리 피드백 루프
**문제 심각도**: ★★★★★ (5/5)
- 패턴이 디자이너 머릿속에만 존재
- 과거 실험 결과/정책 변경이 Notion/Slack에 흩어져 재사용 불가
- 비디자이너가 프로토타입 단계에서 참조할 기준 부재

**솔루션 설계**
- v1: 주요 화면 HTML 스냅샷 + ODS 컴포넌트 매핑 + 실험 결과/정책 히스토리를 구조화된 리포지토리로 관리 → 패턴 검색 Skill
- v2: DS-prototype과 자동 동기화되어 패턴 업데이트가 양방향 피드백 루프로 순환

**만드는 방법**
1. 주요 화면 10개 선정 → HTML 스냅샷 + 패턴 구조 문서화
2. 각 화면에 ODS 컴포넌트 매핑 정의 (기존 DS-logic-builder 역할 흡수)
3. 실험 결과/정책 변경 히스토리 수집·연결
4. 패턴 검색 Skill 구축 (/pattern)
5. DS-prototype과 연동하여 피드백 루프 폐쇄

**해외 사례**: Spotify DS MCP 서버 사례. 기존 Design-knowledge-playbook + DS-logic-builder 흡수

**성공 지표**
- DS-prototype 품질의 패턴 기반 향상
- 비디자이너의 프로토타입 단계 참여 가능
- 과거 실험/정책 근거를 30초 내 검색

**선행 조건**: 주요 화면 목록 선정, 패턴 구조 정의

---

#### 14. Insight-archive `P1` `Quick Win`
**한줄 정의**: 실시간 쿼리(MCP) + 큐레이션 아카이브 통합 허브
**문제 심각도**: ★★★★☆ (4/5)
- MCP는 준비돼 있고, Insight 아카이브는 Notion/Slack에 흩어져 있음
- 실시간 쿼리와 과거 히스토리가 별도 도구에 존재해 연결 끊김
- 신규 입사자가 도메인 맥락 파악에 수개월 소요

**솔루션 설계**
- v1: /query (자연어 → SQL 실행) + /insight (큐레이션 아카이브 검색)를 하나의 MCP/Skill 허브로 통합
- v2: 자주 쓰는 쿼리·실험 결과를 자동 대시보드로 생성, Notion/Slack 자동 수집

**만드는 방법**
1. Athena/Redash MCP 세팅 확인
2. /query Skill 작성 (자연어 → SQL)
3. 지식 분류 체계 설계 (실험/지표/AI 팁/의사결정 히스토리)
4. 기존 인사이트 큐레이션 → MD/JSON 정리 → /insight Skill 구축
5. 두 Skill을 하나의 허브로 통합 + 월 1회 큐레이션 프로세스 수립

**해외 사례**: Athena MCP, Redash MCP (기존 Data-insight + Insight-archive 병합)

**성공 지표**
- 데이터 조회 시간: 2~4h → 5분 이내
- 도메인 맥락 파악 시간: 수개월 → 1~2주
- DA 의존도 감소

**선행 조건**: Athena/Redash MCP 세팅, 지식 분류 체계 설계

---

#### 15. Team-toolkit `P1`
**한줄 정의**: 스킬 저장소 + MCP 설정 + 온보딩 키트
**문제 심각도**: ★★★★☆ (4/5)
- 각자 만든 스킬이 개인 환경에만 존재
- 신규 입사자 MCP/스킬 세팅에 시간 소요

**솔루션 설계**
- v1: Git repo에 스킬 목록 + .mcp.json 공유 + 온보딩 체크리스트
- v2: /toolkit Skill로 스킬 검색 + 원클릭 설치

**만드는 방법**
1. Git 저장소 구조 설계 (skills/, configs/, onboarding/)
2. 기존 스킬 3~4개를 저장소에 등록
3. .mcp.json 팀 공통 설정 파일 작성
4. 온보딩 체크리스트 MD 작성

**성공 지표**: 스킬 재사용률 향상, 온보딩 환경 세팅 시간 50% 단축
**선행 조건**: Git 저장소 구조 설계

---

#### 16. DESIGN.md `P1`
**한줄 정의**: AI 프로토타이핑 컨텍스트 문서 (디자인 원칙 + 브랜드 톤 + 제약)
**문제 심각도**: ★★★★☆ (4/5)
- LLM이 디자인 원칙을 모른 채 UI 생성 → 시각적 위계/타이포/인터랙션 일관성 무시
- 비디자이너도 판단 기준 부재
- 프로토타이핑 툴마다 컨텍스트를 반복 입력

**솔루션 설계**
- v1: 9-section DESIGN.md 포맷으로 원칙·브랜드 톤·제약·좋은 예/나쁜 예 정리 → Claude Project 컨텍스트로 주입
- v2: Design-critique 봇 + DS-prototype / HTML-to-Figma-refiner에 자동 참조 연동

**9-section 구조**
1. Visual Theme & Atmosphere — 오늘의집 브랜드 톤
2. Color Palette & Roles — ODS 컬러 토큰
3. Typography Rules — 타이포 위계 테이블
4. Component Stylings — 주요 컴포넌트 상태별
5. Layout Principles — 간격 스케일, 그리드, 여백
6. Depth & Elevation — 그림자 시스템
7. Do's and Don'ts — 안티패턴 명시
8. Responsive Behavior — 브레이크포인트, 터치 타겟
9. Agent Prompt Guide — 색상 코드 레퍼런스, 자주 쓰는 프롬프트

**만드는 방법**
1. 9-section 구조 정의
2. btb100 등 검증된 원칙 소스 수집 및 분류
3. 카테고리별 좋은 예/나쁜 예 포함
4. /principles 검색 Skill 구현
5. Design-critique / DS-prototype / HTML-to-Figma-refiner 컨텍스트에 연동

**해외 사례**: o2o-pd-ai-workflow-map의 DESIGN.md. btb100.vercel.app. 기존 Design-principles 흡수

**성공 지표**
- 디자인 리뷰 피드백이 원칙 기반으로 객관화
- 비디자이너 디자인 판단 기준 확보
- DS-prototype 초기 품질 향상

**선행 조건**: btb100 등 디자인 원칙 소스 정리, Claude Project 컨텍스트 설계

---

## 외부 협업

#### DS-code-bridge
DS 팀/엔지니어링 주도. Tokens Studio + Style Dictionary 등 기존 도구 활용. PD는 요구사항 전달.

---

## Team Directory

| 이름 | Slack ID | 소속 |
|---|---|---|
| Yohan | [U06PVRTFW4D](https://bucketplace.slack.com/team/U06PVRTFW4D) | Product Design Lead |
| Jack | [U05SH5S3Z8W](https://bucketplace.slack.com/team/U05SH5S3Z8W) | Design / PD |
| Deeer | [UK2DNAVF1](https://bucketplace.slack.com/team/UK2DNAVF1) | Product Designer (C&C) |
| Gongdee | [U013D45SC1Z](https://bucketplace.slack.com/team/U013D45SC1Z) | 커머스 / Product Designer |
| Stella | [U04JG8UCPUG](https://bucketplace.slack.com/team/U04JG8UCPUG) | Search / Product Designer |
| Sun | [U03674Y2G01](https://bucketplace.slack.com/team/U03674Y2G01) | Product Designer |
| Selah | [U091ZKWFTPA](https://bucketplace.slack.com/team/U091ZKWFTPA) | Design / Product Designer |
| Dana | [U08CXAHDHUY](https://bucketplace.slack.com/team/U08CXAHDHUY) | Ads, OhousePay, Commerce |
| dana (writer) | [U0779QQDJ7M](https://bucketplace.slack.com/team/U0779QQDJ7M) | Brand Language / BD |
| Jenna | [U04HPKBE8S1](https://bucketplace.slack.com/team/U04HPKBE8S1) | 커머스 / Product Designer |
| Joy | [U06NQR86HD3](https://bucketplace.slack.com/team/U06NQR86HD3) | O2O / Product Design |
| Lain | [U03T2K19P8E](https://bucketplace.slack.com/team/U03T2K19P8E) | Product Designer |
| Lana | [U092GJY6KR8](https://bucketplace.slack.com/team/U092GJY6KR8) | 커머스 / PD Assistant |
| Lizzy | [U05AW0T8B4K](https://bucketplace.slack.com/team/U05AW0T8B4K) | Product Design (O2O) |
| Rocky | [U09V999L97S](https://bucketplace.slack.com/team/U09V999L97S) | O2O / Product Design |
| Rowan | [U0A36J72T26](https://bucketplace.slack.com/team/U0A36J72T26) | O2O Product Designer |
| Skamie | [U07EEGAD674](https://bucketplace.slack.com/team/U07EEGAD674) | Life Event & User growth |
| Tyler | [U06T6NEQ0M8](https://bucketplace.slack.com/team/U06T6NEQ0M8) | Design System / PD |
| Yun | [U09TAJE771Q](https://bucketplace.slack.com/team/U09TAJE771Q) | O2O / Product Designer |

---

## 과업 배분 요약

### P0 — 핵심 인프라 / 킬러 기능 (6개)
| # | 과업 | Phase | 소요 | 오너 |
|---|---|---|---|---|
| 1 | Initiative-prioritizer | Discovery | 2~3주 | Yohan |
| 2 | Hypothesis-builder | Discovery | 1~2주 | Selah |
| 4 | DS-prototype | Design & Prototype | 2~4주 | Jack, Gongdee, Lana, Tyler |
| 6 | State-edge-simulator | Design & Prototype | 2~3주 | Jenna |
| 9 | Complete-handoff-doc | Handoff & QA | 2~3주 | Deeer |
| 13 | Design-pattern-library | Platform | 3~4주 | Jack, Deeer, Tyler |

### P1 — 높은 임팩트 (8개)
| # | 과업 | Phase | 소요 | 오너 |
|---|---|---|---|---|
| 3 | Data-interpreter | Discovery | 1~2주 | Selah |
| 5 | UT-prototyping | Design & Prototype | 2~3주 | Deeer, Stella |
| 7 | HTML-to-Figma-refiner | Design & Prototype | 2~3주 | Tyler |
| 8 | Design-critique `Quick Win` | Review | 1~2주 | Yohan |
| 10 | Design-QA | Handoff & QA | 3~4주 | Selah |
| 14 | Insight-archive `Quick Win` | Platform | 2~3주 | Sun |
| 15 | Team-toolkit | Platform | 2~3주 | Yohan |
| 16 | DESIGN.md | Platform | 2~3주 | Yohan |

### P2 — 중기 (2개)
| # | 과업 | Phase | 소요 | 오너 |
|---|---|---|---|---|
| 11 | UX-writing | Handoff & QA | 1~2주 | dana(writer) |
| 12 | Responsive-support | Handoff & QA | 1~2주 | Dana |

### 외부
| # | 과업 | 비고 |
|---|---|---|
| - | DS-code-bridge | DS 팀 주도 |
