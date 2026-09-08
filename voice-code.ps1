# voice-code.ps1 — 用「說話」跟 opencode 寫程式
# 原理：Windows 內建語音辨識(STT) → opencode run → 內建語音合成(TTS) 朗讀回覆
# 用法：
#   .\voice-code.ps1                    # 在目前目錄開工，沿用上次對話
#   .\voice-code.ps1 -Fresh             # 開新對話
#   .\voice-code.ps1 -ProjectDir C:\path\to\proj -Model "anthropic/claude-sonnet-4-6"
#   .\voice-code.ps1 -Auto              # 自動批准檔案操作（方便但風險自負）
#   .\voice-code.ps1 -NoSpeech          # 不要朗讀，只要文字
param(
  [int]$Seconds = 20,
  [string]$ProjectDir = (Get-Location).Path,
  [string]$Model = "",
  [switch]$Fresh,
  [switch]$Auto,
  [switch]$NoSpeech,
  [string]$Text = ""
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech

# ---------- 前置檢查 ----------
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
  Write-Host "找不到 opencode，請先安裝：npm install -g opencode-ai" -ForegroundColor Red
  Write-Host "裝完跑 opencode auth login 登入模型供應商，再回來用這支腳本。"
  exit 1
}

# ---------- 語音辨識 ----------
function Get-VoiceText {
  param([int]$TimeoutSec)
  $info = [System.Speech.Recognition.SpeechRecognitionEngine]::InstalledRecognizers() |
    Where-Object { $_.Culture.Name -like 'zh-*' } |
    Select-Object -First 1
  if (-not $info) {
    Write-Host "找不到中文語音辨識引擎。請到 設定→時間與語言→語言→中文→語音→安裝語音辨識。" -ForegroundColor Red
    return ""
  }
  $rec = New-Object System.Speech.Recognition.SpeechRecognitionEngine($info)
  Write-Host ("辨識語言：" + $rec.RecognizerInfo.Culture.Name)
  $rec.LoadGrammar((New-Object System.Speech.Recognition.DictationGrammar))
  $rec.SetInputToDefaultAudioDevice()
  $rec.InitialSilenceTimeout = [TimeSpan]::FromSeconds(5)
  $rec.EndSilenceTimeout = [TimeSpan]::FromSeconds(1.5)
  $rec.BabbleTimeout = [TimeSpan]::FromSeconds(3)
  Write-Host "請說話（$TimeoutSec 秒內，講完停 1.5 秒自動結束）..." -ForegroundColor Cyan
  try { $res = $rec.Recognize([TimeSpan]::FromSeconds($TimeoutSec)) }
  catch { $res = $null }
  finally { $rec.Dispose() }
  if ($res -and $res.Text) { return $res.Text } else { return "" }
}

# ---------- 語音合成 ----------
function Speak-Text {
  param([string]$Text)
  $sp = New-Object System.Speech.Synthesis.SpeechSynthesizer
  $v = $sp.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Culture.Name -like 'zh-*' } | Select-Object -First 1
  if ($v) { $sp.SelectVoice($v.VoiceInfo.Name); Write-Host ("朗讀語音：" + $v.VoiceInfo.Name) }
  else { Write-Host "找不到中文語音，用預設語音朗讀。" -ForegroundColor Yellow }
  $short = $Text
  if ($short.Length -gt 400) { $short = $short.Substring(0, 400) + "。以下省略，全文已存入 voice-log.txt" }
  $sp.Speak($short)
  $sp.Dispose()
}

# ---------- 主流程 ----------
if ($Text -ne "") { $text = $Text; Write-Host "(文字模式，跳過語音辨識)" -ForegroundColor DarkGray }
else {
  $text = Get-VoiceText -TimeoutSec $Seconds
  if (-not $text) { Write-Host "沒聽到內容，結束。" -ForegroundColor Yellow; exit 0 }
}
Write-Host ""
Write-Host ("你說：" + $text) -ForegroundColor Green
$yn = Read-Host "Enter 送出給 opencode / R 重錄 / Q 離開"
if ($yn -eq 'Q' -or $yn -eq 'q') { exit 0 }
if ($yn -eq 'R' -or $yn -eq 'r') { $text = Get-VoiceText -TimeoutSec $Seconds }

$ocArgs = @('run', '--dir', $ProjectDir)
if (-not $Fresh) { $ocArgs += '--continue' }
if ($Model -ne "") { $ocArgs += @('--model', $Model) }
if ($Auto) { $ocArgs += '--auto' }
$ocArgs += $text

Write-Host "opencode 執行中..." -ForegroundColor Cyan
$out = & opencode @ocArgs 2>&1 | Out-String
Write-Host ""
Write-Host $out

$log = Join-Path $ProjectDir 'voice-log.txt'
Add-Content -LiteralPath $log -Encoding UTF8 ("`n===== " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + " =====")
Add-Content -LiteralPath $log -Encoding UTF8 ("你說：" + $text)
Add-Content -LiteralPath $log -Encoding UTF8 ("opencode：" + $out)
Write-Host ("對話已存入 " + $log) -ForegroundColor DarkGray

if (-not $NoSpeech) { Speak-Text -Text $out }
