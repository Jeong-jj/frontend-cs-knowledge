# DNS, TCP, TLS

> **이 문서가 답하는 질문** — URL 을 입력한 뒤 HTTP 요청이 나가기 전까지 무슨 일이 일어나는가?

## 한 줄 요약

## 기초

<!-- 다룰 것: IP 주소, 포트, 소켓의 역할 · DNS 조회 과정과 캐시 계층 ·
     TCP 의 연결 지향성과 신뢰성 · 3-way handshake 와 4-way termination -->

### 무엇인가

### 왜 필요한가

### 어떻게 동작하는가

## 심화

<!-- 다룰 것: 패킷 손실과 재전송 · 흐름 제어와 혼잡 제어 · TCP 와 UDP 의 선택 기준 ·
     TLS 핸드셰이크와 인증서 · 공개키와 대칭키의 역할 분담 ·
     HTTP/1.1, HTTP/2, HTTP/3 의 차이와 멀티플렉싱 · head-of-line blocking -->

## 실무 적용

## 면접 예상 질문

### Q1. 도메인 이름은 어떻게 IP 주소로 변환되는가

**30초**

**2분**

**심화**

### Q2. TCP 는 왜 3-way handshake 를 사용하는가

**30초**

**2분**

**심화**

### Q3. HTTPS 는 무엇을 보호하며 인증서는 어떤 역할을 하는가

**30초**

**2분**

**심화**

### Q4. TLS 는 공개키와 대칭키를 왜 둘 다 쓰는가

**30초**

**2분**

**심화**

### Q5. TCP 와 UDP 는 어떻게 다르고 웹에서 각각 어디에 쓰이는가

**30초**

**2분**

**심화**

### Q6. HTTP/2 는 HTTP/1.1 의 어떤 문제를 해결했는가

**30초**

**2분**

**심화**

### Q7. HTTP/3 가 QUIC 위에서 동작하는 이유는 무엇인가

**30초**

**2분**

**심화**

## 꼬리 질문

## 흔한 오해

## 직접 재현하기

<!-- Network 패널의 Timing 탭에서 DNS Lookup, Initial connection, SSL 구간을 나눠 본다. -->

## 검증 TODO

## 관련 문서

## 참고 자료

- [RFC 1035 — Domain Names: Implementation and Specification](https://www.rfc-editor.org/rfc/rfc1035.html)
- [RFC 9293 — Transmission Control Protocol](https://www.rfc-editor.org/rfc/rfc9293.html)
- [RFC 8446 — TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446.html)
- [RFC 9113 — HTTP/2](https://www.rfc-editor.org/rfc/rfc9113.html)
- [RFC 9114 — HTTP/3](https://www.rfc-editor.org/rfc/rfc9114.html)
