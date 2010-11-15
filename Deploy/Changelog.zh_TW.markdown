## Nally 1.4.5 (2009/09/07)

* 修正預覽圖片時取得檔案名稱的問題。(jjgod)

## Nally 1.4.4 (2009/09/04)

* 修正 ssh 無法連接的問題。(jjgod)
* 修正 Tab 欄無法出現圖示的問題。(jjgod)
* 修正 newsmth 附件檔案名解讀問題。(jjgod)
* 在 Leopard 下預設以 32-bit 模式執行。(jjgod)

## Nally 1.4.3 (2009/08/28)

* 支援 64-bit 和 Snow Leopard。(jjgod)

## 1.4.2 的修改

* SSH 到 BBS 時關閉 X11 Forwarding。(mjhsieh)
* 修正半型處理中引發的重繪問題。(mjhsieh)
* 正確處理地址欄輸入的地址。(mjhsieh)
* 其他終端相關的相容性改進。(mjhsieh)

## 1.4.1 的修改

* (新增) 加入對預覽圖片存檔的試驗性支援。
* 修正 GBK 特定高位元 (0x9B) 處理問題。
* 將 GBK 中原來對應到 PUA 的字元根據 Unicode 5.0 改為對應到 CJK Ext-A 區。
* 修正對游標處於窗口邊界時的檢查。(fayewong 報告)
* 修正預覽圖片時部分內容被窗口標題欄覆蓋的問題。(fayewong 報告)

## 1.4.0 的修改

* 修正 GBK 特定低位元處理問題。
* 加入對屬於 GBK 但不屬於 CP936 的 80 個漢字的支援。
* 修正背景色不能延伸到行末的問題。(Evan 報告)
* 修正一些半透明背景繪製的問題。(fishy 報告)
* 修正輸入到窗口邊緣游標判斷的問題。(fayewong)

