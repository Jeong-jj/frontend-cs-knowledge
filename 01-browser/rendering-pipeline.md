# 브라우저와 렌더링 파이프라인

> **이 문서가 답하는 질문** — 서버에서 받은 HTML 이 화면의 픽셀이 되기까지 무슨 일이 일어나는가?

## 한 줄 요약

## 기초

<!-- 다룰 것: 브라우저 구성 요소와 멀티프로세스 구조 · HTML 파싱과 DOM 생성 ·
     CSS 파싱과 CSSOM 생성 · Render Tree · Layout · Paint · Composite -->

### 무엇인가

### 왜 필요한가

### 어떻게 동작하는가

## 심화

<!-- 다룰 것: parser-blocking script · async, defer, ES module 의 실행 차이 ·
     Reflow 와 Repaint 의 비용 차이 · 합성 전용 속성 · Critical Rendering Path -->

## 실무 적용

## 면접 예상 질문

### Q1. HTML 을 내려받은 뒤 화면이 그려질 때까지 무슨 일이 일어나는가

**30초**

**2분**

**심화**

### Q2. `<script>` 를 만났을 때 HTML 파싱은 어떻게 되는가

**30초**

**2분**

**심화**

### Q3. `async` 와 `defer` 는 무엇이 다른가

**30초**

**2분**

**심화**

### Q4. Reflow 와 Repaint 는 어떻게 다르며 무엇이 더 비싼가

**30초**

**2분**

**심화**

### Q5. CSS 는 렌더링을 차단하는가

**30초**

**2분**

**심화**

## 꼬리 질문

## 흔한 오해

## 직접 재현하기

<!-- Performance 패널에서 Parse HTML, Recalculate Style, Layout, Paint, Composite Layers 를 확인한다. -->

## 검증 TODO

## 관련 문서

## 참고 자료

- [HTML Standard — Parsing HTML documents](https://html.spec.whatwg.org/multipage/parsing.html)
- [MDN — `<script>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
- [Chrome — Inside look at modern web browser](https://developer.chrome.com/blog/inside-browser-part1)
- [web.dev — Learn Performance](https://web.dev/learn/performance/)
