# 브라우저와 렌더링 파이프라인

> **이 문서가 답하는 질문** — 서버에서 받은 HTML 이 화면의 픽셀이 되기까지 무슨 일이 일어나는가?

## 한 줄 요약

브라우저는 HTML 과 CSS 를 각각 트리로 만들고, 둘을 합쳐 보일 박스만 고른 뒤,
위치와 크기를 계산하고, 칠하고, 레이어를 합쳐 한 프레임을 만든다. 단계가 나뉘어 있어
무언가 바뀌면 바뀐 단계부터 다시 돌린다.

## 기초

<!-- 다룰 것: 브라우저 구성 요소와 멀티프로세스 구조 -->

### 무엇인가

서버가 보내는 것은 텍스트(바이트)이고 모니터가 받는 것은 픽셀이다.
렌더링 파이프라인은 그 사이를 잇는 변환 단계의 연쇄다.

```text
HTML 바이트 ─파싱→ DOM ──┐
                         ├─→ Render Tree → Layout → Paint → Composite → 화면
CSS 바이트  ─파싱→ CSSOM ┘
```

| 단계 | 결정하는 것 | 결과물 |
|---|---|---|
| DOM 생성 | 문서에 **무엇이** 있는가 | 노드의 트리 |
| CSSOM 생성 | 각 요소가 **어떤 스타일**인가 | 스타일 규칙의 트리 |
| Render Tree | 어떤 **박스가 존재**하고 최종 스타일은 무엇인가 | 보이는 박스 + 계산된 스타일 |
| Layout | 각 박스가 **어디에, 얼마나 크게** 놓이는가 | 위치와 크기(geometry) |
| Paint | 각 박스를 **무슨 순서로 무엇을** 칠하는가 | 그리기 명령 목록 |
| Composite | 여러 **레이어를 어떻게 겹쳐** 한 장으로 만드는가 | 최종 프레임 |

DOM 과 CSSOM 은 메모리 안의 자료구조다. 이 단계에서는 아무것도 그려지지 않는다.
화면에 무언가 칠해지는 것은 Paint 이후다.

### 왜 필요한가

각 단계는 앞 단계의 결과만 입력으로 받는다. 그래서 무언가 바뀌었을 때
**바뀐 단계부터 다시** 돌리면 되고 처음부터 다시 할 필요가 없다.

```text
위치·크기가 바뀜  → Layout 부터 다시
색만 바뀜        → Paint 부터 다시
투명도·변형만 바뀜 → Composite 만 다시 (레이어로 분리된 경우)
```

이 성질이 Reflow 와 Repaint 의 비용 차이, `opacity`·`transform` 애니메이션이
싼 이유의 바탕이 된다.

### 어떻게 동작하는가

**1. 파싱 — 바이트에서 DOM 까지**

```text
바이트 → 문자 → 토큰 → 노드 → DOM 트리
```

토큰은 납작한 목록이다. `<p>Hi</p>` 는 `시작 태그 p`, `텍스트 Hi`, `종료 태그 p`
세 개가 나란히 나온다. 트리 빌더가 이것을 "p 노드 아래 텍스트 노드"라는 부모·자식
관계로 바꾼다. 이 관계를 가진 단위가 **노드(Node)** 다. 파싱은 문서를 위에서 아래로
순차 진행한다. CSS 도 같은 방식으로 CSSOM 이 된다.

DOM 의 `Node` 는 트리에 들어가는 모든 것의 공통 인터페이스다. **요소(Element)** 는
그중 태그로 만들어진 노드다.

```html
<p>Hi <b>there</b><!-- memo --></p>
```

```text
Element  p
 ├─ Text     "Hi "
 ├─ Element  b
 │   └─ Text "there"
 └─ Comment  " memo "
```

노드는 다섯 개이고 요소는 `p`, `b` 둘이다. 모든 요소는 노드지만 모든 노드가
요소는 아니다. `Text`, `Comment`, `Document`, `DocumentType` 은 요소가 아닌 노드다.

**2. Render Tree — 존재할 박스를 고른다**

