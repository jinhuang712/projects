# project.huangjin.online

黄锦开源项目站点的聚合仓库。每个项目自己的 GitHub Pages 内容（通常是仓库里的 `docs/`）被拉取到 `_site/<项目名>/`，统一部署到 **https://project.huangjin.online/<项目名>/**。

## 工作方式

| 文件 | 作用 |
|---|---|
| `sites.json` | 项目清单：名字、源仓库、分支、目录、要排除的文件 |
| `scripts/assemble.sh` | 浅克隆每个源仓库，把站点目录复制到 `_site/<name>/` |
| `site/` | 根目录内容：索引页 `index.html`、`404.html`、`CNAME`、favicon |
| `.github/workflows/deploy.yml` | push、每 6 小时、手动或 `repository_dispatch` 触发重建并部署 |

## 新增一个项目站点

1. 在 `sites.json` 追加一条记录；
2. 在 `site/index.html` 的列表里加一行；
3. push 到 `main`，或在 Actions 里手动运行 `deploy`；
4. 在个人主页（`personal/personal-page`）的 `.project-links` 里加一个「网站」链接。

## 立即重建（源仓库更新后）

```bash
gh workflow run deploy -R jinhuang712/projects
```

## 本地预览

```bash
scripts/assemble.sh _site
python3 -m http.server -d _site 8001
```

## DNS（火山引擎云解析）

| 类型 | 主机记录 | 记录值 |
|---|---|---|
| CNAME | `project` | `jinhuang712.github.io` |

要用 API 改记录：先 `arkcli auth login volc-sso`，它会把短期 STS 凭据写进 `~/.arkcli/.env`；再调用云解析 OpenAPI（`open.volcengineapi.com`，service `DNS`，version `2018-08-01`，zone ZID `275799`）。
