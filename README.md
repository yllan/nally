# Nally

Open-Source telnet/ssh BBS client.

## History

### 1.4.9

* 修正短網址打不開的 regression
* 加入自動短網址服務選擇，例如
  	
        nxMg => ppt.cc
        YFIIB => 0rz.tw
        cbt6wym => tinyurl.com
        mid=1726264 => pixiv_member
        id=28497387 => pixiv_illust
        sm1885034 => niconico

* 修正 opt-click URL 不能在背景打開 browser 的 bug。現在可以了。
* 很遺憾，因為用了 block 所以把 deployment target 升高到 10.6。

### 1.4.8

* 修正 10.8 下藍色框的問題。
* 加入 uranusjr 貢獻的 Cmd+上下鍵對應到 PageUp/PageDown。
* 打開 URL 的一些修正。

### 1.4.7

* 修正 crash。
* 使用 uranusjr 開發的功能，可以設定要不要用 image previewer。
* 可同時開啓多個 URL。

### 1.4.6

* 修正 Paste wrap 遇到過長英文會 hang 的 bug。
* Paste wrap 加上避頭尾點的功能。