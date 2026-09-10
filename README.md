# 🎮 HTML Games

免安裝・單檔 HTML5 小遊戲合集。直接用瀏覽器開啟就能玩，最佳成績存在 `localStorage`。

**線上玩：** https://wanpwang2025-boop.github.io/html-games/

各遊戲直連（把網址傳給朋友就能玩，免安裝）：

| 遊戲 | 連結 |
|---|---|
| 🎮 大廳 | https://wanpwang2025-boop.github.io/html-games/ |
| 🐦 憤怒鳥大作戰 | https://wanpwang2025-boop.github.io/html-games/angry-birds.html |
| 🏰 魔法守塔戰 | https://wanpwang2025-boop.github.io/html-games/tower-defense.html |
| 🧛 午夜倖存者 | https://wanpwang2025-boop.github.io/html-games/survivor.html |
| 🏯 華容道 | https://wanpwang2025-boop.github.io/html-games/huarongdao.html |
| 🏃 小朋友下樓梯 | https://wanpwang2025-boop.github.io/html-games/falldown.html |
| 🐍 貪食蛇・增強版 | https://wanpwang2025-boop.github.io/html-games/snake.html |
| 🎹 鋼琴塊 | https://wanpwang2025-boop.github.io/html-games/piano.html |
| 🦛 河馬水中芭蕾 | https://wanpwang2025-boop.github.io/html-games/hippo-water-ballet.html |

> 注意：最佳成績存在「當下那台裝置的瀏覽器」（`localStorage`），換手機/電腦或開無痕不會同步；
> 只有倖存者能上傳全球榜。河馬芭蕾需網路載入 Three.js CDN 才能顯示 3D。

## 遊戲一覽

| 遊戲 | 檔案 | 玩法 |
|---|---|---|
| 🐦 憤怒鳥大作戰 | `angry-birds.html` | 拉弓彈射，消滅綠豬。3 關＋無限隨機關 |
| 🏰 魔法守塔戰 | `tower-defense.html` | 蓋塔＋合成＋屬性相剋，撐過 12 波 |
| 🧛 午夜倖存者 | `survivor.html` | Survivor-like：走位＋自動武器＋撿寶石升級，每 60 秒一隻 BOSS |
| 🏯 華容道 | `huarongdao.html` | Klotski 滑塊益智：12 經典棋譜（橫刀立馬→峰迴路轉），每關附電腦實測最優步數＋三星評價，另有 💡提示 / ▶自動解題 |
| 🏃 小朋友下樓梯 | `falldown.html` | NS-Shaft like：左右移動往下跳，5 種地板＋血量＋隨深度加速。玩法參考 iPel/NS-SHAFT |
| 🐍 貪食蛇・增強版 | `snake.html` | 3 模式（經典/穿牆/障礙）＋5 道具＋4 食物，150 分升一級。概念參考 Snek／Ian-Lusule |
| 🎹 鋼琴塊 | `piano.html` | 演奏/自動/錄音室：內建 4 首＋簡譜貼上/MIDI 上傳＋錄音轉關卡。概念參考 Wscats/piano、Siilsy/Piano |
| 🦛 河馬水中芭蕾 | `hippo-water-ballet.html` | Three.js 3D 跳水＋水花物理展示（需網路載入 CDN）。可放入圖片分析（明亮/飽和/動感/暖冷＋5 色票）產生專屬主題秀，另有海洋/落日/星空/櫻花 4 預設 |

`index.html` 是大廳頁，會讀取各遊戲的最佳成績。

## 本機遊玩

```sh
# 直接雙擊 index.html，或跑個靜態伺服器：
python -m http.server 8000
# → http://localhost:8000/
```

## 更新上線（把改動推上網路玩）

```sh
cd game
git add -A && git commit -m "說明" && git push
```

- GitHub Pages 會自動重建，約 1–2 分鐘生效；若看到舊畫面，開無痕視窗再驗
- 首次開通 Pages：repo → Settings → Pages → Deploy from branch → `main` / `/ (root)`
- 詳細流程（含 `gh` 指令、Supabase 全球榜設定）見 `MANUAL.md` 第 7–8 章

## 存檔 key（`localStorage`）

