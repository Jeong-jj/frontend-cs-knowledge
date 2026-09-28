# JavaScript 런타임과 이벤트 루프

> **이 문서가 답하는 질문** — 싱글 스레드인 JavaScript 가 비동기 작업을 처리하는 순서는 무엇이 결정하는가?

## 한 줄 요약

## 기초

<!-- 다룰 것: Execution Context 와 Call Stack · Heap · Web APIs 와 엔진의 역할 구분 ·
     Event Loop · Task Queue 와 Microtask Queue -->

### 무엇인가

### 왜 필요한가

### 어떻게 동작하는가

## 심화

<!-- 다룰 것: Promise 와 async/await 의 실제 전개 · 렌더링 시점과 이벤트 루프의 관계 ·
     requestAnimationFrame 의 위치 · 가비지 컬렉션 기초 · Long Task 와 메인 스레드 블로킹 -->

## 실무 적용

## 면접 예상 질문

### Q1. JavaScript 가 싱글 스레드인데 비동기 작업이 가능한 이유는 무엇인가

**30초**

**2분**

**심화**

### Q2. Promise 콜백과 `setTimeout` 콜백 중 무엇이 먼저 실행되는가

**30초**

**2분**

**심화**

### Q3. Task 와 Microtask 는 무엇이 다른가

**30초**

**2분**

**심화**

### Q4. Event Loop 는 렌더링과 어떤 관계가 있는가

**30초**

**2분**

**심화**

### Q5. `async/await` 는 Promise 와 어떻게 다른가

**30초**

**2분**

**심화**

### Q6. 긴 JavaScript 작업이 사용자 경험을 해치는 이유는 무엇인가

**30초**

**2분**

**심화**

### Q7. `setTimeout(fn, 0)` 은 즉시 실행되는가

**30초**

**2분**

**심화**

## 실행 순서 예측 문제

<!-- 코드를 먼저 보고 출력 순서를 예측한 뒤 콘솔에서 검증한다. 최소 5개. -->

## 꼬리 질문

## 흔한 오해

## 직접 재현하기

## 검증 TODO

## 관련 문서

## 참고 자료

- [HTML Standard — Event loops](https://html.spec.whatwg.org/multipage/webappapis.html#event-loops)
- [ECMAScript Language Specification](https://tc39.es/ecma262/)
