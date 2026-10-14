# frontend-cs-knowledge

프론트엔드 면접 대비 CS 문서 프로젝트다.

브라우저가 화면을 그리는 순서, HTTP 캐시가 동작하는 조건, 이벤트 루프가 콜백을 꺼내는
규칙처럼 면접에서 실제로 묻는 것들을 **설명할 수 있는 상태**까지 정리한다.

## 개념 정리 노트와 무엇이 다른가

```text
개념 정리 노트   개념의 기초 설명과 심화 내용
면접 대비 문서   개념 정리 + 예상 질의응답 + 실무 적용 + 면접 연습 방식
```

이 저장소는 후자다. 각 문서는 하나의 질문에 답하고, 그 답을 **30초·2분·심화**
세 길이로 말할 수 있는 형태까지 정리한다. 첫 답변이 아니라 그 뒤에 이어지는
꼬리 질문에서 갈리기 때문에, 꼬리 질문과 대응도 함께 담는다.

## 관문 질문

> 브라우저 주소창에 `https://example.com` 을 입력하고 화면이 표시되기까지 무슨 일이 일어나는가?

```text
URL 해석 → DNS 조회 → IP 확인 → TCP 연결 → TLS 핸드셰이크
→ HTTP 요청과 응답 → HTML 파싱과 리소스 로딩 → DOM/CSSOM 생성
→ JavaScript 실행 → Render Tree → Layout → Paint → Composite
```

이 저장소의 모든 문서는 결국 이 흐름의 한 조각을 이유와 함께 설명하기 위한 것이다.

## 문서

| 주제 | 문서 | 상태 |
|---|---|---|
| 브라우저와 렌더링 파이프라인 | [`01-browser/rendering-pipeline.md`](01-browser/rendering-pipeline.md) | 작성 중 |
| HTTP 와 웹 통신 | [`02-http/http-fundamentals.md`](02-http/http-fundamentals.md) | 작성 전 |
| DNS, TCP, TLS | [`03-network/dns-tcp-tls.md`](03-network/dns-tcp-tls.md) | 작성 전 |
| JavaScript 런타임과 이벤트 루프 | [`04-javascript-runtime/event-loop.md`](04-javascript-runtime/event-loop.md) | 작성 전 |
| 브라우저 보안 | [`05-security-and-performance/browser-security.md`](05-security-and-performance/browser-security.md) | 작성 전 |
| 웹 성능 | [`05-security-and-performance/web-performance.md`](05-security-and-performance/web-performance.md) | 작성 전 |
| 프로세스·스레드·메모리 | [`06-os-and-interview/process-thread-memory.md`](06-os-and-interview/process-thread-memory.md) | 작성 전 |
| 통합 답변 | [`06-os-and-interview/integrated-answers.md`](06-os-and-interview/integrated-answers.md) | 작성 전 |

용어는 [`glossary.md`](glossary.md) 에 한 줄 정의와 문서 링크로 모은다.

## 로드맵

주당 8~9시간 기준 1회독 계획이다. 근거와 상세는 [`docs/study-guide.md`](docs/study-guide.md) 에 있다.

| 주차 | 주제 |
|---|---|
| 1 | 브라우저와 렌더링 파이프라인 |
| 2 | HTTP 와 웹 통신 |
| 3 | DNS, TCP, TLS |
| 4 | JavaScript 런타임과 비동기 실행 |
| 5 | 웹 보안과 웹 성능 |
| 6 | OS 기초와 통합 면접 |

순서에는 이유가 있다. 브라우저가 모든 주제가 만나는 중심축이고, HTTP 는 그 위에서
서버와 대화하는 규칙이며, DNS/TCP/TLS 는 HTTP 아래에서 벌어지는 일을 설명한다.
보안은 앞의 지식을 전제로 하고, 성능은 그것들을 통합한다.

## 이 저장소를 쓰는 네 가지 방법

