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

DOM 을 만드는 것은 HTML 파서만이 아니다. JavaScript 도 만들고 바꾼다.

| | DOM 을 만드는가 | DOM 을 바꾸는가 |
|---|---|---|
| HTML 파서 | HTML 을 읽어 노드를 만든다 | — |
| JavaScript | `createElement`, `innerHTML` 등으로 만든다 | 추가, 수정, 삭제 모두 가능 |
| CSS | 못 한다 | 못 한다. Render Tree 에서 거를 뿐이다 |

DOM 은 HTML 파싱 결과에 JavaScript 가 가한 변경을 더한 것이다. 대부분의 SPA 는 HTML 에
`<div id="root"></div>` 하나만 두고 화면의 나머지 노드를 전부 JavaScript 로 만든다.
JavaScript 는 파싱 도중에도 실행되어 DOM 을 바꿀 수 있고, 이것이
[parser-blocking script](#parser-blocking-script) 의 원인이 된다.

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

<!-- 다룰 것: ES module 의 실행 세부 ·
     Reflow 와 Repaint 의 비용 차이 · 합성 전용 속성 · Critical Rendering Path -->

### parser-blocking script

`async`, `defer`, `type="module"` 이 없는 일반 `<script>` 를 만나면 파서는 멈춘다.

```text
HTML 파싱 ──▶ <script src> 발견 ──▶ [다운로드] ──▶ [실행] ──▶ 파싱 재개
                                  └──── 이 구간 동안 아래쪽 DOM 없음 ────┘
```

이유는 파서가 다음에 읽을 내용을 확정할 수 없기 때문이다. `document.write()` 는
파서가 지금 읽는 위치에 HTML 을 끼워 넣는다.

```html
<p>첫 문단</p>
<script>
  document.write('<p>스크립트가 넣은 문단</p>');
</script>
<p>마지막 문단</p>
```

스크립트가 이런 일을 할지는 실행해 보기 전에 알 수 없다. 앞질러 파싱하면 의도와 다른
DOM 이 만들어질 수 있으므로 실행이 끝날 때까지 기다린다.

- 실행 시점의 DOM 에는 그 `<script>` 위쪽 노드만 있다. 아래쪽 요소를 찾으면 `null` 이다
- 인라인 스크립트는 실행하는 동안, `src` 로 불러오는 외부 스크립트는 다운로드와 실행 동안 막는다
- 막힌 동안 스크립트 아래쪽은 DOM 이 없어 화면에 나올 수 없다. `<head>` 에 있으면 첫 화면 전체가 늦어진다

`<script>` 를 `</body>` 직전에 두는 관례는 막을 DOM 이 아래에 남지 않게 하려는 것이다.
[`async` 와 `defer`](#async-와-defer) 는 위치를 옮기지 않고 파서를 막지 않게 하는 방법이다.

### async 와 defer

일반 스크립트가 막는 두 구간 중 다운로드는 네트워크를 기다리는 시간일 뿐이라 파서가 같이
기다릴 이유가 없다. `async` 와 `defer` 는 공통으로 **다운로드를 파싱과 병렬로** 진행한다.
다른 것은 실행 시점이다.

```text
일반   HTML ━━━━┫▓▓▓▓ ██┣━━━━━━━━━━━━━━━━━━━━
                 다운로드·실행 동안 파싱 정지

async  HTML ━━━━━━━━━━━━┫██┣━━━━━━━━━━━━━━━━━
       다운로드 ▓▓▓▓▓▓▓▓  ↑ 도착하는 즉시 실행. 그 순간 파싱이 멈춘다

defer  HTML ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫██
       다운로드 ▓▓▓▓▓▓▓▓                     ↑ 파싱이 끝난 뒤 실행
```

| | 다운로드 동안 파싱 | 실행 시점 | 실행 순서 |
|---|---|---|---|
| 일반 | 멈춤 | 다운로드 직후, 그 태그 위치에서 | 문서 순서 |
| `async` | 계속 | 다운로드 직후, 파싱 중 아무 위치에서 | 도착 순서 |
| `defer` | 계속 | HTML 파싱이 끝난 뒤 | 문서 순서 |

일반과 `async` 는 다운로드 동안 파싱이 다르고, `async` 와 `defer` 는 실행 시점이 다르다.

- `async` 도 실행하는 순간에는 파서를 멈춘다. 막지 않는 것은 다운로드 구간뿐이다
- `async` 의 실행 위치는 도착 시점에 달려 있어 예측할 수 없다. 아래쪽 DOM 이 아직 없을 수 있다
- `defer` 는 `DOMContentLoaded` 이벤트 직전에 실행되므로 항상 완성된 DOM 을 본다.
  `async` 는 `DOMContentLoaded` 보다 앞일 수도 뒤일 수도 있다
- 두 속성은 `src` 가 있는 외부 스크립트에만 효과가 있다. 인라인 스크립트에서는 무시된다.
  다운로드할 것이 없으니 분리할 것도 없다
- `type="module"` 은 속성 없이도 `defer` 처럼 파싱이 끝난 뒤 실행된다. 세부는 [검증 TODO](#검증-todo)

선택 기준은 의존 관계와 실행 시점의 이득이다.

```text
DOM 이나 다른 스크립트에 의존하는가?
 ├─ 예    → defer   완성된 DOM, 문서 순서 보장
 └─ 아니오 → 빨리 실행되는 게 이득인가?
            ├─ 예    → async   분석, 광고, 에러 수집
            └─ 아니오 → defer   파싱을 끊지 않아 더 안전
```

### script-blocking stylesheet

스크립트는 DOM 뿐 아니라 스타일도 읽는다. `getComputedStyle(el)`, `el.offsetWidth` 는
CSSOM 이 반영된 값을 돌려준다. 그래서 두 규칙이 생긴다.

```text
규칙 1   스크립트 실행은  앞에 있는, 아직 받지 못한 스타일시트를 기다린다
규칙 2   HTML 파싱은     parser-blocking 스크립트의 실행을 기다린다
```

규칙 1 은 스크립트가 실제로 스타일을 읽는지와 관계없이 적용된다. 실행 전에는 무엇을
읽을지 알 수 없기 때문이다. `console.log('hello')` 한 줄짜리 스크립트도 기다린다.

두 규칙은 따로 있고, 스타일시트 뒤에 스크립트가 오면 이어진다.

```text
[스타일시트 뒤에 스크립트가 있을 때]
CSS 다운로드 ◀─기다림─ 스크립트 실행 ◀─기다림─ HTML 파싱
→ 파싱이 CSS 를 간접적으로 기다린다

[스타일시트 뒤에 스크립트가 없을 때]
CSS 다운로드        (중간 고리 없음)        HTML 파싱
→ 둘은 따로 진행한다
```

CSS 가 파싱을 막는 것이 아니라 스크립트가 둘을 잇는다. 연쇄를 끊는 방법은 둘이다.

- 스타일을 읽지 않는 스크립트는 스타일시트보다 앞에 둔다
- 스크립트에 `async` 나 `defer` 를 붙여 규칙 2 를 끊는다

### render-blocking CSS

`<head>` 의 스타일시트는 파싱은 막지 않지만 **렌더링을 막는다.**

```text
HTML 파싱(DOM)   ─────────────────────▶   계속 진행
CSS 다운로드      ───────────▶ 완료
렌더링           ............  대기  ──▶  Render Tree → Layout → Paint
```

받은 데까지만 반영해 그리지 않는 이유는 cascade 다. 같은 속성에 규칙이 여럿 걸리면
명시도가 같을 때 나중에 나온 규칙이 이긴다. 뒤의 규칙이 앞의 결과를 뒤집을 수 있으므로
스타일시트를 다 받기 전에는 최종 스타일을 확정할 수 없다.

```css
/* 10번째 줄 */   .title { color: black; font-size: 16px; }  .sidebar { display: block; }
/* 5000번째 줄 */ .title { color: red;   font-size: 32px; }  .sidebar { display: none; }
```

10번째 줄까지만 반영해 그리면 5000번째 줄이 도착할 때 글자가 커지고 사이드바가 사라지며
레이아웃이 통째로 바뀐다. 스타일 없는 화면이 번쩍였다 바뀌는 이 현상이 FOUC 이고,
렌더링 보류는 이것을 막으려는 설계다.

브라우저는 UA stylesheet 만으로도 Render Tree 를 만들 수 있다. 기다리는 것은 기술적으로
못 그려서가 아니라 일부러 안 그리는 선택이다. 그래서 스타일시트 요청이 실패로 끝나면
그 시트를 빼고 렌더링을 진행한다.

렌더링은 파싱 한 줄마다 일어나지 않는다. 렌더링할 기회가 올 때마다 그 시점의 DOM 과
CSSOM 으로 파이프라인을 돌리므로 긴 HTML 은 위에서부터 점진적으로 보인다.
화면의 어느 부분이 보이려면 두 조건이 모두 필요하다.

```text
① 그 부분의 DOM 이 파싱됐다          parser-blocking script 가 막을 수 있다
② render-blocking CSS 가 준비됐다     스타일시트가 막는다
```

body 중간의 스크립트가 파싱을 막고 있어도, CSS 가 준비됐다면 위쪽 콘텐츠는 보일 수 있다.
CSS 가 아직이면 위쪽도 보이지 않는다.

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

일반 `<script>` 를 만나면 파서는 스크립트를 다운로드하고 실행할 때까지 멈춥니다.
스크립트가 `document.write` 처럼 DOM 을 바꿀 수 있어서, 실행 전에는 뒤에 올 내용이
확정되지 않기 때문입니다. 그동안 스크립트 아래쪽 DOM 이 만들어지지 않아 그 부분의 표시가
늦어지고, 앞에 아직 받지 못한 스타일시트가 있으면 스크립트가 그것까지 기다려 지연이 커집니다.

**2분**

일반 `<script>` 를 만나면 파서는 스크립트를 다운로드하고 실행할 때까지 멈춥니다.
`document.write` 는 파서가 지금 읽는 위치에 HTML 을 끼워 넣는데, 스크립트가 이런 조작을
할지는 실행 전에는 알 수 없습니다. 뒤를 먼저 파싱하면 의도와 다른 DOM 이 만들어질 수 있어서
실행이 끝날 때까지 기다립니다. 그동안 스크립트 아래쪽 DOM 이 없으니 그 부분은 화면에 나오지
않고, `<head>` 에 있으면 첫 화면 전체가 늦어집니다. `src` 로 불러오는 외부 스크립트는
네트워크 왕복까지 더해져 지연이 더 커집니다.

스타일시트 뒤에 스크립트가 오면 연쇄가 생깁니다. 스크립트는 스타일도 읽을 수 있어서 앞에
아직 받지 못한 스타일시트가 있으면 실행을 미룹니다. 스크립트가 CSS 를 기다리고 파싱이
스크립트를 기다리니 결과적으로 CSS 다운로드가 파싱을 막습니다. CSS 다운로드 자체는 파싱을
막지 않으므로, 스타일을 읽지 않는 스크립트라면 스타일시트보다 앞에 두거나
`async`·`defer` 를 붙여 연쇄를 끊습니다.

**심화**

### Q3. `async` 와 `defer` 는 무엇이 다른가

**30초**

둘 다 외부 스크립트를 HTML 파싱과 병렬로 다운로드해, 다운로드 동안 파싱을 막지 않습니다.
차이는 실행 시점입니다. `async` 는 도착하는 즉시 그 순간의 파싱 위치에서 실행되어 파싱을
잠깐 멈추고, 도착 순서대로 실행되므로 순서를 보장하지 않습니다. `defer` 는 HTML 파싱이
끝난 뒤 `DOMContentLoaded` 직전에 문서 순서대로 실행됩니다. 그래서 DOM 이나 다른 스크립트에
의존하면 `defer`, 의존하지 않고 빨리 실행되는 게 이득이면 `async` 를 씁니다.

**2분**

**심화**

### Q4. Reflow 와 Repaint 는 어떻게 다르며 무엇이 더 비싼가

**30초**

**2분**

**심화**

### Q5. CSS 는 렌더링을 차단하는가

**30초**

예, 막습니다. HTML 파싱은 계속되지만, CSS 를 다 받아 CSSOM 을 만들어야 cascade 의
최종 결과를 알 수 있습니다. 그 전에 그리면 스타일이 뒤바뀌는 FOUC 가 생기므로 브라우저는
렌더링을 미룹니다. 그래서 CSS 가 느리면 흰 화면이 길어집니다.

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

### 스타일시트 뒤에 스크립트가 없으면 CSS 는 파싱을 막는가

막지 않는다. 파싱이 CSS 를 기다리는 것은 스크립트가 중간에 낄 때뿐이다
([script-blocking stylesheet](#script-blocking-stylesheet)). 다만 렌더링은 여전히 막는다.

### DOM 은 다 만들어졌는데 CSS 가 아직이면 화면이 그려지는가

그려지지 않는다. 사용자에게는 이전 화면, 새 탭이면 흰 화면이 그대로 보인다.
render-blocking 스타일시트가 준비될 때까지 렌더링을 미루기 때문이다.

원인을 "CSSOM 이 없어 Render Tree 를 못 만든다"로 설명하면 틀린다. UA stylesheet 만으로도
만들 수 있다. cascade 의 최종 결과를 모른 채 그리면 FOUC 가 생기므로 일부러 안 그리는 것이다.

### 스타일시트 요청이 404 이거나 응답이 없으면 어떻게 되는가

```text
404              즉시 실패 → 그 시트를 빼고 렌더링 진행
응답 없음(hang)   요청이 실패로 끝날 때까지 대기 → 그동안 흰 화면
```

렌더링 보류는 선택이므로 요청이 끝나면 기다릴 이유가 사라진다. 위험한 쪽은 응답 없음이다.
렌더링 전용 타임아웃이 아니라 네트워크 요청의 타임아웃까지 기다리므로 흰 화면이 길어진다.

내가 통제하지 못하는 리소스 하나가 페이지 전체를 멈추게 하는 지점을 프론트엔드
SPOF(단일 장애점)라고 한다. 외부 도메인의 render-blocking CSS 와 parser-blocking 스크립트가
대표적이다. 우리 서버가 멀쩡해도 외부 폰트 CSS 하나가 응답하지 않으면 사이트 전체가 흰 화면이 된다.

### 분석 스크립트와 앱 스크립트에는 각각 무엇을 붙이는가

- `analytics.js` (다른 코드와 무관한 외부 분석 도구) → `async`.
  DOM 에도 다른 스크립트에도 의존하지 않고, 일찍 실행될수록 기록이 정확하다
- `app.js` (`#root` 를 찾고 먼저 로드한 `lib.js` 를 사용) → `defer`.
  완성된 DOM 이 필요하고 `lib.js` 다음에 실행되어야 한다

### `lib.js` 와 `app.js` 에 둘 다 `async` 를 붙이면

순서를 보장하지 않고 실행 위치도 예측할 수 없어 두 가지 버그가 생길 수 있다.

```text
① app.js 가 lib.js 보다 먼저 도착  → lib 의 함수가 아직 없음 → ReferenceError
② app.js 가 HTML 파싱 도중 도착    → #root 가 아직 파싱 전  → getElementById 가 null
```

네트워크 상황에 따라 재현되거나 안 되므로 로컬에서는 멀쩡하고 운영에서만 간헐적으로 깨진다.

### 분석 스크립트에 `defer` 를 붙이면 무엇을 잃는가

동작은 한다. 하지만 HTML 파싱이 끝날 때까지 실행되지 않으므로 그 전에 떠난 사용자는
기록되지 않는다. 이 누락은 무작위가 아니라 일찍 이탈한 사용자에게 몰린다.

```text
실제   1,000명 방문 · 300명 이탈 → 이탈률 30%
기록     700명 방문 ·   0명 이탈 → 이탈률  0%
```

측정하려던 집단이 통째로 빠져 이탈률이 실제보다 낮게 나온다. 페이지가 느려질수록 더 많이
빠지므로 문제가 심해질수록 지표에서는 덜 보인다. 분석 도구가 대부분 `async` 를 권하는
이유다. 대신 `async` 는 도착 순간 파서를 잠깐 멈추므로, 파싱을 조금 희생하고 기록 시점을
앞당기는 트레이드오프다.

## 흔한 오해

- **"DOM 과 CSSOM 이 그려진다"** — 둘은 자료구조다. 그리는 것은 Paint 이후다.
  Paint 이전 단계에 "그린다"는 표현을 쓰면 단계를 구분하지 못하는 것으로 들린다.
- **"DOM 은 HTML 로만 만든다"** — HTML 파서와 JavaScript 가 함께 만든다. 대부분의 SPA 는
  화면의 노드 대부분을 JavaScript 로 만든다.
- **"CSS 로 숨기면 DOM 에서 빠진다"** — DOM 은 HTML 파서와 JavaScript 가 만든다. CSS 는 노드를 지우지 못하고
  Render Tree 에서 거를 뿐이다. `display: none` 인 요소도 `querySelector` 로 찾힌다.
- **"Node 와 Element 는 같다"** — Element 는 Node 의 한 종류다. `childNodes` 는 Text·Comment
  노드까지, `children` 은 요소만 센다. 줄바꿈 공백도 Text 노드라 두 값이 다르게 나온다.
- **"`hidden` 속성은 무조건 숨긴다"** — UA stylesheet 의 `display: none` 일 뿐이라
  작성자 CSS 의 `display: block` 같은 선언에 덮인다.
- **"`visibility: hidden` 은 공간을 차지하지 않는다"** — Render Tree 에 남아 Layout 에서
  자리를 받는다. 공간을 없애려면 `display: none` 이다.

- **"CSS 가 파싱을 막는다"** — CSS 다운로드 자체는 파싱을 막지 않는다. 스타일시트 뒤의
  스크립트가 CSS 를 기다리고, 파서가 그 스크립트를 기다릴 때만 간접적으로 막힌다.
- **"스타일을 읽지 않는 스크립트는 CSS 를 기다리지 않는다"** — 실행 전에는 무엇을 읽을지
  알 수 없으므로 앞에 받지 못한 스타일시트가 있으면 항상 기다린다.
- **"스크립트 연쇄 때문에 CSS 가 렌더링을 막는다"** — 연쇄가 막는 것은 파싱이다.
  렌더링은 스크립트와 관계없이 render-blocking 스타일시트가 직접 막는다.
- **"CSS 를 받은 데까지는 먼저 그린다"** — cascade 때문에 뒤의 규칙이 앞을 뒤집을 수 있어
  render-blocking 스타일시트는 다 받을 때까지 렌더링을 미룬다.
- **"`async` 는 파싱을 전혀 막지 않는다"** — 다운로드 동안만 막지 않는다. 도착해서 실행하는
  순간에는 파서가 멈춘다.
- **"인라인 스크립트에 `defer` 를 붙이면 지연 실행된다"** — `async` 와 `defer` 는 `src` 가
  있는 외부 스크립트에만 효과가 있다. 인라인에서는 무시되고 일반 스크립트로 동작한다.

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

### 스크립트 실행 시점의 DOM

1. 아래 내용을 `test.html` 로 저장한다.

   ```html
   <!doctype html>
   <p id="a">위</p>
   <script>
     console.log('a:', document.getElementById('a'));
     console.log('b:', document.getElementById('b'));
   </script>
   <p id="b">아래</p>
   ```

2. DevTools 를 연 빈 탭에 파일을 끌어다 놓고 Console 을 본다.
   - `a` 는 `<p id="a">` 가 찍힌다
   - `b` 는 `null` 이 찍힌다 → 스크립트가 실행되는 순간의 DOM 에는 그 위쪽만 있다.
     파서가 스크립트에서 멈춰 아래쪽을 아직 만들지 않았다

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
- 파서가 parser-blocking 스크립트에서 멈춘 동안 이미 파싱된 위쪽 콘텐츠를 그리는 조건 (브라우저 구현)
- `type="module"` 과 `defer` 스크립트도 실행 전에 script-blocking stylesheet 를 기다리는지
  (HTML 스펙 「Interactions of styling and scripting」)
- `<body>` 중간의 `<link rel="stylesheet">` 가 그 뒤 콘텐츠의 렌더링만 막는지
  (HTML 스펙의 render-blocking 정의와 브라우저 구현)
- 렌더링 기회가 오는 시점과 파싱의 관계 (HTML 스펙 「update the rendering」,
  [이벤트 루프](../04-javascript-runtime/event-loop.md) 에서 다룬다)
- 브라우저별 연결·응답 타임아웃 값과, render-blocking 리소스에 별도 상한을 두는지
- `type="module"` 스크립트에 `async` 를 붙였을 때의 실행 시점과, 인라인 module 에서의 동작
- `async` 와 `defer` 를 동시에 붙였을 때 어느 쪽이 적용되는지 (HTML 스펙 script 처리 모델)
- `async`·`defer` 실행 순서를 직접 재현하는 절차. 응답을 지연시키는 서버가 필요해 아직 돌려보지 않았다

## 관련 문서

- [웹 성능](../05-security-and-performance/web-performance.md) — 렌더링 비용과 합성 전용 속성
- [이벤트 루프](../04-javascript-runtime/event-loop.md) — 렌더링이 실행되는 시점

## 참고 자료

- [HTML Standard — Parsing HTML documents](https://html.spec.whatwg.org/multipage/parsing.html)
- [HTML Standard — Rendering (UA stylesheet)](https://html.spec.whatwg.org/multipage/rendering.html)
- [DOM Standard — Interface Node](https://dom.spec.whatwg.org/#interface-node)
- [CSS Display Module — visibility](https://www.w3.org/TR/css-display-3/#visibility)
- [HTML Standard — The script element](https://html.spec.whatwg.org/multipage/scripting.html#the-script-element)
- [HTML Standard — Interactions of styling and scripting](https://html.spec.whatwg.org/multipage/semantics.html#interactions-of-styling-and-scripting)
- [HTML Standard — Render-blocking mechanism](https://html.spec.whatwg.org/multipage/dom.html#render-blocking-mechanism)
- [MDN — Cascade](https://developer.mozilla.org/en-US/docs/Web/CSS/Cascade)
- [web.dev — Render blocking CSS](https://web.dev/articles/critical-rendering-path/render-blocking-css)
- [MDN — `<script>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script)
- [MDN — visibility](https://developer.mozilla.org/en-US/docs/Web/CSS/visibility)
- [Chrome — Inside look at modern web browser](https://developer.chrome.com/blog/inside-browser-part1)
- [Chrome — RenderingNG architecture](https://developer.chrome.com/docs/chromium/renderingng-architecture)
- [web.dev — Learn Performance](https://web.dev/learn/performance/)
