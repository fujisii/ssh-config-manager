#!/bin/sh

# リポジトリディレクトリの絶対パス
cd `dirname $0`
repository=`pwd`

echo "▼ 実行モードを選択"
echo "[1] 環境: 全て, Include: On"
echo "[2] 環境: 全て, Include: Off"
echo "[3] 環境: 開発, Include: Off"
echo ""
read -p "実行します。よろしいですか？(1/2/3/n [1]) " input_key

case "$input_key" in
    [1]) sh ${repository}/make-config.sh all include ;;
    [2]) sh ${repository}/make-config.sh ;;
    [3]) sh ${repository}/make-config.sh dev ;;
    [nN]) echo "終了します。"; exit; ;;
    *)
        if [ -z "$input_key" ]; then
            sh ${repository}/make-config.sh all include
        else
            echo "不正な値が入力されました。終了します。"; exit;
        fi
esac