DOM 과 CSSOM 을 합쳐 **박스를 만드는 것**만 남기고 각 박스에 최종 스타일을 붙인다.
DOM 과 1:1 이 아니다. 빠지는 것과 추가되는 것은 [꼬리 질문](#render-tree-에서-빠지는-것과-추가되는-것은)에서 다룬다.

**3. Layout — 위치와 크기를 계산한다**

Render Tree 의 각 박스가 뷰포트 안에서 어디에, 얼마나 크게 놓이는지 계산한다.
Render Tree 에 있는 박스는 모두 이 단계에서 자리를 받는다.

**4. Paint — 그리기 명령을 만든다**

스타일은 이미 계산되어 있다. Paint 는 그 결과로 배경, 테두리, 텍스트, 그림자를
어떤 순서로 칠할지 명령 목록을 만든다. Render Tree 에 있어도 칠하지 않는 박스가
있다(`visibility: hidden`).

**5. Composite — 레이어를 합친다**

페이지는 여러 레이어로 나뉘어 그려질 수 있다. 이 레이어들을 순서대로 겹쳐
한 프레임을 만들고 화면에 보낸다. `opacity` 의 투명도 적용도 주로 이 단계에서 일어난다.

위 다섯 단계는 면접과 학습에 쓰는 표준 모델이다. 실제 브라우저 구현은 더 잘게 나뉜다.
[검증 TODO](#검증-todo) 를 본다.

## 심화

<!-- 다룰 것: parser-blocking script · async, defer, ES module 의 실행 차이 ·
     Reflow 와 Repaint 의 비용 차이 · 합성 전용 속성 · Critical Rendering Path -->

## 실무 적용

### 조건부 렌더링과 `display: none`

React 에서 요소를 숨기는 두 방법은 DOM 에 남는지가 다르고, 그 결과가 실무에서 갈린다.

```jsx
{show && <Modal />}                          // show=false 면 노드를 만들지 않음
<Modal style={{ display: show ? 'block' : 'none' }} />  // 노드는 DOM 에 남고 Render Tree 에서만 빠짐
```

| | 조건부 렌더링 | `display: none` |
|---|---|---|
| 실제 DOM | 없음 | 있음 |
| 컴포넌트 | 언마운트 | 마운트 유지 |
| 내부 state | 사라짐 (다시 열면 초기값) | 유지 |
| `useEffect`·구독·타이머 | cleanup 됨 | 계속 동작 |
| 토글 비용 | 노드 생성·제거와 마운트 | 스타일 재계산과 Layout |

- 탭 안의 입력값처럼 상태를 보존해야 하면 `display: none`
- 무겁고 드물게 열리는 것(모달, 큰 차트)은 조건부 렌더링. 숨긴 동안 메모리와 effect 비용이 없다

### `opacity: 0` 으로 숨긴 요소가 클릭된다

`opacity: 0` 은 시각 효과일 뿐 숨김이 아니다. 투명한 버튼이 다른 요소 위에 남아
클릭을 가로채는 버그가 생긴다. 페이드 아웃 후에는 `visibility: hidden` 으로 바꾸거나
`pointer-events: none` 을 함께 준다.

## 면접 예상 질문

### Q1. HTML 을 내려받은 뒤 화면이 그려질 때까지 무슨 일이 일어나는가

**30초**

HTML 은 파싱해서 DOM 을, CSS 는 파싱해서 CSSOM 을 만듭니다. 둘을 합쳐 화면에 보일
노드만 골라 최종 스타일을 붙인 것이 Render Tree 입니다. Layout 에서 각 박스의 위치와
크기를 계산하고, Paint 에서 그 박스들을 어떤 순서로 무엇을 칠할지 그리기 명령을 만듭니다.
마지막으로 Composite 에서 레이어들을 합쳐 한 프레임으로 화면에 보냅니다.

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

### `display: none`, `visibility: hidden`, `opacity: 0` 은 어떻게 다른가

"어느 단계에서 빠지는가"로 정리된다.

```text
display: none       DOM ✓ → Render Tree ✗           (Layout 부터 전부 빠짐)
visibility: hidden  DOM ✓ → Render Tree ✓ → Layout ✓ → Paint 에서 빠짐
opacity: 0          DOM ✓ → Render Tree ✓ → Layout ✓ → Paint ✓ → 투명도 0 으로 합성
```

| | `display: none` | `visibility: hidden` | `opacity: 0` |
|---|---|---|---|
| DOM | 있음 | 있음 | 있음 |
| Render Tree | 없음 | 있음 | 있음 |
| 공간 차지 | 안 함 | 함 | 함 |
| 클릭·hover | 받지 않음 | 받지 않음 | **받음** |
| 스크린 리더 | 읽지 않음 | 읽지 않음 | 읽음 |
| 자식이 되살릴 수 있나 | 불가 | 자식에 `visible` 주면 보임 | 불가 (투명도는 곱해짐) |

공간은 외우지 않고 추론한다. Render Tree 에 있으면 Layout 의 입력이 되고,
Layout 에서 자리를 받으므로 공간을 차지한다.

`visibility` 의 값은 `visible`, `hidden`, `collapse` 셋이다.
`collapse` 는 표의 행·열과 flex 아이템에서만 다르게 동작하고, 그 외 요소에서는 `hidden` 과 같다.

- 표의 행·열: 그 행·열을 접어 공간을 없애되, 다른 열의 너비 계산은 유지해 표가 출렁이지 않게 한다
- flex 아이템: 주축 방향 공간은 없애고 교차축 크기(줄 높이)는 남긴다

### `visibility: hidden` 은 Layout 이 있는데 왜 클릭되지 않는가

클릭 위치의 요소를 찾는 hit testing 은 두 단계다.

```text
① Layout 좌표로 후보를 찾는다            필요조건
② 상호작용 가능한 박스인지 거른다        충분조건
     visibility: hidden  → 제외
     pointer-events: none → 제외
     inert 속성           → 제외
```

픽셀 색이 아니라 좌표로 후보를 찾기 때문에 `opacity: 0` 은 클릭된다.
`visibility: hidden` 은 "자리만 남기고 없는 것으로 친다"는 선언이라 클릭, 포커스,
스크린 리더 모두에서 일관되게 제외된다. 반면 `opacity` 는 숨김의 의미가 없는 시각 효과다.

판정은 박스별 속성이다. 부모가 `hidden` 이어도 자식에 `visibility: visible` 을 주면
그 자식은 보이고 클릭된다.

### Render Tree 에서 빠지는 것과 추가되는 것은

기준은 **박스를 만드는가**다. `display: none` 은 그 대표 사례다.

**DOM 에 있지만 빠지는 것**

| 경우 | 이유 |
|---|---|
| `display: none` 과 그 자손 | 박스를 만들지 않음 |
| `<head>`, `<script>`, `<style>`, `<meta>`, `<link>`, `<title>` | UA stylesheet 가 `display: none` 을 줌 |
| `hidden` 속성이 붙은 요소 | UA stylesheet 의 `[hidden] { display: none }` |
| 주석, `<!DOCTYPE>` | 요소도 텍스트도 아닌 노드 |
| 블록 사이의 공백만 있는 Text 노드 | 공백이 접혀 박스가 생기지 않는 경우가 있음 ([검증 TODO](#검증-todo)) |

**절반만 빠지는 것** — `display: contents` 는 자기 박스는 만들지 않고 자식의 박스는 만든다.

**DOM 에 없지만 추가되는 것**

- `::before`, `::after`, `::marker`, `::first-letter` 같은 의사 요소
- 익명 박스. 블록 안에 텍스트와 블록이 섞이면 텍스트를 감싸는 이름 없는 박스가 생긴다

"그릴지 말지"는 한 단계에서 정해지지 않는다. Render Tree 가 **박스의 존재**를 거르고,
Paint 가 **칠할지**를 거르고, 래스터화와 합성 단계에서 화면 밖 영역의 처리를 미루거나 생략한다.

## 흔한 오해

- **"DOM 과 CSSOM 이 그려진다"** — 둘은 자료구조다. 그리는 것은 Paint 이후다.
  Paint 이전 단계에 "그린다"는 표현을 쓰면 단계를 구분하지 못하는 것으로 들린다.
- **"CSS 로 숨기면 DOM 에서 빠진다"** — DOM 은 HTML 로 만든다. CSS 는 노드를 지우지 못하고
  Render Tree 에서 거를 뿐이다. `display: none` 인 요소도 `querySelector` 로 찾힌다.
- **"Node 와 Element 는 같다"** — Element 는 Node 의 한 종류다. `childNodes` 는 Text·Comment
  노드까지, `children` 은 요소만 센다. 줄바꿈 공백도 Text 노드라 두 값이 다르게 나온다.
- **"`hidden` 속성은 무조건 숨긴다"** — UA stylesheet 의 `display: none` 일 뿐이라
  작성자 CSS 의 `display: block` 같은 선언에 덮인다.
- **"`visibility: hidden` 은 공간을 차지하지 않는다"** — Render Tree 에 남아 Layout 에서
  자리를 받는다. 공간을 없애려면 `display: none` 이다.

## 직접 재현하기

<!-- Performance 패널에서 Parse HTML, Recalculate Style, Layout, Paint, Composite Layers 를 확인한다. -->

### 세 가지 숨김 방식 비교

1. 아무 페이지에서 DevTools 를 열고 Console 에 붙여 넣는다.

   ```js
   document.body.insertAdjacentHTML('afterbegin', `
     <div style="border:2px solid red">
       <span>A</span>
       <span style="display:none">B</span>
       <span style="visibility:hidden" onclick="alert('C')">C</span>
       <span style="opacity:0" onclick="alert('D')">D</span>
       <span>E</span>
     </div>`);
   ```

2. 화면을 본다.
   - B 자리에는 간격이 없다 → Render Tree 에 없어 Layout 에서 자리를 받지 않았다
   - C, D 자리에는 글자 폭만큼 간격이 있다 → Layout 에서 자리를 받았다
   - span 사이 줄바꿈도 공백 Text 노드라 약간의 간격을 만든다. C·D 의 폭과 구분한다

3. C 와 D 자리를 클릭한다.
   - C 는 반응하지 않는다 → `visibility: hidden` 은 hit testing 에서 제외된다
   - D 는 alert 가 뜬다 → `opacity: 0` 은 클릭을 받는다

4. Elements 패널에서 B 를 찾는다. 있다 → `display: none` 이어도 DOM 에 남는다.

### Node 와 Element 개수 비교

위 div 를 넣은 상태에서 Console 에 입력한다.

```js
const div = document.body.firstElementChild;
div.childNodes.length; // 요소 5개 + 그 사이와 양끝의 공백 Text 노드 6개 = 11
div.children.length;   // 요소만 = 5
```

## 검증 TODO

- 실제 Chrome 의 렌더링 단계 구분(RenderingNG 의 Style, Layout, Pre-paint, Paint, Commit,
  Raster, Composite 등)과 Render Tree 에 해당하는 내부 구조(LayoutObject 트리)의 대응
- "invisible box 는 상호작용할 수 없다"를 규정한 스펙 위치 (CSS Display 의 `visibility` 절로 추정)
- `visibility: collapse` 의 표 행·열에서 열 너비가 유지되는 정확한 규칙(CSS Tables 3)과 브라우저별 지원
- 공백만 있는 Text 노드가 박스를 만드는 조건 (CSS Text 의 white-space 처리 규칙)
- `content-visibility: auto` 가 화면 밖 하위 트리의 Layout·Paint 를 건너뛰는 방식.
  [웹 성능](../05-security-and-performance/web-performance.md) 에서 다룬다

## 관련 문서

- [웹 성능](../05-security-and-performance/web-performance.md) — 렌더링 비용과 합성 전용 속성
- [이벤트 루프](../04-javascript-runtime/event-loop.md) — 렌더링이 실행되는 시점

## 참고 자료

- [HTML Standard — Parsing HTML documents](https://html.spec.whatwg.org/multipage/parsing.html)
- [HTML Standard — Rendering (UA stylesheet)](https://html.spec.whatwg.org/multipage/rendering.html)
- [DOM Standard — Interface Node](https://dom.spec.whatwg.org/#interface-node)
- [CSS Display Module — visibility](https://www.w3.org/TR/css-display-3/#visibility)
- [MDN — `<script>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
- [MDN — visibility](https://developer.mozilla.org/en-US/docs/Web/CSS/visibility)
- [Chrome — Inside look at modern web browser](https://developer.chrome.com/blog/inside-browser-part1)
- [Chrome — RenderingNG architecture](https://developer.chrome.com/docs/chromium/renderingng-architecture)
- [web.dev — Learn Performance](https://web.dev/learn/performance/)
