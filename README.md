# Narou.rb Docker Image

Narou.rb を Docker で実行するための Docker イメージ<br>
最終的な参照先は同じ作者製の fork 先である [laprusk/narou-docker](https://github.com/laprusk/narou-docker)をベースとしています。 <br>
このページのファイルは quiita のページの手順の為に準備しました。
※https://github.com/whiteleaf7/narou/issues/445 への対応のために更新

# イメージの構成

- Debian Linux
- Ruby 3.4.1
- [改造版 AozoraEpub3](https://github.com/kyukyunyorituryo/AozoraEpub3) から AozoraEpub3-1.1.1b30

# 使い方

```
docker run -it --name narou \
  -e NAROU_PORT=33000 \
  -p 33000:33000 \
  haoling/narou:3.9.0
```

自動的に WEB UI が起動します。<br>
http://localhost:33000/<br>
にアクセスしてください。
