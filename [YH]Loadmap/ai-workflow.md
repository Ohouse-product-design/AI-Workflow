# 오늘의집 PD AI Workflow Map v2

> 4그룹 17과업(+ 부가 2). 그룹으로 진행률을 보고, 과업으로 오너십을 준다.
> 마지막 업데이트: 2026-04-10

---

## 우선순위 기준
- **P0** — 핵심 인프라 / 킬러 기능. 즉시 시작
- **P1** — 높은 임팩트. P0와 병행 가능
- **P2** — 중기. 핵심 과업 안정화 후 확장
- **Quick Win** — 1~2주 내 즉시 산출 가능한 가속 과업

## 실행 로드맵
- Month 1: Quick Win (Data-insight, Design-critique, Team-toolkit)
- Month 1~2: 핵심 인프라 (Design-knowledge-playbook, Complete-handoff)
- Month 2~3: 킬러 기능 (Design-draft, Edge-case-simulator, UT-prototyping, Design-QA)
- Month 3~6: P2 확장 (Design-principles, Insight-archive, Reference-analyzer)

---

## Phase 1: Design & Prototype

### [그룹 A] Design & Generate

#### 1. Design-draft `P0`
**한줄 정의**: PRD → HTML 결론안 자동 생성
**문제 심각도**: ★★★★★ (5/5)
- 모든 PD의 핵심 업무. 3~8일 소요
- 잭: "초안보다 결론안", 스텔라: "HTML 다 만들어두고 아이데이션"

**솔루션 설계**
- v1 (지금 가능): Claude Project에 ODS 컨텍스트 세팅 → PRD 입력 → HTML 생성 → Figma 수동 반영
- v2 (이상적): Figma MCP + Code-to-Canvas로 자동 반영

**만드는 방법**
1. ODS 컴포넌트를 HTML snippet + 사용 규칙 MD로 정리
2. Claude Project 시스템 프롬프트 작성 (ODS 컨텍스트 포함)
3. 실제 PRD 3건으로 파일럿 테스트 (A/B/C안 병렬)
4. 팀원 피드백 → 프롬프트 개선
5. Figma Code-to-Canvas 파이프라인 연결

**해외 사례**: Spotify MCP 서버(디자인 시스템 노출 → AI 품질 향상), Vercel v0(AI-friendly DS → 의도적인 프로토타입)

**성공 지표**
- 디자인 초안 시간 50%+ 단축
- PO가 HTML 프로토타입으로 직접 아이데이션 가능

**선행 조건**: ODS 컴포넌트 정비, Design-knowledge-playbook

---

#### 2. UT-prototyping `P1`
**한줄 정의**: 유저 개인화 UT 프로토타입(html 프로토타입 + user id 기반 정보 교체 반영)
**문제 심각도**: ★★★☆☆ (3/5)
- UT 준비에 2~3일 소요, 프로토타입과 유저별 맞춤 상품 및 콘텐츠 셋업 교체가 수작업으로 이뤄짐
- PD: UT를 위한 프로토타이핑 과업을 주기적으로 수행함

**솔루션 설계**
- (스킬1)MCP최적화 프레임명 교체 (스킬2)Flow 연결된 피그마 링크 첨부시, html프로토타입 생성, (스킬3) user id 첨부시,맞춤 정보 셋업 교체

**만드는 방법**
1. MCP최적화 프레임명 교체 스킬 제작
2. Flow 연결된 피그마 첨부시, html 프로토타입 생성 스킬 제작
3. user id 첨부시, 맞춤 정보 셋업 교체
4. 스킬이 결합된 에이전트 생성 : flow연결된 프레임 링크, use id 제공시 한번에 수행 가능하도록 제작

**성공 지표**: UT 준비 시간 50% 이상 단축, UT 실행 빈도 증가
**선행 조건**: 화면 Flow연결된 프레임 링크 준비 완료 / Figma MCP, Athena MCP 연결 완료

---

### [그룹 B] Design-knowledge-playbook

#### 3. Design-knowledge-playbook `P0`
**한줄 정의**: 화면 패턴/규칙/히스토리 → HTML 플레이북
**문제 심각도**: ★★★★★ (5/5)
- 디자인 규칙이 디자이너 머릿속에만 존재
- LLM에게 컴포넌트만 주면 잘못된 조합/배치의 UI 생성
- 비디자이너가 디자인에 참여하기 어려움

