# 용어 사전

각 용어의 한 줄 정의와, 그 개념을 다루는 문서 링크다.
면접 직전에 훑으며 설명이 막히는 것을 골라내는 용도로도 쓴다.

**형식** — `- **용어** (영문) — 한 줄 정의. → [문서](경로)`

정의는 한 문장으로 쓴다. 두 문장이 필요하면 그 용어는 문서에서 다룰 것이지
여기 있을 것이 아니다. 같은 용어를 문서마다 다르게 설명하지 않도록 여기를 기준으로 삼는다.

새 용어는 등장한 세션에서 바로 추가한다. 나중에 몰아서 채우면 채워지지 않는다.

## 브라우저와 렌더링

- **DOM** (Document Object Model) — HTML 을 파싱해 만든 노드의 트리로, 문서에 무엇이 있는지를 담는다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **CSSOM** (CSS Object Model) — CSS 를 파싱해 만든 스타일 규칙의 트리로, Render Tree 의 한쪽 입력이다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Render Tree** (렌더 트리) — DOM 과 CSSOM 을 합쳐 박스를 만드는 것만 남기고 최종 스타일을 붙인 트리다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Layout** (레이아웃) — Render Tree 의 각 박스가 어디에 얼마나 크게 놓이는지 계산하는 단계다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Paint** (페인트) — 계산된 박스를 어떤 순서로 무엇을 칠할지 그리기 명령 목록을 만드는 단계다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Composite** (합성) — 따로 그려진 레이어들을 겹쳐 한 프레임으로 만드는 단계다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Node** (노드) — DOM 트리에 들어가는 모든 것의 공통 인터페이스로, 요소·텍스트·주석·문서를 포함한다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Element** (요소) — 태그로 만들어진 노드로, Node 의 한 종류다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **Hit testing** (히트 테스팅) — 포인터 위치에 있는 상호작용 가능한 박스를 Layout 좌표로 찾는 과정이다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **UA stylesheet** (User Agent stylesheet) — 브라우저가 기본으로 적용하는 스타일시트로, `<head>` 와 `[hidden]` 에 `display: none` 을 준다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)
- **익명 박스** (anonymous box) — DOM 요소 없이 레이아웃을 위해 브라우저가 만드는 이름 없는 박스다. → [렌더링 파이프라인](01-browser/rendering-pipeline.md)

## HTTP

## 네트워크

## JavaScript 런타임

## 웹 보안

## 웹 성능

## 운영체제
