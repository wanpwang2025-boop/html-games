# 📖 HTML Games 專案說明書

> 對象：想看懂、改寫、擴充這個專案的人。
> 閱讀順序：第 1 章總覽 → 第 3 章模板（先跑起來）→ 第 4 章挑一款拆解 → 第 7/8 章上線。

---

## 目錄

1. [專案總覽](#1-專案總覽)
2. [開發環境與本機執行](#2-開發環境與本機執行)
3. [通用遊戲模板（完整可運行程式碼）](#3-通用遊戲模板完整可運行程式碼)
4. [四款遊戲拆解與調參](#4-四款遊戲拆解與調參)
5. [大廳頁 index.html](#5-大廳頁-indexhtml)
6. [存檔系統 localStorage](#6-存檔系統-localstorage)
7. [全球榜 Supabase 設定](#7-全球榜-supabase-設定)
8. [GitHub 上線流程](#8-github-上線流程)
9. [注意事項總表](#9-注意事項總表)
10. [常見問題 FAQ](#10-常見問題-faq)
11. [擴充：如何做第 5 款遊戲](#11-擴充如何做第-5-款遊戲)

---

## 1. 專案總覽

### 1.1 檔案清單

```
game/
├── index.html               # 大廳頁（四款入口＋最佳成績）
├── angry-birds.html         # 🐦 憤怒鳥（物理彈射，3關＋無限隨機）
├── tower-defense.html       # 🏰 守塔（12波，蓋塔＋合成＋相剋）
├── survivor.html            # 🧛 倖存者（Survivor-like＋全球榜）
├── hippo-water-ballet.html  # 🦛 河馬3D芭蕾（展示型，無輸贏）
├── README.md                # 專案簡介
├── MANUAL.md                # 本說明書
└── .gitignore
```

線上試玩：https://wanpwang2025-boop.github.io/html-games/

### 1.2 技術選型（為什麼這樣設計）

| 決策 | 內容 | 理由 |
|---|---|---|
| 單檔 HTML | 每款遊戲一個 `.html`，CSS＋JS 全內嵌 | 雙擊即玩、GitHub Pages 零設定、參考 [90s-games](https://github.com/prateek121/90s-games) |
| 零依賴 | 除了河馬用 Three.js CDN，其餘純 Canvas＋WebAudio | 無 npm、無 build、不會壞 |
| Canvas 2D | 分辨率固定 `1280×720`，CSS 等比縮放 | 邏輯座標固定，手機桌機同一套碼 |
| WebAudio 合成音效 | `beep()` 函式現場合成 | 免音檔，單檔原則 |
| localStorage 存檔 | key 前綴 `hg-` | 免登入、離線可用 |
| Supabase 全球榜 | 只用 REST＋publishable key | Pages 無後端，借免費 BaaS |

### 1.3 四款共通骨架

每款都是同一個殼，學會一款等於學會全部：

```
<head>：viewport＋<style>（#app/#stage/canvas/#hud/#panel/#tip）
<body>：
  #stage
   ├── canvas#game (width=1280 height=720)
   ├── #hud（藥丸 pill 狀態列）
   ├── #btns（暫停/重來）
   ├── #panel > #card（開場/升級/結算共用面板）
   └── #tip（底部操作提示）
<script>：
  音效 → 狀態 → 輸入 → 更新 update(dt) → 繪圖 draw() → requestAnimationFrame 迴圈
```

---

## 2. 開發環境與本機執行

### 2.1 需要的工具

- 瀏覽器：Chrome／Edge（開發者工具 F12 看 Console）
- 編輯器：VS Code（裝 Live Server 外掛最省事）
- 選用：Node.js（跑語法檢查）、Python（跑靜態伺服器）、`gh` CLI（推 GitHub）

### 2.2 本機執行（三選一）

```sh
# A. 最懶：直接雙擊 index.html（河馬除外，見 9.4）
# B. Python 靜態伺服器
python -m http.server 8000
# → http://localhost:8000/
# C. VS Code Live Server：對 index.html 按 Go Live
```

### 2.3 JS 語法檢查（改完必跑）

本專案用的檢查腳本原理：取出各檔 `<script>` 內文，用 `vm.Script` 只編譯不執行：

```js
// 概念版：node check-syntax.js
const fs = require('fs'), vm = require('vm'), path = require('path');
const dir = 'C:\\Users\\wanp\\Documents\\N8N-DOCKER\\game';
for (const f of ['index.html','angry-birds.html','tower-defense.html','survivor.html']) {
  const html = fs.readFileSync(path.join(dir, f), 'utf8');
  const m = [...html.matchAll(/<script(?![^>]*src)(?![^>]*type="module")[^>]*>([\s\S]*?)<\/script>/g)];
  for (const [i, s] of m.map(x => x[1]).entries())
    try { new vm.Script(s, { filename: f + '#' + i }); console.log(f, 'OK'); }
    catch (e) { console.log(f, 'FAIL:', e.message); process.exitCode = 1; }
}
```

> 注意：`hippo-water-ballet.html` 是 `type="module"`＋`import three`，上面腳本會跳過它，
> 它的錯誤只能開瀏覽器看 Console。

---

## 3. 通用遊戲模板（完整可運行程式碼）

下面是抽取四款共通骨架的**最小完整模板**：存檔新檔 `my-game.html` 貼上就能跑，
包含遊戲迴圈、HUD、結算面板、localStorage 最佳成績、WebAudio 音效、鍵盤＋觸控。
新遊戲一律從這份改（第 11 章有 checklist）。

```html
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>我的遊戲 | My Game</title>
<style>
  *{margin:0;padding:0;box-sizing:border-box}
  html,body{width:100%;height:100%;background:#0b1622;font-family:"Noto Sans TC",system-ui,sans-serif;overflow:hidden}
  #app{width:100vw;height:100vh;display:flex;align-items:center;justify-content:center}
  #stage{position:relative;aspect-ratio:16/9;width:min(100vw,177.78vh);max-height:100vh;border-radius:14px;overflow:hidden;box-shadow:0 20px 80px rgba(0,0,0,.6)}
  canvas{width:100%;height:100%;display:block;touch-action:none}
  #hud{position:absolute;top:10px;left:10px;display:flex;gap:8px;z-index:5;pointer-events:none}
  .pill{background:rgba(8,20,32,.8);border:1px solid rgba(255,255,255,.15);color:#fff;border-radius:999px;padding:6px 14px;font-size:14px;font-weight:800}
  .pill b{color:#ffd166}
  #panel{position:absolute;inset:0;display:none;align-items:center;justify-content:center;background:rgba(0,0,0,.6);z-index:10}
  #card{background:#fffdf4;border-radius:18px;padding:28px 40px;text-align:center}
</style>
</head>
<body>
<div id="app"><div id="stage">
  <canvas id="game" width="1280" height="720"></canvas>
  <div id="hud"><div class="pill">⭐ 分數 <b id="h-score">0</b></div><div class="pill">🏆 最佳 <b id="h-best">—</b></div></div>
  <div id="panel"><div id="card"><h2 id="c-title"></h2><p id="c-sub"></p><button id="c-again">↻ 再來一局</button></div></div>
</div></div>
<script>
"use strict";
const W=1280,H=720;
const cv=document.getElementById('game'),ctx=cv.getContext('2d');
const $=id=>document.getElementById(id);
/* --- 音效 --- */
let AC=null;
function beep(f,d=.1,type='triangle',v=.07){try{AC=AC||new(window.AudioContext||window.webkitAudioContext)();
  const o=AC.createOscillator(),g=AC.createGain();o.type=type;o.frequency.value=f;g.gain.value=v;
  o.connect(g);g.connect(AC.destination);o.start();
  g.gain.exponentialRampToValueAtTime(.001,AC.currentTime+d);o.stop(AC.currentTime+d);}catch(e){}}
/* --- 存檔 --- */
const KEY='hg-mygame-best';let BEST=0;
try{BEST=+(localStorage.getItem(KEY)||0);}catch(e){}
/* --- 狀態 --- */
let score,over;
function reset(){score=0;over=false;$('panel').style.display='none';syncHud();}
function syncHud(){$('h-score').textContent=score;$('h-best').textContent=BEST>0?BEST:'—';}
function die(){over=true;
  if(score>BEST){BEST=score;try{localStorage.setItem(KEY,String(score));}catch(e){}}
  $('c-title').textContent='遊戲結束';$('c-sub').textContent='分數 '+score+'・最佳 '+BEST;
  $('panel').style.display='flex';syncHud();}
/* --- 輸入（鍵盤＋觸控二選一記住座標即可） --- */
const keys={};
addEventListener('keydown',e=>{keys[e.key.toLowerCase()]=true;});
addEventListener('keyup',e=>{keys[e.key.toLowerCase()]=false;});
/* --- 主迴圈：固定 update＋render --- */
let last=0;
function loop(ts){requestAnimationFrame(loop);
  const dt=Math.min(.05,(ts-last)/1000||0);last=ts;
  if(over)return;update(dt);draw();}
function update(dt){score+=Math.floor(dt*10);if(score>500)return die();syncHud();} // ← 換成你的規則
function draw(){ctx.fillStyle='#141428';ctx.fillRect(0,0,W,H);
  ctx.fillStyle='#ffd166';ctx.font='900 60px sans-serif';ctx.textAlign='center';
  ctx.fillText(score,W/2,H/2);} // ← 換成你的畫面
$('c-again').onclick=reset;
reset();requestAnimationFrame(loop);
</script>
</body>
</html>
```

---

## 4. 四款遊戲拆解與調參

### 4.1 🐦 angry-birds.html（約 430 行）

- 玩法：按住紅鳥後拉→放開射出，消滅所有綠豬過關。前 3 關手刻（`LEVELS`），第 4 關起 `genLevel()` 種子隨機無限生成。
- 物理：自寫重力＋圓對矩形碰撞（`circleRect`），無引擎。
- 調參位置：
  - `GRAV=1500` 重力，`dx*9.0` 拉力係數，`1700` 最大初速
  - `BIRD_COLORS` 鳥色，`blk()` 的 `wood:40/glass:22/stone:75` 血量
  - `addScore` 分數：石頭150／木100／豬另計，過關獎勵 `500+剩鳥×300`
- 存檔：過關時寫 `hg-angry-best`（分數）＋`hg-angry-level`（關卡）。

### 4.2 🏰 tower-defense.html（約 465 行）

- 玩法：點符文基座蓋塔，撐過 12 波（含第 5／10／12 波 BOSS），塔可合成（同種同級未滿3級）與出售（返 70%）。
- 數值表都在檔頭，改平衡只動這兩塊：
  - `TOWER`：fire／ice／bolt／arc 的 `cost/range/dmg/rate/chain/slow`
  - `FOE`＋`WAVES`：血攻速賞金、每波 `groups=[種類,隻數,間隔秒]`，波次成長 `mul=1+(wave-1)*.12`
- 相剋（寫在側欄文案，邏輯對應）：骷髏高魔抗→用奧術塔；狼群→雷電鏈傷；石像血厚→集火。
- 存檔：戰敗寫 `hg-tower-wave`（到達波次），勝利寫 `hg-tower-best`（`金＋血×50＋石×100＋殺×10`）。

### 4.3 🧛 survivor.html（約 550 行，功能最多）

系統一覽（按執行順序）：

1. **預渲染精靈**：`makeSprite()` 把敵人渐層＋光暈＋眼睛畫進離屏 canvas，`SPR` 快取每幀只 `drawImage`（怪多也不卡的關鍵）。
2. **星雲背景**：`BG` 1600×1000 預渲染，視差 `.3` 捲動＋霓虹格線。
3. **武器**：飛刀（最近敵自動射擊）＋環繞法球（接觸傷＋`orbCd` 內置冷卻防連打）。
4. **升級池 `UPS`**（10 種）：傷害／射速／數量／法球／移速／血量／磁鐵／護盾／新星，升級暫停＋三選一。
5. **敵人 `FOE`**：slime／bat／golem／elite／boss，血量隨時間 `mul=1+t/75`，BOSS 每 60 秒一隻。
6. **本地榜**：`hg-survivor-board` 存前 10 筆 `{t,k,l,d}`；開場秀前 3。
7. **全球榜**：見第 7 章。
8. 觸控：全屏浮動搖桿（手指落點即原點，半徑 70）。

調參速查：`P.speed=300` 移速、`iv` 生成間隔（`.9→.22`）、`xpNext=8+lvl*4.5` 升級曲線、`magnet=110` 拾取範圍。

### 4.4 🦛 hippo-water-ballet.html（約 474 行，展示型）

- Three.js（CDN `three@0.160.0`）水花＋芭蕾自動演出，14 秒循環：跳水→漣漪→芭蕾→評分（8.5～10 隨機）。
- 不是對戰遊戲：改它請往「加玩法」走（建議：按節奏空白鍵壓水花，評分改為實測）。
- 存檔：每次揭曉分數寫 `hg-hippo-best`（只增不減）。

---

## 5. 大廳頁 index.html

- 四張卡片連結各遊戲；載入時讀 7 個 key 顯示最佳成績，沒紀錄顯示「來當第一個！」。
- 新增第 5 款時：複製一張 `.card`，`href` 指新檔，並在 `<script>` 加讀取對應 key（key 命名沿用 `<slug>-best`）。
- 頁尾保留了架構參考連結（90s-games／canvas-vampire-survivors），註明出處。

---

## 6. 存檔系統 localStorage

### 6.1 key 一覽

| key | 遊戲 | 內容 |
|---|---|---|
| `hg-angry-best`／`hg-angry-level` | 憤怒鳥 | 最高分／到達關卡 |
| `hg-tower-best`／`hg-tower-wave` | 守塔 | 勝利總分／到達波次 |
| `hg-survivor-best`／`hg-survivor-kills` | 倖存者 | 最長存活秒／最多擊殺 |
| `hg-survivor-board` | 倖存者 | 前10筆 `{t,k,l,d}` JSON |
| `hg-survivor-name` | 倖存者 | 上傳用暱稱 |
| `hg-hippo-best` | 河馬 | 最高評分 |

### 6.2 讀寫範本（全專案統一寫法）

```js
let BEST=0;try{BEST=+(localStorage.getItem('hg-xxx-best')||0);}catch(e){}
function saveBest(v){if(v>BEST){BEST=v;try{localStorage.setItem('hg-xxx-best',String(v));}catch(e){}}}
```

一律 `try/catch`（見 9.1），一律只增不減（除了清除按鈕）。

---

## 7. 全球榜 Supabase 設定

### 7.1 為什麼需要它

GitHub Pages 是純靜態託管，沒有資料庫。「跨裝置共用榜」必須另接後端；
本專案選 Supabase 免費版（Postgres＋REST＋RLS），前端無需自寫後端程式。

### 7.2 建置步驟（5 分鐘）

1. supabase.com 註冊（用 GitHub 登入最快）→ New project，名稱 `html-games`，Org 已是 FREE 即免費，
   Region 選 `Northeast Asia (Tokyo)`，Security 保持勾選 Data API。
2. 左側 **SQL Editor** → New query，貼上執行：
```sql
create table if not exists scores (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 12),
  time int not null check (time between 1 and 3600),
  kills int not null default 0 check (kills between 0 and 100000),
  level int not null default 1 check (level between 1 and 100),
  created_at timestamptz not null default now()
);
alter table scores enable row level security;
create policy "public read" on scores for select using (true);
create policy "public insert" on scores for insert with check (true);
create index if not exists scores_time_idx on scores (time desc);
```
3. 左側 **API Keys** → 複製 **Publishable key**（`sb_publishable_...`）。
   ⚠️ 只要這把；**Secret key（`sb_secret_...`）絕對不進網頁**。

### 7.3 前端串接程式碼（survivor.html 現行版本）

```js
const SB_URL='https://你的專案id.supabase.co';
const SB_KEY='sb_publishable_...'; // 公開用途，靠 RLS 保護
function sbH(json){const h={apikey:SB_KEY,Authorization:'Bearer '+SB_KEY};
  if(json)h['Content-Type']='application/json';return h;}
async function sbTop10(){ // 讀前10
  const r=await fetch(SB_URL+'/rest/v1/scores?select=name,time,kills,level&order=time.desc&limit=10',{headers:sbH()});
  if(!r.ok)throw new Error('HTTP '+r.status);return r.json();}
async function sbUpload(o){ // 上傳一筆
  const r=await fetch(SB_URL+'/rest/v1/scores',{method:'POST',
    headers:{...sbH(true),Prefer:'return=representation'},
    body:JSON.stringify([{name:o.name,time:o.t,kills:o.k,level:o.l}])});
  if(!r.ok)throw new Error('HTTP '+r.status);return r.json();}
```

上傳前記暱稱（`hg-survivor-name`），顯示前先 `esc()` 跳脫防 XSS；讀寫失敗一律降級顯示本機榜，
不斷線、不報錯（玩家視角只是「全球榜離線中」）。

### 7.4 安全邊界（誠實告知）

- publishable key 在前端看得到是**設計如此**；保護靠 RLS＋CHECK（只能讀、只能插合理範圍）。
- 前端分數**防君子不防小人**：懂的人可直接 curl 灌分數。家庭同樂夠用，正式電競不夠。
- 要再嚴：加 Cloudflare Turnstile 人機驗證，或成績加簽（需後端，不在本說明書範圍）。

---

## 8. GitHub 上線流程

前置：裝 `gh`（`winget install --id GitHub.cli -e`，新開終端機才有 PATH），
`gh auth login` 走瀏覽器 device 碼登入；多帳號用 `gh auth switch --user 名稱` 切換，
建 repo 前務必 `gh auth status` 確認 Active 帳號。

```sh
cd game
git branch -M main
gh repo create html-games --public --source=. --remote=origin \
  --description "免安裝單檔 HTML5 小遊戲合集"
git push -u origin main
# 開 Pages（等同網頁 Settings→Pages→main/root）
gh api repos/你的帳號/html-games/pages -X POST \
  -f build_type=legacy -f "source[branch]=main" -f "source[path]=/"
# 查 build 狀態
gh api repos/你的帳號/html-games/pages/builds/latest --jq "{status:.status}"
```

- 試玩網址：`https://你的帳號.github.io/html-games/`（首次 build 約 1–2 分鐘，404 就是還在 build）。
- 日常更新：改完跑第 2.3 節語法檢查 → `git add -A && git commit -m "..." && git push`，
  Pages 自動重建，無需其他操作。

---

## 9. 注意事項總表

| # | 事項 | 說明 |
|---|---|---|
| 9.1 | localStorage 一律 try/catch | 隱私模式／停用 cookie 會拋錯，不包會整局腳本死掉 |
| 9.2 | Secret key 永不進前端 | 進了等於把資料庫 root 密碼貼上網，看到 `sb_secret` 出現在 html 立刻 rotate |
| 9.3 | 名字先 esc 再 innerHTML | 全球榜名字是別人輸入的，不跳脫＝XSS；專案用 `esc()` 統一處理 |
| 9.4 | 河馬需網路 | Three.js 走 CDN，離線／file:// 打開是黑屏；其餘三款＋大廳全離線可玩 |
| 9.5 | 手機音效要手勢解鎖 | 瀏覽器擋自動播放；倖存者開場「開始挑戰」按鈕已順便解鎖 AC，其他款第一次 tap 才有聲，屬正常 |
| 9.6 | 效能紅線 | 敵人上限 140、粒子隨手清、發光用預渲染精靈不用每幀 `shadowBlur`（陰影模糊每幀全場開會掉幀） |
| 9.7 | Canvas 固定 1280×720 | 改解析度要同步改 `evPos` 映射與 HUD 百分比，否則觸控漂移 |
| 9.8 | dt 上限 .05 | 切分頁回來 `requestAnimationFrame` 間隔很大，`Math.min(.05,…)` 防穿牆＋防一幀暴斃 |
| 9.9 | CRLF 警告可忽略 | Windows git 預設換行警告不影響 Pages |
| 9.10 | Pages 快取 | push 後 1–2 分鐘才生效；懷疑快取用無痕視窗驗 |
| 9.11 | upabase.com 是假站 | 正確只有 supabase.com（曾有人打錯字進釣魚站，切記） |
| 9.12 | 免費額度 | Supabase Free：500MB 資料庫／5GB 流量，排行榜幾萬筆都夠；久不用會被 pause，開 dashboard 點 resume |

---

## 10. 常見問題 FAQ

**Q: 雙擊 html 是黑的？**
A: 先 F12 看 Console。河馬黑屏＝沒網路載不到 Three.js；其他款黑屏＝JS 語法錯，跑 2.3 節檢查。

**Q: 全球榜顯示離線？**
A: 依序查：網路→Supabase 專案是否被 pause→SQL 表建了沒→key 是否 publishable 那把。用本說明書 7.2 的 SQL 重跑一次多半就好，驗證法見當初上線紀錄（讀應回 0 筆，亂填應回 400）。

**Q: 手機搖桿沒反應？**
A: canvas 要有 `touch-action:none`（模板已有）；另確認是拖曳不是點擊系統手勢區。

**Q: 分數被刷假的？**
A: 見 7.4，家庭級架構本來就擋不住 curl 灌分；要擋只能加後端驗證。

**Q: 想換美術（怪換造型）？**
A: 改 `survivor.html` 的 `SPR` 預渲染函式即可，邏輯（半徑／血量）不用動；半徑變了記得同步 `FOE` 的 `r`。

---

## 11. 擴充：如何做第 5 款遊戲

1. 複製第 3 章模板存為新檔（如 `breakout.html`）。
2. 把 `update()` 換成你的規則、`draw()` 換成你的畫面（先能玩，再求美）。
3. 存檔 key 取 `hg-<slug>-best`，沿用 6.2 範本。
4. `index.html` 複一張卡＋讀 key；`README.md` 加一行。
5. 跑 2.3 語法檢查 → commit → push → 開 Pages 網址親測。
6. 要全球榜：scores 表加 `game` 欄區分遊戲，前端 `sbUpload` 多送 `game:'breakout'`，讀榜加 `&game=eq.breakout`。
