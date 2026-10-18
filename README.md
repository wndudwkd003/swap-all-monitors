# Swap All Monitors

단축키 한 번으로 좌우 모니터의 창들을 서로 교환하는 GNOME 확장입니다.

이 프로젝트는 **GPT-6-Astra**로 만들었습니다.

## 지원 환경

- GNOME Shell 42
- 모니터 2개

## 설치

프로젝트 폴더에서 다음 명령을 실행하세요. `sudo`는 사용하지 마세요.

```bash
bash install.sh
```

설치 후 로그아웃하고 다시 로그인하면 준비가 끝납니다.
컴퓨터를 껐다 켜도 로그인하면 자동으로 활성화됩니다.

## 사용법

**Super(윈도우 키) + Shift + S**를 누르면 현재 작업 공간의 좌우 모니터 창이 서로 이동합니다. 최소화된 창은 제외됩니다.

## 제거

```bash
gnome-extensions uninstall swapall@local
```

제거 후 로그아웃하고 다시 로그인하세요.