`hg-angry-best`・`hg-angry-level`・`hg-tower-best`・`hg-tower-wave`・
`hg-survivor-best`・`hg-survivor-kills`・`hg-survivor-board`（倖存者前 10 名榮譽榜）・`hg-survivor-name`（上傳用暱稱）・`hg-hippo-best`・`hg-hippo-theme`（河馬主題秀 JSON）・`hg-huarong-bests`（華容道每關最少步 JSON）・`hg-huarong-level`・`hg-fall-best`（下樓梯最深層數）・`hg-fall-board`（下樓梯前 10 名本機榜）・`hg-fall-name`（上傳用暱稱）・`hg-snake-best`・`hg-snake-board`（貪食蛇前 10 名本機榜）・`hg-piano-best`・`hg-piano-songs`（自訂曲譜 JSON）・`hg-piano-recs`（錄音 JSON）

## 鋼琴塊曲譜格式（`piano.html`）

簡譜文字：數字 `1~7`（`+`高八度／`-`低八度），`0`休止，`-`延長，`|`分小節（忽略）。
例：`1 1 5 5 6 6 5 -`。遊戲內 📂 面板可貼上載入，也可上傳 `.mid` 檔自動轉成關卡
（自寫最小 SMF 解析：type 0/1、速度圖、和弦保留，不支援 SMPTE／純鼓組）；
錄音室用 `A S D F J K L ;` 彈 Do~Do⁺，錄完可存檔（最多 5 首）、回放、匯出簡譜、一鍵轉挑戰關卡。

## 全球榜（Supabase）

倖存者結算可上傳到 Supabase `scores` 表（`time/kills/level/name`），RLS 只開公開讀＋寫入，
外加 CHECK 擋亂填。前端用 publishable key 直連 REST，無後端程式。

下樓梯全球榜用同一專案的 `fall_scores` 表，SQL Editor 貼上執行一次即可
（沒建表也能玩，只是全球榜會顯示離線，本機榜不受影響）：

```sql
create table if not exists fall_scores (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 12),
  depth int not null check (depth between 1 and 100000),
  created_at timestamptz not null default now()
);
alter table fall_scores enable row level security;
drop policy if exists "public read" on fall_scores;
drop policy if exists "public insert" on fall_scores;
create policy "public read" on fall_scores for select using (true);
create policy "public insert" on fall_scores for insert with check (true);
create index if not exists fall_scores_depth_idx on fall_scores (depth desc);
```

下樓梯結算面板：📱本機榜（前 10，開場秀前 3）＋ 🌍全球榜頁籤 ＋ 輸入暱稱上傳，
直接把遊戲網址傳給朋友就能比拼。

## 參考的開源 repo

- [prateek121/90s-games](https://github.com/prateek121/90s-games) — 114 個單檔遊戲＋大廳＋`localStorage`，本專案結構即仿此
- [ricardo-foundry/canvas-vampire-survivors](https://github.com/ricardo-foundry/canvas-vampire-survivors) — 零依賴倖存者，玩法參考
- [Mihailazvfx/vampire-survivor-game](https://github.com/Mihailazvfx/vampire-survivor-game) — 單檔＋手機搖桿
- [magejosh/one-page-games](https://github.com/magejosh/one-page-games) — 單頁遊戲合集＋Pages 範例
- [iPel/NS-SHAFT](https://github.com/iPel/NS-SHAFT)（Apache-2.0）— 小朋友下樓梯重製；本專案 `falldown.html` 玩法數值（重力／地板種類／加速曲線）參考自它，原創 NS-SHAFT 版權屬 NAGI-P SOFT
- [jeantimex/klotski](https://github.com/jeantimex/klotski)（MIT）— 40 局華容道棋譜＋求解器；本專案 `huarongdao.html` 12 關擺法取自它的 `hrd-games.json`
- [Esskay1945/Snek](https://github.com/Esskay1945/Snek)（無授權聲明，僅參考玩法概念）— 4 模式＋道具的增強蛇；本專案 `snake.html` 為重新實作
- [Ian-Lusule/Advanced-snake-game](https://github.com/Ian-Lusule/Advanced-snake-game)（MIT）— 道具/等級設計參考
- [Wscats/piano](https://github.com/Wscats/piano)（無授權聲明，僅參考概念）— 簡譜陣列＋自動演奏的想法；本專案 `piano.html` 為重新實作
- [Siilsy/Piano](https://github.com/Siilsy/Piano)（MIT）— MIDI 播放/錄製設計參考（本專案 MIDI 解析器為自寫最小實作）
