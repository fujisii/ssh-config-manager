#!/bin/sh

# --------------------
# 引数の設定
# --------------------

# 本番環境・ツール等をconfigファイルから除外する場合はtrue
is_dev=false
# Include形式のconfigファイルを出力する場合はtrue
is_include=false

if [ -n "$1" ]; then
    if [ $1 = "dev" ]; then
        is_dev=true
    fi
fi
if [ -n "$2" ]; then
    if [ $2 = "include" ]; then
        is_include=true
    fi
fi

# --------------------
# configファイルの作成
# --------------------

# リポジトリディレクトリの絶対パス
cd `dirname $0`
repository=`pwd`
# ファイル名に特定の文字列を含むファイルを除外
conditions="-not -name '.gitkeep' -not -name '.DS_Store'"
if "${is_dev}"; then
    conditions+=" -not -name '*production*' -not -name '*tool*'"
fi
files=`eval find config.d -type f $conditions | sort -n`

rm -f config

for file in ${files}
do
    if "${is_include}"; then
        echo Include ${repository}/${file} >> config
    else
        cat ${repository}/${file} >> config
        echo >> config
    fi
done

echo "完了しました。"