| | 무엇을 하나 |
|---|---|
| **읽기** | 문서만 읽는다. 클론할 필요도 없다 |
| **학습** | 클론해서 같은 방식으로 공부한다. 진도는 로컬에 남는다 |
| **자기 것으로** | fork 해서 자기 저장소의 문서를 자기 말로 다시 쓴다 |
| **기여** | 문서의 오류나 누락을 발견하면 PR 을 연다 |

### 학습

만들어진 방식 그대로 따라 할 수 있다.
[Claude Code](https://claude.com/claude-code) 를 쓴다면 스킬이 함께 들어 있다.

```bash
git clone git@github.com:Jeong-jj/frontend-cs-knowledge.git
cd frontend-cs-knowledge

mkdir -p sessions
cp docs/progress-template.md sessions/progress.md
```

문서가 이미 채워져 있어도 **읽기 전에 진단 질문부터 받는다.**
읽고 나면 아는 것과 방금 읽은 것을 구분할 수 없다.
`/study` 가 그 순서로 진행한다.

### 자기 것으로

문서를 자기 말로 다시 쓰는 것은 fork 에서 한다. 원본이 개선되면 가져올 수 있고,
그 저장소가 그대로 자기 기록이 된다.

### 기여

학습하다 문서의 오류나 누락을 발견하면 PR 을 연다.
`.github/pull_request_template.md` 를 따르고, `근거와 확인` 절에 1차 출처를 적는다.

PR 에 쓰는 것은 학습 과정이 아니라 **문서의 어디가 틀렸고 근거가 무엇인지**다.
`설명이 막혔다` 는 각자의 `sessions/` 몫이고, `문서가 틀렸다` 가 PR 몫이다.

| 스킬 | 하는 일 |
|---|---|
| `/study` | 세션 시작. 진도를 확인하고 진단 질문부터 던진다 |
| `/drill` | 문서를 보지 않고 답하는 복습과 모의 면접 |
| `/wrap` | 문서, 세션 기록, 용어, 진행 상태를 갱신한다 |
| `/commit` | 저장소 규칙대로 커밋한다 |
| `/pr` | 학습 결과를 PR 로 정리한다 |

`sessions/` 는 추적하지 않는다. 진단 답변과 복습 이력, 막힌 지점처럼 학습자마다
다른 것이 들어가기 때문이다. **기록하는 방법은 공개하고 기록 자체는 각자 로컬에 둔다.**
클론한 사람은 자기 `sessions/` 를 만들어 같은 방식으로 학습한다.

학습 방식은 [`docs/study-guide.md`](docs/study-guide.md),
문서 템플릿은 [`docs/document-template.md`](docs/document-template.md) 에 있다.

## 구조

```text
README.md                    이 파일
CLAUDE.md                    멘토 역할과 저장소 규칙
glossary.md                  용어 사전
docs/                        학습 가이드와 템플릿
01-browser/                  브라우저와 렌더링
02-http/                     HTTP
03-network/                  DNS, TCP, TLS
04-javascript-runtime/       JavaScript 런타임
05-security-and-performance/ 웹 보안과 성능
06-os-and-interview/         OS 기초와 통합 면접
scripts/                     제목 검사 등 저장소 도구
sessions/                    개인 학습 기록. 추적하지 않는다
```

## 통합 면접 질문

주제를 가로지르는 질문들이다. 개별 문서를 다 쓴 뒤
[`06-os-and-interview/integrated-answers.md`](06-os-and-interview/integrated-answers.md) 에서 다룬다.

- 주소창에 URL 을 입력하면 어떤 일이 일어나는가
- 로그인 상태에서 API 요청이 처리되는 과정을 보안과 네트워크 관점에서 설명하라
- 초기 페이지 로딩이 느릴 때 진단 순서와 개선 방법을 설명하라
- 비동기 요청의 응답 이후 화면이 갱신되기까지 무슨 일이 일어나는가
- 브라우저가 탭과 렌더러 프로세스를 분리하는 이유는 무엇인가
