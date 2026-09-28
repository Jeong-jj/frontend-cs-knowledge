#!/bin/bash
# 커밋과 PR 의 제목이 규칙을 지키는지 본다.
#
#   scripts/check-title.sh "<제목>"
#
# 통과하면 0, 걸리면 사유를 내고 1 을 반환한다.
#
# 왜 훅이 아닌가. 스쿼시 머지라 main 에 남는 제목은 PR 제목인데
# commit-msg 훅은 커밋만 본다. 커밋과 PR 을 만드는 자리에서 이것을 부른다.

set -u

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  echo "제목을 인자로 주세요." >&2
  echo "  scripts/check-title.sh \"note(browser): 렌더링 파이프라인 4단계 정리\"" >&2
  exit 1
fi

t="$1"
fail=0

say() { echo "  $1" >&2; fail=1; }

# 1. 형식. scope 는 없어도 통과시킨다
if ! echo "$t" | grep -qE '^(init|note|fix|docs|refactor|chore)(\([a-z-]+\))?: .+'; then
  say "형식이 <type>(<scope>): <제목> 이 아닙니다."
  say "type: init note fix docs refactor chore"
  say "scope: browser http network runtime security perf os interview meta"
fi

# 2. 길이. 제목 부분만 센다
body="${t#*: }"
n=$(echo -n "$body" | wc -m | tr -d ' ')
if [ "$n" -gt 50 ]; then
  say "제목이 ${n}자입니다. 50자 안으로 줄이세요."
fi

# 3. 종결형. 제목은 문장이 아니라 라벨이다
last="${body##* }"
case "$last" in
  *게|*함|*됨|*임|*음|*다|*했다|*한다)
    say "제목이 서술형으로 끝납니다: '$last'"
    say "체언으로 끝내세요. 정리 추가 보강 교정 수정 분리 갱신 반영 같은 명사입니다."
    ;;
esac

# 4. 쪼갤 신호
if echo "$body" | grep -qE '그리고|및 '; then
  say "제목에 '그리고' 나 '및' 이 있습니다. 단위를 쪼개는 것을 먼저 생각하세요."
fi

[ "$fail" -eq 0 ] && exit 0
echo "제목: $t" >&2
exit 1
