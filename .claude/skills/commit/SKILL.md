---
description: 이 저장소의 규칙대로 커밋한다. 분기점 확인, 제목 검사, 본문 항목화를 거친다
disable-model-invocation: true
argument-hint: "[<제목>]"
---

# 커밋

규칙은 `CLAUDE.md` 에 산문으로 있다. 읽는 것과 절차를 거치게 하는 것은 다르다.

## 1. 분기점을 먼저 본다

```bash
git branch --show-current
git --no-pager log --oneline -1
```

**`main` 이면 브랜치를 먼저 만든다.** 작업은 브랜치에서 하고 PR 로 머지한다.

```bash
git checkout -b <type>/<주제> main
git merge-base --is-ancestor main HEAD && echo "main 위"
```

`git checkout -b` 는 현재 `HEAD` 에서 가른다. **어느 브랜치에 서 있었는지 안 보고 부르면
남의 브랜치 위에 얹힌다.**

브랜치 이름은 커밋 type 과 맞춘다. `note/browser-rendering-pipeline` 같은 형태다.

## 2. 무엇이 담기는지 본다

```bash
git status -s
```

`sessions/` 는 `.gitignore` 에 있어 담기지 않는다. **여기 뜨면 `.gitignore` 가 깨진 것이다.**
개인 학습 기록이 공개 저장소에 올라가지 않도록 이 단계에서 확인한다.

## 3. 제목을 짓는다

```text
<type>(<scope>): <제목, 한글, 50자 내>
```

```text
type    init      저장소 최초 구성. 한 번만 쓴다
        note      학습 문서 작성과 보강
        fix       잘못 정리한 내용 교정
        docs      가이드, 템플릿, README
        refactor  문서 구조 개편
        chore     설정과 도구

scope   browser http network runtime security perf os interview meta
```

**제목은 체언으로 끝낸다.** 정리, 추가, 보강, 교정, 갱신, 분리 같은 명사다.
`~함`, `~했다`, `~하게 함` 을 쓰지 않는다. **제목은 문장이 아니라 라벨이다.**

```text
나쁨  note(browser): async 와 defer 의 차이를 정리함
좋음  note(browser): async 와 defer 실행 시점 차이 정리
```

**서술로 짓고 끝을 자르면 서술형이 남는다.** 처음부터 라벨로 짓는다.

## 4. 제목을 검사한다

```bash
scripts/check-title.sh "<제목>"
```

형식, 50자, 서술형 종결, `그리고` 를 본다. **종료 코드 1 이면 고치고 다시 부른다.**

## 5. 본문을 쓴다

주제가 하나면 문단으로 쓴다. **둘 이상이면 `-` 로 항목화한다.**
이어지는 줄은 두 칸 들여쓰고 항목 사이는 빈 줄로 띄운다.

```text
note(runtime): microtask 와 렌더링의 순서 정리

- 렌더링은 task 사이에 들어가고 microtask 큐는 그 전에 비워진다.
  Promise 체인이 길면 렌더링이 그만큼 밀리는 이유가 여기 있다.

- requestAnimationFrame 은 렌더링 직전 단계라 setTimeout 과 위치가 다르다.
  실행 순서 예측 문제 3번이 이 차이를 묻는다.
```

**무엇을 썼는지가 아니라 왜 그렇게 정리했는지를 쓴다.** 무엇은 diff 에 있다.
스쿼시 머지라 이 본문들이 이어 붙으므로, 항목화해두면 머지 후에도 구분된다.

## 6. AI 표기를 넣지 않는다

`Co-Authored-By`, `Generated with` 같은 트레일러를 **커밋에도 PR 본문에도 넣지 않는다.**

## 7. 커밋한다

```bash
git add -A && git commit -F - <<'MSG'
<제목>

<본문>
MSG
```

## PR 을 이미 열었으면

**커밋을 새로 쌓는다. `--amend` 하지 않는다.**
강제 푸시하면 PR 에 force-pushed 기록이 남는다. 어차피 스쿼시 머지라
`main` 에는 커밋 하나로 남는다.

리베이스는 예외다. `main` 을 따라가려면 `--force-with-lease` 만 쓴다.

## 원격에 나가는 것은 확인받는다

`push`, PR 열기, 저장소 설정 변경은 사용자에게 묻고 한다.
