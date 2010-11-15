## Nally 1.4.5 (2009/09/07)

* 修正预览图片时获取文件名的问题。(jjgod)

## Nally 1.4.4 (2009/09/04)

* 修正 ssh 无法连接的问题。(jjgod)
* 修正 Tab 栏无法出现图标的问题。(jjgod)
* 修正 newsmth 附件文件名解码问题。(jjgod)
* 在 Leopard 下默认以 32-bit 模式执行。(jjgod)

## Nally 1.4.3 (2009/08/28)

* 支持 64-bit 和 Snow Leopard。(jjgod)

## Nally 1.4.2

* SSH 到 BBS 时关闭 X11 Forwarding。(mjhsieh)
* 修正半型处理中引发的重绘问题。(mjhsieh)
* 正确处理地址栏输入的地址。(mjhsieh)
* 其他终端相关的相容性改进。(mjhsieh)

## Nally 1.4.1

* (新增) 加入对保存预览图片的试验性支持。
* 修正 GBK 特定高字节 (0x9B) 处理问题。
* 将 GBK 中原映射到 PUA 的字符根据 Unicode 5.0 改为映射到 CJK Ext-A 区。
* 修正对光标处于窗口边界时的检查。(fayewong 报告)
* 修正预览图片时部分内容被窗口标题栏覆盖的问题。(fayewong 报告)

## Nally 1.4.0

* 修正 GBK 特定低字节处理问题。
* 加入对属于 GBK 但不属于 CP936 的 80 个汉字的支持。
* 修正背景色不能延伸到行末的问题。(Evan 报告)
* 修正一些半透明背景绘制的问题。(fishy 报告)
* 修正输入到窗口边沿光标判断的问题。(fayewong)

