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
# 除外するファイルの設定
# --------------------
# 除外するファイルの設定
array=()
array+=(".gitkeep")

# macOSの隠しファイルや一時ファイル等を除外する
# 参考: https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
array+=(".DS_Store")
array+=(".AppleDouble")
array+=(".LSOverride")
array+=("Icon")
array+=("._*")
array+=(".DocumentRevisions-V100")
array+=(".fseventsd")
array+=(".Spotlight-V100")
array+=(".TemporaryItems")
array+=(".Trashes")
array+=(".VolumeIcon.icns")
array+=(".com.apple.timemachine.donotpresent")
array+=(".AppleDB")
array+=(".AppleDesktop")
array+=("\"Network Trash Folder\"")
array+=("\"Temporary Items\"")
array+=(".apdisk")

# ファイル名に特定の文字列を含むファイルを除外する
if "${is_dev}"; then
    array+=("*production*")
    array+=("*tool*")
fi

conditions=""
for v in "${array[@]}"
do
    conditions+=" -not -name ${v}"
done

# --------------------
# configファイルの作成
# --------------------

# リポジトリディレクトリの絶対パス
cd `dirname $0`
repository=`pwd`

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
