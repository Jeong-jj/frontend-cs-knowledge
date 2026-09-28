# 브라우저 보안

> **이 문서가 답하는 질문** — 브라우저는 어떤 경계로 출처를 나누고, 그 경계를 노리는 공격은 어떻게 막는가?

## 한 줄 요약

## 기초

<!-- 다룰 것: Origin 의 정의 · Same-Origin Policy · CORS 의 목적과 동작 ·
     단순 요청과 preflight 요청 · 자격 증명 요청 -->

### 무엇인가

### 왜 필요한가

### 어떻게 동작하는가

## 심화

<!-- 다룰 것: XSS 의 유형(Stored, Reflected, DOM-based)과 방어 · CSRF 의 원리와 방어 ·
     HttpOnly, Secure, SameSite 쿠키 속성 · CSP · 토큰 저장 위치의 트레이드오프 -->

## 실무 적용

## 공격과 방어 비교

<!-- 공격, 성립 조건, 방어 주체(브라우저/프론트엔드/서버), 방어 수단을 표로 잇는다. -->

| 공격 | 성립 조건 | 방어 주체 | 방어 수단 |
|---|---|---|---|

## 면접 예상 질문

### Q1. Same-Origin Policy 는 무엇을 막는가

**30초**

**2분**

**심화**

### Q2. CORS 오류는 누가 왜 발생시키는가

**30초**

**2분**

**심화**

### Q3. preflight 요청은 언제 발생하는가

**30초**

**2분**

**심화**

### Q4. XSS 와 CSRF 는 어떻게 다르며 각각 어떻게 방어하는가

**30초**

**2분**

**심화**

### Q5. `SameSite` 쿠키 속성은 무엇을 해결하는가

**30초**

**2분**

**심화**

### Q6. 액세스 토큰을 어디에 저장해야 하는가

**30초**

**2분**

**심화**

## 꼬리 질문

## 흔한 오해

## 직접 재현하기

<!-- 다른 출처로 fetch 를 보내 preflight OPTIONS 요청과 응답 헤더를 Network 패널에서 확인한다. -->

## 검증 TODO

## 관련 문서

## 참고 자료

- [Fetch Standard — CORS protocol](https://fetch.spec.whatwg.org/#http-cors-protocol)
- [RFC 6265 — HTTP State Management Mechanism](https://www.rfc-editor.org/rfc/rfc6265.html)
- [OWASP — Cross Site Scripting (XSS)](https://owasp.org/www-community/attacks/xss/)
- [OWASP — CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
