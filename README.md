Gauche-net-yamareco
===================

Gauche からヤマレコ (https://www.yamareco.com/) の api を呼び出せます。

Gauche-net-oauth2 が必要です。https://github.com/mhayashi1120/Gauche-net-oauth2 をインストールしてください。

API に関しての詳細は本家の Document をご覧ください。https://sites.google.com/site/apiforyamareco/api/rest-api


## Install

    ./configure
    make check
    sudo make install


## OAuth

Web API での authentication のみ動作を確認しています。

    (let1 cred (yamareco-authenticate "**your client id**" "**client secret**" "**redirect uri**")
	  (yamareco-write-credential cred "/path/to/your/favorite/token"))

で access_token を取得して保存できます。

    (let1 cred (yamareco-read-credential "/path/to/your/favorite/token")
	  (GET/json cred "/getArealist"))

みたいな感じで OAuth が必要な機能の利用ができます。