**솔루션 설계**
- v1: Notion에 주요 화면 20개 패턴 카드 작성 (컴포넌트 조합, 사용 규칙, 의사결정 히스토리)
- v2: 패턴 라이브러리를 MD/JSON으로 구조화하여 LLM이 직접 읽을 수 있게

**만드는 방법**
1. 주요 화면 20개 선정
2. 각 화면의 패턴 카드 작성 (컴포넌트 조합, 왜 이렇게 배치했는지, 의사결정 히스토리)
3. Figma→HTML 변환 규칙 포함 (Auto Layout→Flexbox, 토큰→CSS 변수)
4. 보편 디자인 원칙(btb100 등) 구조화
5. /playbook 검색 Skill 구현

**해외 사례**: Spotify의 디자인 시스템 MCP 서버(기계 읽기 가능 문서화), Figma Design System Rules

**성공 지표**
- Design-draft 결론안 품질 향상 (리뷰 수정 횟수 감소)
- 비디자이너가 플레이북 보고 디자인 가능

**선행 조건**: 주요 화면별 패턴 정리, 디자이너 인터뷰

---

#### 4. DS-logic-builder `P1`
**한줄 정의**: 컴포넌트 네이밍/속성 정규화
**문제 심각도**: ★★★★☆ (4/5)
- "Frame 124" 같은 의미 없는 레이어 이름
- 컴포넌트 속성 불일치

**솔루션 설계**
- v1: Design Lint 플러그인 도입 + 네이밍 컨벤션 문서화. 커스텀 빌드 불필요
- v2: Figma MCP로 자동 린팅 + 수정 제안

**만드는 방법**
1. ODS 컴포넌트 네이밍 컨벤션 문서화 (Category/Component/Variant/State)
2. Design Lint 플러그인 도입
3. 주요 파일 10개에 대해 린팅 실행 → 위반 사항 목록화
4. 점진적 정비 (신규 파일부터 컨벤션 적용)

**해외 사례**: 블로그 "AI가 이해할 수 있는 피그마 디자인 시스템 설계하기" 원칙 #1, #3, #8

**성공 지표**: 네이밍 컨벤션 위반율 감소, LLM Figma 구조 이해도 향상
**선행 조건**: ODS 컴포넌트 속성/네이밍 현황 파악

---

#### 5. ODS-checker `P1`
**한줄 정의**: ODS 컴포넌트 검색 + QnA 자동 응답
**문제 심각도**: ★★★☆☆ (3/5)
- "이 컴포넌트 ODS에 있나요?" 반복 질문
- 전체 문의의 51%

**솔루션 설계**
- v1: 174건 QnA 데이터 기반 Slack 봇
- v2: Design-knowledge-playbook 연동으로 컨텍스트 있는 답변

**만드는 방법**
1. 174건 QnA 데이터 구조화
2. ODS 컴포넌트 목록 + 상태(active/legacy) 정리
3. Slack 봇 또는 /ods Skill 구현
4. 2주 운영 후 미응답 질문 분석 → 데이터 보강

**해외 사례**: Spotify 디자인 시스템 MCP 서버의 검색 기능

**성공 지표**: design_system 채널 문의 응답 시간 50% 감소
**선행 조건**: 174건 QnA 분석, 채널 접근 권한

---

## Phase 2: Review & Critique

#### 6. Design-critique `P1` `Quick Win`
**한줄 정의**: AI 다각도 크리틱 자동 제공
**문제 심각도**: ★★★★☆ (4/5)
- 리뷰어 관점 편중, 체크포인트 누락
- 이미 운영 중인 #des_pd_design_critique 기반

**솔루션 설계**
- v1: 기존 봇에 Design-knowledge-playbook의 규칙 컨텍스트 추가
- v2: 보편 디자인 원칙(btb100) 기반 원칙 참조 크리틱

**만드는 방법**
1. 현재 크리틱 봇 피드백 품질 평가 (10건 샘플링)
2. Design-knowledge-playbook 규칙을 크리틱 컨텍스트에 추가
3. 접근성/DS 적용 여부 체크 강화
4. 2주 운영 후 피드백 품질 재평가

**해외 사례**: 없으나 "AI peer review" 업계 확산 중

**성공 지표**: 디자인 리뷰 수정 요청 횟수 감소
**선행 조건**: 기존 크리틱 봇 운영 중

---

#### 7. Design-principles `P2` `NEW`
**한줄 정의**: 보편 디자인 원칙 → 구조화된 참조 문서 + 검색 Skill
**문제 심각도**: ★★★☆☆ (3/5)
- 시각적 위계 / 타이포그래피 / 인터랙션 / 레이아웃 같은 보편 원칙이 디자이너 머릿속에만 존재
- LLM이 기본기 없이 UI를 생성하면 어색한 결과
- 팀원이 판단 기준으로 참고할 공통 원칙 부재 (btb100 미정리)

**솔루션 설계**
- v1: 디자인 원칙을 4영역(시각 위계 / 타이포 / 인터랙션 / 레이아웃)으로 정리한 MD 문서
- v2: /principles 검색 Skill로 LLM과 팀원이 즉시 참조

**만드는 방법**
1. btb100 등 디자인 원칙 소스 수집
2. 4영역으로 구조화 (각 원칙별 정의 + Do/Don't 예시)
3. /principles Skill 프롬프트 작성
4. Design-critique 봇 컨텍스트에 연결

**해외 사례**: Refactoring UI (Adam Wathan), Material Design Foundations, IBM Carbon Design Principles

**성공 지표**
- LLM 생성 UI의 기본기 향상 (리뷰 수정 지점 감소)
- 비디자이너의 디자인 판단력 향상

**선행 조건**: btb100 등 디자인 원칙 소스 정리

---

## Phase 3: Handoff & QA

### [그룹 C] Complete-handoff

#### 8. Spec-policy-handoff `P0`
**한줄 정의**: 정책/비즈니스 규칙/엣지 케이스 포함 스펙 문서
**문제 심각도**: ★★★★★ (5/5)
- 셀라: "디자인 handoff보다 정책 handoff가 더 중요"
- 핸드오프 후 "왜 이렇게?" 질문 왕복 5~10회

**솔루션 설계**
- v1: 체크리스트 템플릿 Skill — "이 항목들 다 채웠는지" 검증. 자동 생성이 아니라 누락 방지
- v2: 기획 문서 + 디자인 파일 분석 → 구조화된 스펙 자동 생성

**만드는 방법**
1. 최근 핸드오프 3건에서 "개발자가 추가로 물어본 질문" 수집
2. 정책 스펙 템플릿 설계 (비즈니스 규칙, 엣지 케이스, 상태 분기, API 포인트)
3. /handoff Skill 프롬프트 작성
4. 실제 핸드오프에 적용 → 질문 왕복 횟수 측정

**해외 사례**: Figma Dev Mode + Code Connect 방향성 유사

**성공 지표**: 핸드오프 후 질문 왕복 50% 감소
**선행 조건**: 정책 문서 구조 정의

---

#### 9. State-verifier `P0`
**한줄 정의**: 상태별 UI 누락 자동 체크
**문제 심각도**: ★★★★☆ (4/5)
- 공디: "쏟아내는 것은 쉬운데 챙기지 못한 거 챙기는"
- Loading, Empty, Error 등 빠뜨리고 핸드오프

**솔루션 설계**
- v1: 체크리스트 Skill — 화면 이름 입력 → 필요한 상태 목록 자동 생성. Figma Plugin 불필요
- v2: Figma MCP로 파일 스캔 → 누락 상태 자동 탐지

**만드는 방법**
1. 오늘의집 기준 필수 상태 목록 정의 (Default, Loading, Empty, Error, Success, Disabled, 권한없음 등 10~15개)
2. /state-check Skill 프롬프트 작성
3. 실제 핸드오프 5건에 적용
4. 누락 상태 패턴 분석 → 체크리스트 보강

**성공 지표**: 상태 UI 누락으로 인한 개발 중 추가 요청 제로화
**선행 조건**: 상태별 UI 체크리스트 정의

---

#### 10. Design-handoff-doc `P1`
**한줄 정의**: Figma Dev Mode 기반 핸드오프 문서 템플릿
**문제 심각도**: ★★★★☆ (4/5)
- 핸드오프 문서 수동 작성에 시간 소요
- Figma Dev Mode가 이미 많은 기능 제공

**솔루션 설계**
- v1: Figma Dev Mode 활용 + 구조화된 핸드오프 템플릿 Skill. 커스텀 빌드 불필요
- v2: Selah GitHub 연동 자동 커밋

**만드는 방법**
1. Figma Dev Mode 활용 가이드 작성
2. 핸드오프 문서 템플릿 설계 (컴포넌트 스펙, 인터랙션 정의, 예외 처리)
3. /handoff-doc Skill 프롬프트 작성
4. Spec-policy-handoff와 연계하여 완전한 핸드오프 패키지 구성

**성공 지표**: 핸드오프 문서 작성 시간 50% 단축
**선행 조건**: Selah GitHub 권한

---

### [그룹 D] Quality & Verification

#### 11. Edge-case-simulator `P1`
**한줄 정의**: 엣지 케이스 데이터 자동 생성 + 텍스트 오버플로 검증
**문제 심각도**: ★★★★☆ (4/5)
- 디어: 프로토타이핑에 데이터 연결을 핵심 과업으로 집중
- 더미 데이터로 엣지 케이스 놓침

**솔루션 설계**
- v1: Skill로 "화면 타입 + 데이터 필드 → 엣지 케이스 데이터 세트" 생성 + Content Reel 수동 적용
- v2: Figma Variables 연동 자동 적용

**만드는 방법**
1. 화면별 데이터 엣지 케이스 패턴 정의 (빈 값, 최대/최소 길이, 특수문자, 긴 리스트)
2. /edge-case Skill 프롬프트 작성
3. Content Reel / Figma Variables에 데이터 적용 가이드
4. State-verifier와 연계

**해외 사례**: Figma Variables + Content Reel 조합이 업계 표준

**성공 지표**: 엣지 케이스 관련 QA 이슈 50% 감소
**선행 조건**: 데이터 엣지 케이스 패턴 정의

---

#### 12. Design-QA `P1`
**한줄 정의**: 디자이너가 Claude Code로 개발 화면 직접 수정 → GitHub 커밋
**문제 심각도**: ★★★★☆ (4/5)
- 디자이너가 CSS/HTML 수정을 개발자에게 요청 → 왕복 비용
- PD의 새로운 역할: 코드에 직접 참여

**솔루션 설계**
- v1: Claude Code로 CSS/HTML 수정 → PR 생성. 개발자가 리뷰 후 머지
- v2: 디자이너 전용 코드 수정 권한 + CI/CD 파이프라인

**만드는 방법**
1. GitHub 기본 워크플로우 가이드 작성 (clone, branch, commit, PR)
2. Claude Code 활용 CSS 수정 실습 (색상, 간격, 폰트 등 디자인 토큰 수준)
3. 실제 QA 건 3개로 파일럿 (Claude Code로 수정 → PR → 개발자 리뷰)
4. 성공 패턴 정리 → 팀 전체 확산

**해외 사례**: Spotify(시니어 엔지니어가 AI 생성 코드만 리뷰)의 디자이너 버전

**성공 지표**: 디자인 QA 수정 요청 → PR 전환율 측정
**선행 조건**: GitHub 접근 권한, Claude Code 기본 교육

---

## Platform Layer

#### 13. Data-insight `P1` `Quick Win`
**한줄 정의**: 자연어로 핵심 지표 즉시 조회
**문제 심각도**: ★★★☆☆ (3/5)
- 지표 확인에 2~4h 소요, DA 의존도 높음

**솔루션 설계**
- v1: /query Skill + Athena/Redash MCP (이미 완성)
- v2: 자주 쓰는 쿼리 템플릿 등록

**만드는 방법**
1. 디자이너가 자주 조회하는 지표 Top 10 목록화
2. /query Skill 프롬프트에 디자이너 맥락 추가
3. 자주 쓰는 쿼리 템플릿 5개 등록

**성공 지표**: 데이터 조회 시간 80% 단축
**선행 조건**: Athena MCP, Redash MCP 세팅 완료

---

#### 14. Team-toolkit `P1`
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
4. 온보딩 체크리스트 MD 작성 (환경 세팅 → 플레이북 학습 → 첫 태스크)

**성공 지표**: 스킬 재사용률 향상, 온보딩 환경 세팅 시간 50% 단축
**선행 조건**: Git 저장소 구조 설계

---

#### 15. Insight-archive `P2`
**한줄 정의**: 실험 결과/인사이트/AI 팁 축적
**문제 심각도**: ★★★★☆ (4/5)
- 과거 실험 결과, 의사결정 근거가 흩어져 있음
- AI 활용 노하우가 개인에게만 축적

**솔루션 설계**
- v1: Notion 페이지에 수동 큐레이션 + /insight 검색 Skill
- v2: Slack/Notion에서 자동 수집 (장기)

**만드는 방법**
1. Notion에 인사이트 DB 구조 설계 (프로젝트, 실험 결과, 지표 변화, 교훈)
2. AI 팁 섹션 추가 ("이럴 때 이렇게 쓰면 잘 된다")
3. /insight 검색 Skill 구현
4. 월 1회 팀 회고에서 인사이트 등록 루틴화

**성공 지표**: 도메인 맥락 파악 시간 단축, 과거 실험 재반복 방지
**선행 조건**: Notion 지식 허브 구조 설계

---

#### 16. Reference-analyzer `P2`
**한줄 정의**: 경쟁사/글로벌 레퍼런스 분석 리포트
**문제 심각도**: ★★★☆☆ (3/5)
- 레퍼런스 수집+분석에 4~8h 소요

**솔루션 설계**
- v1: 수집한 스크린샷을 입력하면 패턴 분석하는 Skill. Figma 정리는 수동
- v2: 웹 자동 크롤링 + 패턴 매칭

**만드는 방법**
1. 분석 결과 템플릿 정의 (레이아웃/컴포넌트/인터랙션 분류)
2. /reference Skill 프롬프트 작성
3. 분석 결과를 Notion에 자동 저장하는 워크플로우

**성공 지표**: 레퍼런스 분석 시간 50% 단축
**선행 조건**: STACK 컴포넌트 데이터

---

## 부가 기능 (P2)

#### 17. UX-writing
**한줄 정의**: 브랜드 가이드 기반 카피 자동 작성 + 맞춤법/띄어쓰기 검사
- Design-draft 부가 기능. 카피 생성을 Design-draft 프롬프트에 포함하여 별도 도구 불필요
- v1: /writing Skill 단독 호출 가능
- 선행 조건: 브랜드 가이드, 용어 사전

#### 18. Responsive-support
**한줄 정의**: HTML 생성 시 CSS 미디어쿼리 포함하여 반응형 자동 해결
- Design-draft 부가 기능. HTML 생성 단계에 자동 포함
- v1: 브레이크포인트 가이드 + Figma 플러그인 활용
- 선행 조건: 브레이크포인트 가이드

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

### P0 — 핵심 인프라 / 킬러 기능 (4개)
| # | 과업 | 그룹 | 소요 | 오너 |
|---|---|---|---|---|
| 1 | Design-draft | Design & Generate | 2~4주 | 할당 대기 |
| 3 | Design-knowledge-playbook | Knowledge Playbook | 2~3주 | 할당 대기 |
| 8 | Spec-policy-handoff | Complete-handoff | 2~3주 | 할당 대기 |
| 9 | State-verifier | Complete-handoff | 1~2주 | 할당 대기 |

### P1 — 높은 임팩트 (9개)
| # | 과업 | 그룹 | 소요 | 오너 |
|---|---|---|---|---|
| 2 | UT-prototyping | Design & Generate | 2~3주 | 할당 대기 |
| 4 | DS-logic-builder | Knowledge Playbook | 2~3주 | 할당 대기 |
| 5 | ODS-checker | Knowledge Playbook | 1~2주 | 할당 대기 |
| 6 | Design-critique `Quick Win` | Review | 1~2주 | 할당 대기 |
| 10 | Design-handoff-doc | Complete-handoff | 1~2주 | 할당 대기 |
| 11 | Edge-case-simulator | Quality & Verification | 2~3주 | 할당 대기 |
| 12 | Design-QA | Quality & Verification | 3~4주 | 할당 대기 |
| 13 | Data-insight `Quick Win` | Platform | 1~2주 | 할당 대기 |
| 14 | Team-toolkit | Platform | 2~3주 | 할당 대기 |

### P2 — 중기 (5개 + 부가)
| # | 과업 | 그룹 | 소요 | 오너 |
|---|---|---|---|---|
| 7 | Design-principles `NEW` | Review | 2~3주 | 할당 대기 |
| 15 | Insight-archive | Platform | 3~4주 | 할당 대기 |
| 16 | Reference-analyzer | Platform | 2~3주 | 할당 대기 |
| 17 | UX-writing | 부가 | 1~2주 | Design-draft에 포함 |
| 18 | Responsive-support | 부가 | 1~2주 | Design-draft에 포함 |
| - | DS-code-bridge | 외부 | DS 팀 주도 | - |
